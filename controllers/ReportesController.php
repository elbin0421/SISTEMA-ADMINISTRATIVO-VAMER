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
    $action === 'boucher_pdf'                                => boucherPDF(),
    $action === 'boucher_todos_pdf'                          => boucherTodosPDF(),
    $action === 'inventario' || $action === 'inventario_mov'=> reporteInventario($format),
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
    echo '<table><thead><tr><th>Empleado</th><th>Ubic.</th><th>Sal.Quincenal</th><th>H.Extra</th><th>Mto.HE</th><th style="color:#e8a020">Viáticos</th><th>D.Falt.</th><th>Desc.Falt.</th>';
    if($mostrarSeguro) echo '<th>Seguro</th>';
    echo '<th>Abo.Prest.</th><th>Abo.Vale</th><th>Total Ded.</th><th>NETO</th></tr></thead><tbody>';
    $totalViaticosPlanilla = 0;
    foreach($p['detalle'] as $d){
        $viaticoFila = (float)($d['viatico_s1']??0)+(float)($d['viatico_s2']??0)+(float)($d['viatico_s3']??0)+(float)($d['viatico_s4']??0);
        $totalViaticosPlanilla += $viaticoFila;
        echo '<tr>'
            .'<td class="l">'.htmlspecialchars($d['empleado']).'<br><small>'.htmlspecialchars($d['puesto']??'').'</small></td>'
            .'<td style="text-align:center">'.($d['ubicacion']??'').'</td>'
            .'<td>'.$f($d['salario_base']).'</td>'
            .'<td style="text-align:center">'.((float)($d['horas_extra']??0)>0?$d['horas_extra']:'—').'</td>'
            .'<td>'.((float)($d['monto_horas_extra']??0)>0?$f($d['monto_horas_extra']):'—').'</td>'
            .'<td style="color:#b07d00;font-weight:600">'.($viaticoFila>0?$f($viaticoFila):'—').'</td>'
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
        .'<td>'.$f($p['total_salarios']).'</td><td colspan="2">—</td><td>'.$f($totalViaticosPlanilla).'</td><td colspan="2">—</td>';
    if($mostrarSeguro) echo '<td>'.$f($p['total_seguro']).'</td>';
    echo '<td colspan="2">—</td><td>'.$f($p['total_deducciones']).'</td><td>'.$f($p['total_neto']).'</td></tr>';
    echo '</tbody></table>';
    if(!empty($p['observaciones'])) echo '<p><strong>Observaciones:</strong> '.htmlspecialchars($p['observaciones']).'</p>';
    echo '<p style="color:#888;font-size:9px;margin-top:20px">Generado: '.date('d/m/Y H:i').' | SOLDYMEG Sistema Administrativo</p>';
    echo '<script>window.onload=()=>window.print();</script></body></html>';
    exit;
}

// ── Boucher de Pago (individual) ────────────────────────────────
function boucherPDF(): void {
    $id  = (int)($_GET['id'] ?? 0);       // id_planilla
    $emp = (int)($_GET['empleado_id'] ?? 0);
    $p   = PlanillaModel::obtener($id);
    if (!$p) { http_response_code(404); echo 'Planilla no encontrada'; exit; }
    $det = null;
    foreach ($p['detalle'] as $d) { if ((int)$d['empleado_id'] === $emp) { $det = $d; break; } }
    if (!$det) { http_response_code(404); echo 'Empleado no encontrado en esta planilla'; exit; }

    header('Content-Type: text/html; charset=UTF-8');
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Boucher de Pago</title>';
    echo boucherEstilos();
    echo '</head><body>';
    echo renderBoucherHTML($p, $det);
    echo '<script>window.onload=()=>window.print();</script></body></html>';
    exit;
}

// ── Boucher de Pago (todos los empleados de la planilla) ────────
function boucherTodosPDF(): void {
    $id = (int)($_GET['id'] ?? 0);
    $p  = PlanillaModel::obtener($id);
    if (!$p) { http_response_code(404); echo 'Planilla no encontrada'; exit; }
    if (empty($p['detalle'])) { http_response_code(404); echo 'Sin empleados en esta planilla'; exit; }

    header('Content-Type: text/html; charset=UTF-8');
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><title>Bouchers de Pago</title>';
    echo boucherEstilos();
    echo '</head><body>';
    $total = count($p['detalle']);
    $i = 0;
    foreach ($p['detalle'] as $det) {
        $i++;
        echo '<div class="boucher-page"' . ($i < $total ? ' style="page-break-after:always"' : '') . '>';
        echo renderBoucherHTML($p, $det);
        echo '</div>';
    }
    echo '<script>window.onload=()=>window.print();</script></body></html>';
    exit;
}

