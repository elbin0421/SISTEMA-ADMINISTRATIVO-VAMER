<?php
// ============================================================
//  CarnetsController — Carnets de empleados (RRHH)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/CarnetModel.php';

header('Content-Type: application/json');
$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'carnets', 'puede_ver');

$action = $_GET['action'] ?? 'empleados';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'empleados'       && $method === 'GET'  => responder(200, ['ok' => true, 'data' => CarnetModel::empleados()]),
    $action === 'obtener'         && $method === 'GET'  => obtener($sesion),
    $action === 'guardar'         && $method === 'POST' => guardar($sesion),
    $action === 'imagen'          && $method === 'POST' => imagen($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function urlFicha(string $token): string {
    $cfg = @include __DIR__ . '/../config/carnets.php';
    $base = is_array($cfg) ? rtrim(trim((string)($cfg['base_url'] ?? '')), '/') : '';
    if (preg_match('#^https?://[^\s]+$#i', $base)) return $base . '/ficha.php?t=' . $token;
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    $dir = rtrim(str_replace('\\', '/', dirname(dirname($_SERVER['SCRIPT_NAME']))), '/');
    return ($https ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $dir . '/ficha.php?t=' . $token;
}

function obtener(array $sesion): void {
    $id = (int)($_GET['empleado_id'] ?? 0);
    $e = CarnetModel::empleado($id);
    if (!$e) { responder(404, ['error' => 'Empleado no encontrado']); return; }
    $c = CarnetModel::obtenerOCrear($id, (int)$sesion['usuario_id']);
    $emp = CarnetModel::empresaConfig($e['empresa_id'] ? (int)$e['empresa_id'] : null);
    responder(200, ['ok' => true, 'empleado' => $e, 'carnet' => $c, 'empresa' => $emp, 'ficha_url' => urlFicha($c['token'])]);
}

function guardar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'carnets', 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['empleado_id'] ?? 0);
    $e = CarnetModel::empleado($id);
    if (!$e) { responder(404, ['error' => 'Empleado no encontrado']); return; }
    try {
        CarnetModel::guardar($id, $d, (int)$sesion['usuario_id']);
        if ($e['empresa_id'] && isset($d['empresa'])) CarnetModel::guardarEmpresa((int)$e['empresa_id'], (array)$d['empresa']);
        responder(200, ['ok' => true]);
    } catch (Throwable $ex) { responder(400, ['error' => $ex->getMessage()]); }
}

function imagen(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'carnets', 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try {
        $ruta = CarnetModel::guardarImagen((string)($d['tipo'] ?? ''), (int)($d['empleado_id'] ?? 0), !empty($d['quitar']) ? null : (string)($d['imagen'] ?? ''));
        responder(200, ['ok' => true, 'ruta' => $ruta]);
    } catch (Throwable $ex) { responder(400, ['error' => $ex->getMessage()]); }
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
