<?php
// ============================================================
//  SOLDYMEG — UsuarioModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class UsuarioModel {

    public static function listar(): array {
        $stmt = getDB()->query("
            SELECT u.id_usuario, u.nombre, u.usuario, u.estado, u.fecha_creacion,
                   r.nombre AS rol, u.rol_id, u.empleado_id,
                   CONCAT(e.nombres, ' ', e.apellidos) AS empleado_nombre
            FROM usuarios u
            JOIN roles r ON r.id_rol = u.rol_id
            LEFT JOIN empleados e ON e.id_empleado = u.empleado_id
            ORDER BY u.nombre
        ");
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $stmt = getDB()->prepare("
            SELECT u.id_usuario, u.nombre, u.usuario, u.rol_id, u.estado, u.empleado_id
            FROM usuarios u WHERE u.id_usuario = ?
        ");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function listarEmpleados(): array {
        $pdo  = getDB();
        // Detectar estructura: nueva (nombres+apellidos) o antigua (nombre)
        $cols = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        if ($cols) {
            $sql = "SELECT id_empleado, CONCAT(nombres, ' ', apellidos) AS nombre
                    FROM empleados WHERE estado = 'activo' ORDER BY apellidos, nombres";
        } else {
            $sql = "SELECT id_empleado, nombre
                    FROM empleados WHERE estado = 'activo' ORDER BY nombre";
        }
        $stmt = $pdo->query($sql);
        return $stmt->fetchAll();
    }

    public static function existeUsuario(string $usuario): bool {
        $stmt = getDB()->prepare("SELECT id_usuario FROM usuarios WHERE usuario = ?");
        $stmt->execute([$usuario]);
        return (bool)$stmt->fetch();
    }

    public static function crear(array $d): int {
        $pdo  = getDB();
        $hash = password_hash($d['password'], PASSWORD_BCRYPT);
        $pdo->prepare(
            "INSERT INTO usuarios (nombre, usuario, contrasena, rol_id, empleado_id) VALUES (?,?,?,?,?)"
        )->execute([
            trim($d['nombre']),
            trim($d['usuario']),
            $hash,
            (int)$d['rol_id'],
            ($d['empleado_id'] ?? null) ?: null,
        ]);
        return (int)$pdo->lastInsertId();
    }

    public static function editar(array $d): bool {
        $pdo = getDB();
        $empId = ($d['empleado_id'] ?? null) ?: null;
        if (!empty($d['password'])) {
            $hash = password_hash($d['password'], PASSWORD_BCRYPT);
            return $pdo->prepare(
                "UPDATE usuarios SET nombre=?, rol_id=?, contrasena=?, empleado_id=? WHERE id_usuario=?"
            )->execute([trim($d['nombre']), (int)$d['rol_id'], $hash, $empId, (int)$d['id']]);
        }
        return $pdo->prepare(
            "UPDATE usuarios SET nombre=?, rol_id=?, empleado_id=? WHERE id_usuario=?"
        )->execute([trim($d['nombre']), (int)$d['rol_id'], $empId, (int)$d['id']]);
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        $stmt = getDB()->prepare("UPDATE usuarios SET estado=? WHERE id_usuario=?");
        return $stmt->execute([$estado, $id]);
    }
}
