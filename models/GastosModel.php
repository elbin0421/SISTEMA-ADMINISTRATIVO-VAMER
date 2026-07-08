<?php
require_once __DIR__ . '/../config/db.php';

class GastosModel {

    public static function listar(array $filtros = []): array {
        $pdo = getDB();
        $where = ['1=1']; $params = [];
        if (!empty($filtros['mes']))    { $where[] = 'g.mes_declaracion=?';  $params[] = (int)$filtros['mes']; }
        if (!empty($filtros['anio']))   { $where[] = 'g.anio_declaracion=?'; $params[] = (int)$filtros['anio']; }
        if (!empty($filtros['estado'])) { $where[] = 'g.estado=?';           $params[] = $filtros['estado']; }
        $stmt = $pdo->prepare("
            SELECT g.*, u.nombre AS registrado_por
            FROM gastos_dmc g
            LEFT JOIN usuarios u ON u.id_usuario = g.usuario_id
            WHERE " . implode(' AND ', $where) . "
            ORDER BY g.fecha DESC, g.id_gasto DESC LIMIT 500");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT g.*, u.nombre AS registrado_por
            FROM gastos_dmc g LEFT JOIN usuarios u ON u.id_usuario = g.usuario_id
            WHERE g.id_gasto = ?");
        $stmt->execute([$id]);
        $g = $stmt->fetch();
        if (!$g) return null;
        $its = $pdo->prepare("SELECT * FROM gastos_dmc_items WHERE gasto_id = ? ORDER BY id_item");
        $its->execute([$id]);
        $g['items'] = $its->fetchAll();
        return $g;
    }

    public static function crear(array $d, int $uid): int {
        $pdo   = getDB();
        $items = $d['items'] ?? [];
        $tasa  = in_array((int)($d['tasa_isv'] ?? 15), [0, 15, 18]) ? (int)$d['tasa_isv'] : 15;

        // Calcular subtotal sumando cantidad × monto de cada ítem
        $sub = 0;
        foreach ($items as $it) {
            $cant  = max(1, (float)($it['cantidad'] ?? 1));
            $monto = (float)($it['monto'] ?? 0);
            $sub  += round($cant * $monto, 2);
        }
        $sub  = round($sub, 2);
        $isv  = round($sub * $tasa / 100, 2);
        $tot  = round($sub + $isv, 2);
        $desc = implode(' | ', array_map(fn($it) => trim($it['descripcion']), $items));

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO gastos_dmc
                  (fecha, rtn_proveedor, nombre_proveedor, tipo_documento, numero_factura,
                   categoria, descripcion, subtotal, tasa_isv, isv, total, deducible,
                   mes_declaracion, anio_declaracion, estado, observaciones, usuario_id)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
                ->execute([
                    $d['fecha'],
                    trim($d['rtn_proveedor'] ?? '') ?: null,
                    strtoupper(trim($d['nombre_proveedor'])),
                    $d['tipo_documento'] ?? 'factura',
                    trim($d['numero_factura'] ?? '') ?: null,
                    $d['categoria'] ?? 'otros',
                    $desc, $sub, $tasa, $isv, $tot,
                    isset($d['deducible']) ? (int)(bool)$d['deducible'] : 1,
                    (int)$d['mes_declaracion'],
                    (int)$d['anio_declaracion'],
                    $d['estado'] ?? 'pendiente',
                    trim($d['observaciones'] ?? '') ?: null,
                    $uid,
                ]);
            $gasto_id = (int)$pdo->lastInsertId();
            self::guardarItems($pdo, $gasto_id, $items, $tasa);
            $pdo->commit();
            return $gasto_id;
        } catch (Exception $e) { $pdo->rollBack(); throw $e; }
    }

