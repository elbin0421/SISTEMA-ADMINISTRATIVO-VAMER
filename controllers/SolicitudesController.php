<?php
// ============================================================
//  SolicitudesController — Solicitud → decisión OT / COT
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/SolicitudModel.php';

header('Content-Type: application/json');
$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'solicitudes', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'    && $method === 'GET'  => responder(200, ['ok' => true, 'data' => SolicitudModel::listar((string)($_GET['estado'] ?? ''))]),
    $action === 'obtener'   && $method === 'GET'  => obtener(),
    $action === 'crear'     && $method === 'POST' => guardar($sesion, false),
    $action === 'editar'    && $method === 'POST' => guardar($sesion, true),
    $action === 'anular'    && $method === 'POST' => anular($sesion),
    $action === 'vincular_ot'  && $method === 'POST' => vincularOT($sesion),
    $action === 'vincular_cot' && $method === 'POST' => vincularCot($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function body(): array { return json_decode(file_get_contents('php://input'), true) ?? []; }

function obtener(): void {
    $s = SolicitudModel::obtener((int)($_GET['id'] ?? 0));
    if (!$s) { responder(404, ['error' => 'Solicitud no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $s]);
}

function guardar(array $sesion, bool $editar): void {
    requirePermiso($sesion['rol_id'], 'solicitudes', $editar ? 'puede_editar' : 'puede_crear');
    $d = body();
    try {
        if ($editar) { SolicitudModel::editar((int)($d['id'] ?? 0), $d); responder(200, ['ok' => true]); }
        else         { $id = SolicitudModel::crear($d, (int)$sesion['usuario_id'], (string)$sesion['nombre']); responder(201, ['ok' => true, 'id' => $id]); }
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function anular(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'solicitudes', 'puede_eliminar');
    try { SolicitudModel::anular((int)(body()['id'] ?? 0)); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function vincularOT(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'solicitudes', 'puede_editar');
    $d = body();
    try { SolicitudModel::vincularOrden((int)($d['id'] ?? 0), (int)($d['orden_id'] ?? 0)); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function vincularCot(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'solicitudes', 'puede_editar');
    $d = body();
    try { SolicitudModel::vincularCotizacion((int)($d['id'] ?? 0), (int)($d['cotizacion_id'] ?? 0)); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}
