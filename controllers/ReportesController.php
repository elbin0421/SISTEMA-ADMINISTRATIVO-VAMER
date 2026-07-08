<?php
// ============================================================
//  SOLDYMEG — ReportesController  (Fase 5 — Rev.2)
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/PlanillaModel.php';
require_once __DIR__ . '/../models/PagoModel.php';

$sesion = requireAuth();
requirePermiso($sesion['rol_id'], 'reportes', 'puede_ver');

$action = $_GET['action'] ?? '';
$format = $_GET['format'] ?? 'json';

match(true) {
    $action === 'ventas'                                    => reporteVentas($format),
    $action === 'cxc'                                       => reporteCxC($format),
    $action === 'retenciones'                               => reporteRetenciones($format),
    $action === 'planilla_pdf'                              => planillaPDF(),
    $action === 'planilla_excel'                            => planillaExcel(),
    $action === 'inventario' || $action === 'inventario_mov'=> reporteInventario($format),
    $action === 'inventario_stock'                          => inventarioStock($format),
    $action === 'rentabilidad'||$action==='rentabilidad_ot' => reporteRentabilidad($format),
    default => jsonResponder(400, ['error' => 'Accion no valida'])
};

function reporteVentas(string $format): void {
    $mes=$_GET['mes']??''; $anio=$_GET['anio']??date('Y');
    $pdo=getDB();
    $where="WHERE f.estado!='anulada' AND YEAR(f.fecha)=?"; $params=[(int)$anio];
    if($mes){$where.=" AND MONTH(f.fecha)=?";$params[]=(int)$mes;}
    $stmt=$pdo->prepare("SELECT f.numero_factura,f.fecha,cl.nombre AS cliente,f.subtotal,f.isv,f.total,f.estado,f.metodo_pago,COALESCE(pg.pagado,0) AS pagado,f.total-COALESCE(pg.pagado,0) AS pendiente FROM facturas f JOIN clientes cl ON cl.id_cliente=f.cliente_id LEFT JOIN(SELECT factura_id,SUM(monto) AS pagado FROM pagos_clientes WHERE estado='aplicado' GROUP BY factura_id)pg ON pg.factura_id=f.id_factura $where ORDER BY f.fecha ASC");
    $stmt->execute($params); $rows=$stmt->fetchAll();
    $tot=['cantidad'=>count($rows),'subtotal'=>array_sum(array_column($rows,'subtotal')),'isv'=>array_sum(array_column($rows,'isv')),'total'=>array_sum(array_column($rows,'total')),'pagado'=>array_sum(array_column($rows,'pagado')),'pendiente'=>array_sum(array_column($rows,'pendiente'))];
    if($format==='excel') exportarExcel($rows,'ventas',"Reporte_Ventas_{$anio}");
    else jsonResponder(200,['ok'=>true,'data'=>$rows,'totales'=>$tot]);
}

function reporteCxC(string $format): void {
    $rows=PagoModel::cuentasPorCobrar(); $total=array_sum(array_column($rows,'saldo_pendiente'));
    if($format==='excel') exportarExcel($rows,'cxc','Cuentas_por_Cobrar');
    else jsonResponder(200,['ok'=>true,'data'=>$rows,'total_pendiente'=>$total]);
}

function reporteRetenciones(string $format): void {
    $mes=$_GET['mes']??''; $anio=$_GET['anio']??date('Y');
    $where="WHERE p.estado='aplicado' AND YEAR(p.fecha)=?"; $params=[(int)$anio];
    if($mes){$where.=" AND MONTH(p.fecha)=?";$params[]=(int)$mes;}
    $stmt=getDB()->prepare("SELECT p.fecha,cl.nombre AS cliente,cl.rtn,f.numero_factura,f.subtotal,p.monto,p.retencion_isr,p.retencion_isv,p.monto_neto FROM pagos_clientes p JOIN facturas f ON f.id_factura=p.factura_id JOIN clientes cl ON cl.id_cliente=p.cliente_id $where ORDER BY p.fecha ASC");
    $stmt->execute($params); $rows=$stmt->fetchAll();
    $tot=['monto'=>array_sum(array_column($rows,'monto')),'retencion_isr'=>array_sum(array_column($rows,'retencion_isr')),'retencion_isv'=>array_sum(array_column($rows,'retencion_isv')),'monto_neto'=>array_sum(array_column($rows,'monto_neto'))];
    if($format==='excel') exportarExcel($rows,'retenciones',"Retenciones_{$anio}");
    else jsonResponder(200,['ok'=>true,'data'=>$rows,'totales'=>$tot]);
}

