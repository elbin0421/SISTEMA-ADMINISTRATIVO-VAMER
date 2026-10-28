<?php
// ============================================================
//  SOLDYMEG — RolModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class RolModel {

    public static function listar(): array {
        $stmt = getDB()->query("SELECT * FROM roles ORDER BY id_rol");
        return $stmt->fetchAll();
    }

    private static function validarNombre(string $nombre, int $excluirId = 0): string {
        $nombre = trim(preg_replace('/\s+/', ' ', $nombre));
        if (mb_strlen($nombre) < 2 || mb_strlen($nombre) > 50) throw new Exception('El nombre del rol debe tener entre 2 y 50 caracteres.');
        $st = getDB()->prepare("SELECT id_rol FROM roles WHERE LOWER(nombre) = LOWER(?) AND id_rol <> ?");
        $st->execute([$nombre, $excluirId]);
        if ($st->fetch()) throw new Exception('Ya existe un rol con ese nombre.');
        return $nombre;
    }

    /** Crea un rol; opcionalmente copia los permisos de otro rol. */
    public static function crear(string $nombre, int $copiarDe = 0): int {
        $nombre = self::validarNombre($nombre);
        $pdo = getDB();
        $pdo->beginTransaction();
        try {
            $pdo->prepare("INSERT INTO roles (nombre) VALUES (?)")->execute([$nombre]);
            $id = (int)$pdo->lastInsertId();
            if ($copiarDe > 0) {
                $pdo->prepare("
                    INSERT INTO permisos (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
                    SELECT ?, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar FROM permisos WHERE rol_id = ?
                ")->execute([$id, $copiarDe]);
            }
            $pdo->commit();
            return $id;
        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $e;
        }
    }

    public static function renombrar(int $id, string $nombre): void {
        if ($id === 1) throw new Exception('El rol Administrador no se puede renombrar.');
        $st = getDB()->prepare("SELECT 1 FROM roles WHERE id_rol = ?");
        $st->execute([$id]);
        if (!$st->fetch()) throw new Exception('Rol no encontrado.');
        $nombre = self::validarNombre($nombre, $id);
        getDB()->prepare("UPDATE roles SET nombre = ? WHERE id_rol = ?")->execute([$nombre, $id]);
    }

    public static function eliminar(int $id): void {
        if ($id === 1) throw new Exception('El rol Administrador no se puede eliminar.');
        $pdo = getDB();
        $st = $pdo->prepare("SELECT 1 FROM roles WHERE id_rol = ?");
        $st->execute([$id]);
        if (!$st->fetch()) throw new Exception('Rol no encontrado.');
        $u = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE rol_id = ?");
        $u->execute([$id]);
        $n = (int)$u->fetchColumn();
        if ($n > 0) throw new Exception("No se puede eliminar: hay $n usuario(s) con este rol. Cámbialos de rol primero.");
        $pdo->beginTransaction();
        try {
            $pdo->prepare("DELETE FROM permisos WHERE rol_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM roles WHERE id_rol = ?")->execute([$id]);
            $pdo->commit();
        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $e;
        }
    }

    public static function permisos(int $rol_id): array {
        $stmt = getDB()->prepare(
            "SELECT * FROM permisos WHERE rol_id = ? ORDER BY modulo"
        );
        $stmt->execute([$rol_id]);
        return $stmt->fetchAll();
    }

    /**
     * Guarda (inserta o actualiza) todos los permisos de un rol.
     * Usa ON DUPLICATE KEY para ser idempotente.
     */
    public static function guardarPermisos(int $rol_id, array $permisos): bool {
        $stmt = getDB()->prepare("
            INSERT INTO permisos (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
            VALUES (?,?,?,?,?,?)
            ON DUPLICATE KEY UPDATE
              puede_ver      = VALUES(puede_ver),
              puede_crear    = VALUES(puede_crear),
              puede_editar   = VALUES(puede_editar),
              puede_eliminar = VALUES(puede_eliminar)
        ");
        foreach ($permisos as $p) {
            $stmt->execute([
                $rol_id,
                $p['modulo'],
                (int)($p['puede_ver']      ?? 0),
                (int)($p['puede_crear']    ?? 0),
                (int)($p['puede_editar']   ?? 0),
                (int)($p['puede_eliminar'] ?? 0),
            ]);
        }
        return true;
    }
}
