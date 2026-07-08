<?php
// ============================================================
//  SOLDYMEG — Diagnóstico de sesión
//  1. Sube a /admin/debug.php
//  2. Primero intenta hacer login normal en login.html
//  3. Luego abre http://localhost/admin/debug.php
//  4. ELIMINA este archivo después
// ============================================================

require_once __DIR__ . '/config/db.php';

header('Content-Type: text/html; charset=utf-8');
echo '<pre style="font-family:monospace;font-size:14px;padding:20px">';
echo "=== SOLDYMEG DEBUG ===\n\n";

// 1. Conexión a BD
try {
    $pdo = getDB();
    echo "✅ Conexión BD: OK\n";
} catch(Exception $e) {
    echo "❌ Conexión BD: " . $e->getMessage() . "\n";
    exit;
}

// 2. Usuario admin
$u = $pdo->query("SELECT id_usuario, nombre, usuario, estado, rol_id, LEFT(contrasena,10) as hash_inicio FROM usuarios WHERE usuario='admin'")->fetch();
echo "✅ Usuario admin: " . print_r($u, true) . "\n";

// 3. Verificar contraseña
$full = $pdo->query("SELECT contrasena FROM usuarios WHERE usuario='admin'")->fetch();
$ok   = password_verify('Admin2025*', $full['contrasena']);
echo ($ok ? "✅" : "❌") . " password_verify('Admin2025*'): " . ($ok ? "CORRECTO" : "FALLA") . "\n\n";

// 4. Sesiones activas
$sesiones = $pdo->query("SELECT id_sesion, usuario_id, LEFT(token,16) as token_inicio, estado, fecha_expiracion FROM sesiones_admin ORDER BY id_sesion DESC LIMIT 5")->fetchAll();
echo "=== ÚLTIMAS SESIONES ===\n";
print_r($sesiones);

// 5. Cookie
echo "\n=== COOKIES RECIBIDAS ===\n";
print_r($_COOKIE);

// 6. Headers
echo "\n=== HEADERS RECIBIDOS ===\n";
$headers = getallheaders();
foreach ($headers as $k => $v) {
    echo "$k: $v\n";
}

// 7. Simular verificarSesion manualmente
echo "\n=== TEST MANUAL verificarSesion ===\n";
$token = $_COOKIE['sm_token'] ?? null;
echo "Token en cookie: " . ($token ? substr($token,0,16).'...' : 'NO HAY COOKIE') . "\n";

if ($token) {
    $stmt = $pdo->prepare("
        SELECT s.id_sesion, s.estado, s.fecha_expiracion,
               u.nombre, u.estado AS estado_usuario
        FROM sesiones_admin s
        JOIN usuarios u ON u.id_usuario = s.usuario_id
        WHERE s.token = ?
    ");
    $stmt->execute([$token]);
    $row = $stmt->fetch();
    if ($row) {
        echo "✅ Token encontrado en BD\n";
        echo "   Estado sesión: " . $row['estado'] . "\n";
        echo "   Expira: " . $row['fecha_expiracion'] . "\n";
        echo "   Ahora:  " . date('Y-m-d H:i:s') . "\n";
        echo "   Expirado: " . (strtotime($row['fecha_expiracion']) < time() ? "SÍ ❌" : "NO ✅") . "\n";
        echo "   Estado usuario: " . $row['estado_usuario'] . "\n";
    } else {
        echo "❌ Token NO encontrado en BD\n";
    }
}

echo "\n=== PHP SESSION PATH ===\n";
echo "Cookie path del setcookie: /admin\n";
echo "URL actual: " . $_SERVER['REQUEST_URI'] . "\n";

echo '</pre>';
