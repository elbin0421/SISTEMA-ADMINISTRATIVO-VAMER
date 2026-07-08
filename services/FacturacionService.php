<?php
// ============================================================
//  SOLDYMEG — FacturacionService  (Fase 3)
//  Orquesta el flujo: Cotización aprobada → Factura → Pago
// ============================================================
require_once __DIR__ . '/../models/FacturaModel.php';
require_once __DIR__ . '/../models/PagoModel.php';
require_once __DIR__ . '/../models/CotizacionModel.php';
require_once __DIR__ . '/../helpers/Calculos.php';

class FacturacionService {

    /**
     * Flujo completo: cotización aprobada → factura emitida.
     */
    public static function facturarCotizacion(int $cotizacion_id, array $opciones, int $usuario_id): array {
        $factura_id = FacturaModel::crearDesdeCotizacion($cotizacion_id, $opciones, $usuario_id);
        $factura    = FacturaModel::obtener($factura_id);
        return ['ok' => true, 'factura' => $factura];
    }

    /**
     * Factura directa (sin cotización previa).
     */
    public static function crearDirecta(array $opciones, array $items, int $usuario_id): array {
        $factura_id = FacturaModel::crearDirecta($opciones, $items, $usuario_id);
        $factura    = FacturaModel::obtener($factura_id);
        return ['ok' => true, 'factura' => $factura];
    }

    /**
     * Registrar pago parcial o total de una factura.
     */
    public static function registrarPago(int $factura_id, array $datos, int $usuario_id): array {
        $factura = FacturaModel::obtener($factura_id);
        if (!$factura) throw new Exception('Factura no encontrada.');
        if ($factura['estado'] === 'anulada') throw new Exception('No se puede pagar una factura anulada.');

        $ya_pagado = PagoModel::totalPagadoPorFactura($factura_id);
        $pendiente = (float)$factura['total'] - $ya_pagado;

        if ((float)$datos['monto'] > $pendiente + 0.01) {
            throw new Exception("El monto excede el saldo pendiente (L. " . number_format($pendiente, 2) . ").");
        }

        $datos['factura_id'] = $factura_id;
        $datos['cliente_id'] = $factura['cliente_id'];
        $datos['retencion_isr'] = (float)($datos['retencion_isr'] ?? 0);
        $datos['retencion_isv'] = (float)($datos['retencion_isv'] ?? 0);
        PagoModel::registrar($datos, $usuario_id);

        // Actualizar estado de factura
        $nuevo_pagado = $ya_pagado + (float)$datos['monto'];
        if ($nuevo_pagado >= (float)$factura['total'] - 0.01) {
            getDB()->prepare("UPDATE facturas SET estado='pagada' WHERE id_factura=?")
                   ->execute([$factura_id]);
        }

        $retenciones = PagoModel::totalRetencionesPorFactura($factura_id);
        return [
            'ok'           => true,
            'pagado'       => $nuevo_pagado,
            'pendiente'    => max(0, (float)$factura['total'] - $nuevo_pagado),
            'retencion_isr'=> $retenciones['total_isr'],
            'retencion_isv'=> $retenciones['total_isv'],
            'monto_neto'   => $retenciones['total_neto'],
        ];
    }

    /**
     * Anular factura con motivo.
     */
    public static function anular(int $factura_id, string $motivo, int $usuario_id): array {
        FacturaModel::anular($factura_id, $motivo, $usuario_id);
        return ['ok' => true];
    }

    /**
     * Libro de ventas mensual con resumen.
     */
    public static function libroVentas(string $mes, string $anio): array {
        return FacturaModel::libroVentas($mes, $anio);
    }

