<?php
// ============================================================
//  SOLDYMEG — Middleware de autenticación
//  Incluir al inicio de cada página protegida
// ============================================================

require_once __DIR__ . '/../config/db.php';

define('SESSION_DURATION_HOURS', 8);

function auth_check(): array {
    $token = $_COOKIE['soldymeg_token'] ?? '';

    if (empty($token)) {
        auth_redirect();
    }

    $db  = getDB();
    $sql = "SELECT s.id_sesion, s.usuario_id, s.fecha_expiracion, s.estado,
                   u.nombre, u.usuario, u.estado AS usuario_estado,
                   r.nombre AS rol, r.id_rol
            FROM sesiones_admin s
            JOIN usuarios u ON u.id_usuario = s.usuario_id
            JOIN roles    r ON r.id_rol     = u.rol_id
            WHERE s.token = ? AND s.estado = 'activa'
            LIMIT 1";
    $stmt = $db->prepare($sql);
    $stmt->execute([$token]);
    $sesion = $stmt->fetch();

    if (!$sesion) {
        auth_redirect();
    }

    // Verificar expiración
    if (strtotime($sesion['fecha_expiracion']) < time()) {
        $db->prepare("UPDATE sesiones_admin SET estado = 'expirada' WHERE token = ?")
           ->execute([$token]);
        auth_redirect();
    }

    // Verificar que el usuario siga activo
    if ($sesion['usuario_estado'] !== 'activo') {
        auth_redirect();
    }

    // Refrescar fecha_ultimo_acceso
    $db->prepare("UPDATE sesiones_admin SET fecha_ultimo_acceso = NOW() WHERE token = ?")
       ->execute([$token]);

    return $sesion;
}

function auth_permisos(int $rol_id): array {
    $db   = getDB();
    $stmt = $db->prepare("SELECT modulo, puede_ver, puede_crear, puede_editar, puede_eliminar
                          FROM permisos WHERE rol_id = ?");
    $stmt->execute([$rol_id]);
    $rows = $stmt->fetchAll();

    $permisos = [];
    foreach ($rows as $row) {
        $permisos[$row['modulo']] = [
            'ver'      => (bool)$row['puede_ver'],
            'crear'    => (bool)$row['puede_crear'],
            'editar'   => (bool)$row['puede_editar'],
            'eliminar' => (bool)$row['puede_eliminar'],
        ];
    }
    return $permisos;
}

function auth_puede(array $permisos, string $modulo, string $accion = 'ver'): bool {
    return $permisos[$modulo][$accion] ?? false;
}

function auth_redirect(): void {
    setcookie('soldymeg_token', '', time() - 3600, '/');
    header('Location: /admin/login.php');
    exit;
}
