<?php
// ============================================================
//  VAMER — RecibosController
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/ReciboModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'recibos', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'         && $method === 'GET'  => listar(),
    $action === 'obtener'        && $method === 'GET'  => obtener(),
    $action === 'empleados'      && $method === 'GET'  => responder(200, ['ok' => true, 'data' => ReciboModel::empleados()]),
    $action === 'serie'          && $method === 'GET'  => responder(200, ['ok' => true, 'data' => ReciboModel::serie() ?: null]),
    $action === 'serie_guardar'  && $method === 'POST' => serieGuardar($sesion),
    $action === 'crear'          && $method === 'POST' => crear($sesion),
    $action === 'editar'         && $method === 'POST' => editar($sesion),
    $action === 'anular'         && $method === 'POST' => anular($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function body(): array { return json_decode(file_get_contents('php://input'), true) ?? []; }

function listar(): void {
    responder(200, ['ok' => true, 'data' => ReciboModel::listar($_GET)]);
}
function obtener(): void {
    $r = ReciboModel::obtener((int)($_GET['id'] ?? 0));
    if (!$r) { responder(404, ['error' => 'Recibo no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $r]);
}
function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'recibos', 'puede_crear');
    try {
        $id = ReciboModel::crear(body(), $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id, 'data' => ReciboModel::obtener($id)]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'recibos', 'puede_editar');
    $d = body();
    try {
        ReciboModel::editar((int)($d['id'] ?? 0), $d);
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function anular(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'recibos', 'puede_eliminar');
    $d = body();
    try {
        ReciboModel::anular((int)($d['id'] ?? 0));
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function serieGuardar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'recibos', 'puede_editar');
    try {
        ReciboModel::guardarSerie(body());
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE); exit;
}
