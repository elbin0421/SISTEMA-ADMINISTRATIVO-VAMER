<?php
// ============================================================
//  SOLDYMEG — CotizacionModel
//  Soporta dos modos:
//    POST_TRABAJO : generada desde OT finalizada
//    DIRECTA      : sin OT previa
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../helpers/Calculos.php';

class CotizacionModel {

    public static function listar(string $estado = ''): array {
        $where  = $estado ? "WHERE cot.estado = ?" : "";
        $params = $estado ? [$estado] : [];
        $stmt   = getDB()->prepare("
            SELECT cot.id_cotizacion, cot.numero_cotizacion, cot.fecha,
                   cot.cliente_id,
                   cot.estado, cot.modo, cot.vigencia_dias,
                   cot.subtotal_materiales, cot.subtotal_mano_obra,
                   cot.costo_base, cot.subtotal_comercial, cot.isv, cot.total,
                   cot.ot_cliente, cot.orden_compra, cot.unidad, cot.motivo_rechazo,
                   cot.elaborado_por, cot.telefono_elaborado,
                   cl.nombre AS cliente,
                   ot.numero_orden,
                   (SELECT o2.numero_orden FROM ordenes_trabajo o2 WHERE o2.cotizacion_origen_id = cot.id_cotizacion AND o2.estado <> 'anulada' ORDER BY o2.id_orden DESC LIMIT 1) AS ot_origen_numero,
                   (SELECT o2.estado       FROM ordenes_trabajo o2 WHERE o2.cotizacion_origen_id = cot.id_cotizacion AND o2.estado <> 'anulada' ORDER BY o2.id_orden DESC LIMIT 1) AS ot_origen_estado
            FROM cotizaciones cot
            JOIN clientes cl ON cl.id_cliente = cot.cliente_id
            LEFT JOIN ordenes_trabajo ot ON ot.id_orden = cot.orden_id
            $where
            ORDER BY cot.fecha DESC, cot.id_cotizacion DESC
            LIMIT 300
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT cot.*, cl.nombre AS cliente, cl.rtn AS cliente_rtn,
                   cl.direccion AS cliente_direccion, cl.telefono AS cliente_tel,
                   ot.numero_orden, cot.ot_cliente, cot.orden_compra
            FROM cotizaciones cot
            JOIN clientes cl ON cl.id_cliente = cot.cliente_id
            LEFT JOIN ordenes_trabajo ot ON ot.id_orden = cot.orden_id
            WHERE cot.id_cotizacion = ?
        ");
        $stmt->execute([$id]);
        $cot = $stmt->fetch();
        if (!$cot) return null;

        $o = $pdo->prepare("SELECT id_orden, numero_orden, estado FROM ordenes_trabajo WHERE cotizacion_origen_id = ? AND estado <> 'anulada' ORDER BY id_orden DESC LIMIT 1");
        $o->execute([$id]);
        $ot = $o->fetch();
        $cot['ot_origen_id']     = $ot['id_orden']     ?? null;
        $cot['ot_origen_numero'] = $ot['numero_orden'] ?? null;
        $cot['ot_origen_estado'] = $ot['estado']       ?? null;

        $s = $pdo->prepare("SELECT * FROM detalle_cotizacion WHERE cotizacion_id = ?");
        $s->execute([$id]);
        $cot['detalle'] = $s->fetchAll();

        return $cot;
    }

    /**
     * Resuelve el nombre y teléfono del empleado vinculado al usuario.
     * Devuelve [nombre_completo, telefono]
     */
    private static function resolverElaborado(int $usuario_id): array {
        try {
            $stmt = getDB()->prepare("
                SELECT e.nombres AS emp_nombre,
                       e.apellidos AS emp_apellido,
                       e.telefono AS emp_tel
                FROM usuarios u
                LEFT JOIN empleados e ON e.id_empleado = u.empleado_id
                WHERE u.id_usuario = ?
                LIMIT 1
            ");
            $stmt->execute([$usuario_id]);
            $row = $stmt->fetch();
            if ($row && !empty($row['emp_nombre'])) {
                // Solo primer nombre + primer apellido para la cotización
                $primerNombre   = explode(' ', trim($row['emp_nombre']))[0];
                $primerApellido = explode(' ', trim($row['emp_apellido'] ?? ''))[0];
                $elaborado = strtoupper($primerNombre) . ' ' . strtoupper($primerApellido);
                return [
                    trim($elaborado),
                    strtoupper(trim($row['emp_tel'] ?? '')),
                ];
            }
        } catch (\Exception $e) {}
        return ['', ''];
    }

    /**
     * Crea una cotización POST_TRABAJO desde una OT finalizada.
     * Toma materiales y mano de obra directamente de la OT.
     */
    public static function crearDesdeOT(int $orden_id, int $usuario_id, int $vigencia = 15): int {
        $pdo = getDB();

        // Cargar OT con todos sus detalles
        require_once __DIR__ . '/OrdenModel.php';
        $ot = OrdenModel::obtener($orden_id);
        if (!$ot) throw new Exception('Orden no encontrada.');
        if ($ot['estado'] !== 'finalizada') {
            throw new Exception('Solo se puede cotizar una OT en estado finalizada.');
        }
        if (!empty($ot['cotizacion_origen_id'])) {
            throw new Exception('Esta O.T. se originó de una cotización aprobada; esa misma cotización es la que se factura.');
        }

        $calc   = Calculos::calcularCotizacion(
            (float)$ot['total_materiales'],
            (float)$ot['total_mano_obra']
        );
        $numero = self::generarNumero();
        [$elaboradoPor, $telElaborado] = self::resolverElaborado($usuario_id);

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("
                INSERT INTO cotizaciones
                  (numero_cotizacion, cliente_id, orden_id, usuario_id, fecha,
                   vigencia_dias, modo,
                   subtotal_materiales, subtotal_mano_obra, costo_base,
                   subtotal_con_soldymeg, subtotal_comercial, isv, total,
                   observaciones, ot_cliente, orden_compra,
                   elaborado_por, telefono_elaborado, estado)
                VALUES (?,?,?,?,CURDATE(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,'borrador')
            ");
            $stmt->execute([
                $numero,
                $ot['cliente_id'],
                $orden_id,
                $usuario_id,
                $vigencia,
                'POST_TRABAJO',
                $calc['subtotal_materiales'],
                $calc['subtotal_mano_obra'],
                $calc['costo_base'],
                $calc['subtotal_con_soldymeg'],
                $calc['subtotal_comercial'],
                $calc['isv'],
                $calc['total'],
                $ot['observaciones'] ?? '',
                null,
                null,
                $elaboradoPor ?: null,
                $telElaborado ?: null,
            ]);
            $cot_id = (int)$pdo->lastInsertId();

            // Copiar materiales de la OT al detalle de cotización
            // subtotal ya incluye precio_venta (con margen 35%)
            foreach ($ot['materiales'] as $m) {
                $pdo->prepare("
                    INSERT INTO detalle_cotizacion
                      (cotizacion_id, tipo, descripcion, cantidad, precio_unitario,
                       subtotal_base, subtotal_final)
                    VALUES (?,?,?,?,?,?,?)
                ")->execute([
                    $cot_id, 'material',
                    $m['material'],
                    $m['cantidad'],
                    $m['precio_unitario'],
                    $m['subtotal'],
                    $m['subtotal'],   // precio_venta ya tiene margen
                ]);
            }

            // Copiar mano de obra
            // subtotal en OT = dias × tarifa × 1.35 (margen ya aplicado)
            foreach ($ot['mano_obra'] as $mo) {
                $pdo->prepare("
                    INSERT INTO detalle_cotizacion
                      (cotizacion_id, tipo, descripcion, cantidad, precio_unitario,
                       subtotal_base, subtotal_final)
                    VALUES (?,?,?,?,?,?,?)
                ")->execute([
                    $cot_id, 'mano_obra',
                    $mo['descripcion'],
                    $mo['dias'],
                    $mo['tarifa_dia'],
                    $mo['subtotal'],  // ya lleva ×1.35
                    $mo['subtotal'],
                ]);
            }

            // Actualizar estado de la OT a 'cotizado'
            OrdenModel::cambiarEstado($orden_id, 'cotizado');

            $pdo->commit();
            return $cot_id;

        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /**
     * Crea una cotización DIRECTA (sin OT previa).
     * Recibe items libres con descripción, cantidad, precio.
     */
    public static function crearDirecta(array $d, int $usuario_id): int {
        $pdo    = getDB();
        $items  = $d['items'] ?? [];
        if (empty($items)) throw new Exception('La cotización debe tener al menos un ítem.');

        $total_materiales = 0;
        $total_mo         = 0;
        $total_desc_items = 0; // suma de rebajas por ítem
        foreach ($items as $it) {
            $sub      = (float)$it['cantidad'] * (float)$it['precio_unitario'];
            $desc_pct = (float)($it['descuento_porcentaje'] ?? 0);
            $desc_mto = $desc_pct > 0 ? round($sub * $desc_pct / 100, 2) : (float)($it['descuento_monto'] ?? 0);
            $sub_neto = max(0, $sub - $desc_mto);
            $total_desc_items += $desc_mto;
            if (($it['tipo'] ?? 'material') === 'mano_obra') $total_mo += $sub_neto;
            else $total_materiales += $sub_neto;
        }

        $calc   = Calculos::calcularCotizacion($total_materiales, $total_mo);
        $numero = self::generarNumero();
        [$elaboradoPor, $telElaborado] = self::resolverElaborado($usuario_id);

        // Descuento global sobre el total (después de ISV)
        $desc_global_pct = (float)($d['descuento_porcentaje'] ?? 0);
        $desc_global_mto_input = $desc_global_pct > 0
            ? round($calc['total'] * $desc_global_pct / 100, 2)
            : (float)($d['descuento_monto'] ?? 0);

        // Descuento total = rebajas por ítem + descuento global
        $desc_total_mto  = round($total_desc_items + $desc_global_mto_input, 2);
        // Porcentaje representativo (solo del global si lo hay)
        $desc_total_pct  = $desc_global_pct;
        $total_con_desc  = max(0, round($calc['total'] - $desc_global_mto_input, 2));

        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("
                INSERT INTO cotizaciones
                  (numero_cotizacion, cliente_id, orden_id, usuario_id, fecha,
                   vigencia_dias, modo,
                   subtotal_materiales, subtotal_mano_obra, costo_base,
                   subtotal_con_soldymeg, subtotal_comercial, isv, total,
                   descuento_porcentaje, descuento_monto, total_con_descuento,
                   observaciones, ot_cliente, orden_compra, unidad,
                   elaborado_por, telefono_elaborado, estado)
                VALUES (?,?,NULL,?,CURDATE(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'borrador')
            ");
            $stmt->execute([
                $numero,
                (int)$d['cliente_id'],
                $usuario_id,
                (int)($d['vigencia_dias'] ?? 15),
                'DIRECTA',
                $calc['subtotal_materiales'],
                $calc['subtotal_mano_obra'],
                $calc['costo_base'],
                $calc['subtotal_con_soldymeg'],
                $calc['subtotal_comercial'],
                $calc['isv'],
                $calc['total'],
                $desc_total_pct,
                $desc_total_mto,
                $total_con_desc,
                $d['observaciones'] ?? '',
                trim($d['ot_cliente']   ?? '') ?: null,
                trim($d['orden_compra'] ?? '') ?: null,
                trim($d['unidad']       ?? '') ?: null,
                $elaboradoPor ?: null,
                $telElaborado ?: null,
            ]);
            $cot_id = (int)$pdo->lastInsertId();

            foreach ($items as $it) {
                $tipo      = $it['tipo'] ?? 'material';
                $cant      = (float)$it['cantidad'];
                $pu        = (float)$it['precio_unitario'];
                $sub       = round($cant * $pu, 2);
                $dpct      = (float)($it['descuento_porcentaje'] ?? 0);
                $dmto      = $dpct > 0 ? round($sub * $dpct / 100, 2) : (float)($it['descuento_monto'] ?? 0);
                $sub_desc  = max(0, round($sub - $dmto, 2));
                $pdo->prepare("
                    INSERT INTO detalle_cotizacion
                      (cotizacion_id, tipo, descripcion, cantidad, precio_unitario,
                       subtotal_base, subtotal_final,
                       descuento_porcentaje, descuento_monto, subtotal_con_descuento)
                    VALUES (?,?,?,?,?,?,?,?,?,?)
                ")->execute([
                    $cot_id, $tipo,
                    $it['descripcion'],
                    $cant, $pu,
                    $sub, $sub,
                    $dpct, $dmto, $sub_desc,
                ]);
            }

            $pdo->commit();
            return $cot_id;

        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    /** Estados en los que la cotización aún se puede editar. */
    public static function editable(array $cot): bool { return $cot['estado'] === 'borrador'; }

    /**
     * Edita una cotización en borrador (ítems a precio de venta, descuentos, referencias).
     * Cada ítem: descripcion, tipo, cantidad, precio_unitario (precio de venta), descuento_porcentaje|descuento_monto.
     */
    public static function editar(int $id, array $d): void {
        $cot = self::obtener($id);
        if (!$cot) throw new Exception('Cotización no encontrada.');
        if (!self::editable($cot)) throw new Exception('Solo se puede editar una cotización en estado borrador.');
        $items = $d['items'] ?? [];
        if (empty($items)) throw new Exception('La cotización debe tener al menos un ítem.');

        $totMat = 0; $totMO = 0; $totDescItems = 0; $filas = [];
        foreach ($items as $it) {
            $desc = trim((string)($it['descripcion'] ?? ''));
            $cant = (float)($it['cantidad'] ?? 0); $pu = (float)($it['precio_unitario'] ?? -1);
            if ($desc === '' || $cant <= 0 || $pu < 0) throw new Exception('Revisa los ítems: descripción, cantidad y precio son requeridos.');
            $tipo = ($it['tipo'] ?? 'material') === 'mano_obra' ? 'mano_obra' : 'material';
            $sub  = round($cant * $pu, 2);
            $dpct = (float)($it['descuento_porcentaje'] ?? 0);
            $dmto = $dpct > 0 ? round($sub * $dpct / 100, 2) : (float)($it['descuento_monto'] ?? 0);
            $neto = max(0, round($sub - $dmto, 2));
            $totDescItems += $dmto;
            if ($tipo === 'mano_obra') $totMO += $neto; else $totMat += $neto;
            $filas[] = [$tipo, $desc, $cant, $pu, $sub, $dpct, $dmto, $neto];
        }
        $calc = Calculos::calcularCotizacion($totMat, $totMO);
        $gPct = (float)($d['descuento_porcentaje'] ?? 0);
        $gMto = $gPct > 0 ? round($calc['total'] * $gPct / 100, 2) : (float)($d['descuento_monto'] ?? 0);
        $totalDesc = max(0, round($calc['total'] - $gMto, 2));

        $pdo = getDB(); $pdo->beginTransaction();
        try {
            $pdo->prepare("UPDATE cotizaciones SET vigencia_dias=?, subtotal_materiales=?, subtotal_mano_obra=?, costo_base=?, subtotal_con_soldymeg=?, subtotal_comercial=?, isv=?, total=?,
                           descuento_porcentaje=?, descuento_monto=?, total_con_descuento=?, observaciones=?, ot_cliente=?, orden_compra=?, unidad=? WHERE id_cotizacion=?")
                ->execute([max(1, min(90, (int)($d['vigencia_dias'] ?? $cot['vigencia_dias']))), $calc['subtotal_materiales'], $calc['subtotal_mano_obra'], $calc['costo_base'], $calc['subtotal_con_soldymeg'],
                           $calc['subtotal_comercial'], $calc['isv'], $calc['total'], $gPct, round($totDescItems + $gMto, 2), $totalDesc,
                           trim((string)($d['observaciones'] ?? '')), trim((string)($d['ot_cliente'] ?? '')) ?: null, trim((string)($d['orden_compra'] ?? '')) ?: null,
                           trim((string)($d['unidad'] ?? '')) ?: null, $id]);
            $pdo->prepare("DELETE FROM detalle_cotizacion WHERE cotizacion_id=?")->execute([$id]);
            $ins = $pdo->prepare("INSERT INTO detalle_cotizacion (cotizacion_id, tipo, descripcion, cantidad, precio_unitario, subtotal_base, subtotal_final, descuento_porcentaje, descuento_monto, subtotal_con_descuento) VALUES (?,?,?,?,?,?,?,?,?,?)");
            foreach ($filas as $f) $ins->execute([$id, $f[0], $f[1], $f[2], $f[3], $f[4], $f[4], $f[5], $f[6], $f[7]]);
            $pdo->commit();
        } catch (Throwable $e) { $pdo->rollBack(); throw $e; }
    }

    /**
     * Cliente aprobó una cotización DIRECTA → se activa (crea) la O.T. en proceso.
     * Devuelve ['id_orden'=>, 'numero_orden'=>] o null si no corresponde (ya existe OT o es post-trabajo).
     */
    public static function activarOT(int $cotId, int $usuarioId): ?array {
        $cot = self::obtener($cotId);
        if (!$cot || $cot['modo'] !== 'DIRECTA' || !empty($cot['ot_origen_id'])) return null;
        $pdo = getDB();
        $lineas = array_map(fn($d) => $d['descripcion'], $cot['detalle']);
        $pdo->beginTransaction();
        try {
            $pdo->prepare("INSERT INTO ordenes_trabajo (numero_orden, fecha_apertura, cliente_id, usuario_id, placa, descripcion_trabajo, estado, cotizacion_origen_id, observaciones)
                           VALUES ('TEMP', CURDATE(), ?, ?, ?, ?, 'en_proceso', ?, ?)")
                ->execute([$cot['cliente_id'], $usuarioId, $cot['unidad'] ?: null, implode("\n", $lineas) ?: 'Trabajo según cotización ' . $cot['numero_cotizacion'], $cotId,
                           'Activada por aprobación de la cotización ' . $cot['numero_cotizacion'] . ($cot['ot_cliente'] ? ' · OT cliente: ' . $cot['ot_cliente'] : '') . ($cot['orden_compra'] ? ' · OC: ' . $cot['orden_compra'] : '')]);
            $ordenId = (int)$pdo->lastInsertId();
            // Si la cotización vino de una Solicitud, la solicitud también apunta a la O.T.
            try { $pdo->prepare("UPDATE solicitudes SET orden_id=? WHERE cotizacion_id=?")->execute([$ordenId, $cotId]); } catch (Throwable $e) {}
            $pdo->commit();
        } catch (Throwable $e) { $pdo->rollBack(); throw $e; }
        $n = $pdo->prepare("SELECT numero_orden FROM ordenes_trabajo WHERE id_orden=?"); $n->execute([$ordenId]);
        return ['id_orden' => $ordenId, 'numero_orden' => $n->fetchColumn()];
    }

    /** Motivo por el que NO se puede facturar todavía (O.T. de origen sin finalizar) o null si está libre. */
    public static function bloqueoFacturacion(int $cotId): ?string {
        $st = getDB()->prepare("SELECT numero_orden, estado FROM ordenes_trabajo WHERE cotizacion_origen_id=? AND estado <> 'anulada' ORDER BY id_orden DESC LIMIT 1");
        $st->execute([$cotId]);
        $ot = $st->fetch();
        if ($ot && !in_array($ot['estado'], ['finalizada', 'cotizado', 'facturada'], true))
            return "La {$ot['numero_orden']} aún no está finalizada. Al finalizarla se habilita la facturación.";
        return null;
    }

    public static function cambiarEstado(int $id, string $estado, ?string $motivo_rechazo = null): bool {
        if ($estado === 'rechazada' && $motivo_rechazo !== null) {
            $stmt = getDB()->prepare("UPDATE cotizaciones SET estado=?, motivo_rechazo=? WHERE id_cotizacion=?");
            return $stmt->execute([$estado, strtoupper(trim($motivo_rechazo)), $id]);
        }
        $stmt = getDB()->prepare("UPDATE cotizaciones SET estado=?, motivo_rechazo=NULL WHERE id_cotizacion=?");
        return $stmt->execute([$estado, $id]);
    }

    public static function actualizarReferencias(int $id, string $ot_cliente, string $orden_compra): bool {
        $stmt = getDB()->prepare(
            "UPDATE cotizaciones SET ot_cliente=?, orden_compra=? WHERE id_cotizacion=?"
        );
        return $stmt->execute([
            trim($ot_cliente)   ?: null,
            trim($orden_compra) ?: null,
            $id,
        ]);
    }

    private static function generarNumero(): string {
        $year = date('Y');
        $pdo  = getDB();

        // Traer todos los números del año y calcular el max en PHP
        // para evitar problemas de CAST en MySQL con valores vacíos
        $stmt = $pdo->prepare(
            "SELECT numero_cotizacion FROM cotizaciones
             WHERE numero_cotizacion LIKE ? ORDER BY id_cotizacion DESC"
        );
        $stmt->execute(["COT-$year-%"]);
        $rows = $stmt->fetchAll(\PDO::FETCH_COLUMN);

        $max = 0;
        foreach ($rows as $num) {
            // Formato: COT-YYYY-NNN  → extraer la parte numérica final
            $parts = explode('-', $num);
            $n = (int)end($parts);
            if ($n > $max) $max = $n;
        }
        $seq = $max + 1;

        // Verificar unicidad en caso de concurrencia
        $numero = "COT-$year-" . str_pad($seq, 3, '0', STR_PAD_LEFT);
        while (true) {
            $chk = $pdo->prepare("SELECT id_cotizacion FROM cotizaciones WHERE numero_cotizacion = ?");
            $chk->execute([$numero]);
            if (!$chk->fetch()) break;
            $seq++;
            $numero = "COT-$year-" . str_pad($seq, 3, '0', STR_PAD_LEFT);
        }
        return $numero;
    }
}
