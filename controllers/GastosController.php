<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/GastosModel.php';

header('Content-Type: application/json');
$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'gastos', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'          && $method === 'GET'  => listar(),
    $action === 'obtener'         && $method === 'GET'  => obtener(),
    $action === 'crear'           && $method === 'POST' => crear($sesion),
    $action === 'actualizar'      && $method === 'POST' => actualizar(),
    $action === 'eliminar'        && $method === 'POST' => eliminar(),
    $action === 'resumen'         && $method === 'GET'  => resumen(),
    $action === 'declarar_mes'    && $method === 'POST' => marcarDeclarado(),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $filtros = ['mes'=>$_GET['mes']??'','anio'=>$_GET['anio']??'','estado'=>$_GET['estado']??''];
    responder(200, ['ok' => true, 'data' => GastosModel::listar($filtros)]);
}

function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $g  = GastosModel::obtener($id);
    if (!$g) { responder(404, ['error' => 'No encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $g]);
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'gastos', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];

    if (empty($d['nombre_proveedor'])) { responder(400, ['error' => 'Proveedor requerido']); return; }
    if (empty($d['fecha']))            { responder(400, ['error' => 'Fecha requerida']);      return; }

    // Aceptar tanto items[] como descripcion+subtotal legacy
    $items = $d['items'] ?? [];
    if (empty($items)) {
        if (empty($d['descripcion']) || empty($d['subtotal'])) {
            responder(400, ['error' => 'Agrega al menos un ítem con descripción y monto.']); return;
        }
        // Compatibilidad legacy: convertir a items
        $items = [['descripcion' => $d['descripcion'], 'cantidad' => 1, 'monto' => (float)$d['subtotal']]];
        $d['items'] = $items;
    }

    try {
        $id = GastosModel::crear($d, $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function actualizar(): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }

    $items = $d['items'] ?? [];
    if (empty($items) && !empty($d['descripcion'])) {
        $d['items'] = [['descripcion' => $d['descripcion'], 'cantidad' => 1, 'monto' => (float)$d['subtotal']]];
    }

    try { GastosModel::actualizar($id, $d); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function eliminar(): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    try { GastosModel::eliminar($id); responder(200, ['ok' => true]); }
    catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}

function resumen(): void {
    $mes  = (int)($_GET['mes']  ?? 0);
    $anio = (int)($_GET['anio'] ?? 0);
    if (!$mes || !$anio) { responder(400, ['error' => 'mes y anio requeridos']); return; }
    responder(200, ['ok' => true, 'data' => GastosModel::resumen($mes, $anio)]);
}

function marcarDeclarado(): void {
    $d    = json_decode(file_get_contents('php://input'), true) ?? [];
    $mes  = (int)($d['mes']  ?? 0);
    $anio = (int)($d['anio'] ?? 0);
    if (!$mes || !$anio) { responder(400, ['error' => 'mes y anio requeridos']); return; }
    $n = GastosModel::declararMes($mes, $anio);
    responder(200, ['ok' => true, 'actualizados' => $n]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
