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
