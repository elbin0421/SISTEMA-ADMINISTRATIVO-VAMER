<?php
// ============================================================
//  SOLDYMEG — ComprasController  (usa CompraModel + ProveedorModel)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/CompraModel.php';
require_once __DIR__ . '/../models/ProveedorModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'compras', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'          && $method === 'GET'  => listar(),
    $action === 'obtener'         && $method === 'GET'  => obtener(),
    $action === 'proveedores'     && $method === 'GET'  => proveedores(),
    $action === 'prov_obtener'    && $method === 'GET'  => provObtener(),
    $action === 'crear'           && $method === 'POST' => crear($sesion),
    $action === 'cambiar_estado'  && $method === 'POST' => cambiarEstado($sesion),
    $action === 'editar' && $method === 'POST' => editar($sesion),
    $action === 'prov_crear'      && $method === 'POST' => provCrear($sesion),
    $action === 'prov_editar'     && $method === 'POST' => provEditar($sesion),
    $action === 'prov_estado'     && $method === 'POST' => provEstado($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => CompraModel::listar()]);
}

function obtener(): void {
    $id     = (int)($_GET['id'] ?? 0);
    $compra = CompraModel::obtener($id);
    if (!$compra) { responder(404, ['error' => 'Compra no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $compra]);
}

function proveedores(): void {
    $estado = $_GET['estado'] ?? 'activo';
    responder(200, ['ok' => true, 'data' => ProveedorModel::listar($estado)]);
}

function provObtener(): void {
    $id  = (int)($_GET['id'] ?? 0);
    $row = ProveedorModel::obtener($id);
    if (!$row) { responder(404, ['error' => 'Proveedor no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function editar(array $sesion): void {
    $d=json_decode(file_get_contents('php://input'),true)??[];
    $id=(int)($d['id']??0);
    if(!$id){responder(400,['error'=>'id requerido']);return;}
    try{CompraModel::actualizar($id,$d);responder(200,['ok'=>true]);}catch(Exception $e){responder(400,['error'=>$e->getMessage()]);}
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'compras', 'puede_crear');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $provId = (int)($d['proveedor_id'] ?? 0);
    $items  = $d['items'] ?? [];
    if (!$provId || empty($items)) {
        responder(400, ['error' => 'Proveedor e items son requeridos.']); return;
    }
    try {
        $id = CompraModel::crear($d, $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id]);
    } catch (Exception $e) {
        responder(500, ['error' => 'Error al guardar la compra: ' . $e->getMessage()]);
    }
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'compras', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = $d['estado']       ?? '';
    if (!$id || !in_array($estado, ['pendiente', 'pagada', 'anulada'])) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    CompraModel::cambiarEstado($id, $estado, $d['metodo_pago'] ?? null, trim($d['referencia'] ?? ''));
    responder(200, ['ok' => true]);
}

function provCrear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'compras', 'puede_crear');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $nombre = trim($d['nombre'] ?? '');
    if (!$nombre) { responder(400, ['error' => 'El nombre es requerido.']); return; }
    $id = ProveedorModel::crear($d);
    responder(201, ['ok' => true, 'id' => $id]);
}

function provEditar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'compras', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $nombre = trim($d['nombre'] ?? '');
    if (!$id || !$nombre) { responder(400, ['error' => 'Datos incompletos.']); return; }
    ProveedorModel::editar($d);
    responder(200, ['ok' => true]);
}

function provEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'compras', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $estado = $d['estado'] ?? '';
    if (!$id || !in_array($estado, ['activo','inactivo'])) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    ProveedorModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
