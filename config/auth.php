<?php
// ============================================================
//  SOLDYMEG — Middleware de autenticación
//  Incluir al inicio de cada página protegida
// ============================================================

require_once __DIR__ . '/db.php';

function getTokenFromRequest(): ?string {
    // Primero busca en cookie (para páginas HTML)
    if (!empty($_COOKIE['sm_token'])) {
        return $_COOKIE['sm_token'];
    }
    // Luego en header Authorization (para llamadas AJAX/API)
    $headers = getallheaders();
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            if (strpos($value, 'Bearer ') === 0) {
                return substr($value, 7);
            }
        }
    }
    return null;
}

function verificarSesion(): array {
    $token = getTokenFromRequest();
    if (!$token) {
        return ['valido' => false, 'motivo' => 'sin_token'];
    }

    $pdo = getDB();
    $stmt = $pdo->prepare("
        SELECT s.id_sesion, s.usuario_id, s.estado, s.fecha_expiracion,
               u.nombre, u.usuario, u.estado AS estado_usuario,
               r.nombre AS rol, u.rol_id
        FROM sesiones_admin s
        JOIN usuarios u ON u.id_usuario = s.usuario_id
        JOIN roles r ON r.id_rol = u.rol_id
        WHERE s.token = ?
        LIMIT 1
    ");
    $stmt->execute([$token]);
    $sesion = $stmt->fetch();

    if (!$sesion) {
        return ['valido' => false, 'motivo' => 'token_invalido'];
    }
    if ($sesion['estado'] !== 'activa') {
        return ['valido' => false, 'motivo' => 'sesion_' . $sesion['estado']];
    }
    if ($sesion['estado_usuario'] !== 'activo') {
        return ['valido' => false, 'motivo' => 'usuario_inactivo'];
    }
    if (strtotime($sesion['fecha_expiracion']) < time()) {
        // Marcar como expirada
        $pdo->prepare("UPDATE sesiones_admin SET estado='expirada' WHERE id_sesion=?")
            ->execute([$sesion['id_sesion']]);
        return ['valido' => false, 'motivo' => 'sesion_expirada'];
    }

    // Actualizar último acceso
    $pdo->prepare("UPDATE sesiones_admin SET fecha_ultimo_acceso=NOW() WHERE id_sesion=?")
        ->execute([$sesion['id_sesion']]);

    return [
        'valido'      => true,
        'id_sesion'   => $sesion['id_sesion'],
        'usuario_id'  => $sesion['usuario_id'],
        'nombre'      => $sesion['nombre'],
        'usuario'     => $sesion['usuario'],
        'rol'         => $sesion['rol'],
        'rol_id'      => $sesion['rol_id'],
        'token'       => $token,
    ];
}

function requireAuth(): array {
    $sesion = verificarSesion();
    if (!$sesion['valido']) {
        // Si es petición AJAX devuelve JSON, si no redirige
        if (!empty($_SERVER['HTTP_X_REQUESTED_WITH'])) {
            http_response_code(401);
            die(json_encode(['error' => 'No autorizado', 'motivo' => $sesion['motivo']]));
        }
        header('Location: /admin/login.html');
        exit;
    }
    return $sesion;
}

function tienePermiso(int $rol_id, string $modulo, string $accion = 'puede_ver'): bool {
    $pdo = getDB();
    $stmt = $pdo->prepare("
        SELECT $accion FROM permisos
        WHERE rol_id = ? AND modulo = ?
        LIMIT 1
    ");
    $stmt->execute([$rol_id, $modulo]);
    $row = $stmt->fetch();
    return $row ? (bool)$row[$accion] : false;
}

function requirePermiso(int $rol_id, string $modulo, string $accion = 'puede_ver'): void {
    if (!tienePermiso($rol_id, $modulo, $accion)) {
        http_response_code(403);
        die(json_encode(['error' => 'Sin permisos para esta acción.']));
    }
}
