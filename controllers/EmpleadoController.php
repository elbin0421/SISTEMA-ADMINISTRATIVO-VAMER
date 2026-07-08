<?php
// ============================================================
//  SOLDYMEG — EmpleadoController  (Fase 5)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/EmpleadoModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'planillas', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'        && $method === 'GET'  => listar(),
    $action === 'obtener'       && $method === 'GET'  => obtener(),
    $action === 'crear'         && $method === 'POST' => crear($sesion),
    $action === 'actualizar'    && $method === 'POST' => actualizar($sesion),
    $action === 'cambiar_estado'&& $method === 'POST' => cambiarEstado($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $estado    = $_GET['estado']    ?? 'activo';
    $ubicacion  = $_GET['ubicacion']  ?? '';
    $empresa_id = (int)($_GET['empresa_id'] ?? 0);
    responder(200, ['ok' => true, 'data' => EmpleadoModel::listar($estado, $ubicacion, $empresa_id)]);
}
function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $e  = EmpleadoModel::obtener($id);
    if (!$e) { responder(404, ['error' => 'Empleado no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $e]);
}
function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['nombres']) || empty($d['apellidos'])) { responder(400, ['error' => 'Nombres y apellidos son requeridos']); return; }
    try {
        $id = EmpleadoModel::crear($d, $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function actualizar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    try {
        EmpleadoModel::actualizar($id, $d);
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $estado = trim($d['estado'] ?? '');
    if (!$id || !$estado) { responder(400, ['error' => 'id y estado requeridos']); return; }
    EmpleadoModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}
function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
