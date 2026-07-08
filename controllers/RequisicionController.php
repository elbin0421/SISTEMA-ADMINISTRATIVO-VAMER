<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/RequisicionModel.php';

$sesion = requireAuth();
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'           && $method === 'GET'  => listar(),
    $action === 'obtener'          && $method === 'GET'  => obtener(),
    $action === 'siguiente_numero' && $method === 'GET'  => siguienteNumero(),
    $action === 'crear'            && $method === 'POST' => crear($sesion),
    $action === 'editar'           && $method === 'POST' => editar(),
    $action === 'estado'           && $method === 'POST' => estado($sesion),
    default => responder(400, ['error' => 'Acción no válida']),
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => RequisicionModel::listar($_GET['estado'] ?? 'todos', trim($_GET['q'] ?? ''))]);
}
function obtener(): void {
    $r = RequisicionModel::obtener((int)($_GET['id'] ?? 0));
    if (!$r) { responder(404, ['error' => 'No encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $r]);
}
function siguienteNumero(): void {
    responder(200, ['ok' => true, 'numero' => RequisicionModel::siguienteNumero()]);
}
function crear(array $sesion): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $detalle = $d['detalle'] ?? []; unset($d['detalle']);
    if (empty($d['empleado_id']) || empty($d['fecha_solicitud']) || empty($d['departamento'])) {
        responder(400, ['error' => 'Empleado, fecha y departamento son requeridos']); return;
    }
    if (empty($detalle)) { responder(400, ['error' => 'Debe agregar al menos un material']); return; }
    $id = RequisicionModel::crear($d, $detalle, $sesion['usuario_id']);
    responder(201, ['ok' => true, 'id' => $id, 'numero' => RequisicionModel::obtener($id)['numero']]);
}
function editar(): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0); $detalle = $d['detalle'] ?? []; unset($d['detalle'], $d['id']);
    if (!$id || empty($d['empleado_id']) || empty($d['fecha_solicitud']) || empty($d['departamento'])) {
        responder(400, ['error' => 'Datos incompletos']); return;
    }
    if (empty($detalle)) { responder(400, ['error' => 'Debe agregar al menos un material']); return; }
    RequisicionModel::actualizar($id, $d, $detalle);
    responder(200, ['ok' => true]);
}
function estado(array $sesion): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0); $estado = $d['estado'] ?? '';
    if (!$id || !in_array($estado, ['pendiente','aprobada','despachada','anulada'])) {
        responder(400, ['error' => 'Datos inválidos']); return;
    }
    try {
        RequisicionModel::cambiarEstado($id, $estado, $sesion['usuario_id']);
        responder(200, ['ok' => true]);
    } catch (\Exception $e) {
        responder(409, ['error' => $e->getMessage()]);
    }
}
function responder(int $code, mixed $data): void {
    http_response_code($code); header('Content-Type: application/json'); echo json_encode($data); exit;
}
