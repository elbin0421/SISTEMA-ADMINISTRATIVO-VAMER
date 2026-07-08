<?php
// ============================================================
//  SOLDYMEG — OrdenesController  (usa OrdenModel + OrdenService)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/OrdenModel.php';
require_once __DIR__ . '/../services/OrdenService.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'           && $method === 'GET'  => listar(),
    $action === 'obtener'          && $method === 'GET'  => obtener(),
    $action === 'tecnicos'         && $method === 'GET'  => tecnicos(),
    $action === 'crear'            && $method === 'POST' => crear($sesion),
    $action === 'editar'           && $method === 'POST' => editar($sesion),
    $action === 'cambiar_estado'   && $method === 'POST' => cambiarEstado($sesion),
    $action === 'agregar_material' && $method === 'POST' => agregarMaterial($sesion),
    $action === 'quitar_material'  && $method === 'POST' => quitarMaterial($sesion),
    $action === 'agregar_mo'       && $method === 'POST' => agregarManoObra($sesion),
    $action === 'quitar_mo'        && $method === 'POST' => quitarManoObra($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    $estado = $_GET['estado'] ?? '';
    responder(200, ['ok' => true, 'data' => OrdenModel::listar($estado)]);
}

function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $ot = OrdenModel::obtener($id);
    if (!$ot) { responder(404, ['error' => 'Orden no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $ot]);
}

function tecnicos(): void {
    try {
        responder(200, ['ok' => true, 'data' => OrdenModel::tecnicos()]);
    } catch (Exception $e) {
        responder(200, ['ok' => true, 'data' => []]);
    }
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_crear');
    $d         = json_decode(file_get_contents('php://input'), true) ?? [];
    $clienteId = (int)($d['cliente_id'] ?? 0);
    $desc      = trim($d['descripcion_trabajo'] ?? '');
    if (!$clienteId || !$desc) {
        responder(400, ['error' => 'Cliente y descripcion son requeridos.']); return;
    }
    $pdo = getDB();
    $pdo->prepare("
        INSERT INTO ordenes_trabajo
          (numero_orden, fecha_apertura, cliente_id, usuario_id,
           placa, marca, modelo, anio, color, kilometraje,
           numero_motor, numero_chasis, descripcion_trabajo, estado, observaciones)
        VALUES ('TEMP',?,?,?,?,?,?,?,?,?,?,?,?,'borrador',?)
    ")->execute([
        $d['fecha_apertura']     ?? date('Y-m-d'),
        $clienteId,
        $sesion['usuario_id'],
        trim($d['placa']         ?? ''),
        trim($d['marca']         ?? ''),
        trim($d['modelo']        ?? ''),
        ($d['anio']              ?? null) ?: null,
        trim($d['color']         ?? ''),
        ($d['kilometraje']       ?? null) ?: null,
        trim($d['numero_motor']  ?? ''),
        trim($d['numero_chasis'] ?? ''),
        $desc,
        trim($d['observaciones'] ?? ''),
    ]);
    $newId   = (int)$pdo->lastInsertId();
    $tecnicos = $d['tecnicos'] ?? [];
    if (!empty($tecnicos)) {
        $st = $pdo->prepare("INSERT IGNORE INTO orden_tecnicos (orden_id, empleado_id) VALUES (?,?)");
        foreach ($tecnicos as $empId) { $st->execute([$newId, (int)$empId]); }
    }
    responder(201, ['ok' => true, 'id' => $newId]);
}

function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    $ot = OrdenModel::obtener($id);
    if (!$ot) { responder(404, ['error' => 'Orden no encontrada']); return; }
    if (in_array($ot['estado'], ['facturada', 'anulada'])) {
        responder(400, ['error' => 'No se puede editar una OT facturada o anulada.']); return;
    }
    $pdo = getDB();
    $pdo->prepare("
        UPDATE ordenes_trabajo SET
          cliente_id=?, fecha_apertura=?,
          placa=?, marca=?, modelo=?, anio=?, color=?, kilometraje=?,
          numero_motor=?, numero_chasis=?, descripcion_trabajo=?, observaciones=?
        WHERE id_orden=?
    ")->execute([
        (int)($d['cliente_id']       ?? 0),
        $d['fecha_apertura']         ?? date('Y-m-d'),
        trim($d['placa']             ?? ''),
        trim($d['marca']             ?? ''),
        trim($d['modelo']            ?? ''),
        ($d['anio']                  ?? null) ?: null,
        trim($d['color']             ?? ''),
        ($d['kilometraje']           ?? null) ?: null,
        trim($d['numero_motor']      ?? ''),
        trim($d['numero_chasis']     ?? ''),
        trim($d['descripcion_trabajo'] ?? ''),
        trim($d['observaciones']     ?? ''),
        $id,
    ]);
    // Técnicos: borrar y reinsertar
    $pdo->prepare("DELETE FROM orden_tecnicos WHERE orden_id=?")->execute([$id]);
    $tecnicos = $d['tecnicos'] ?? [];
    if (!empty($tecnicos)) {
        $st = $pdo->prepare("INSERT IGNORE INTO orden_tecnicos (orden_id, empleado_id) VALUES (?,?)");
        foreach ($tecnicos as $empId) { $st->execute([$id, (int)$empId]); }
    }
    responder(200, ['ok' => true]);
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']    ?? 0);
    $estado = trim($d['estado'] ?? '');
    if (!$id || !$estado) { responder(400, ['error' => 'id y estado requeridos.']); return; }
    try {
        $res = OrdenService::cambiarEstado($id, $estado);
        responder(200, ['ok' => true, 'data' => $res]);
    } catch (Exception $e) {
        responder(400, ['error' => $e->getMessage()]);
    }
}

