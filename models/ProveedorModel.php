<?php
// ============================================================
//  SOLDYMEG — ProveedorModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class ProveedorModel {

    public static function listar(string $estado = 'activo'): array {
        $stmt = getDB()->prepare(
            "SELECT id_proveedor, nombre, rtn, telefono, contacto, estado
             FROM proveedores WHERE estado = ? ORDER BY nombre"
        );
        $stmt->execute([$estado]);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare("SELECT * FROM proveedores WHERE id_proveedor = ?");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function crear(array $d): int {
        $pdo = getDB();
        $pdo->prepare(
            "INSERT INTO proveedores (nombre, rtn, telefono, direccion, correo, contacto)
             VALUES (?,?,?,?,?,?)"
        )->execute([
            trim($d['nombre']),
            trim($d['rtn']       ?? ''),
            trim($d['telefono']  ?? ''),
            trim($d['direccion'] ?? ''),
            trim($d['correo']    ?? ''),
            trim($d['contacto']  ?? ''),
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function editar(array $d): bool {
        return getDB()->prepare(
            "UPDATE proveedores
             SET nombre=?, rtn=?, telefono=?, direccion=?, correo=?, contacto=?
             WHERE id_proveedor=?"
        )->execute([
            trim($d['nombre']),
            trim($d['rtn']       ?? ''),
            trim($d['telefono']  ?? ''),
            trim($d['direccion'] ?? ''),
            trim($d['correo']    ?? ''),
            trim($d['contacto']  ?? ''),
            (int)$d['id'],
        ]);
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        $stmt = getDB()->prepare("UPDATE proveedores SET estado=? WHERE id_proveedor=?");
        return $stmt->execute([$estado, $id]);
    }
}
