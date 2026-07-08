<?php
// ============================================================
//  SOLDYMEG — CatalogoPreciosController
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/CatalogoPreciosModel.php';

$sesion = requireAuth();
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'          && $method === 'GET'  => listar(),
    $action === 'obtener'         && $method === 'GET'  => obtener(),
    $action === 'siguiente_codigo'&& $method === 'GET'  => siguienteCodigo(),
    $action === 'existe'          && $method === 'GET'  => existe(),
    $action === 'crear'           && $method === 'POST' => crear(),
    $action === 'editar'          && $method === 'POST' => editar(),
    $action === 'estado'          && $method === 'POST' => estado(),
    default => responder(400, ['error' => 'Acción no válida']),
};

function siguienteCodigo(): void {
    $stmt = getDB()->query("SELECT MAX(CAST(codigo AS UNSIGNED)) AS max_cod FROM catalogo_precios WHERE codigo REGEXP '^[0-9]+$'");
    $row  = $stmt->fetch();
    $next = (int)($row['max_cod'] ?? 0) + 1;
    responder(200, ['ok' => true, 'codigo' => str_pad($next, 4, '0', STR_PAD_LEFT)]);
}

function existe(): void {
    $desc = strtolower(trim($_GET['descripcion'] ?? ''));
    $excId = (int)($_GET['excluir_id'] ?? 0);
    if (!$desc) { responder(200, ['existe' => false]); return; }
    $sql  = "SELECT id_catalogo FROM catalogo_precios WHERE LOWER(descripcion) = ? AND estado = 'activo'";
    $params = [$desc];
    if ($excId) { $sql .= " AND id_catalogo != ?"; $params[] = $excId; }
    $stmt = getDB()->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    responder(200, ['existe' => (bool)$row, 'id' => $row['id_catalogo'] ?? null]);
}


function listar(): void {
    $est = $_GET['estado'] ?? 'activo';
    $q   = trim($_GET['q'] ?? '');
    responder(200, ['ok' => true, 'data' => CatalogoPreciosModel::listar($est, $q)]);
}

function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $r  = CatalogoPreciosModel::obtener($id);
    if (!$r) { responder(404, ['error' => 'No encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $r]);
}

function crear(): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['descripcion']) || !isset($d['precio'])) {
        responder(400, ['error' => 'Descripción y precio son requeridos']); return;
    }
    $id = CatalogoPreciosModel::crear($d);
    responder(201, ['ok' => true, 'id' => $id]);
}

function editar(): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id || empty($d['descripcion']) || !isset($d['precio'])) {
        responder(400, ['error' => 'Datos incompletos']); return;
    }
    CatalogoPreciosModel::actualizar($id, $d);
    responder(200, ['ok' => true]);
}

function estado(): void {
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $estado = $d['estado'] ?? '';
    if (!$id || !in_array($estado, ['activo', 'inactivo'])) {
        responder(400, ['error' => 'Datos inválidos']); return;
    }
    CatalogoPreciosModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}

function responder(int $code, mixed $data): void {
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}