    /**
     * Factura múltiples cotizaciones en una sola factura.
     * Todas las cotizaciones deben ser del mismo cliente y estar aprobadas.
     */
    public static function facturarMultiples(array $cotizacion_ids, array $opciones, int $usuario_id): array {
        require_once __DIR__ . '/../models/CotizacionModel.php';
        $pdo = getDB();

        $cotizacion_ids = array_map('intval', $cotizacion_ids);
        if (empty($cotizacion_ids)) throw new Exception('Sin cotizaciones seleccionadas.');

        // Cargar y validar todas las cotizaciones
        $cotizaciones = [];
        $cliente_id   = null;
        foreach ($cotizacion_ids as $cid) {
            $cot = CotizacionModel::obtener($cid);
            if (!$cot) throw new Exception("Cotización #$cid no encontrada.");
            if ($cot['estado'] !== 'aprobada_cliente')
                throw new Exception("Cotización {$cot['numero_cotizacion']} no está aprobada.");
            // Verificar que no tenga factura activa
            $chk = $pdo->prepare("SELECT id_factura FROM facturas WHERE cotizacion_id=? AND estado!='anulada' LIMIT 1");
            $chk->execute([$cid]);
            if ($chk->fetch())
                throw new Exception("La cotización {$cot['numero_cotizacion']} ya fue facturada.");
            // Mismo cliente
            if ($cliente_id === null) $cliente_id = (int)$cot['cliente_id'];
            elseif ((int)$cot['cliente_id'] !== $cliente_id)
                throw new Exception("Todas las cotizaciones deben ser del mismo cliente.");
            $cotizaciones[] = $cot;
        }

        // Obtener CAI activo
        $cai = FacturaModel::obtenerCAIActivo();
        if (!$cai) throw new Exception('No hay CAI activo.');

        // Usar correlativo_actual directamente (ya es el número a emitir)
        $numero = $cai['correlativo_actual'];
        // El siguiente se calculará al actualizar el CAI

        // Sumar totales de todas las cotizaciones
        $subtotal = array_sum(array_column($cotizaciones, 'subtotal_comercial'));
        $isv      = array_sum(array_column($cotizaciones, 'isv'));
        $total    = array_sum(array_column($cotizaciones, 'total'));

        $orden_id = $cotizaciones[0]['orden_id'] ?? null;

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO facturas
                  (numero_factura, cai_id, cliente_id, cotizacion_id, orden_id,
                   usuario_id, fecha, subtotal, isv, total,
                   metodo_pago, referencia_pago, observaciones, estado)
                VALUES (?,?,?,?,?,?,CURDATE(),?,?,?,?,?,?,?)
            ")->execute([
                $numero, $cai['id_cai'], $cliente_id,
                $cotizacion_ids[0],  // cotizacion principal (primera)
                $orden_id, $usuario_id,
                round($subtotal, 2), round($isv, 2), round($total, 2),
                $opciones['metodo_pago']     ?? 'efectivo',
                $opciones['referencia_pago'] ?? null,
                $opciones['observaciones']   ?? null,
                'emitida',
            ]);
            $factura_id = (int)$pdo->lastInsertId();

            // Avanzar correlativo en CAI al siguiente
            $partes2  = explode('-', $numero);
            $seq2     = (int)end($partes2) + 1;
            $prefijo2 = implode('-', array_slice($partes2, 0, 3));
            $siguiente = $prefijo2 . '-' . str_pad($seq2, 8, '0', STR_PAD_LEFT);
            $pdo->prepare("UPDATE cai_facturacion SET correlativo_actual=? WHERE id_cai=?")
                ->execute([$siguiente, $cai['id_cai']]);

            // Copiar ítems de todas las cotizaciones + marcar facturadas
            $insItem = $pdo->prepare("
                INSERT INTO detalle_factura
                  (factura_id, tipo, descripcion, cantidad, precio_unitario,
                   subtotal_base, subtotal_final)
                VALUES (?,?,?,?,?,?,?)
            ");
            foreach ($cotizaciones as $cot) {
                // $cot['detalle'] viene de CotizacionModel::obtener()
                foreach (($cot['detalle'] ?? []) as $it) {
                    $insItem->execute([
                        $factura_id,
                        $it['tipo']            ?? 'material',
                        $it['descripcion'],
                        $it['cantidad'],
                        $it['precio_unitario'],
                        $it['subtotal_base']   ?? 0,
                        $it['subtotal_final']  ?? 0,
                    ]);
                }
                // Marcar cotización como facturada
                $pdo->prepare("UPDATE cotizaciones SET estado='facturada' WHERE id_cotizacion=?")
                    ->execute([$cot['id_cotizacion']]);
            }

            // Si es contado, marcar como pagada
            if (($opciones['metodo_pago'] ?? '') !== 'credito') {
                $pdo->prepare("UPDATE facturas SET estado='pagada' WHERE id_factura=?")
                    ->execute([$factura_id]);
            }

            $pdo->commit();
            $factura = FacturaModel::obtener($factura_id);
            return ['ok' => true, 'factura' => $factura];
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

}