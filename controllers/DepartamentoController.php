<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/DepartamentoModel.php';

requireAuth();
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar' && $method === 'GET'  => listar(),
    $action === 'crear'  && $method === 'POST' => crear(),
    $action === 'editar' && $method === 'POST' => editar(),
    $action === 'estado' && $method === 'POST' => estado(),
    default => responder(400, ['error' => 'Acción no válida']),
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => DepartamentoModel::listar($_GET['estado'] ?? 'activo')]);
}
function crear(): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['nombre'])) { responder(400, ['error' => 'Nombre requerido']); return; }
    $id = DepartamentoModel::crear($d['nombre'], $d['descripcion'] ?? '');
    responder(201, ['ok' => true, 'id' => $id]);
}
function editar(): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id || empty($d['nombre'])) { responder(400, ['error' => 'Datos incompletos']); return; }
    DepartamentoModel::actualizar($id, $d['nombre'], $d['descripcion'] ?? '');
    responder(200, ['ok' => true]);
}
function estado(): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0); $e = $d['estado'] ?? '';
    if (!$id || !in_array($e, ['activo','inactivo'])) { responder(400, ['error' => 'Inválido']); return; }
    DepartamentoModel::cambiarEstado($id, $e);
    responder(200, ['ok' => true]);
}
function responder(int $code, mixed $data): void {
    http_response_code($code); header('Content-Type: application/json'); echo json_encode($data); exit;
}
