<?php
// ============================================================
//  SOLDYMEG — InventarioModel
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../helpers/Calculos.php';

class InventarioModel {

    public static function listar(): array {
        $stmt = getDB()->query("
            SELECT m.*, c.nombre AS categoria
            FROM materiales m
            LEFT JOIN categorias_material c ON c.id_categoria = m.categoria_id
            WHERE m.estado = 'activo'
            ORDER BY m.nombre
        ");
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare(
            "SELECT m.*, c.nombre AS categoria
             FROM materiales m
             LEFT JOIN categorias_material c ON c.id_categoria = m.categoria_id
             WHERE m.id_material = ?"
        );
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function stockBajo(): array {
        $stmt = getDB()->query(
            "SELECT * FROM materiales WHERE estado='activo' AND stock <= stock_minimo"
        );
        return $stmt->fetchAll();
    }

    public static function buscar(string $q): array {
        $like = '%' . $q . '%';
        $stmt = getDB()->prepare(
            "SELECT id_material, nombre, unidad_medida, precio_compra, precio_venta, stock
             FROM materiales WHERE estado='activo'
             AND (nombre LIKE ? OR codigo LIKE ?)
             ORDER BY nombre LIMIT 20"
        );
        $stmt->execute([$like, $like]);
        return $stmt->fetchAll();
    }

    public static function crear(array $d): int {
        $pdo = getDB();
        $precio_venta = isset($d['precio_venta']) && $d['precio_venta'] > 0
            ? $d['precio_venta']
            : Calculos::precioVentaMaterial((float)($d['precio_compra'] ?? 0))['precio_venta'];
        $stmt   = $pdo->query("SELECT COALESCE(MAX(CAST(codigo AS UNSIGNED)), 0) + 1 FROM materiales");
        $seq    = (int)$stmt->fetchColumn();
        $codigo = str_pad($seq, 5, '0', STR_PAD_LEFT);
        $pdo->prepare("
            INSERT INTO materiales
              (codigo, nombre, descripcion, categoria_id, unidad_medida,
               precio_compra, precio_venta, stock, stock_minimo)
            VALUES (?,?,?,?,?,?,?,?,?)
        ")->execute([
            $codigo, $d['nombre'], $d['descripcion'] ?? null,
            $d['categoria_id'] ?? null, $d['unidad_medida'] ?? 'unidad',
            (float)($d['precio_compra'] ?? 0), $precio_venta,
            (float)($d['stock'] ?? 0), (float)($d['stock_minimo'] ?? 0),
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function ajusteManual(int $material_id, string $tipo, float $cantidad, string $obs, int $usuario_id): bool {
        $pdo = getDB();
        $op  = $tipo === 'entrada' ? '+' : '-';
        $pdo->prepare("UPDATE materiales SET stock = stock $op ? WHERE id_material = ?")->execute([$cantidad, $material_id]);
        $pdo->prepare("
            INSERT INTO movimientos_inventario
              (material_id, tipo, cantidad, costo_unitario, tipo_referencia, usuario_id, observaciones)
            VALUES (?,?,?,0,'ajuste_manual',?,?)
        ")->execute([$material_id, $tipo, $cantidad, $usuario_id, $obs]);
        return true;
    }

    public static function kardex(int $material_id): array {
        $stmt = getDB()->prepare("
            SELECT mi.*, u.nombre AS usuario
            FROM movimientos_inventario mi
            JOIN usuarios u ON u.id_usuario = mi.usuario_id
            WHERE mi.material_id = ?
            ORDER BY mi.fecha DESC
            LIMIT 200
        ");
        $stmt->execute([$material_id]);
        return $stmt->fetchAll();
    }

    public static function categorias(): array {
        $stmt = getDB()->query("SELECT * FROM categorias_material ORDER BY nombre");
        return $stmt->fetchAll();
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        $stmt = getDB()->prepare("UPDATE materiales SET estado=? WHERE id_material=?");
        return $stmt->execute([$estado, $id]);
    }
}
