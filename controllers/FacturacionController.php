<?php
// ============================================================
//  SOLDYMEG — FacturacionController  (Fase 3)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/FacturaModel.php';
require_once __DIR__ . '/../models/PagoModel.php';
require_once __DIR__ . '/../services/FacturacionService.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'facturacion', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'           && $method === 'GET'  => listar(),
    $action === 'obtener'          && $method === 'GET'  => obtener(),
    $action === 'saldo_pendiente'  && $method === 'GET'  => saldoPendiente(),
    $action === 'libro_ventas'     && $method === 'GET'  => libroVentas(),
    $action === 'kpis'             && $method === 'GET'  => kpis(),
    $action === 'cai_listar'       && $method === 'GET'  => caiListar(),
    $action === 'cai_activo'       && $method === 'GET'  => caiActivo(),
    $action === 'facturar'          && $method === 'POST' => facturar($sesion),
    $action === 'facturar_multiple' && $method === 'POST' => facturarMultiple($sesion),
    $action === 'facturar_directo' && $method === 'POST' => facturarDirecto($sesion),
    $action === 'anular'           && $method === 'POST' => anular($sesion),
    $action === 'registrar_pago'   && $method === 'POST' => registrarPago($sesion),
    $action === 'cai_crear'        && $method === 'POST' => caiCrear($sesion),
    $action === 'cai_inactivar'    && $method === 'POST' => caiInactivar($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function saldoPendiente(): void {
    $id      = (int)($_GET['id'] ?? 0);
    $factura = FacturaModel::obtener($id);
    if (!$factura) { responder(404, ['error' => 'Factura no encontrada']); return; }
    $pagado   = PagoModel::totalPagadoPorFactura($id);
    $pendiente = max(0, (float)$factura['total'] - $pagado);
    responder(200, ['ok' => true, 'pendiente' => $pendiente, 'pagado' => $pagado, 'subtotal' => $factura['subtotal']]);
}

function listar(): void {
    $estado = $_GET['estado'] ?? '';
    responder(200, ['ok' => true, 'data' => FacturaModel::listar($estado)]);
}

function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $f  = FacturaModel::obtener($id);
    if (!$f) { responder(404, ['error' => 'Factura no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $f]);
}

function libroVentas(): void {
    $mes  = $_GET['mes']  ?? date('m');
    $anio = $_GET['anio'] ?? date('Y');
    $data = FacturacionService::libroVentas($mes, $anio);
    responder(200, ['ok' => true, 'data' => $data]);
}

function kpis(): void {
    responder(200, ['ok' => true, 'data' => FacturaModel::kpis()]);
}

function caiListar(): void {
    responder(200, ['ok' => true, 'data' => FacturaModel::listarCAI()]);
}

function caiActivo(): void {
    $cai = FacturaModel::obtenerCAIActivoConEstado();
    responder(200, ['ok' => true, 'data' => $cai]);
}

function caiInactivar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    FacturaModel::inactivarCAI($id);
    responder(200, ['ok' => true, 'msg' => 'CAI inactivado correctamente.']);
}

function facturar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $cotizacion_id = (int)($d['cotizacion_id'] ?? 0);
    if (!$cotizacion_id) { responder(400, ['error' => 'cotizacion_id requerido']); return; }
    try {
        $res = FacturacionService::facturarCotizacion($cotizacion_id, $d, $sesion['usuario_id']);
        responder(201, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function facturarMultiple(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $cotizacion_ids = $d['cotizacion_ids'] ?? [];
    if (empty($cotizacion_ids) || count($cotizacion_ids) < 1) {
        responder(400, ['error' => 'Selecciona al menos una cotización.']); return;
    }
    try {
        $res = FacturacionService::facturarMultiples($cotizacion_ids, $d, $sesion['usuario_id']);
        responder(201, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function facturarDirecto(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $items = $d['items'] ?? [];
    if (empty($d['cliente_id'])) { responder(400, ['error' => 'cliente_id requerido']); return; }
    if (empty($items))           { responder(400, ['error' => 'Debe agregar al menos un ítem']); return; }
    try {
        $res = FacturacionService::crearDirecta($d, $items, $sesion['usuario_id']);
        responder(201, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function anular(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $motivo = trim($d['motivo']  ?? '');
    if (!$id || !$motivo) { responder(400, ['error' => 'id y motivo requeridos']); return; }
    try {
        $res = FacturacionService::anular($id, $motivo, $sesion['usuario_id']);
        responder(200, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function registrarPago(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    $factura_id = (int)($d['factura_id'] ?? 0);
    if (!$factura_id || empty($d['monto']) || empty($d['metodo_pago'])) {
        responder(400, ['error' => 'factura_id, monto y metodo_pago son requeridos']); return;
    }
    try {
        $res = FacturacionService::registrarPago($factura_id, $d, $sesion['usuario_id']);
        responder(200, $res);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function caiCrear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'facturacion', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['cai']) || empty($d['rango_inicio']) || empty($d['rango_fin']) || empty($d['fecha_limite_emision'])) {
        responder(400, ['error' => 'CAI, rango_inicio, rango_fin y fecha_limite_emision son requeridos']); return;
    }
    try {
        $id = FacturaModel::crearCAI($d, $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id]);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function responder(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}