function reporteInventario(string $format): void {
    $mes=$_GET['mes']??''; $anio=$_GET['anio']??date('Y');
    $where="WHERE YEAR(m.fecha)=?"; $params=[(int)$anio];
    if($mes){$where.=" AND MONTH(m.fecha)=?";$params[]=(int)$mes;}
    $stmt=getDB()->prepare("
        SELECT DATE(m.fecha) AS fecha, mat.nombre AS material,
               mat.codigo, m.tipo, m.cantidad, m.costo_unitario,
               m.tipo_referencia, m.observaciones
        FROM movimientos_inventario m
        JOIN materiales mat ON mat.id_material = m.material_id
        $where
        ORDER BY m.fecha DESC
    ");
    $stmt->execute($params); $rows=$stmt->fetchAll();
    if($format==='excel') exportarExcel($rows,'inventario',"Movimientos_Inventario_{$anio}");
    else jsonResponder(200,['ok'=>true,'data'=>$rows]);
}

function reporteRentabilidad(string $format): void {
    $anio=(int)($_GET['anio']??date('Y'));
    $stmt=getDB()->prepare("SELECT ot.numero_orden,ot.fecha_apertura,ot.fecha_cierre,cl.nombre AS cliente,COALESCE(mat.costo,0) AS costo_materiales,COALESCE(mo.costo,0) AS costo_mano_obra,COALESCE(mat.costo,0)+COALESCE(mo.costo,0) AS costo_total,COALESCE(f.total,0) AS facturado,COALESCE(f.total,0)-COALESCE(mat.costo,0)-COALESCE(mo.costo,0) AS utilidad,ot.estado FROM ordenes_trabajo ot JOIN clientes cl ON cl.id_cliente=ot.cliente_id LEFT JOIN(SELECT orden_id,SUM(subtotal) AS costo FROM detalle_orden_materiales GROUP BY orden_id)mat ON mat.orden_id=ot.id_orden LEFT JOIN(SELECT orden_id,SUM(subtotal) AS costo FROM detalle_orden_mano_obra GROUP BY orden_id)mo ON mo.orden_id=ot.id_orden LEFT JOIN(SELECT orden_id,SUM(total) AS total FROM facturas WHERE estado!='anulada' GROUP BY orden_id)f ON f.orden_id=ot.id_orden WHERE YEAR(ot.fecha_apertura)=? ORDER BY utilidad DESC");
    $stmt->execute([$anio]); $rows=$stmt->fetchAll();
    $tot=['costo_total'=>array_sum(array_column($rows,'costo_total')),'facturado'=>array_sum(array_column($rows,'facturado')),'utilidad'=>array_sum(array_column($rows,'utilidad'))];
    if($format==='excel') exportarExcel($rows,'rentabilidad',"Rentabilidad_OT_{$anio}");
    else jsonResponder(200,['ok'=>true,'data'=>$rows,'totales'=>$tot]);
}

// ── PDF Planilla ──────────────────────────────────────────────
function planillaPDF(): void {
    $id=(int)($_GET['id']??0);
    $p=PlanillaModel::obtener($id);
    if(!$p){http_response_code(404);echo'Planilla no encontrada';exit;}
    $mes=PlanillaModel::nombreMes((int)$p['periodo_mes']);
    $anio=$p['periodo_anio']; $quincena=$p['quincena']??'1ra';
    $titulo="Planilla {$quincena} Quincena - {$mes} {$anio}";
    $f=fn($n)=>'L. '.number_format((float)$n,2,'.',',');
    header('Content-Type: text/html; charset=UTF-8');
    $mostrarSeguro=($quincena==='2da');
    $cols=$mostrarSeguro?12:11;
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>'.htmlspecialchars($titulo).'</title>';
    echo '<style>body{font-family:Arial,sans-serif;font-size:10px;margin:15px;color:#222}h2{text-align:center;font-size:13px;margin-bottom:3px}.sub{text-align:center;color:#555;font-size:10px;margin-bottom:12px}table{width:100%;border-collapse:collapse;margin-bottom:12px}th{background:#1a1a2e;color:#fff;padding:5px 3px;text-align:center;font-size:9px}td{border:1px solid #ddd;padding:4px 3px;text-align:right;font-size:9px}td.l{text-align:left}tr:nth-child(even){background:#f5f5f5}.tot{background:#e8f4e8;font-weight:bold}.boxes{text-align:center;margin-bottom:12px}.box{display:inline-block;border:1px solid #ccc;border-radius:5px;padding:6px 12px;margin:3px;text-align:center}.box strong{display:block;font-size:12px}@media print{body{margin:8px}}</style></head><body>';
    echo '<h2>SOLDYMEG - '.htmlspecialchars($titulo).'</h2>';
    echo '<div class="sub">Fecha de pago: '.$p['fecha_pago'].' | Estado: '.strtoupper($p['estado']).'</div>';
    echo '<div class="boxes">'
        .'<div class="box">Empleados<strong>'.count($p['detalle']).'</strong></div>'
        .'<div class="box">Total salarios<strong>'.$f($p['total_salarios']).'</strong></div>'
        .'<div class="box">Deducciones<strong>'.$f($p['total_deducciones']).'</strong></div>'
        .'<div class="box">Neto a pagar<strong>'.$f($p['total_neto']).'</strong></div>'
        .'</div>';
    echo '<table><thead><tr><th>Empleado</th><th>Ubic.</th><th>Sal.Quincenal</th><th>H.Extra</th><th>Mto.HE</th><th>D.Falt.</th><th>Desc.Falt.</th>';
    if($mostrarSeguro) echo '<th>Seguro</th>';
    echo '<th>Abo.Prest.</th><th>Abo.Vale</th><th>Total Ded.</th><th>NETO</th></tr></thead><tbody>';
    foreach($p['detalle'] as $d){
        echo '<tr>'
            .'<td class="l">'.htmlspecialchars($d['empleado']).'<br><small>'.htmlspecialchars($d['puesto']??'').'</small></td>'
            .'<td style="text-align:center">'.($d['ubicacion']??'').'</td>'
            .'<td>'.$f($d['salario_base']).'</td>'
            .'<td style="text-align:center">'.((float)($d['horas_extra']??0)>0?$d['horas_extra']:'—').'</td>'
            .'<td>'.((float)($d['monto_horas_extra']??0)>0?$f($d['monto_horas_extra']):'—').'</td>'
            .'<td style="text-align:center">'.((float)($d['dias_faltados']??0)>0?$d['dias_faltados']:'—').'</td>'
            .'<td>'.((float)($d['monto_dias_faltados']??0)>0?$f($d['monto_dias_faltados']):'—').'</td>';
        if($mostrarSeguro) echo '<td>'.$f($d['seguro_privado']).'</td>';
        echo '<td>'.((float)($d['abono_prestamo']??0)>0?$f($d['abono_prestamo']):'—').'</td>'
            .'<td>'.((float)($d['abono_vale']??0)>0?$f($d['abono_vale']):'—').'</td>'
            .'<td>'.$f($d['total_deducciones']).'</td>'
            .'<td><strong>'.$f($d['salario_neto']).'</strong></td>'
            .'</tr>';
    }
    echo '<tr class="tot"><td class="l" colspan="2"><strong>TOTALES</strong></td>'
        .'<td>'.$f($p['total_salarios']).'</td><td colspan="4">—</td>';
    if($mostrarSeguro) echo '<td>'.$f($p['total_seguro']).'</td>';
    echo '<td colspan="2">—</td><td>'.$f($p['total_deducciones']).'</td><td>'.$f($p['total_neto']).'</td></tr>';
    echo '</tbody></table>';
    if(!empty($p['observaciones'])) echo '<p><strong>Observaciones:</strong> '.htmlspecialchars($p['observaciones']).'</p>';
    echo '<p style="color:#888;font-size:9px;margin-top:20px">Generado: '.date('d/m/Y H:i').' | SOLDYMEG Sistema Administrativo</p>';
    echo '<script>window.onload=()=>window.print();</script></body></html>';
    exit;
}

// ── Excel Planilla ────────────────────────────────────────────
function planillaExcel(): void {
    $id=(int)($_GET['id']??0);
    $p=PlanillaModel::obtener($id);
    if(!$p){http_response_code(404);echo'No encontrada';exit;}
    $mes=PlanillaModel::nombreMes((int)$p['periodo_mes']);
    $quincena=$p['quincena']??'1ra';
    $filename="Planilla_{$quincena}_{$mes}_{$p['periodo_anio']}.csv";
    header('Content-Type: text/csv; charset=UTF-8');
    header('Content-Disposition: attachment; filename="'.$filename.'"');
    echo "\xEF\xBB\xBF";
    $out=fopen('php://output','w');
    fputcsv($out,["SOLDYMEG - Planilla {$quincena} Quincena - {$mes} {$p['periodo_anio']}"]);
    fputcsv($out,['Fecha pago: '.$p['fecha_pago'],'Estado: '.$p['estado']]);
    fputcsv($out,[]);
    $cab=['Empleado','Puesto','Ubicacion','Sal. Quincenal','Horas Extra','Monto HE','Dias Faltados','Desc. Faltados'];
    if($quincena==='2da') $cab[]='Seguro';
    array_push($cab,'Abono Prestamo','Abono Vale','Total Deducciones','Neto a Pagar');
    fputcsv($out,$cab);
    foreach($p['detalle'] as $d){
        $fila=[$d['empleado'],$d['puesto']??'',$d['ubicacion']??'',$d['salario_base'],$d['horas_extra']??0,$d['monto_horas_extra']??0,$d['dias_faltados']??0,$d['monto_dias_faltados']??0];
        if($quincena==='2da') $fila[]=$d['seguro_privado']??0;
        array_push($fila,$d['abono_prestamo']??0,$d['abono_vale']??0,$d['total_deducciones'],$d['salario_neto']);
        fputcsv($out,$fila);
    }
    fputcsv($out,[]);
    $tot=['TOTALES','','',$p['total_salarios'],'','','',''];
    if($quincena==='2da') $tot[]=$p['total_seguro'];
    array_push($tot,'','',$p['total_deducciones'],$p['total_neto']);
    fputcsv($out,$tot);
    fclose($out);
    exit;
}

// ── Excel genérico ────────────────────────────────────────────
function inventarioStock(string $format): void {
    $categoria = $_GET['categoria'] ?? '';
    $estado     = $_GET['estado']    ?? '';   // 'bajo' = stock bajo mínimo
    $pdo = getDB();

    $where  = 'WHERE 1=1';
    $params = [];
    if ($categoria) { $where .= ' AND c.nombre = ?'; $params[] = $categoria; }
    if ($estado === 'bajo') { $where .= ' AND mat.stock <= mat.stock_minimo'; }

    $stmt = $pdo->prepare("
        SELECT mat.codigo             AS 'Código',
               mat.nombre             AS 'Material',
               c.nombre               AS 'Categoría',
               mat.unidad_medida      AS 'Unidad',
               mat.stock              AS 'Stock Actual',
               mat.stock_minimo       AS 'Stock Mínimo',
               mat.precio_compra      AS 'P. Compra (L.)',
               mat.precio_venta       AS 'P. Venta (L.)',
               ROUND(mat.stock * mat.precio_compra, 2) AS 'Valor en Stock (L.)',
               CASE WHEN mat.stock <= mat.stock_minimo THEN 'BAJO' ELSE 'OK' END AS 'Estado Stock',
               mat.descripcion        AS 'Descripción'
        FROM materiales mat
        LEFT JOIN categorias_material c ON c.id_categoria = mat.categoria_id
        $where
        ORDER BY c.nombre ASC, mat.nombre ASC
    ");
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    // Totales para resumen
    $totalValor = array_sum(array_column($rows, 'Valor en Stock (L.)'));
    $totalItems = count($rows);
    $bajosStock = count(array_filter($rows, fn($r) => $r['Estado Stock'] === 'BAJO'));

    if ($format === 'excel') {
        exportarExcel($rows, 'inventario_stock', 'Inventario_Stock_' . date('Y-m-d'));
        return;
    }

    // ── PDF (HTML para imprimir / abrir en nueva pestaña) ──
    $f  = fn($n) => 'L. ' . number_format((float)$n, 2, '.', ',');
    $fc = fn($n) => number_format((float)$n, 2, '.', ',');
    header('Content-Type: text/html; charset=UTF-8');
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Inventario — SOLDYMEG</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;font-size:9.5px;color:#1a1a2e;background:#fff;padding:14px}
  h2{font-size:14px;text-align:center;margin-bottom:2px}
  .sub{text-align:center;color:#555;font-size:9px;margin-bottom:10px}
  .boxes{display:flex;gap:10px;margin-bottom:12px;flex-wrap:wrap}
  .box{border:1px solid #ccc;border-radius:5px;padding:7px 14px;text-align:center;flex:1;min-width:110px}
  .box strong{display:block;font-size:13px;margin-top:2px}
  .box.warn strong{color:#c0392b}
  table{width:100%;border-collapse:collapse;font-size:8.8px}
  thead th{background:#1a1a2e;color:#fff;padding:4px 3px;text-align:center;white-space:nowrap}
  td{border:1px solid #ddd;padding:3px 4px;vertical-align:middle}
  td.r{text-align:right} td.c{text-align:center}
  tr:nth-child(even){background:#f7f7f7}
  .bajo{background:#fdecea!important;color:#c0392b;font-weight:700}
  .footer{margin-top:10px;font-size:8.5px;color:#888;text-align:center}
  @media print{body{padding:6px}button{display:none}}
</style></head><body>';

    echo '<h2>📦 SOLDYMEG — Inventario de Materiales</h2>';
    echo '<div class="sub">Generado: ' . date('d/m/Y H:i') . ($categoria ? ' | Categoría: ' . htmlspecialchars($categoria) : '') . ($estado === 'bajo' ? ' | Solo stock bajo mínimo' : '') . '</div>';

    echo '<div class="boxes">'
        . '<div class="box"><span>Total materiales</span><strong>' . $totalItems . '</strong></div>'
        . '<div class="box warn"><span>Stock bajo mínimo</span><strong>' . $bajosStock . '</strong></div>'
        . '<div class="box"><span>Valor total inventario</span><strong>' . $f($totalValor) . '</strong></div>'
        . '</div>';

    echo '<table><thead><tr>
        <th>#</th><th>Código</th><th>Material</th><th>Categoría</th><th>Unidad</th>
        <th>Stock</th><th>Mínimo</th><th>P.Compra</th><th>P.Venta</th>
        <th>Valor Stock</th><th>Estado</th>
    </tr></thead><tbody>';

    foreach ($rows as $i => $r) {
        $bajo    = $r['Estado Stock'] === 'BAJO';
        $trClass = $bajo ? ' class="bajo"' : '';
        echo "<tr{$trClass}>"
            . '<td class="c">' . ($i + 1) . '</td>'
            . '<td class="c"><code>' . htmlspecialchars($r['Código'] ?? '—') . '</code></td>'
            . '<td>' . htmlspecialchars($r['Material']) . '</td>'
            . '<td class="c">' . htmlspecialchars($r['Categoría'] ?? '—') . '</td>'
            . '<td class="c">' . htmlspecialchars($r['Unidad']) . '</td>'
            . '<td class="r">' . $fc($r['Stock Actual']) . '</td>'
            . '<td class="r c">' . $fc($r['Stock Mínimo']) . '</td>'
            . '<td class="r">' . $f($r['P. Compra (L.)']) . '</td>'
            . '<td class="r">' . $f($r['P. Venta (L.)']) . '</td>'
            . '<td class="r"><strong>' . $f($r['Valor en Stock (L.)']) . '</strong></td>'
            . '<td class="c ' . ($bajo ? 'bajo' : '') . '">' . ($bajo ? '⚠ BAJO' : '✔ OK') . '</td>'
            . '</tr>';
    }

    // Fila de totales
    echo '<tr style="background:#e8f4e8;font-weight:bold">'
        . '<td colspan="9" style="text-align:right;padding:4px 6px">VALOR TOTAL INVENTARIO</td>'
        . '<td class="r">' . $f($totalValor) . '</td>'
        . '<td></td></tr>';

    echo '</tbody></table>';
    echo '<div class="footer">SOLDYMEG &mdash; Reporte generado el ' . date('d/m/Y \a \l\a\s H:i') . '</div>';
    echo '</body></html>';
    exit;
}

function exportarExcel(array $rows, string $tipo, string $filename): void {
    header('Content-Type: text/csv; charset=UTF-8');
    header('Content-Disposition: attachment; filename="'.$filename.'.csv"');
    echo "\xEF\xBB\xBF";
    if(!$rows){echo"Sin datos";exit;}
    $out=fopen('php://output','w');
    fputcsv($out,array_keys($rows[0]));
    foreach($rows as $row) fputcsv($out,array_values($row));
    fclose($out);
    exit;
}

function jsonResponder(int $code, array $data): void {
    header('Content-Type: application/json');
    http_response_code($code);
    echo json_encode($data);
    exit;
}