function agregarMaterial(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $ordId  = (int)($d['orden_id']       ?? 0);
    $matId  = (int)($d['material_id']    ?? 0);
    $cant   = (float)($d['cantidad']     ?? 0);
    $precio = (float)($d['precio_unitario'] ?? 0);
    if (!$ordId || !$matId || $cant <= 0) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    $pdo = getDB();
    $mat = $pdo->prepare("SELECT stock, nombre FROM materiales WHERE id_material=?");
    $mat->execute([$matId]);
    $row = $mat->fetch();
    if (!$row) { responder(404, ['error' => 'Material no encontrado.']); return; }
    if ($row['stock'] < $cant) {
        responder(400, ['error' => "Stock insuficiente de '{$row['nombre']}'. Disponible: {$row['stock']}"]); return;
    }
    // ¿Ya existe el material en esta OT?
    $existe = $pdo->prepare("SELECT id_detalle_om, cantidad FROM detalle_orden_materiales WHERE orden_id=? AND material_id=?");
    $existe->execute([$ordId, $matId]);
    $linea = $existe->fetch();
    if ($linea) {
        // Actualizar cantidad y descontar manualmente (trigger solo actúa en INSERT)
        $nuevaCant = $linea['cantidad'] + $cant;
        $pdo->prepare("UPDATE detalle_orden_materiales SET cantidad=?, subtotal=? WHERE id_detalle_om=?")
            ->execute([$nuevaCant, $nuevaCant * $precio, $linea['id_detalle_om']]);
        $pdo->prepare("UPDATE materiales SET stock = stock - ? WHERE id_material=?")->execute([$cant, $matId]);
        $pdo->prepare("
            INSERT INTO movimientos_inventario
              (material_id, tipo, cantidad, costo_unitario, tipo_referencia, referencia_id, usuario_id, observaciones)
            SELECT ?, 'salida', ?, ?, 'orden_trabajo', ot.id_orden, ot.usuario_id, CONCAT('OT ', ot.numero_orden)
            FROM ordenes_trabajo ot WHERE ot.id_orden = ?
        ")->execute([$matId, $cant, $precio, $ordId]);
    } else {
        // Insert nuevo — el trigger maneja inventario automáticamente
        $pdo->prepare("INSERT INTO detalle_orden_materiales (orden_id, material_id, cantidad, precio_unitario, subtotal) VALUES (?,?,?,?,?)")
            ->execute([$ordId, $matId, $cant, $precio, $cant * $precio]);
    }
    responder(201, ['ok' => true]);
}

function quitarMaterial(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    OrdenModel::quitarMaterial($id);
    // El trigger trg_ot_revertir_inventario devuelve el stock automáticamente
    responder(200, ['ok' => true]);
}

function agregarManoObra(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d     = json_decode(file_get_contents('php://input'), true) ?? [];
    $ordId = (int)($d['orden_id']   ?? 0);
    $desc  = trim($d['descripcion'] ?? '');
    $dias  = (float)($d['dias']     ?? 1);
    $tarifa = (float)($d['tarifa_dia'] ?? 0);
    if (!$ordId || !$desc) { responder(400, ['error' => 'Datos incompletos.']); return; }
    $sub = isset($d['subtotal_override']) ? (float)$d['subtotal_override'] : round($dias * $tarifa * 1.35, 2);
    OrdenModel::agregarManoObra($ordId, $desc, $dias, $tarifa, $sub);
    responder(201, ['ok' => true]);
}

function quitarManoObra(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'ordenes_trabajo', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    OrdenModel::quitarManoObra($id);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
