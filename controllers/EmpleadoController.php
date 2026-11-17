<?php
// ============================================================
//  SOLDYMEG — EmpleadoController  (Fase 5)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/EmpleadoModel.php';

header('Content-Type: application/json');

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'planillas', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'        && $method === 'GET'  => listar(),
    $action === 'obtener'       && $method === 'GET'  => obtener(),
    $action === 'crear'         && $method === 'POST' => crear($sesion),
    $action === 'actualizar'    && $method === 'POST' => actualizar($sesion),
    $action === 'cambiar_estado'&& $method === 'POST' => cambiarEstado($sesion),
    $action === 'foto'          && $method === 'POST' => subirFoto($sesion),
    $action === 'foto_quitar'   && $method === 'POST' => quitarFoto($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function listar(): void {
    $estado    = $_GET['estado']    ?? 'activo';
    $ubicacion  = $_GET['ubicacion']  ?? '';
    $empresa_id = (int)($_GET['empresa_id'] ?? 0);
    responder(200, ['ok' => true, 'data' => EmpleadoModel::listar($estado, $ubicacion, $empresa_id)]);
}
function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $e  = EmpleadoModel::obtener($id);
    if (!$e) { responder(404, ['error' => 'Empleado no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $e]);
}
function crear(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    if (empty($d['nombres']) || empty($d['apellidos'])) { responder(400, ['error' => 'Nombres y apellidos son requeridos']); return; }
    try {
        $id = EmpleadoModel::crear($d, $sesion['usuario_id']);
        responder(201, ['ok' => true, 'id' => $id]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function actualizar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    try {
        EmpleadoModel::actualizar($id, $d);
        responder(200, ['ok' => true]);
    } catch (Exception $e) { responder(400, ['error' => $e->getMessage()]); }
}
function cambiarEstado(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d      = json_decode(file_get_contents('php://input'), true) ?? [];
    $id     = (int)($d['id'] ?? 0);
    $estado = trim($d['estado'] ?? '');
    if (!$id || !$estado) { responder(400, ['error' => 'id y estado requeridos']); return; }
    EmpleadoModel::cambiarEstado($id, $estado);
    responder(200, ['ok' => true]);
}
function fotoDir(): string { return __DIR__ . '/../uploads/empleados/'; }

function borrarFotoActual(int $id): void {
    $st = getDB()->prepare("SELECT foto FROM empleados WHERE id_empleado = ?"); $st->execute([$id]);
    $f = $st->fetchColumn();
    if ($f && preg_match('#^uploads/empleados/emp_\d+_\d+\.(jpg|png|webp)$#', $f) && is_file(__DIR__ . '/../' . $f)) @unlink(__DIR__ . '/../' . $f);
}
function subirFoto(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id || !EmpleadoModel::obtener($id)) { responder(400, ['error' => 'Empleado no encontrado']); return; }
    if (!preg_match('#^data:image/(jpeg|png|webp);base64,(.+)$#s', (string)($d['imagen'] ?? ''), $m)) { responder(400, ['error' => 'Imagen no válida']); return; }
    $bin = base64_decode($m[2], true);
    if ($bin === false || strlen($bin) > 3 * 1024 * 1024) { responder(400, ['error' => 'La imagen es inválida o supera 3 MB']); return; }
    $info = @getimagesizeFromString($bin);
    $ext = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'][$info['mime'] ?? ''] ?? null;
    if (!$ext) { responder(400, ['error' => 'El archivo no es una imagen válida']); return; }
    if (!is_dir(fotoDir()) && !@mkdir(fotoDir(), 0755, true)) { responder(500, ['error' => 'No se pudo crear la carpeta uploads/empleados']); return; }
    $nombre = "emp_{$id}_" . time() . ".$ext";
    if (@file_put_contents(fotoDir() . $nombre, $bin) === false) { responder(500, ['error' => 'No se pudo guardar la foto (revisa permisos de uploads/empleados)']); return; }
    borrarFotoActual($id);
    getDB()->prepare("UPDATE empleados SET foto = ? WHERE id_empleado = ?")->execute(["uploads/empleados/$nombre", $id]);
    responder(200, ['ok' => true, 'foto' => "uploads/empleados/$nombre"]);
}
function quitarFoto(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'planillas', 'puede_editar');
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'id requerido']); return; }
    borrarFotoActual($id);
    getDB()->prepare("UPDATE empleados SET foto = NULL WHERE id_empleado = ?")->execute([$id]);
    responder(200, ['ok' => true]);
}
function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
