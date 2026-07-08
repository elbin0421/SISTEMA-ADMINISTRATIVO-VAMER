<?php
// ============================================================
//  SOLDYMEG — CatalogoPreciosModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class CatalogoPreciosModel {

    public static function listar(string $estado = 'activo', string $q = ''): array {
        $where = "WHERE 1=1";
        $params = [];
        if ($estado !== 'todos') { $where .= " AND estado = ?"; $params[] = $estado; }
        if ($q) { $where .= " AND (descripcion LIKE ? OR codigo LIKE ? OR categoria LIKE ?)"; $params[] = "%$q%"; $params[] = "%$q%"; $params[] = "%$q%"; }
        $stmt = getDB()->prepare("SELECT * FROM catalogo_precios $where ORDER BY categoria ASC, descripcion ASC");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare("SELECT * FROM catalogo_precios WHERE id_catalogo = ?");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function crear(array $d): int {
        $pdo = getDB();
        $pdo->prepare("
            INSERT INTO catalogo_precios (codigo, descripcion, tipo, categoria, precio, estado)
            VALUES (?, ?, ?, ?, ?, 'activo')
        ")->execute([
            trim($d['codigo']),
            trim($d['descripcion']),
            $d['tipo']      ?? 'material',
            trim($d['categoria'] ?? ''),
            (float)$d['precio'],
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function actualizar(int $id, array $d): bool {
        return (bool) getDB()->prepare("
            UPDATE catalogo_precios SET
              codigo=?, descripcion=?, tipo=?, categoria=?, precio=?
            WHERE id_catalogo=?
        ")->execute([
            strtoupper(trim($d['codigo']      ?? '')),
            trim($d['descripcion']),
            $d['tipo']      ?? 'material',
            trim($d['categoria'] ?? ''),
            (float)$d['precio'],
            $id,
        ]);
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        return (bool) getDB()->prepare(
            "UPDATE catalogo_precios SET estado=? WHERE id_catalogo=?"
        )->execute([$estado, $id]);
    }
}
