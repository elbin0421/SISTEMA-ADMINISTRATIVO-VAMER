<?php
// ============================================================
//  SOLDYMEG — CotizacionesController
//  Punto de entrada API para el módulo de Cotizaciones
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/CotizacionModel.php';
require_once __DIR__ . '/../services/CotizacionService.php';
require_once __DIR__ . '/../helpers/Calculos.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'cotizaciones', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'                 && $method === 'GET'  => listar(),
    $action === 'listar_cliente'         && $method === 'GET'  => listarPorCliente(),
    $action === 'obtener'                && $method === 'GET'  => obtener(),
    $action === 'desde_ot'               && $method === 'POST' => desdeOT($sesion),
    $action === 'directa'                && $method === 'POST' => directa($sesion),
    $action === 'cambiar_estado'         && $method === 'POST' => cambiarEstado($sesion),
    $action === 'actualizar_referencias' && $method === 'POST' => actualizarReferencias($sesion),
    $action === 'previsualizar'          && $method === 'POST' => previsualizar(),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $estado = $_GET['estado'] ?? '';
    responder(200, ['ok' => true, 'data' => CotizacionModel::listar($estado)]);
}

function listarPorCliente(): void {
    $cliente_id = (int)($_GET['cliente_id'] ?? 0);
    if (!$cliente_id) { responder(400, ['error' => 'cliente_id requerido']); return; }
    // Cotizaciones aprobadas del cliente sin factura activa
    $pdo  = getDB();
    $stmt = $pdo->prepare("
        SELECT cot.id_cotizacion, cot.numero_cotizacion, cot.fecha,
               cot.cliente_id, cot.estado, cot.total,
               cot.ot_cliente, cot.orden_compra,
               cl.nombre AS cliente
        FROM cotizaciones cot
        JOIN clientes cl ON cl.id_cliente = cot.cliente_id
        WHERE cot.cliente_id = ?
          AND cot.estado = 'aprobada'
          AND NOT EXISTS (
              SELECT 1 FROM facturas f
              WHERE f.cotizacion_id = cot.id_cotizacion AND f.estado != 'anulada'
          )
        ORDER BY cot.fecha DESC, cot.id_cotizacion DESC
    ");
    $stmt->execute([$cliente_id]);
    responder(200, ['ok' => true, 'data' => $stmt->fetchAll()]);
}

function obtener(): void {
    $id  = (int)($_GET['id'] ?? 0);
    $cot = CotizacionModel::obtener($id);
    if (!$cot) { responder(404, ['error' => 'Cotización no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $cot]);
}

function desdeOT(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'cotizaciones', 'puede_crear');
    $d        = json_decode(file_get_contents('php://input'), true) ?? [];
    $orden_id = (int)($d['orden_id'] ?? 0);
    $vigencia = (int)($d['vigencia_dias'] ?? 15);
    if (!$orden_id) { responder(400, ['error' => 'orden_id requerido']); return; }
    try {
        $res = CotizacionService::generarDesdeOT($orden_id, $sesion['usuario_id'], $vigencia);
        responder(201, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function directa(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'cotizaciones', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['cliente_id'])) { responder(400, ['error' => 'cliente_id requerido']); return; }
    if (empty($d['items']))      { responder(400, ['error' => 'items requeridos']);       return; }
    try {
        $res = CotizacionService::generarDirecta($d, $sesion['usuario_id']);
        responder(201, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'cotizaciones', 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = trim($d['estado']  ?? '');
    $motivo = trim($d['motivo_rechazo'] ?? '');
    if (!$id || !$estado) { responder(400, ['error' => 'id y estado requeridos']); return; }
    try {
        $res = CotizacionService::cambiarEstado($id, $estado, $motivo ?: null, $sesion);
        responder(200, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function actualizarReferencias(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'cotizaciones', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    CotizacionModel::actualizarReferencias(
        $id,
        $d['ot_cliente']   ?? '',
        $d['orden_compra'] ?? ''
    );
    responder(200, ['ok' => true]);
}

function previsualizar(): void {
    $d     = json_decode(file_get_contents('php://input'), true) ?? [];
    $mats  = (float)($d['total_materiales'] ?? 0);
    $mo    = (float)($d['total_mano_obra']   ?? 0);
    $calc  = Calculos::calcularCotizacion($mats, $mo);
    responder(200, ['ok' => true, 'data' => $calc]);
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
