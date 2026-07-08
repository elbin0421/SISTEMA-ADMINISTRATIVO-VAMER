<?php
// ============================================================
//  SOLDYMEG — FacturaModel  (Fase 3)
//  Facturación SAR Honduras con control CAI
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../helpers/Calculos.php';

class FacturaModel {

    public static function listar(string $estado = ''): array {
        $where  = $estado ? "WHERE f.estado = ?" : "";
        $params = $estado ? [$estado] : [];
        $stmt   = getDB()->prepare("
            SELECT f.id_factura, f.numero_factura, f.fecha,
                   f.estado, f.cotizacion_id, f.orden_id,
                   f.subtotal, f.isv, f.total,
                   f.descuento_porcentaje, f.descuento_monto,
                   f.metodo_pago, f.observaciones,
                   cl.nombre AS cliente, cl.rtn AS cliente_rtn,
                   u.nombre  AS usuario,
                   cot.numero_cotizacion
            FROM facturas f
            JOIN clientes cl  ON cl.id_cliente  = f.cliente_id
            JOIN usuarios u   ON u.id_usuario   = f.usuario_id
            LEFT JOIN cotizaciones cot ON cot.id_cotizacion = f.cotizacion_id
            $where
            ORDER BY f.fecha DESC, f.id_factura DESC
            LIMIT 500
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT f.*,
                   cl.nombre AS cliente, cl.rtn AS cliente_rtn,
                   cl.direccion AS cliente_direccion, cl.telefono AS cliente_tel,
                   u.nombre AS usuario,
                   cot.numero_cotizacion,
                   ot.numero_orden,
                   cai.cai AS cai_codigo, cai.fecha_limite_emision,
                   cai.establecimiento, cai.punto_emision
            FROM facturas f
            JOIN clientes cl  ON cl.id_cliente  = f.cliente_id
            JOIN usuarios u   ON u.id_usuario   = f.usuario_id
            LEFT JOIN cotizaciones cot    ON cot.id_cotizacion = f.cotizacion_id
            LEFT JOIN ordenes_trabajo ot  ON ot.id_orden       = f.orden_id
            LEFT JOIN cai_facturacion cai ON cai.id_cai        = f.cai_id
            WHERE f.id_factura = ?
        ");
        $stmt->execute([$id]);
        $f = $stmt->fetch();
        if (!$f) return null;

        $det = $pdo->prepare("SELECT * FROM detalle_factura WHERE factura_id = ?");
        $det->execute([$id]);
        $f['detalle'] = $det->fetchAll();

        return $f;
    }

    /**
     * Crea una factura desde una cotización aprobada.
     * Solo permite facturar una vez — lanza excepción si ya existe factura activa.
     */
    public static function crearDesdeCotizacion(int $cotizacion_id, array $opciones, int $usuario_id): int {
        $pdo = getDB();

        // Cargar cotización
        require_once __DIR__ . '/CotizacionModel.php';
        $cot = CotizacionModel::obtener($cotizacion_id);
        if (!$cot) throw new Exception('Cotización no encontrada.');
        if ($cot['estado'] !== 'aprobada_cliente') {
            throw new Exception('Solo se puede facturar una cotización aprobada. Estado actual: ' . $cot['estado']);
        }

        // Verificar que no exista ya una factura activa para esta cotización
        $chk = $pdo->prepare(
            "SELECT id_factura, numero_factura FROM facturas
             WHERE cotizacion_id = ? AND estado != 'anulada'
             LIMIT 1"
        );
        $chk->execute([$cotizacion_id]);
        $existente = $chk->fetch();
        if ($existente) {
            throw new Exception(
                "Esta cotización ya fue facturada (Factura {$existente['numero_factura']}). " .
                "Solo se puede emitir una factura por cotización."
            );
        }

        // Obtener CAI activo
        $cai = self::obtenerCAIActivo();
        if (!$cai) throw new Exception('No hay CAI activo. Configure el CAI en el sistema.');

        // Generar número de factura correlativo
        $numero = self::generarCorrelativo($cai);

        // Tomar descuento de la cotización
        $desc_pct = (float)($cot['descuento_porcentaje'] ?? 0);
        $desc_mto = (float)($cot['descuento_monto']      ?? 0);

        // Recalcular desde SUB-TOTAL bruto para consistencia con el PDF
        $sub_bruto = 0.0;
        foreach ($cot['detalle'] as $item) {
            $sub_bruto += (float)$item['cantidad'] * (float)$item['precio_unitario'];
        }
        $sub_bruto = round($sub_bruto, 2);
        $base_isv  = max(0, round($sub_bruto - $desc_mto, 2));
        $isv       = round($base_isv * 0.15, 2);
        $total     = round($base_isv + $isv, 2);

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO facturas
                  (numero_factura, cai_id, cliente_id, cotizacion_id, orden_id,
                   usuario_id, fecha, subtotal, isv, total,
                   descuento_porcentaje, descuento_monto,
                   metodo_pago, referencia_pago, observaciones, estado)
                VALUES (?,?,?,?,?,?,CURDATE(),?,?,?,?,?,?,?,?,'emitida')
            ")->execute([
                $numero,
                $cai['id_cai'],
                $cot['cliente_id'],
                $cotizacion_id,
                $cot['orden_id'],
                $usuario_id,
                $sub_bruto,
                $isv,
                $total,
                $desc_pct,
                $desc_mto,
                $opciones['metodo_pago']     ?? 'efectivo',
                $opciones['referencia_pago'] ?? null,
                $opciones['observaciones']   ?? null,
            ]);
            $factura_id = (int)$pdo->lastInsertId();

