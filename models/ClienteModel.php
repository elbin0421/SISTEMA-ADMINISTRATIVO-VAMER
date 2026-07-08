<?php
// ============================================================
//  SOLDYMEG — ClienteModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class ClienteModel {

    public static function listar(string $estado = 'activo'): array {
        $stmt = getDB()->prepare(
            "SELECT * FROM clientes WHERE estado = ? ORDER BY nombre"
        );
        $stmt->execute([$estado]);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare("SELECT * FROM clientes WHERE id_cliente = ?");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function buscar(string $q): array {
        $like = '%' . $q . '%';
        $stmt = getDB()->prepare(
            "SELECT id_cliente, nombre, tipo_cliente, rtn, telefono
             FROM clientes WHERE estado = 'activo'
             AND (nombre LIKE ? OR rtn LIKE ? OR telefono LIKE ?)
             ORDER BY nombre LIMIT 20"
        );
        $stmt->execute([$like, $like, $like]);
        return $stmt->fetchAll();
    }

    public static function crear(array $d): int {
        $pdo  = getDB();
        $stmt = $pdo->prepare(
            "INSERT INTO clientes (nombre, tipo_cliente, rtn, telefono, telefono2,
             correo, contacto, dias_credito, direccion)
             VALUES (?,?,?,?,?,?,?,?,?)"
        );
        $stmt->execute([
            $d['nombre'], $d['tipo_cliente'] ?? 'empresa',
            $d['rtn'] ?? null, $d['telefono'] ?? null,
            $d['telefono2'] ?? null, $d['correo'] ?? null,
            $d['contacto'] ?? null, (int)($d['dias_credito'] ?? 0),
            $d['direccion'] ?? null,
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function editar(array $d): bool {
        $stmt = getDB()->prepare(
            "UPDATE clientes SET nombre=?, tipo_cliente=?, rtn=?, telefono=?,
             telefono2=?, correo=?, contacto=?, dias_credito=?, direccion=?
             WHERE id_cliente=?"
        );
        return $stmt->execute([
            $d['nombre'], $d['tipo_cliente'],
            $d['rtn'] ?? null, $d['telefono'] ?? null,
            $d['telefono2'] ?? null, $d['correo'] ?? null,
            $d['contacto'] ?? null, (int)($d['dias_credito'] ?? 0),
            $d['direccion'] ?? null,
            $d['id'],
        ]);
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        $stmt = getDB()->prepare("UPDATE clientes SET estado=? WHERE id_cliente=?");
        return $stmt->execute([$estado, $id]);
    }
}
