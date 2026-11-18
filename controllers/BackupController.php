<?php
// ============================================================
//  BackupController — Respaldos de la base de datos + Google Drive
//  Solo roles con permiso sobre el módulo 'backups' (Administrador).
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/BackupModel.php';

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'backups', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'            && $method === 'GET'  => listar(),
    $action === 'config_guardar'    && $method === 'POST' => configGuardar($sesion),
    $action === 'crear'             && $method === 'POST' => crearBackup($sesion),
    $action === 'subir_drive'       && $method === 'POST' => subirDrive($sesion),
    $action === 'eliminar'          && $method === 'POST' => eliminarBackup($sesion),
    $action === 'descargar'         && $method === 'GET'  => descargar($sesion),
    $action === 'drive_conectar'    && $method === 'GET'  => driveConectar($sesion),
    $action === 'drive_callback'    && $method === 'GET'  => driveCallback($sesion),
    $action === 'drive_desconectar' && $method === 'POST' => driveDesconectar($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

function redirectUri(): string {
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    $dir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
    return ($https ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $dir . '/BackupController.php?action=drive_callback';
}
function stateCsrf(array $sesion): string { return hash_hmac('sha256', $sesion['token'], DB_NAME . DB_PASS . 'bk-state'); }

function listar(): void {
    $c = BackupModel::config();
    $d = BackupModel::dir();
    responder(200, ['ok' => true,
        'data' => BackupModel::listar(),
        'config' => [
            'google_client_id'    => $c['google_client_id'] ?? '',
            'tiene_secret'        => !empty($c['google_client_secret']),
            'drive_conectado'     => BackupModel::driveConectado($c),
            'google_email'        => $c['google_email'] ?? '',
            'drive_folder_nombre' => $c['drive_folder_nombre'] ?? 'Respaldos VAMER',
            'subir_auto'          => (int)($c['subir_auto'] ?? 0),
            'retencion_local'     => (int)($c['retencion_local'] ?? 10),
        ],
        'redirect_uri' => redirectUri(),
        'carpeta_ok'   => is_dir($d) && is_writable($d),
        'curl_ok'      => function_exists('curl_init'),
        'cron'         => 'php ' . realpath(__DIR__ . '/../scripts/backup_cron.php'),
    ]);
}

function configGuardar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_editar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { BackupModel::guardarConfig($d); responder(200, ['ok' => true]); }
    catch (Throwable $e) { responder(400, ['error' => $e->getMessage()]); }
}

function crearBackup(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try {
        $r = BackupModel::crear((int)$sesion['usuario_id'], 'manual', !empty($d['subir_drive']));
        responder(201, ['ok' => true] + $r);
    } catch (Throwable $e) { responder(400, ['error' => $e->getMessage()]); }
}

function subirDrive(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_crear');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { BackupModel::subirADrive((int)($d['id'] ?? 0)); responder(200, ['ok' => true]); }
    catch (Throwable $e) { responder(400, ['error' => $e->getMessage()]); }
}

function eliminarBackup(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_eliminar');
    $d = json_decode(file_get_contents('php://input'), true) ?? [];
    try { BackupModel::eliminar((int)($d['id'] ?? 0)); responder(200, ['ok' => true]); }
    catch (Throwable $e) { responder(400, ['error' => $e->getMessage()]); }
}

function descargar(array $sesion): void {
    $b = BackupModel::obtener((int)($_GET['id'] ?? 0));
    $f = $b ? BackupModel::rutaArchivo($b) : '';
    if (!$b || !is_file($f)) { responder(404, ['error' => 'El archivo ya no está en el servidor.']); return; }
    header_remove('Content-Type');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . basename($b['archivo']) . '"');
    header('Content-Length: ' . filesize($f));
    header('Cache-Control: no-store');
    readfile($f);
    exit;
}

function driveConectar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_editar');
    try {
        $url = BackupModel::urlAutorizacion(redirectUri(), stateCsrf($sesion));
        header('Location: ' . $url); exit;
    } catch (Throwable $e) { header('Location: ../dashboard.php?bk=' . rawurlencode('error:' . $e->getMessage())); exit; }
}

function driveCallback(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_editar');
    $volver = fn(string $m) => header('Location: ../dashboard.php?bk=' . rawurlencode($m));
    if (!empty($_GET['error'])) { $volver('error:Google canceló la autorización (' . $_GET['error'] . ').'); exit; }
    if (!hash_equals(stateCsrf($sesion), (string)($_GET['state'] ?? ''))) { $volver('error:Solicitud no válida (state). Intenta conectar de nuevo.'); exit; }
    try {
        BackupModel::intercambiarCodigo((string)($_GET['code'] ?? ''), redirectUri());
        $volver('ok:Google Drive conectado correctamente.');
    } catch (Throwable $e) { $volver('error:' . $e->getMessage()); }
    exit;
}

function driveDesconectar(array $sesion): void {
    requirePermiso($sesion['rol_id'], 'backups', 'puede_editar');
    BackupModel::desconectar();
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); header('Content-Type: application/json'); echo json_encode($data); exit;
}
