<?php
// ============================================================
//  VAMER — MarcacionesController (Asistencia diaria)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/MarcacionModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'marcaciones', 'puede_ver');

$action = $_GET['action'] ?? 'periodo';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'periodo'       && $method === 'GET'  => periodo(),
    $action === 'catalogos'     && $method === 'GET'  => responder(200, ['ok' => true, 'empleados' => MarcacionModel::empleadosActivos(), 'departamentos' => MarcacionModel::departamentos()]),
    $action === 'config'        && $method === 'GET'  => responder(200, ['ok' => true, 'data' => MarcacionModel::config()]),
    $action === 'config_guardar'&& $method === 'POST' => escribir($sesion, 'puede_editar', fn($d) => MarcacionModel::guardarConfig($d)),
    $action === 'guardar'       && $method === 'POST' => escribir($sesion, 'puede_crear',  fn($d) => MarcacionModel::guardar($d, $sesion['usuario_id'])),
    $action === 'marcar_ahora'  && $method === 'POST' => marcarAhora($sesion),
    $action === 'lote'          && $method === 'POST' => lote($sesion),
    $action === 'enviar_tiempo_extra' && $method === 'POST' => enviarTiempoExtra($sesion),
    $action === 'justificar'    && $method === 'POST' => escribir($sesion, 'puede_editar', fn($d) => MarcacionModel::justificar($d, $sesion['usuario_id'])),
    $action === 'eliminar'      && $method === 'POST' => escribir($sesion, 'puede_eliminar', fn($d) => MarcacionModel::eliminar((int)($d['id'] ?? 0))),
    default => responder(400, ['error' => 'Acción no válida'])
};

function fechaOk(string $f): bool { return (bool)preg_match('/^\d{4}-\d{2}-\d{2}$/', $f) && strtotime($f) !== false; }

function periodo(): void {
    $desde = $_GET['desde'] ?? ''; $hasta = $_GET['hasta'] ?? '';
    $hoy   = fechaOk($_GET['hoy'] ?? '') ? $_GET['hoy'] : date('Y-m-d');
    if (!fechaOk($desde) || !fechaOk($hasta) || $hasta < $desde) { responder(400, ['error' => 'Rango de fechas inválido']); return; }
    if ((strtotime($hasta) - strtotime($desde)) / 86400 > 62)    { responder(400, ['error' => 'El rango máximo es de 2 meses']); return; }
    responder(200, ['ok' => true, 'data' => MarcacionModel::periodo($desde, $hasta, $hoy, (int)($_GET['empresa_id'] ?? 0), (int)($_GET['departamento_id'] ?? 0))]);
}

function escribir(array $sesion, string $permiso, callable $fn): void {
    requirePermiso($sesion['rol_id'], 'marcaciones', $permiso);
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { $fn($d); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function marcarAhora(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'marcaciones', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { responder(200, ['ok' => true, 'mensaje' => MarcacionModel::marcarAhora($d, $sesion['usuario_id'])]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function lote(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'marcaciones', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { responder(200, ['ok' => true] + MarcacionModel::lote($d, $sesion['usuario_id'])); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function enviarTiempoExtra(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'marcaciones', 'puede_ver');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $aplicar = !empty($d['aplicar']);
    if ($aplicar) requirePermiso($sesion['rol_id'], 'asistencia', 'puede_crear');
    if (!fechaOk($d['desde'] ?? '') || !fechaOk($d['hasta'] ?? '') || ($d['hasta'] ?? '') < ($d['desde'] ?? '')) { responder(400, ['error' => 'Rango de fechas inválido']); return; }
    if ((strtotime($d['hasta']) - strtotime($d['desde'])) / 86400 > 62) { responder(400, ['error' => 'El rango máximo es de 2 meses']); return; }
    if (!fechaOk($d['hoy'] ?? '')) $d['hoy'] = date('Y-m-d');
    try { responder(200, ['ok' => true] + MarcacionModel::sincronizarTiempoExtra($d, $sesion['usuario_id'], $aplicar)); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE); exit;
}
