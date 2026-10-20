<?php
// ============================================================
//  VAMER — AsistenciaController (tiempo extra y días faltados)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/AsistenciaModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'asistencia', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'    && $method === 'GET'  => responder(200, ['ok' => true, 'data' => AsistenciaModel::listar($_GET)]),
    $action === 'empleados' && $method === 'GET'  => responder(200, ['ok' => true, 'data' => AsistenciaModel::empleados()]),
    $action === 'obtener'   && $method === 'GET'  => obtener(),
    $action === 'crear'     && $method === 'POST' => guardar($sesion, 'crear'),
    $action === 'editar'    && $method === 'POST' => guardar($sesion, 'editar'),
    $action === 'eliminar'  && $method === 'POST' => eliminar($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function obtener(): void {
    $r = AsistenciaModel::obtener((int)($_GET['id'] ?? 0));
    if (!$r) { responder(404, ['error' => 'Registro no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $r]);
}
function guardar(array $sesion, string $modo): void {
    requirePermiso($sesion['rol_id'], 'asistencia', $modo === 'crear' ? 'puede_crear' : 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try {
        if ($modo === 'crear') {
            $id = AsistenciaModel::crear($d, $sesion['usuario_id']);
            responder(201, ['ok' => true, 'id' => $id]);
        } else {
            AsistenciaModel::editar((int)($d['id'] ?? 0), $d);
            responder(200, ['ok' => true]);
        }
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function eliminar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'asistencia', 'puede_eliminar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try {
        AsistenciaModel::eliminar((int)($d['id'] ?? 0));
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE); exit;
}
