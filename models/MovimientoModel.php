<?php
// ============================================================
//  SOLDYMEG — MovimientoModel
//  Registro de movimientos de transporte (MAERSK / ALPLA)
// ============================================================
require_once __DIR__ . '/../config/db.php';

class MovimientoModel {

    public static function listar(array $filtros = []): array {
        $where  = "WHERE 1=1";
        $params = [];

        if (!empty($filtros['tipo']) && $filtros['tipo'] !== 'todos') {
            $where .= " AND m.tipo = ?"; $params[] = $filtros['tipo'];
        }
        if (!empty($filtros['estado']) && $filtros['estado'] !== 'todos') {
            $where .= " AND m.estado = ?"; $params[] = $filtros['estado'];
        }
        if (!empty($filtros['cliente_id'])) {
            $where .= " AND m.cliente_id = ?"; $params[] = (int)$filtros['cliente_id'];
        }
        if (!empty($filtros['fecha_desde'])) {
            $where .= " AND m.fecha >= ?"; $params[] = $filtros['fecha_desde'];
        }
        if (!empty($filtros['fecha_hasta'])) {
            $where .= " AND m.fecha <= ?"; $params[] = $filtros['fecha_hasta'];
        }
        if (!empty($filtros['q'])) {
            $where .= " AND (m.ot LIKE ? OR m.contenedor LIKE ? OR m.chasis LIKE ? OR m.motorista LIKE ? OR m.placa LIKE ? OR c.nombre LIKE ?)";
            for ($i = 0; $i < 6; $i++) $params[] = '%' . $filtros['q'] . '%';
        }

        $stmt = getDB()->prepare("
            SELECT m.*, c.nombre AS cliente_nombre, f.numero_factura,
                   u.nombre AS registrado_por
            FROM movimientos m
            LEFT JOIN clientes  c ON c.id_cliente  = m.cliente_id
            LEFT JOIN facturas  f ON f.id_factura  = m.factura_id
            LEFT JOIN usuarios  u ON u.id_usuario  = m.usuario_id
            $where
            ORDER BY m.fecha DESC, m.hora DESC, m.id_movimiento DESC
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare("
            SELECT m.*, c.nombre AS cliente_nombre, f.numero_factura
            FROM movimientos m
            LEFT JOIN clientes c ON c.id_cliente = m.cliente_id
            LEFT JOIN facturas f ON f.id_factura = m.factura_id
            WHERE m.id_movimiento = ?
        ");
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    /**
     * Movimientos pendientes (no facturados, no anulados) de un cliente específico.
     * Usado por el flujo "Facturar Movimientos" (selección múltiple).
     */
    public static function pendientesPorCliente(int $cliente_id): array {
        $stmt = getDB()->prepare("
            SELECT m.*
            FROM movimientos m
            WHERE m.cliente_id = ? AND m.estado = 'pendiente'
            ORDER BY m.fecha ASC, m.id_movimiento ASC
        ");
        $stmt->execute([$cliente_id]);
        return $stmt->fetchAll();
    }

    public static function crear(array $d, int $usuario_id): int {
        $pdo = getDB();
        $pdo->prepare("
            INSERT INTO movimientos
              (tipo, fecha, hora, periodo, flete, destino, cliente_id, ot, contenedor,
               chasis, motorista_id, motorista, placa, tarifa, estado, observacion, usuario_id)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,'pendiente',?,?)
        ")->execute([
            $d['tipo'], $d['fecha'], $d['hora'] ?: null, $d['periodo'] ?: null,
            $d['flete'] ?: null, $d['destino'] ?: null, $d['cliente_id'] ?: null, $d['ot'] ?: null,
            $d['contenedor'] ?: null, $d['chasis'] ?: null,
            $d['motorista_id'] ?: null, $d['motorista'] ?: null,
            $d['placa'] ?: null, (float)($d['tarifa'] ?? 0), $d['observacion'] ?: null,
            $usuario_id,
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function editar(int $id, array $d): void {
        $actual = self::obtener($id);
        if (!$actual) throw new Exception('Movimiento no encontrado.');
        if ($actual['estado'] === 'facturado') {
            throw new Exception('No se puede editar un movimiento ya facturado. Anule la factura primero.');
        }
        getDB()->prepare("
            UPDATE movimientos SET
              tipo=?, fecha=?, hora=?, periodo=?, flete=?, destino=?, cliente_id=?, ot=?,
              contenedor=?, chasis=?, motorista_id=?, motorista=?, placa=?, tarifa=?, observacion=?
            WHERE id_movimiento=?
        ")->execute([
            $d['tipo'], $d['fecha'], $d['hora'] ?: null, $d['periodo'] ?: null,
            $d['flete'] ?: null, $d['destino'] ?: null, $d['cliente_id'] ?: null, $d['ot'] ?: null,
            $d['contenedor'] ?: null, $d['chasis'] ?: null,
            $d['motorista_id'] ?: null, $d['motorista'] ?: null,
            $d['placa'] ?: null, (float)($d['tarifa'] ?? 0), $d['observacion'] ?: null,
            $id,
        ]);
    }

    public static function anular(int $id): void {
        $actual = self::obtener($id);
        if (!$actual) throw new Exception('Movimiento no encontrado.');
        if ($actual['estado'] === 'facturado') {
            throw new Exception('No se puede anular un movimiento ya facturado. Anule la factura primero.');
        }
        getDB()->prepare("UPDATE movimientos SET estado='anulado' WHERE id_movimiento=?")->execute([$id]);
    }

    /** Marca varios movimientos como facturados y los liga a una factura. Usado dentro de una transacción externa. */
    public static function marcarFacturados(array $ids, int $factura_id): void {
        if (empty($ids)) return;
        $in = implode(',', array_fill(0, count($ids), '?'));
        $params = array_merge([$factura_id], $ids);
        getDB()->prepare("UPDATE movimientos SET estado='facturado', factura_id=? WHERE id_movimiento IN ($in)")
               ->execute($params);
    }
}
