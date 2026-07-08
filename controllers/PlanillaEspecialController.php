<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/PlanillaEspecialModel.php';
require_once __DIR__ . '/../models/PlanillaModel.php';

header('Content-Type: application/json');
$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'planillas', 'puede_ver');

$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action==='listar'        && $method==='GET'  => listar(),
    $action==='obtener'       && $method==='GET'  => obtener(),
    $action==='previsualizar' && $method==='GET'  => previsualizar(),
    $action==='generar'       && $method==='POST' => generar($sesion),
    $action==='cerrar'        && $method==='POST' => cerrar($sesion),
    $action==='eliminar'      && $method==='POST' => eliminar($sesion),
    default => responder(400,['error'=>'Acción no válida'])
};

function listar(): void {
    $tipo = $_GET['tipo'] ?? '';
    responder(200,['ok'=>true,'data'=>PlanillaEspecialModel::listar($tipo)]);
}
function obtener(): void {
    $id = (int)($_GET['id']??0);
    $p  = PlanillaEspecialModel::obtener($id);
    if(!$p){responder(404,['error'=>'No encontrada']);return;}
    responder(200,['ok'=>true,'data'=>$p]);
}
function previsualizar(): void {
    $tipo      = $_GET['tipo']  ?? 'catorceavo';
    $anio      = (int)($_GET['anio'] ?? date('Y'));
    $excluidos = array_filter(array_map('intval', explode(',', $_GET['excluidos'] ?? '')));
    try { responder(200,['ok'=>true,'data'=>PlanillaEspecialModel::previsualizar($tipo,$anio,$excluidos)]); }
    catch(Exception $e){ responder(400,['error'=>$e->getMessage()]); }
}
function generar(array $sesion): void {
    requirePermiso($sesion['rol_id'],'planillas','puede_crear');
    $d         = json_decode(file_get_contents('php://input'),true) ?? [];
    $tipo      = trim($d['tipo'] ?? 'catorceavo');
    $anio      = (int)($d['anio'] ?? 0);
    $excluidos = array_values(array_filter(array_map('intval',$d['excluidos']??[])));
    if(!$anio||!in_array($tipo,['catorceavo','aguinaldo'])){ responder(400,['error'=>'tipo y anio requeridos.']); return; }
    try {
        $id = PlanillaEspecialModel::generar($tipo,$anio,$d['fecha_pago']??date('Y-m-d'),$d['observaciones']??'',$excluidos,$sesion['usuario_id'],(int)($d['excluir_id']??0));
        responder(201,['ok'=>true,'id'=>$id,'data'=>PlanillaEspecialModel::obtener($id)]);
    } catch(Exception $e){ responder(400,['error'=>$e->getMessage()]); }
}
function cerrar(array $sesion): void {
    requirePermiso($sesion['rol_id'],'planillas','puede_editar');
    $d = json_decode(file_get_contents('php://input'),true)??[];
    $id=(int)($d['id']??0);
    if(!$id){responder(400,['error'=>'id requerido']);return;}
    PlanillaModel::cerrar($id);
    responder(200,['ok'=>true]);
}
function eliminar(array $sesion): void {
    requirePermiso($sesion['rol_id'],'planillas','puede_eliminar');
    $d = json_decode(file_get_contents('php://input'),true)??[];
    $id=(int)($d['id']??0);
    try{ PlanillaModel::eliminar($id); responder(200,['ok'=>true]); }
    catch(Exception $e){ responder(400,['error'=>$e->getMessage()]); }
}
function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
