<?php
// ============================================================
//  SOLDYMEG — PagosController  (Fase 4)
//  Módulo dedicado de Pagos de Clientes
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/PagoModel.php';
require_once __DIR__ . '/../models/ClienteModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'pagos', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'           && $method === 'GET'  => listar(),
    $action === 'kpis'             && $method === 'GET'  => kpis(),
    $action === 'cuentas_cobrar'   && $method === 'GET'  => cuentasCobrar(),
    $action === 'historial_cliente'&& $method === 'GET'  => historialCliente(),
    $action === 'anular'           && $method === 'POST' => anular($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $filtros = [
        'cliente_id'  => (int)($_GET['cliente_id'] ?? 0) ?: 0,
        'mes'         => $_GET['mes']          ?? '',
        'anio'        => $_GET['anio']         ?? '',
        'metodo_pago' => $_GET['metodo_pago']  ?? '',
        'factura_id'  => (int)($_GET['factura_id'] ?? 0) ?: 0,
    ];
    responder(200, ['ok' => true, 'data' => PagoModel::listarCompleto($filtros)]);
}

function kpis(): void {
    responder(200, ['ok' => true, 'data' => PagoModel::kpis()]);
}

function cuentasCobrar(): void {
    $cliente_id = (int)($_GET['cliente_id'] ?? 0);
    responder(200, ['ok' => true, 'data' => PagoModel::cuentasPorCobrar($cliente_id)]);
}

function historialCliente(): void {
    $cliente_id = (int)($_GET['cliente_id'] ?? 0);
    if (!$cliente_id) { responder(400, ['error' => 'cliente_id requerido']); return; }
    responder(200, ['ok' => true, 'data' => PagoModel::historialCliente($cliente_id)]);
}

function anular(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'pagos', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    try {
        PagoModel::anular($id, $sesion['usuario_id']);
        responder(200, ['ok' => true]);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
