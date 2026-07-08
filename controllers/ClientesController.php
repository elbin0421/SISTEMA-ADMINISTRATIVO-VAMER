<?php
// ============================================================
//  SOLDYMEG — ClientesController  (usa ClienteModel)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/ClienteModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'clientes', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'  && $method === 'GET'  => listar(),
    $action === 'obtener' && $method === 'GET'  => obtener(),
    $action === 'buscar'  && $method === 'GET'  => buscar(),
    $action === 'crear'   && $method === 'POST' => crear($sesion),
    $action === 'editar'  && $method === 'POST' => editar($sesion),
    $action === 'estado'  && $method === 'POST' => cambiarEstado($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    $estado = $_GET['estado'] ?? 'activo';
    responder(200, ['ok' => true, 'data' => ClienteModel::listar($estado)]);
}

function obtener(): void {
    $id  = (int)($_GET['id'] ?? 0);
    $row = ClienteModel::obtener($id);
    if (!$row) { responder(404, ['error' => 'Cliente no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function buscar(): void {
    $q = trim($_GET['q'] ?? '');
    responder(200, ['ok' => true, 'data' => ClienteModel::buscar($q)]);
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'clientes', 'puede_crear');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $nombre = trim($d['nombre'] ?? '');
    if (!$nombre) { responder(400, ['error' => 'El nombre es requerido.']); return; }
    $id = ClienteModel::crear($d);
    responder(201, ['ok' => true, 'id' => $id]);
}

function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'clientes', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $nombre = trim($d['nombre'] ?? '');
    if (!$id || !$nombre) { responder(400, ['error' => 'Datos incompletos.']); return; }
    ClienteModel::editar($d);
    responder(200, ['ok' => true]);
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'clientes', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = $d['estado'] ?? '';
    if (!$id || !in_array($estado, ['activo', 'inactivo'])) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    ClienteModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
