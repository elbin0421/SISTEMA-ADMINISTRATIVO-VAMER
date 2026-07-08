<?php
// ============================================================
//  SOLDYMEG — UsuariosController  (usa UsuarioModel)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/UsuarioModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'usuarios', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'    && $method === 'GET'  => listar(),
    $action === 'obtener'   && $method === 'GET'  => obtener(),
    $action === 'empleados' && $method === 'GET'  => listarEmpleados(),
    $action === 'crear'     && $method === 'POST' => crear($sesion),
    $action === 'editar'    && $method === 'POST' => editar($sesion),
    $action === 'estado'    && $method === 'POST' => cambiarEstado($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => UsuarioModel::listar()]);
}

function listarEmpleados(): void {
    responder(200, ['ok' => true, 'data' => UsuarioModel::listarEmpleados()]);
}

function obtener(): void {
    $id  = (int)($_GET['id'] ?? 0);
    $row = UsuarioModel::obtener($id);
    if (!$row) { responder(404, ['error' => 'Usuario no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'usuarios', 'puede_crear');
    $d       = json_decode(file_get_contents('php://input'), true) ?? [];
    $nombre  = trim($d['nombre']   ?? '');
    $usuario = trim($d['usuario']  ?? '');
    $pass    = trim($d['password'] ?? '');
    $rol_id  = (int)($d['rol_id']  ?? 0);
    if (!$nombre || !$usuario || !$pass || !$rol_id) {
        responder(400, ['error' => 'Todos los campos son requeridos.']); return;
    }
    if (UsuarioModel::existeUsuario($usuario)) {
        responder(409, ['error' => 'El nombre de usuario ya existe.']); return;
    }
    $id = UsuarioModel::crear([
        'nombre'      => $nombre,
        'usuario'     => $usuario,
        'password'    => $pass,
        'rol_id'      => $rol_id,
        'empleado_id' => $d['empleado_id'] ?? null,
    ]);
    responder(201, ['ok' => true, 'id' => $id]);
}

function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'usuarios', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $nombre = trim($d['nombre']  ?? '');
    $rol_id = (int)($d['rol_id'] ?? 0);
    if (!$id || !$nombre || !$rol_id) {
        responder(400, ['error' => 'Datos incompletos.']); return;
    }
    UsuarioModel::editar([
        'id'          => $id,
        'nombre'      => $nombre,
        'rol_id'      => $rol_id,
        'password'    => $d['password'] ?? '',
        'empleado_id' => $d['empleado_id'] ?? null,
    ]);
    responder(200, ['ok' => true]);
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'usuarios', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = $d['estado'] ?? '';
    if (!$id || !in_array($estado, ['activo', 'inactivo'])) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    if ($id === $sesion['usuario_id']) {
        responder(400, ['error' => 'No puedes desactivar tu propia cuenta.']); return;
    }
    UsuarioModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
