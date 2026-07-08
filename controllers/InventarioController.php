<?php
// ============================================================
//  SOLDYMEG — InventarioController  (usa InventarioModel)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/InventarioModel.php';
header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'inventario', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'     && $method === 'GET'  => listar(),
    $action === 'obtener'    && $method === 'GET'  => obtener(),
    $action === 'buscar'     && $method === 'GET'  => buscar(),
    $action === 'categorias' && $method === 'GET'  => categorias(),
    $action === 'kardex'     && $method === 'GET'  => kardex(),
    $action === 'stock_bajo' && $method === 'GET'  => stockBajo(),
    $action === 'crear'      && $method === 'POST' => crear($sesion),
    $action === 'editar'     && $method === 'POST' => editar($sesion),
    $action === 'ajuste'     && $method === 'POST' => ajusteStock($sesion),
    $action === 'estado'     && $method === 'POST' => cambiarEstado($sesion),
    default => responder(400, ['error' => 'Accion no valida'])
};

function listar(): void {
    responder(200, ['ok' => true, 'data' => InventarioModel::listar()]);
}

function obtener(): void {
    $id  = (int)($_GET['id'] ?? 0);
    $row = InventarioModel::obtener($id);
    if (!$row) { responder(404, ['error' => 'Material no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

function buscar(): void {
    $q = trim($_GET['q'] ?? '');
    responder(200, ['ok' => true, 'data' => InventarioModel::buscar($q)]);
}

function categorias(): void {
    responder(200, ['ok' => true, 'data' => InventarioModel::categorias()]);
}

function kardex(): void {
    $id = (int)($_GET['id'] ?? 0);
    responder(200, ['ok' => true, 'data' => InventarioModel::kardex($id)]);
}

function stockBajo(): void {
    responder(200, ['ok' => true, 'data' => InventarioModel::stockBajo()]);
}

function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'inventario', 'puede_crear');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $nombre = trim($d['nombre'] ?? '');
    if (!$nombre) { responder(400, ['error' => 'El nombre es requerido.']); return; }

    $pdo = getDB();
    // Código secuencial con verificación de unicidad
    $last = $pdo->query("
        SELECT codigo FROM materiales
        WHERE codigo REGEXP '^[0-9]+$'
        ORDER BY CAST(codigo AS UNSIGNED) DESC LIMIT 1
    ")->fetch();
    $sig    = $last ? (int)$last['codigo'] + 1 : 1;
    $codigo = str_pad($sig, 5, '0', STR_PAD_LEFT);
    while ($pdo->prepare("SELECT id_material FROM materiales WHERE codigo=?")->execute([$codigo]) &&
           $pdo->query("SELECT id_material FROM materiales WHERE codigo='$codigo'")->fetch()) {
        $sig++;
        $codigo = str_pad($sig, 5, '0', STR_PAD_LEFT);
    }

    $pdo->prepare("
        INSERT INTO materiales
          (codigo, nombre, descripcion, categoria_id, unidad_medida,
           precio_compra, precio_venta, stock, stock_minimo)
        VALUES (?,?,?,?,?,?,?,?,?)
    ")->execute([
        $codigo,
        $nombre,
        trim($d['descripcion']   ?? ''),
        ($d['categoria_id']      ?? null) ?: null,
        $d['unidad_medida']      ?? 'unidad',
        (float)($d['precio_compra'] ?? 0),
        (float)($d['precio_venta']  ?? 0),
        (float)($d['stock']         ?? 0),
        (float)($d['stock_minimo']  ?? 0),
    ]);
    $newId = (int)$pdo->lastInsertId();

    // Stock inicial → movimiento en kardex
    $stockInicial = (float)($d['stock'] ?? 0);
    if ($stockInicial > 0) {
        $pdo->prepare("
            INSERT INTO movimientos_inventario
              (material_id, tipo, cantidad, costo_unitario, tipo_referencia, usuario_id, observaciones)
            VALUES (?, 'entrada', ?, ?, 'ajuste_manual', ?, 'Stock inicial')
        ")->execute([$newId, $stockInicial, (float)($d['precio_compra'] ?? 0), $sesion['usuario_id']]);
    }
    responder(201, ['ok' => true, 'id' => $newId]);
}

function editar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'inventario', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']    ?? 0);
    $nombre = trim($d['nombre'] ?? '');
    if (!$id || !$nombre) { responder(400, ['error' => 'Datos incompletos.']); return; }
    // Código nunca se edita — se preserva el original
    getDB()->prepare("
        UPDATE materiales
        SET nombre=?, descripcion=?, categoria_id=?, unidad_medida=?,
            precio_compra=?, precio_venta=?, stock_minimo=?
        WHERE id_material=?
    ")->execute([
        $nombre,
        trim($d['descripcion']  ?? ''),
        ($d['categoria_id']     ?? null) ?: null,
        $d['unidad_medida']     ?? 'unidad',
        (float)($d['precio_compra'] ?? 0),
        (float)($d['precio_venta']  ?? 0),
        (float)($d['stock_minimo']  ?? 0),
        $id,
    ]);
    responder(200, ['ok' => true]);
}

function ajusteStock(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'inventario', 'puede_editar');
    $d    = json_decode(file_get_contents('php://input'), true) ?? [];
    $id   = (int)($d['id']       ?? 0);
    $tipo = $d['tipo']           ?? '';
    $cant = (float)($d['cantidad'] ?? 0);
    $obs  = trim($d['observaciones'] ?? 'Ajuste manual');
    if (!$id || !in_array($tipo, ['entrada', 'salida']) || $cant <= 0) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    $pdo = getDB();
    $mat = $pdo->prepare("SELECT stock, nombre FROM materiales WHERE id_material=?");
    $mat->execute([$id]);
    $row = $mat->fetch();
    if (!$row) { responder(404, ['error' => 'Material no encontrado']); return; }
    if ($tipo === 'salida' && $row['stock'] < $cant) {
        responder(400, ['error' => "Stock insuficiente de '{$row['nombre']}'. Disponible: {$row['stock']}"]); return;
    }
    InventarioModel::ajusteManual($id, $tipo, $cant, $obs, $sesion['usuario_id']);
    responder(200, ['ok' => true]);
}

function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'inventario', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id']     ?? 0);
    $estado = $d['estado']       ?? '';
    if (!$id || !in_array($estado, ['activo', 'inactivo'])) {
        responder(400, ['error' => 'Datos invalidos.']); return;
    }
    InventarioModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