            // Copiar detalle de la cotización a la factura
            foreach ($cot['detalle'] as $item) {
                $pdo->prepare("
                    INSERT INTO detalle_factura
                      (factura_id, tipo, descripcion, cantidad, precio_unitario,
                       subtotal_base, subtotal_final)
                    VALUES (?,?,?,?,?,?,?)
                ")->execute([
                    $factura_id,
                    $item['tipo'],
                    $item['descripcion'],
                    $item['cantidad'],
                    $item['precio_unitario'],
                    $item['subtotal_base'],
                    $item['subtotal_final'],
                ]);
            }

            // Actualizar correlativo en CAI al siguiente (el usado fue $numero)
            $pdo->prepare("UPDATE cai_facturacion SET correlativo_actual=? WHERE id_cai=?")
                ->execute([self::siguienteCorrelativo($numero), $cai['id_cai']]);

            // Marcar cotización como FACTURADA (bloquea nuevo intento)
            $pdo->prepare("UPDATE cotizaciones SET estado='facturada' WHERE id_cotizacion=?")
                ->execute([$cotizacion_id]);

            // Marcar OT como facturada (si tiene)
            if ($cot['orden_id']) {
                $pdo->prepare("UPDATE ordenes_trabajo SET estado='facturada' WHERE id_orden=?")
                    ->execute([$cot['orden_id']]);
            }

            // Registrar pago automático solo si es contado (efectivo/tarjeta/transferencia)
            // y marcar la factura como pagada. Si es crédito, queda en estado 'pendiente'.
            $metodo = $opciones['metodo_pago'] ?? 'efectivo';
            if (in_array($metodo, ['efectivo', 'tarjeta', 'transferencia'])) {
                $pdo->prepare("
                    INSERT INTO pagos_clientes
                      (factura_id, cliente_id, usuario_id, fecha, monto,
                       metodo_pago, referencia, concepto, estado)
                    VALUES (?,?,?,CURDATE(),?,?,?,?,'aplicado')
                ")->execute([
                    $factura_id,
                    $cot['cliente_id'],
                    $usuario_id,
                    $total,
                    $metodo,
                    $opciones['referencia_pago'] ?? null,
                    'Pago factura ' . $numero,
                ]);
                // Marcar factura como pagada
                $pdo->prepare("UPDATE facturas SET estado='pagada' WHERE id_factura=?")
                    ->execute([$factura_id]);
            } else {
                // Crédito: factura queda en 'pendiente' para cobro posterior
                $pdo->prepare("UPDATE facturas SET estado='pendiente' WHERE id_factura=?")
                    ->execute([$factura_id]);
            }

            $pdo->commit();
            return $factura_id;

        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    public static function anular(int $id, string $motivo, int $usuario_id): bool {
        $pdo = getDB();
        $f   = self::obtener($id);
        if (!$f) throw new Exception('Factura no encontrada.');
        if ($f['estado'] === 'anulada') throw new Exception('La factura ya está anulada.');
        if ($f['estado'] === 'pagada')  throw new Exception('No se puede anular una factura pagada. Debe revertir el pago primero.');

        $pdo->beginTransaction();
        try {
            // Guardar cotizacion_id antes de nullearlo
            $cotizacion_id = $f['cotizacion_id'] ?? null;

            $pdo->prepare("UPDATE facturas SET estado='anulada', cotizacion_id=NULL, observaciones=CONCAT(COALESCE(observaciones,''),' | ANULADA: ',?) WHERE id_factura=?")
                ->execute([$motivo, $id]);

            // Si venía de cotización: reactivarla como aprobada_cliente
            if ($cotizacion_id) {
                $pdo->prepare("UPDATE cotizaciones SET estado='aprobada_cliente' WHERE id_cotizacion=?")
                    ->execute([$cotizacion_id]);
            }

            // Revertir OT a estado cotizado si aplica
            if ($f['orden_id']) {
                $pdo->prepare("UPDATE ordenes_trabajo SET estado='cotizado' WHERE id_orden=? AND estado='facturada'")
                    ->execute([$f['orden_id']]);
            }
            $pdo->commit();
            return true;
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /**
     * CAI válido para facturar: estado=activo Y fecha no vencida.
     * Si existe un CAI activo con fecha vencida, lo marca como 'vencido' automáticamente.
     */
    public static function obtenerCAIActivo(): ?array {
        $pdo = getDB();

        // Marcar automáticamente como 'vencido' cualquier CAI activo con fecha pasada
        $pdo->prepare("
            UPDATE cai_facturacion
            SET estado = 'vencido'
            WHERE estado = 'activo' AND fecha_limite_emision < CURDATE()
        ")->execute();

        // Devolver el CAI activo vigente
        $stmt = $pdo->prepare("
            SELECT * FROM cai_facturacion
            WHERE estado = 'activo' AND fecha_limite_emision >= CURDATE()
            ORDER BY id_cai DESC LIMIT 1
        ");
        $stmt->execute();
        return $stmt->fetch() ?: null;
    }

    /**
     * Para el módulo CAI: devuelve el CAI activo (sin importar fecha)
     * con flag fecha_vencida para mostrar advertencia visual.
     */
    public static function obtenerCAIActivoConEstado(): ?array {
        $stmt = getDB()->prepare("
            SELECT *,
                CASE WHEN fecha_limite_emision < CURDATE() THEN 1 ELSE 0 END AS fecha_vencida
            FROM cai_facturacion
            WHERE estado = 'activo'
            ORDER BY id_cai DESC LIMIT 1
        ");
        $stmt->execute();
        return $stmt->fetch() ?: null;
    }

    /**
     * Inactivar manualmente un CAI (cambia estado a 'vencido').
     */
    public static function inactivarCAI(int $id): bool {
        return getDB()->prepare("
            UPDATE cai_facturacion SET estado = 'vencido' WHERE id_cai = ?
        ")->execute([$id]);
    }

    public static function listarCAI(): array {
        $stmt = getDB()->query("SELECT * FROM cai_facturacion ORDER BY id_cai DESC");
        return $stmt->fetchAll();
    }

    public static function crearCAI(array $d, int $usuario_id): int {
        $pdo = getDB();
        // Desactivar CAI anterior si existe
        $pdo->prepare("UPDATE cai_facturacion SET estado='vencido' WHERE estado='activo'")
            ->execute();
        $pdo->prepare("
            INSERT INTO cai_facturacion
              (cai, rango_inicio, rango_fin, correlativo_actual,
               fecha_limite_emision, establecimiento, punto_emision, tipo_documento,
               estado, usuario_id)
            VALUES (?,?,?,?,?,?,?,?,'activo',?)
        ")->execute([
            strtoupper(trim($d['cai'])),
            trim($d['rango_inicio']),
            trim($d['rango_fin']),
            trim($d['rango_inicio']), // correlativo comienza en rango_inicio
            $d['fecha_limite_emision'],
            $d['establecimiento'] ?? '001',
            $d['punto_emision']   ?? '001',
            $d['tipo_documento']  ?? '01',
            $usuario_id,
        ]);
        return (int)$pdo->lastInsertId();
    }

    /**
     * Genera el próximo correlativo SAR.
     * Formato Honduras: 001-001-01-00000001
     */
    /**
     * Retorna correlativo_actual tal como está (ya es el número a usar).
     * Después de emitir la factura se actualiza al siguiente (+1).
     */
    private static function generarCorrelativo(array $cai): string {
        return $cai['correlativo_actual'];
    }

    /**
     * Calcula el siguiente correlativo para guardarlo en CAI después de facturar.
     */
    private static function siguienteCorrelativo(string $actual): string {
        $partes  = explode('-', $actual);
        $seq     = (int)end($partes) + 1;
        $prefijo = implode('-', array_slice($partes, 0, 3));
        return $prefijo . '-' . str_pad($seq, 8, '0', STR_PAD_LEFT);
    }

    /**
     * Crea una factura directa (sin cotización previa).
     * Recibe items manualmente y registra pago si es contado.
     */
    public static function crearDirecta(array $opciones, array $items, int $usuario_id): int {
        $pdo = getDB();

        if (empty($opciones['cliente_id'])) throw new Exception('cliente_id es requerido.');
        if (empty($items)) throw new Exception('Debe incluir al menos un ítem.');

        // Obtener CAI activo
        $cai = self::obtenerCAIActivo();
        if (!$cai) throw new Exception('No hay CAI activo. Configure el CAI en el sistema.');

        // Calcular totales desde los ítems
        $subtotal = 0.0;
        foreach ($items as $item) {
            $subtotal += (float)($item['cantidad'] ?? 1) * (float)($item['precio_unitario'] ?? 0);
        }
        // Descuento
        $desc_pct  = (float)($opciones['descuento_porcentaje'] ?? 0);
        $desc_mto  = $desc_pct > 0
            ? round($subtotal * $desc_pct / 100, 2)
            : (float)($opciones['descuento_monto'] ?? 0);
        $base_isv  = max(0, round($subtotal - $desc_mto, 2));
        $isv       = round($base_isv * 0.15, 2);
        $total     = round($base_isv + $isv, 2);

        // Generar correlativo
        $numero = self::generarCorrelativo($cai);

        $metodo = $opciones['metodo_pago'] ?? 'efectivo';

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO facturas
                  (numero_factura, cai_id, cliente_id, cotizacion_id, orden_id,
                   usuario_id, fecha, subtotal, isv, total,
                   descuento_porcentaje, descuento_monto,
                   metodo_pago, referencia_pago, observaciones, estado)
                VALUES (?,?,?,NULL,NULL,?,CURDATE(),?,?,?,?,?,?,?,?,'emitida')
            ")->execute([
                $numero,
                $cai['id_cai'],
                (int)$opciones['cliente_id'],
                $usuario_id,
                $subtotal,
                $isv,
                $total,
                $desc_pct,
                $desc_mto,
                $metodo,
                $opciones['referencia_pago'] ?? null,
                $opciones['observaciones']   ?? null,
            ]);
            $factura_id = (int)$pdo->lastInsertId();

            // Insertar detalle
            foreach ($items as $item) {
                $cant    = (float)($item['cantidad']       ?? 1);
                $precio  = (float)($item['precio_unitario'] ?? 0);
                $sub     = round($cant * $precio, 2);
                $pdo->prepare("
                    INSERT INTO detalle_factura
                      (factura_id, tipo, descripcion, cantidad, precio_unitario,
                       subtotal_base, subtotal_final)
                    VALUES (?,?,?,?,?,?,?)
                ")->execute([
                    $factura_id,
                    $item['tipo']        ?? 'otro',
                    $item['descripcion'] ?? 'Servicio',
                    $cant,
                    $precio,
                    $sub,
                    $sub,
                ]);
            }

            // Actualizar correlativo en CAI al siguiente
            $pdo->prepare("UPDATE cai_facturacion SET correlativo_actual=? WHERE id_cai=?")
                ->execute([self::siguienteCorrelativo($numero), $cai['id_cai']]);

            // Pago automático si es contado / marcar estado
            if (in_array($metodo, ['efectivo', 'tarjeta', 'transferencia'])) {
                $pdo->prepare("
                    INSERT INTO pagos_clientes
                      (factura_id, cliente_id, usuario_id, fecha, monto,
                       metodo_pago, referencia, concepto, estado)
                    VALUES (?,?,?,CURDATE(),?,?,?,?,'aplicado')
                ")->execute([
                    $factura_id,
                    (int)$opciones['cliente_id'],
                    $usuario_id,
                    $total,
                    $metodo,
                    $opciones['referencia_pago'] ?? null,
                    'Pago factura ' . $numero,
                ]);
                $pdo->prepare("UPDATE facturas SET estado='pagada' WHERE id_factura=?")
                    ->execute([$factura_id]);
            } else {
                $pdo->prepare("UPDATE facturas SET estado='pendiente' WHERE id_factura=?")
                    ->execute([$factura_id]);
            }

            $pdo->commit();
            return $factura_id;

        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /**
     */
    public static function libroVentas(string $mes, string $anio): array {
        $stmt = getDB()->prepare("
            SELECT
                f.id_factura,
                f.numero_factura,
                f.fecha,
                f.estado,
                cl.nombre       AS cliente,
                cl.rtn          AS rtn_cliente,
                f.subtotal,
                f.isv,
                f.total,
                f.metodo_pago,
                cot.numero_cotizacion,
                ot.numero_orden
            FROM facturas f
            JOIN clientes cl ON cl.id_cliente = f.cliente_id
            LEFT JOIN cotizaciones cot   ON cot.id_cotizacion = f.cotizacion_id
            LEFT JOIN ordenes_trabajo ot ON ot.id_orden       = f.orden_id
            WHERE MONTH(f.fecha) = ? AND YEAR(f.fecha) = ?
            ORDER BY f.fecha ASC, f.id_factura ASC
        ");
        $stmt->execute([(int)$mes, (int)$anio]);
        $filas = $stmt->fetchAll();

        // Totales
        $emitidas = array_filter($filas, fn($r) => $r['estado'] !== 'anulada');
        return [
            'filas'          => $filas,
            'total_facturas' => count($emitidas),
            'total_subtotal' => array_sum(array_column(array_values($emitidas), 'subtotal')),
            'total_isv'      => array_sum(array_column(array_values($emitidas), 'isv')),
            'total_general'  => array_sum(array_column(array_values($emitidas), 'total')),
            'mes'            => $mes,
            'anio'           => $anio,
        ];
    }

    /**
     * Dashboard KPIs de facturación.
     */
    public static function kpis(): array {
        $pdo  = getDB();
        $mes  = date('m');
        $anio = date('Y');

        $stmt = $pdo->prepare("
            SELECT
                COUNT(CASE WHEN estado != 'anulada' THEN 1 END)           AS total_mes,
                COALESCE(SUM(CASE WHEN estado != 'anulada' THEN total END), 0) AS monto_mes,
                COUNT(CASE WHEN estado = 'anulada' THEN 1 END)            AS anuladas_mes,
                COUNT(CASE WHEN estado = 'pendiente' THEN 1 END)          AS pendientes_cobro
            FROM facturas
            WHERE MONTH(fecha) = ? AND YEAR(fecha) = ?
        ");
        $stmt->execute([$mes, $anio]);
        return $stmt->fetch();
    }
}
