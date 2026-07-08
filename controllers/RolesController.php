<?php
// ============================================================
//  SOLDYMEG — RolesController  (usa RolModel)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/RolModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'roles', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'           && $method === 'GET'  => listar(),
    $action === 'permisos'         && $method === 'GET'  => obtenerPermisos(),
    $action === 'guardar_permisos' && $method === 'POST' => guardarPermisos($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => RolModel::listar()]);
}

function obtenerPermisos(): void {
    $rol_id = (int)($_GET['rol_id'] ?? 0);
    responder(200, ['ok' => true, 'data' => RolModel::permisos($rol_id)]);
}

function guardarPermisos(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'roles', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $rol_id = (int)($d['rol_id'] ?? 0);
    $perms  = $d['permisos'] ?? [];
    if (!$rol_id || empty($perms)) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    RolModel::guardarPermisos($rol_id, $perms);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
