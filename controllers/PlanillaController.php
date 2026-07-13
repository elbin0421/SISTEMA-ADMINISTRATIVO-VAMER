<?php
// ============================================================
//  SOLDYMEG — PlanillaController  (Fase 5)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/PlanillaModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'planillas', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'        && $method === 'GET'  => listar(),
    $action === 'obtener'       && $method === 'GET'  => obtener(),
    $action === 'previsualizar' && $method === 'GET'  => previsualizar(),
    $action === 'generar'       && $method === 'POST' => generar($sesion),
    $action === 'cerrar'        && $method === 'POST' => cerrar($sesion),
    $action === 'eliminar'      && $method === 'POST' => eliminar($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $empresa_id = (int)($_GET['empresa_id'] ?? 0);
    responder(200, ['ok' => true, 'data' => PlanillaModel::listar($empresa_id)]);
}
function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $p  = PlanillaModel::obtener($id);
    if (!$p) { responder(404, ['error' => 'Planilla no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $p]);
}
function previsualizar(): void {
    $mes      = (int)($_GET['mes']      ?? date('m'));
    $anio     = (int)($_GET['anio']     ?? date('Y'));
    $quincena   = $_GET['quincena']         ?? '1ra';
    $empresa_id = (int)($_GET['empresa_id'] ?? 0);
    try {
        responder(200, ['ok' => true, 'data' => PlanillaModel::previsualizar($mes, $anio, $quincena, [], $empresa_id)]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function generar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $mes      = (int)($d['mes']      ?? 0);
    $anio     = (int)($d['anio']     ?? 0);
    $quincena = trim($d['quincena']  ?? '1ra');
    $excluirId  = (int)($d['excluir_id']  ?? 0);
    $empresa_id = (int)($d['empresa_id']  ?? 0);
    if (!$mes || !$anio) { responder(400, ['error' => 'mes, anio y quincena requeridos']); return; }
    $extrasMap = [];
    foreach (($d['extras'] ?? []) as $item) {
        $empId = (int)($item['empleado_id'] ?? 0);
        if ($empId) $extrasMap[$empId] = $item;
    }
    try {
        $id = PlanillaModel::generar(
            $mes, $anio, $quincena,
            $d['fecha_pago']    ?? date('Y-m-d'),
            $d['observaciones'] ?? '',
            $extrasMap,
            $sesion['usuario_id'],
            $excluirId,
            $empresa_id
        );
        responder(201, ['ok' => true, 'id' => $id, 'data' => PlanillaModel::obtener($id)]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function cerrar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    PlanillaModel::cerrar($id);
    responder(200, ['ok' => true]);
}
function eliminar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_eliminar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    try {
        PlanillaModel::eliminar($id);
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
