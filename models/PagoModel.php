<?php
// ============================================================
//  SOLDYMEG — PagoModel  (Fase 3)
// ============================================================
require_once __DIR__ . '/../config/db.php';

class PagoModel {

    public static function listarPorFactura(int $factura_id): array {
        $stmt = getDB()->prepare("
            SELECT p.*, u.nombre AS usuario
            FROM pagos_clientes p
            JOIN usuarios u ON u.id_usuario = p.usuario_id
            WHERE p.factura_id = ?
            ORDER BY p.fecha DESC
        ");
        $stmt->execute([$factura_id]);
        return $stmt->fetchAll();
    }

    public static function listar(string $mes = '', string $anio = ''): array {
        $where  = '';
        $params = [];
        if ($mes && $anio) {
            $where  = "WHERE MONTH(p.fecha) = ? AND YEAR(p.fecha) = ?";
            $params = [(int)$mes, (int)$anio];
        }
        $stmt = getDB()->prepare("
            SELECT p.*, f.numero_factura, cl.nombre AS cliente, u.nombre AS usuario
            FROM pagos_clientes p
            JOIN facturas f  ON f.id_factura  = p.factura_id
            JOIN clientes cl ON cl.id_cliente = p.cliente_id
            JOIN usuarios u  ON u.id_usuario  = p.usuario_id
            $where
            ORDER BY p.fecha DESC, p.id_pago DESC
            LIMIT 300
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function registrar(array $d, int $usuario_id): int {
        $pdo = getDB();
        $monto         = (float)$d['monto'];
        $retencion_isr = (float)($d['retencion_isr'] ?? 0);
        $retencion_isv = (float)($d['retencion_isv'] ?? 0);
        $monto_neto    = round($monto - $retencion_isr - $retencion_isv, 2);

        $pdo->prepare("
            INSERT INTO pagos_clientes
              (factura_id, cliente_id, usuario_id, fecha, monto,
               retencion_isr, retencion_isv, monto_neto,
               metodo_pago, referencia, concepto, estado)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,'aplicado')
        ")->execute([
            (int)$d['factura_id'],
            (int)$d['cliente_id'],
            $usuario_id,
            $d['fecha'] ?? date('Y-m-d'),
            $monto,
            $retencion_isr,
            $retencion_isv,
            $monto_neto,
            $d['metodo_pago'],
            $d['referencia'] ?? null,
            $d['concepto']   ?? 'Pago de factura',
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function totalPagadoPorFactura(int $factura_id): float {
        // El total "pagado" para efectos de saldo es el monto bruto declarado,
        // independientemente de las retenciones (que son cobros parciales reconocidos)
        $stmt = getDB()->prepare(
            "SELECT COALESCE(SUM(monto), 0) FROM pagos_clientes WHERE factura_id = ? AND estado = 'aplicado'"
        );
        $stmt->execute([$factura_id]);
        return (float)$stmt->fetchColumn();
    }

    public static function totalRetencionesPorFactura(int $factura_id): array {
        $stmt = getDB()->prepare("
            SELECT COALESCE(SUM(retencion_isr),0) AS total_isr,
                   COALESCE(SUM(retencion_isv),0) AS total_isv,
                   COALESCE(SUM(monto_neto),0)    AS total_neto
            FROM pagos_clientes
            WHERE factura_id = ? AND estado = 'aplicado'
        ");
        $stmt->execute([$factura_id]);
        return $stmt->fetch();
    }

    // ── Fase 4: Módulo Pagos ─────────────────────────────────

    /**
     * Lista todos los pagos con filtros opcionales.
     */
    public static function listarCompleto(array $filtros = []): array {
        $where  = ["p.estado = 'aplicado'"];
        $params = [];

        if (!empty($filtros['cliente_id'])) {
            $where[]  = 'p.cliente_id = ?';
            $params[] = (int)$filtros['cliente_id'];
        }
        if (!empty($filtros['mes']) && !empty($filtros['anio'])) {
            $where[]  = 'MONTH(p.fecha) = ? AND YEAR(p.fecha) = ?';
            $params[] = (int)$filtros['mes'];
            $params[] = (int)$filtros['anio'];
        }
        if (!empty($filtros['metodo_pago'])) {
            $where[]  = 'p.metodo_pago = ?';
            $params[] = $filtros['metodo_pago'];
        }
        if (!empty($filtros['factura_id'])) {
            $where[]  = 'p.factura_id = ?';
            $params[] = (int)$filtros['factura_id'];
        }

        $sql = "
            SELECT p.*,
                   f.numero_factura, f.total AS factura_total, f.estado AS factura_estado,
                   cl.nombre AS cliente, cl.rtn AS cliente_rtn,
                   u.nombre  AS usuario
            FROM pagos_clientes p
            JOIN facturas  f  ON f.id_factura  = p.factura_id
            JOIN clientes  cl ON cl.id_cliente = p.cliente_id
            JOIN usuarios  u  ON u.id_usuario  = p.usuario_id
            WHERE " . implode(' AND ', $where) . "
            ORDER BY p.fecha DESC, p.id_pago DESC
            LIMIT 500
        ";
        $stmt = getDB()->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /**
     * KPIs del módulo pagos para el mes actual.
     */
    public static function kpis(): array {
        $pdo  = getDB();
        $mes  = date('m');
        $anio = date('Y');

        $stmt = $pdo->prepare("
            SELECT
                COUNT(*)                              AS total_pagos,
                COALESCE(SUM(monto), 0)               AS total_cobrado,
                COALESCE(SUM(monto_neto), 0)          AS total_neto,
                COALESCE(SUM(retencion_isr), 0)       AS total_isr,
                COALESCE(SUM(retencion_isv), 0)       AS total_isv
            FROM pagos_clientes
            WHERE estado = 'aplicado'
              AND MONTH(fecha) = ? AND YEAR(fecha) = ?
        ");
        $stmt->execute([$mes, $anio]);
        $kpis = $stmt->fetch();

        // Cuentas por cobrar (facturas pendientes o emitidas con saldo)
        $stmt2 = $pdo->prepare("
            SELECT
                COUNT(*) AS facturas_pendientes,
                COALESCE(SUM(f.total - COALESCE(pg.pagado,0)), 0) AS saldo_total
            FROM facturas f
            LEFT JOIN (
                SELECT factura_id, SUM(monto) AS pagado
                FROM pagos_clientes WHERE estado = 'aplicado'
                GROUP BY factura_id
            ) pg ON pg.factura_id = f.id_factura
            WHERE f.estado IN ('emitida','pendiente')
        ");
        $stmt2->execute();
        $cxc = $stmt2->fetch();

        return array_merge($kpis, $cxc);
    }

    /**
     * Cuentas por cobrar: facturas con saldo pendiente por cliente.
     */
    public static function cuentasPorCobrar(int $cliente_id = 0): array {
        $where  = "WHERE f.estado IN ('emitida','pendiente')";
        $params = [];
        if ($cliente_id) {
            $where  .= ' AND f.cliente_id = ?';
            $params[] = $cliente_id;
        }
        $stmt = getDB()->prepare("
            SELECT
                f.id_factura, f.numero_factura, f.fecha, f.total,
                f.cliente_id,
                f.estado AS factura_estado,
                COALESCE(pg.pagado, 0)           AS total_pagado,
                f.total - COALESCE(pg.pagado, 0) AS saldo_pendiente,
                COALESCE(pg.ret_isr, 0)          AS retencion_isr,
                COALESCE(pg.ret_isv, 0)          AS retencion_isv,
                cl.nombre AS cliente, cl.rtn AS cliente_rtn,
                COALESCE(cl.dias_credito, 0)     AS dias_credito,
                cot.numero_cotizacion,
                DATEDIFF(CURDATE(), f.fecha)     AS dias_transcurridos,
                GREATEST(0, DATEDIFF(CURDATE(), f.fecha) - COALESCE(cl.dias_credito, 0)) AS dias_vencido,
                COALESCE(cl.dias_credito, 0) - DATEDIFF(CURDATE(), f.fecha) AS dias_restantes
            FROM facturas f
            JOIN clientes cl ON cl.id_cliente = f.cliente_id
            LEFT JOIN cotizaciones cot ON cot.id_cotizacion = f.cotizacion_id
            LEFT JOIN (
                SELECT factura_id,
                       SUM(monto)         AS pagado,
                       SUM(retencion_isr) AS ret_isr,
                       SUM(retencion_isv) AS ret_isv
                FROM pagos_clientes WHERE estado = 'aplicado'
                GROUP BY factura_id
            ) pg ON pg.factura_id = f.id_factura
            $where
            HAVING saldo_pendiente > 0.01
            ORDER BY dias_vencido DESC, f.fecha ASC
            LIMIT 300
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /**
     * Historial completo de pagos de un cliente.
     */
    public static function historialCliente(int $cliente_id): array {
        $stmt = getDB()->prepare("
            SELECT p.*,
                   f.numero_factura, f.total AS factura_total,
                   u.nombre AS usuario
            FROM pagos_clientes p
            JOIN facturas f ON f.id_factura = p.factura_id
            JOIN usuarios u ON u.id_usuario = p.usuario_id
            WHERE p.cliente_id = ?
            ORDER BY p.fecha DESC, p.id_pago DESC
        ");
        $stmt->execute([$cliente_id]);
        return $stmt->fetchAll();
    }

    /**
     * Anular un pago y revertir estado de factura si aplica.
     */
    public static function anular(int $id, int $usuario_id): bool {
        $pdo  = getDB();
        $stmt = $pdo->prepare("SELECT * FROM pagos_clientes WHERE id_pago = ?");
        $stmt->execute([$id]);
        $pago = $stmt->fetch();
        if (!$pago) throw new Exception('Pago no encontrado.');
        if ($pago['estado'] === 'anulado') throw new Exception('El pago ya está anulado.');

        $pdo->beginTransaction();
        try {
            $pdo->prepare("UPDATE pagos_clientes SET estado='anulado' WHERE id_pago=?")
                ->execute([$id]);

            // Recalcular saldo de la factura y revertir estado si ya estaba pagada
            $pagado_nuevo = self::totalPagadoPorFactura((int)$pago['factura_id']);
            $fStmt = $pdo->prepare("SELECT total FROM facturas WHERE id_factura=?");
            $fStmt->execute([$pago['factura_id']]);
            $factura = $fStmt->fetch();

            if ($factura) {
                $nuevo_estado = ($pagado_nuevo >= (float)$factura['total'] - 0.01)
                    ? 'pagada' : 'pendiente';
                $pdo->prepare("UPDATE facturas SET estado=? WHERE id_factura=? AND estado != 'anulada'")
                    ->execute([$nuevo_estado, $pago['factura_id']]);
            }

            $pdo->commit();
            return true;
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }
}
