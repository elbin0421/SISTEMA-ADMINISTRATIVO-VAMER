<?php
// ============================================================
//  SOLDYMEG — MovimientosController
//  Registro de movimientos de transporte (MAERSK / ALPLA)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/MovimientoModel.php';
require_once __DIR__ . '/../models/EmpleadoModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'movimientos', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'              && $method === 'GET'  => listar(),
    $action === 'obtener'             && $method === 'GET'  => obtener(),
    $action === 'motoristas'          && $method === 'GET'  => motoristas(),
    $action === 'pendientes_cliente'  && $method === 'GET'  => pendientesCliente(),
    $action === 'crear'               && $method === 'POST' => crear($sesion),
    $action === 'editar'              && $method === 'POST' => editar($sesion),
    $action === 'anular'              && $method === 'POST' => anular($sesion),
    default => responder(400, ['error' => 'Acción no válida']),
};

function motoristas(): void {
    // Empleados activos de VAMER (empresa_id = 2) para el selector de motorista
    responder(200, ['ok' => true, 'data' => EmpleadoModel::listar('activo', '', 2)]);
}

function validar(array $d): ?string {
    if (empty($d['tipo']) || !in_array($d['tipo'], ['MAERSK', 'ALPLA'])) {
        return 'El tipo debe ser MAERSK o ALPLA.';
    }
    if (empty($d['fecha'])) return 'La fecha es requerida.';
    if (!isset($d['tarifa']) || (float)$d['tarifa'] < 0) return 'La tarifa es requerida y debe ser válida.';
    return null;
}

function listar(): void {
    $filtros = [
        'tipo'        => $_GET['tipo']        ?? 'todos',
        'estado'      => $_GET['estado']      ?? 'todos',
        'cliente_id'  => $_GET['cliente_id']  ?? null,
        'fecha_desde' => $_GET['fecha_desde'] ?? null,
        'fecha_hasta' => $_GET['fecha_hasta'] ?? null,
        'q'           => trim($_GET['q'] ?? ''),
    ];
    responder(200, ['ok' => true, 'data' => MovimientoModel::listar($filtros)]);
}

function obtener(): void {
    $row = MovimientoModel::obtener((int)($_GET['id'] ?? 0));
    if (!$row) { responder(404, ['error' => 'Movimiento no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function pendientesCliente(): void {
    $clienteId = (int)($_GET['cliente_id'] ?? 0);
    if (!$clienteId) { responder(400, ['error' => 'cliente_id requerido']); return; }
    responder(200, ['ok' => true, 'data' => MovimientoModel::pendientesPorCliente($clienteId)]);
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'movimientos', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $err = validar($d);
    if ($err) { responder(400, ['error' => $err]); return; }
    $id = MovimientoModel::crear($d, $sesion['usuario_id']);
    responder(201, ['ok' => true, 'id' => $id]);
}

function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'movimientos', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    $err = validar($d);
    if ($err) { responder(400, ['error' => $err]); return; }
    try {
        MovimientoModel::editar($id, $d);
        responder(200, ['ok' => true]);
    } catch (\Exception $e) {
        responder(409, ['error' => $e->getMessage()]);
    }
}

function anular(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'movimientos', 'puede_eliminar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    try {
        MovimientoModel::anular($id);
        responder(200, ['ok' => true]);
    } catch (\Exception $e) {
        responder(409, ['error' => $e->getMessage()]);
    }
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
