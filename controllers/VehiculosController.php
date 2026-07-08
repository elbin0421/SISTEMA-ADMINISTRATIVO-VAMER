<?php
// ============================================================
//  SOLDYMEG — VehiculosController
//  Gestión de vehículos ligados a clientes
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
header('Content-Type: application/json');

$sesion = requireAuth();

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'          && $method === 'GET'  => listar(),
    $action === 'por_cliente'     && $method === 'GET'  => porCliente(),
    $action === 'obtener'         && $method === 'GET'  => obtener(),
    $action === 'por_placa'       && $method === 'GET'  => porPlaca(),
    $action === 'crear'           && $method === 'POST' => crear($sesion),
    $action === 'editar'          && $method === 'POST' => editar($sesion),
    $action === 'eliminar'        && $method === 'POST' => eliminar($sesion),
    $action === 'cambiar_estado'  && $method === 'POST' => cambiarEstado($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $stmt = getDB()->query("
        SELECT v.*, c.nombre AS cliente
        FROM vehiculos v
        JOIN clientes c ON c.id_cliente = v.cliente_id
        WHERE v.estado = 'activo'
        ORDER BY v.placa
    ");
    responder(200, ['ok' => true, 'data' => $stmt->fetchAll()]);
}

function porCliente(): void {
    $clienteId = (int)($_GET['cliente_id'] ?? 0);
    if (!$clienteId) { responder(400, ['error' => 'cliente_id requerido']); return; }
    $stmt = getDB()->prepare("
        SELECT id_vehiculo, placa, marca, modelo, anio, color, numero_motor, numero_chasis
        FROM vehiculos
        WHERE cliente_id = ? AND estado = 'activo'
        ORDER BY placa
    ");
    $stmt->execute([$clienteId]);
    responder(200, ['ok' => true, 'data' => $stmt->fetchAll()]);
}

function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $stmt = getDB()->prepare("SELECT * FROM vehiculos WHERE id_vehiculo = ?");
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) { responder(404, ['error' => 'Vehículo no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function porPlaca(): void {
    $placa = trim($_GET['placa'] ?? '');
    if (!$placa) { responder(400, ['error' => 'placa requerida']); return; }
    $stmt = getDB()->prepare("
        SELECT v.*, c.nombre AS cliente
        FROM vehiculos v
        JOIN clientes c ON c.id_cliente = v.cliente_id
        WHERE v.placa = ?
        LIMIT 1
    ");
    $stmt->execute([$placa]);
    $row = $stmt->fetch();
    if (!$row) { responder(404, ['error' => 'Placa no encontrada']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function crear(array $sesion): void {
    $d         = json_decode(file_get_contents('php://input'), true) ?? [];
    $clienteId = (int)($d['cliente_id'] ?? 0);
    $placa     = trim($d['placa'] ?? '');
    if (!$clienteId || !$placa) {
        responder(400, ['error' => 'cliente_id y placa son requeridos.']); return;
    }
    $pdo = getDB();
    // Verificar placa única
    $ex = $pdo->prepare("SELECT id_vehiculo FROM vehiculos WHERE placa = ?");
    $ex->execute([$placa]);
    if ($ex->fetch()) { responder(409, ['error' => 'La placa ya está registrada.']); return; }

    $pdo->prepare("
        INSERT INTO vehiculos (cliente_id, placa, marca, modelo, anio, color, numero_motor, numero_chasis, observaciones)
        VALUES (?,?,?,?,?,?,?,?,?)
    ")->execute([
        $clienteId,
        strtoupper($placa),
        trim($d['marca']           ?? ''),
        trim($d['modelo']          ?? ''),
        ($d['anio']                ?? null) ?: null,
        trim($d['color']           ?? ''),
        trim($d['numero_motor']    ?? ''),
        trim($d['numero_chasis']   ?? ''),
        trim($d['observaciones']   ?? ''),
    ]);
    responder(201, ['ok' => true, 'id' => (int)$pdo->lastInsertId()]);
}

function editar(array $sesion): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    getDB()->prepare("
        UPDATE vehiculos SET
          cliente_id=?, placa=?, marca=?, modelo=?, anio=?, color=?,
          numero_motor=?, numero_chasis=?, observaciones=?
        WHERE id_vehiculo=?
    ")->execute([
        (int)($d['cliente_id']      ?? 0),
        strtoupper(trim($d['placa'] ?? '')),
        trim($d['marca']            ?? ''),
        trim($d['modelo']           ?? ''),
        ($d['anio']                 ?? null) ?: null,
        trim($d['color']            ?? ''),
        trim($d['numero_motor']     ?? ''),
        trim($d['numero_chasis']    ?? ''),
        trim($d['observaciones']    ?? ''),
        $id,
    ]);
    responder(200, ['ok' => true]);
}

function eliminar(array $sesion): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    getDB()->prepare("UPDATE vehiculos SET estado='inactivo' WHERE id_vehiculo=?")->execute([$id]);
    responder(200, ['ok' => true]);
}

function cambiarEstado(array $sesion): void {
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = trim($d['estado']  ?? '');
    if (!$id || !in_array($estado, ['activo','inactivo'])) {
        responder(400, ['error' => 'Datos inválidos.']); return;
    }
    getDB()->prepare("UPDATE vehiculos SET estado=? WHERE id_vehiculo=?")->execute([$estado, $id]);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