    public static function actualizar(int $id, array $d): bool {
        $pdo   = getDB();
        $items = $d['items'] ?? [];
        $chk   = $pdo->prepare('SELECT estado FROM gastos_dmc WHERE id_gasto=?');
        $chk->execute([$id]);
        $row = $chk->fetch();
        if (!$row || $row['estado'] === 'declarado')
            throw new Exception('No se puede modificar un gasto declarado.');

        $tasa = in_array((int)($d['tasa_isv'] ?? 15), [0, 15, 18]) ? (int)$d['tasa_isv'] : 15;
        $sub  = 0;
        foreach ($items as $it) {
            $cant  = max(1, (float)($it['cantidad'] ?? 1));
            $monto = (float)($it['monto'] ?? 0);
            $sub  += round($cant * $monto, 2);
        }
        $sub  = round($sub, 2);
        $isv  = round($sub * $tasa / 100, 2);
        $tot  = round($sub + $isv, 2);
        $desc = implode(' | ', array_map(fn($it) => trim($it['descripcion']), $items));

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                UPDATE gastos_dmc SET
                  fecha=?, rtn_proveedor=?, nombre_proveedor=?, tipo_documento=?, numero_factura=?,
                  categoria=?, descripcion=?, subtotal=?, tasa_isv=?, isv=?, total=?, deducible=?,
                  mes_declaracion=?, anio_declaracion=?, estado=?, observaciones=?
                WHERE id_gasto=?")
                ->execute([
                    $d['fecha'],
                    trim($d['rtn_proveedor'] ?? '') ?: null,
                    strtoupper(trim($d['nombre_proveedor'])),
                    $d['tipo_documento'] ?? 'factura',
                    trim($d['numero_factura'] ?? '') ?: null,
                    $d['categoria'] ?? 'otros',
                    $desc, $sub, $tasa, $isv, $tot,
                    isset($d['deducible']) ? (int)(bool)$d['deducible'] : 1,
                    (int)$d['mes_declaracion'],
                    (int)$d['anio_declaracion'],
                    $d['estado'] ?? 'pendiente',
                    trim($d['observaciones'] ?? '') ?: null,
                    $id,
                ]);
            $pdo->prepare("DELETE FROM gastos_dmc_items WHERE gasto_id=?")->execute([$id]);
            self::guardarItems($pdo, $id, $items, $tasa);
            $pdo->commit();
            return true;
        } catch (Exception $e) { $pdo->rollBack(); throw $e; }
    }

    private static function guardarItems(PDO $pdo, int $gasto_id, array $items, int $tasa): void {
        $ins = $pdo->prepare("
            INSERT INTO gastos_dmc_items (gasto_id, descripcion, cantidad, monto, total_item, isv, total)
            VALUES (?,?,?,?,?,?,?)");
        foreach ($items as $it) {
            if (!trim($it['descripcion'] ?? '')) continue;
            $cant       = max(1, (float)($it['cantidad'] ?? 1));
            $monto      = round((float)($it['monto'] ?? 0), 2);
            $total_item = round($cant * $monto, 2);
            if ($total_item <= 0) continue;
            $isv   = round($total_item * $tasa / 100, 2);
            $total = round($total_item + $isv, 2);
            $ins->execute([$gasto_id, trim($it['descripcion']), $cant, $monto, $total_item, $isv, $total]);
        }
    }

    public static function eliminar(int $id): bool {
        $chk = getDB()->prepare('SELECT estado FROM gastos_dmc WHERE id_gasto=?');
        $chk->execute([$id]);
        $row = $chk->fetch();
        if (!$row) throw new Exception('Gasto no encontrado.');
        if ($row['estado'] === 'declarado') throw new Exception('No se puede eliminar un gasto declarado.');
        return (bool)getDB()->prepare("DELETE FROM gastos_dmc WHERE id_gasto=?")->execute([$id]);
    }

    public static function declararMes(int $mes, int $anio): int {
        $stmt = getDB()->prepare(
            "UPDATE gastos_dmc SET estado='declarado' WHERE mes_declaracion=? AND anio_declaracion=? AND estado='pendiente'");
        $stmt->execute([$mes, $anio]);
        return $stmt->rowCount();
    }

    public static function resumen(int $mes, int $anio): array {
        $stmt = getDB()->prepare("
            SELECT COUNT(*) AS total_registros,
                   SUM(subtotal) AS total_subtotal, SUM(isv) AS total_isv, SUM(total) AS total_general,
                   SUM(IF(deducible=1,subtotal,0)) AS total_deducible,
                   SUM(IF(deducible=0,subtotal,0)) AS total_no_deducible,
                   SUM(IF(estado='declarado',total,0)) AS total_declarado,
                   SUM(IF(estado='pendiente',total,0)) AS total_pendiente
            FROM gastos_dmc WHERE mes_declaracion=? AND anio_declaracion=?");
        $stmt->execute([$mes, $anio]);
        return $stmt->fetch();
    }
}
