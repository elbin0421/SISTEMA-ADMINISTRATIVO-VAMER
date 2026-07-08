<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';

header('Content-Type: application/json');

$action = $_GET['action'] ?? '';

match($action) {
    'login'     => login(),
    'logout'    => logout(),
    'verificar' => verificar(),
    default     => responder(400, ['error' => 'Accion no valida'])
};

function login(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        responder(405, ['error' => 'Metodo no permitido']);
    }
    $data     = json_decode(file_get_contents('php://input'), true);
    $usuario  = trim($data['usuario']  ?? '');
    $password = trim($data['password'] ?? '');
    if (!$usuario || !$password) {
        responder(400, ['error' => 'Usuario y contrasena son requeridos.']);
    }
    $pdo  = getDB();
    $stmt = $pdo->prepare("
        SELECT u.id_usuario, u.nombre, u.usuario, u.contrasena, u.estado, u.rol_id,
               r.nombre AS rol
        FROM usuarios u
        JOIN roles r ON r.id_rol = u.rol_id
        WHERE u.usuario = ? LIMIT 1
    ");
    $stmt->execute([$usuario]);
    $user = $stmt->fetch();
    if (!$user || !password_verify($password, $user['contrasena'])) {
        responder(401, ['error' => 'Usuario o contrasena incorrectos.']);
    }
    if ($user['estado'] !== 'activo') {
        responder(403, ['error' => 'Tu cuenta esta desactivada. Contacta al administrador.']);
    }
    $token      = bin2hex(random_bytes(32));
    $expiracion = date('Y-m-d H:i:s', time() + SESSION_HOURS * 3600);
    $ip         = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    $ua         = substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255);
    $pdo->prepare("
        INSERT INTO sesiones_admin (usuario_id, token, ip_address, user_agent, fecha_expiracion)
        VALUES (?, ?, ?, ?, ?)
    ")->execute([$user['id_usuario'], $token, $ip, $ua, $expiracion]);
    setcookie('sm_token', $token, [
        'expires'  => time() + SESSION_HOURS * 3600,
        'path'     => '/admin',
        'httponly' => true,
        'samesite' => 'Strict',
    ]);
    responder(200, [
        'ok'      => true,
        'token'   => $token,
        'nombre'  => $user['nombre'],
        'usuario' => $user['usuario'],
        'rol'     => $user['rol'],
        'rol_id'  => $user['rol_id'],
    ]);
}

function logout(): void {
    $sesion = verificarSesion();
    if ($sesion['valido']) {
        getDB()->prepare("UPDATE sesiones_admin SET estado='cerrada' WHERE id_sesion=?")
               ->execute([$sesion['id_sesion']]);
    }
    setcookie('sm_token', '', time() - 3600, '/admin');
    responder(200, ['ok' => true]);
}

function verificar(): void {
    $sesion = verificarSesion();
    if ($sesion['valido']) {
        responder(200, ['ok' => true, 'nombre' => $sesion['nombre'], 'rol' => $sesion['rol']]);
    } else {
        responder(401, ['ok' => false, 'motivo' => $sesion['motivo']]);
    }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