function boucherEstilos(): string {
    return '<style>
      body{font-family:Arial,sans-serif;font-size:11px;margin:0;padding:0;color:#1a1a2e}
      .boucher-page{padding:22px}
      .bh-header{display:flex;justify-content:space-between;align-items:flex-start;border-bottom:2px solid #1a1a2e;padding-bottom:10px;margin-bottom:14px}
      .bh-header h2{margin:0;font-size:16px}
      .bh-header .sub{color:#666;font-size:10px;margin-top:2px}
      .bh-header .right{text-align:right;font-size:10px;color:#666}
      .bh-header .right strong{display:block;font-size:13px;color:#1a1a2e}
      .bh-info{display:grid;grid-template-columns:1fr 1fr;gap:6px 20px;background:#f5f5f5;border-radius:6px;padding:10px 14px;margin-bottom:16px;font-size:11px}
      .bh-info span{color:#666}
      .bh-info strong{color:#1a1a2e}
      table.bh-tabla{width:100%;border-collapse:collapse;margin-bottom:14px}
      table.bh-tabla th{background:#1a1a2e;color:#fff;padding:6px 8px;text-align:left;font-size:10px}
      table.bh-tabla td{border:1px solid #ddd;padding:6px 8px;font-size:10.5px}
      table.bh-tabla td.r{text-align:right}
      .bh-totales{display:flex;justify-content:flex-end;margin-bottom:20px}
      .bh-totales table{border-collapse:collapse;font-size:11px;min-width:260px}
      .bh-totales td{padding:4px 10px}
      .bh-totales td:last-child{text-align:right;font-weight:600}
      .bh-totales tr.neto td{border-top:2px solid #1a1a2e;font-size:14px;font-weight:bold;color:#1a1a2e;padding-top:8px}
      .bh-firmas{display:flex;justify-content:space-between;margin-top:50px;text-align:center}
      .bh-firmas div{width:42%;border-top:1px solid #333;padding-top:5px;font-size:10px;color:#555}
      .bh-footer{margin-top:24px;font-size:8.5px;color:#999;text-align:center}
      @media print{.boucher-page{padding:15px}}
    </style>';
}

function renderBoucherHTML(array $p, array $d): string {
    $f = fn($n) => 'L. ' . number_format((float)$n, 2, '.', ',');
    $mes = PlanillaModel::nombreMes((int)$p['periodo_mes']);
    $quincenaLbl = ($p['quincena'] ?? '1ra') === '1ra' ? '1ra Quincena' : '2da Quincena';
    $tieneViatico = ((float)($d['viatico_s1']??0) + (float)($d['viatico_s2']??0) + (float)($d['viatico_s3']??0) + (float)($d['viatico_s4']??0)) > 0;
    $totalViatico = (float)($d['viatico_s1']??0) + (float)($d['viatico_s2']??0) + (float)($d['viatico_s3']??0) + (float)($d['viatico_s4']??0);
    $empresaNombre = $d['empresa_nombre'] ?? null;
    if (!$empresaNombre && !empty($d['empleado_id'])) {
        // Fallback: buscar directamente la empresa del empleado si no vino en el JOIN
        try {
            $pdo2 = getDB();
            $q = $pdo2->prepare("SELECT emp.nombre FROM empleados e LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id WHERE e.id_empleado = ?");
            $q->execute([(int)$d['empleado_id']]);
            $empresaNombre = $q->fetchColumn() ?: null;
        } catch (Exception $e) { $empresaNombre = null; }
    }
    if (!$empresaNombre) $empresaNombre = 'SOLDYMEG';

    $h  = '<div class="bh-header">';
    $h .= '<div><h2>' . htmlspecialchars($empresaNombre) . '</h2><div class="sub">Comprobante de Pago de Nómina</div></div>';
    $h .= '<div class="right">N° Planilla<strong>#' . str_pad((string)$p['id_planilla'], 5, '0', STR_PAD_LEFT) . '</strong></div>';
    $h .= '</div>';

    $h .= '<div class="bh-info">';
    $h .= '<div><span>Empleado:</span> <strong>' . htmlspecialchars($d['empleado']) . '</strong></div>';
    $h .= '<div><span>Puesto:</span> <strong>' . htmlspecialchars($d['puesto'] ?? '—') . '</strong></div>';
    $h .= '<div><span>Período:</span> <strong>' . htmlspecialchars($mes . ' ' . $p['periodo_anio'] . ' — ' . $quincenaLbl) . '</strong></div>';
    $h .= '<div><span>Fecha de pago:</span> <strong>' . htmlspecialchars($p['fecha_pago']) . '</strong></div>';
    $h .= '<div><span>Ubicación:</span> <strong>' . htmlspecialchars($d['ubicacion'] ?? '—') . '</strong></div>';
    $h .= '<div><span>Banco / Cuenta:</span> <strong>' . htmlspecialchars(($d['banco'] ?? '—') . ' / ' . ($d['cuenta_banco'] ?? '—')) . '</strong></div>';
    $h .= '</div>';

    $h .= '<table class="bh-tabla"><thead><tr><th>Concepto</th><th style="text-align:right">Monto</th></tr></thead><tbody>';
    $h .= '<tr><td>Salario quincenal</td><td class="r">' . $f($d['salario_base']) . '</td></tr>';
    if ((float)($d['horas_extra'] ?? 0) > 0) {
        $h .= '<tr><td>Horas extra (' . htmlspecialchars($d['horas_extra']) . ' hrs)</td><td class="r">' . $f($d['monto_horas_extra']) . '</td></tr>';
    }
    if ($tieneViatico) {
        $h .= '<tr><td>Viáticos</td><td class="r">' . $f($totalViatico) . '</td></tr>';
    }
    $h .= '</tbody></table>';

    $h .= '<table class="bh-tabla"><thead><tr><th>Deducciones</th><th style="text-align:right">Monto</th></tr></thead><tbody>';
    if ((float)($d['dias_faltados'] ?? 0) > 0) {
        $h .= '<tr><td>Días faltados (' . htmlspecialchars($d['dias_faltados']) . ')</td><td class="r">' . $f($d['monto_dias_faltados']) . '</td></tr>';
    }
    if ((float)($d['seguro_privado'] ?? 0) > 0 && !empty($d['aplicar_seguro'])) {
        $h .= '<tr><td>Seguro privado</td><td class="r">' . $f($d['seguro_privado']) . '</td></tr>';
    }
    if ((float)($d['abono_prestamo'] ?? 0) > 0) {
        $h .= '<tr><td>Abono a préstamo</td><td class="r">' . $f($d['abono_prestamo']) . '</td></tr>';
    }
    if ((float)($d['abono_vale'] ?? 0) > 0) {
        $h .= '<tr><td>Abono a vale</td><td class="r">' . $f($d['abono_vale']) . '</td></tr>';
    }
    if ((float)($d['total_deducciones'] ?? 0) == 0) {
        $h .= '<tr><td colspan="2" style="color:#999;text-align:center">Sin deducciones</td></tr>';
    }
    $h .= '</tbody></table>';

    $devengado = (float)$d['salario_base'] + (float)($d['monto_horas_extra'] ?? 0) + $totalViatico;
    $h .= '<div class="bh-totales"><table>';
    $h .= '<tr><td>Total devengado</td><td>' . $f($devengado) . '</td></tr>';
    $h .= '<tr><td>Total deducciones</td><td>-' . $f($d['total_deducciones']) . '</td></tr>';
    $h .= '<tr class="neto"><td>NETO A PAGAR</td><td>' . $f($d['salario_neto']) . '</td></tr>';
    $h .= '</table></div>';

    $h .= '<div class="bh-firmas">';
    $h .= '<div>Firma del Empleado</div>';
    $h .= '<div>Firma Autorizada</div>';
    $h .= '</div>';

    $h .= '<div class="bh-footer">Generado el ' . date('d/m/Y H:i') . ' | Documento interno de nómina — no válido como factura fiscal</div>';

    return $h;
}


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
    $cab=['Empleado','Puesto','Ubicacion','Sal. Quincenal','Horas Extra','Monto HE','Viaticos','Dias Faltados','Desc. Faltados'];
    if($quincena==='2da') $cab[]='Seguro';
    array_push($cab,'Abono Prestamo','Abono Vale','Total Deducciones','Neto a Pagar');
    fputcsv($out,$cab);
    $totalViaticosPlanilla=0;
    foreach($p['detalle'] as $d){
        $viaticoFila=(float)($d['viatico_s1']??0)+(float)($d['viatico_s2']??0)+(float)($d['viatico_s3']??0)+(float)($d['viatico_s4']??0);
        $totalViaticosPlanilla+=$viaticoFila;
        $fila=[$d['empleado'],$d['puesto']??'',$d['ubicacion']??'',$d['salario_base'],$d['horas_extra']??0,$d['monto_horas_extra']??0,$viaticoFila,$d['dias_faltados']??0,$d['monto_dias_faltados']??0];
        if($quincena==='2da') $fila[]=$d['seguro_privado']??0;
        array_push($fila,$d['abono_prestamo']??0,$d['abono_vale']??0,$d['total_deducciones'],$d['salario_neto']);
        fputcsv($out,$fila);
    }
    fputcsv($out,[]);
    $tot=['TOTALES','','',$p['total_salarios'],'','',$totalViaticosPlanilla,'',''];
    if($quincena==='2da') $tot[]=$p['total_seguro'];
    array_push($tot,'','',$p['total_deducciones'],$p['total_neto']);
    fputcsv($out,$tot);
    fclose($out);
    exit;
}

// ── Excel genérico ────────────────────────────────────────────
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
