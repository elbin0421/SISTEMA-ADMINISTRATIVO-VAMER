<?php
// ============================================================
//  SOLDYMEG — CotizacionPDFController
//  Genera PDF (HTML imprimible) y Excel (.xls) de cotización
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/CotizacionModel.php';

$sesion = requireAuth();

$action = $_GET['action'] ?? 'pdf';
$id     = (int)($_GET['id'] ?? 0);

if (!$id) { http_response_code(400); echo 'ID requerido'; exit; }

$cot = CotizacionModel::obtener($id);
if (!$cot) { http_response_code(404); echo 'Cotización no encontrada'; exit; }

match($action) {
    'pdf'   => generarPDF($cot, $sesion),
    'excel' => generarExcel($cot, $sesion),
    default => responder(400, 'Acción no válida'),
};

// ── HELPER: resolver elaborado_por ───────────────────────────
function resolverElaborado(array $c, array $sesion): array {
    if (!empty($c['elaborado_por'])) {
        $partes = array_values(array_filter(explode(' ', trim($c['elaborado_por']))));
        $nombre = implode(' ', array_slice($partes, 0, 2));
        return [strtoupper($nombre), strtoupper($c['telefono_elaborado'] ?? '—')];
    }
    try {
        $stmt = getDB()->prepare("
            SELECT e.nombres AS n, e.apellidos AS a, e.telefono AS t
            FROM usuarios u
            LEFT JOIN empleados e ON e.id_empleado = u.empleado_id
            WHERE u.id_usuario = ? LIMIT 1
        ");
        $stmt->execute([$sesion['usuario_id']]);
        $r = $stmt->fetch();
        if ($r && !empty($r['n'])) {
            $nom = explode(' ', trim($r['n']))[0];
            $ape = explode(' ', trim($r['a'] ?? ''))[0];
            return [strtoupper("$nom $ape"), strtoupper($r['t'] ?? '—')];
        }
    } catch (Exception $e) {}
    return [strtoupper($sesion['nombre'] ?? '—'), '—'];
}

// ── PDF ───────────────────────────────────────────────────────
function generarPDF(array $c, array $sesion): void {
    header('Content-Type: text/html; charset=UTF-8');

    $f     = fn($n) => number_format((float)$n, 2, '.', ',');
    $fecha = date('d/m/Y', strtotime($c['fecha']));
    $num   = htmlspecialchars(strtoupper($c['numero_cotizacion']));
    $cliente   = htmlspecialchars(strtoupper($c['cliente']           ?? '—'));
    $rtn       = htmlspecialchars($c['cliente_rtn']                  ?? '—');
    $dir       = htmlspecialchars(strtoupper($c['cliente_direccion'] ?? '—'));
    $tel       = htmlspecialchars($c['cliente_tel']                  ?? '—');
    $obs       = htmlspecialchars($c['ot_cliente'] ?? ($c['orden_compra'] ?? ''));
    $unidad    = htmlspecialchars(strtoupper($c['unidad'] ?? ''));
    $estado    = $c['estado'] ?? '';
    $motivoRec = htmlspecialchars(strtoupper($c['motivo_rechazo'] ?? ''));
    $detalle   = $c['detalle'] ?? [];

    [$elaborado, $telElaborado] = resolverElaborado($c, $sesion);
    $elaborado    = htmlspecialchars($elaborado);
    $telElaborado = htmlspecialchars($telElaborado);

    $autorizadoPor = 'HENRY JOSUE GUDIEL DIAZ';
    $minRows = 20;
    $empty   = max(0, $minRows - count($detalle));
    ?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Cotización <?= $num ?></title>
<style>
  * { box-sizing:border-box; margin:0; padding:0; }
  body { font-family:Arial, sans-serif; font-size:11px; color:#111; background:#fff; padding:20px; }

  .header-box { border:1.5px solid #333; padding:10px 14px; text-align:center; margin-bottom:8px; }
  .header-box .company { font-size:12px; font-weight:700; }
  .header-box .address { font-size:10px; color:#333; }
  .header-box .email   { font-size:10px; color:#0055aa; }

  .titulo-cot { text-align:center; font-size:13px; font-weight:900;
    background:#eee; border:1px solid #333; padding:5px; margin-bottom:0; letter-spacing:2px; }

  .info-box { border:1px solid #333; border-top:none; margin-bottom:0; }
  .info-box table { width:100%; border-collapse:collapse; }
  .info-box td { padding:4px 8px; font-size:10.5px; }
  .info-box td.lbl { font-weight:700; white-space:nowrap; }

  .items-table { width:100%; border-collapse:collapse; border:1px solid #333; border-top:none; }
  .items-table th {
    background:#ddd; font-size:10px; font-weight:700; text-align:center;
    border:1px solid #333; padding:4px 3px; text-transform:uppercase;
  }
  .items-table td {
    border:1px solid #ccc; padding:3px 5px; font-size:10.5px; vertical-align:middle;
  }
  .items-table td.num   { text-align:center; }
  .items-table td.desc  { text-align:left; }
  .items-table td.monto { text-align:right; }
  .items-table tr.empty td { height:18px; }

  .footer-box { border:1px solid #333; border-top:none; }
  .footer-left  { vertical-align:top; padding:6px 8px; width:60%; }
  .footer-right { vertical-align:top; text-align:right; padding:6px 8px; border-left:1px solid #333; width:40%; }
  .subtotal-row { display:flex; justify-content:space-between; padding:2px 0; font-size:11px; }
  .subtotal-row.total-row { font-weight:900; font-size:12px; border-top:1px solid #333; padding-top:4px; }

  .firma { margin-top:30px; font-size:10.5px; }

  .watermark-rechazada {
    position:fixed; top:50%; left:50%;
    transform:translate(-50%,-50%) rotate(-35deg);
    font-size:90px; font-weight:900; color:rgba(200,0,0,0.13);
    letter-spacing:4px; white-space:nowrap; pointer-events:none;
    z-index:9999; border:8px solid rgba(200,0,0,0.13);
    padding:10px 30px; border-radius:12px;
  }
  .badge-rechazada {
    display:inline-block; background:#c00; color:#fff;
    font-size:13px; font-weight:900; letter-spacing:2px;
    padding:4px 14px; border-radius:4px; margin-bottom:6px;
  }
  @media print {
    body { padding:8px; }
    @page { margin:10mm; }
  }
</style>
</head>
<body>

<?php if ($estado === 'rechazada'): ?>
<div class="watermark-rechazada">RECHAZADA</div>
<div style="text-align:center;margin-bottom:6px">
  <span class="badge-rechazada">✗ RECHAZADA</span>
  <?php if ($motivoRec): ?>
  <div style="font-size:11px;color:#c00;margin-top:3px">MOTIVO: <?= $motivoRec ?></div>
  <?php endif; ?>
</div>
<?php endif; ?>

<!-- ENCABEZADO EMPRESA -->
<div class="header-box">
  <div style="display:flex;align-items:center;gap:16px;justify-content:center">
    <img src="/admin/assets/img/VAMER.png" alt="VAMER"
         style="height:80px;width:auto;object-fit:contain;vertical-align:middle;">
    <div style="text-align:left">
      <div class="company">VENTAS AMERICA S. DE R.L</div>
      <div class="address">Col. San Sebastian, Frente a Cemcol — San Pedro Sula, Cortés</div>
      <div class="address">TEL. 9941-8647 &nbsp;|&nbsp; TEL. 9596-9903</div>
      <div class="email">vamerhn@gmail.com</div>
    </div>
  </div>
</div>

<!-- TÍTULO -->
<div class="titulo-cot">COTIZACIÓN</div>

<!-- INFO CLIENTE -->
<div class="info-box">
  <table style="width:100%;border-collapse:collapse">
    <tr>
      <td class="lbl" style="width:90px">CLIENTE:</td>
      <td><?= $cliente ?></td>
      <td style="border-left:1px solid #333;width:1px;padding:0"></td>
      <td class="lbl" style="width:115px;padding-left:8px">ELABORADO POR:</td>
      <td style="width:160px"><strong><?= $elaborado ?></strong></td>
    </tr>
    <tr>
      <td class="lbl">RTN:</td>
      <td><?= $rtn ?></td>
      <td style="border-left:1px solid #333;width:1px;padding:0"></td>
      <td class="lbl" style="padding-left:8px">TELÉFONO:</td>
      <td><?= $telElaborado ?></td>
    </tr>
    <tr>
      <td class="lbl">DIRECCIÓN:</td>
      <td><?= $dir ?></td>
      <td style="border-left:1px solid #333;width:1px;padding:0"></td>
      <td class="lbl" style="padding-left:8px;white-space:nowrap">COTIZACIÓN NO.:</td>
      <td><strong><?= $num ?></strong></td>
    </tr>
    <tr>
      <td class="lbl">TELÉFONO:</td>
      <td><?= $tel ?></td>
      <td style="border-left:1px solid #333;width:1px;padding:0"></td>
      <td class="lbl" style="padding-left:8px">FECHA:</td>
      <td><?= $fecha ?></td>
    </tr>
    <tr>
      <td class="lbl">UNIDAD/PLACA:</td>
      <td colspan="4"><strong><?= $unidad ?: '&nbsp;' ?></strong></td>
    </tr>
  </table>
</div>

<!-- TABLA DE ÍTEMS (sin columna UNIDAD) -->
<table class="items-table">
  <thead>
    <tr>
      <th style="width:35px">ITEM</th>
      <th style="width:55px">CÓDIGO</th>
      <th>DESCRIPCIÓN</th>
      <th style="width:45px">CANT.</th>
      <th style="width:90px">P. UNITARIO</th>
      <th style="width:90px">TOTAL</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($detalle as $i => $it): ?>
    <tr>
      <td class="num"><?= $i + 1 ?></td>
      <td class="num"><?= $i + 1 ?></td>
      <td class="desc"><?= htmlspecialchars(strtoupper($it['descripcion'])) ?></td>
      <?php $cant1 = (float)$it['cantidad']; $pu1 = (float)$it['precio_unitario']; $sub1 = (float)($it['subtotal_final'] ?? ($cant1 * $pu1)); ?>
      <td class="num"><?= ($cant1 == 0 || $pu1 == 0) ? '—' : ($cant1 == (int)$cant1 ? (int)$cant1 : $f($cant1)) ?></td>
      <td class="monto"><?= $pu1 == 0 ? '—' : $f($pu1) ?></td>
      <td class="monto"><?= $sub1 == 0 ? '—' : $f($sub1) ?></td>
    </tr>
    <?php endforeach; ?>
    <?php for ($e = 0; $e < $empty; $e++): ?>
    <tr class="empty">
      <td></td><td></td>
      <td><span style="color:#ccc">-</span></td>
      <td></td>
      <td class="monto"><span style="color:#ccc">-</span></td>
      <td class="monto"><span style="color:#ccc">-</span></td>
    </tr>
    <?php endfor; ?>
  </tbody>
</table>

<!-- PIE: OBSERVACIONES + TOTALES -->
<div class="footer-box">
  <table style="width:100%;border-collapse:collapse">
    <tr>
      <td class="footer-left">
        <strong>OBSERVACIONES:</strong><br>
        <?php if ($obs): ?>
          <span style="font-size:11px"><?= nl2br(htmlspecialchars($obs)) ?></span>
        <?php endif; ?>
        <?php if (!empty($c['observaciones'])): ?>
          <span style="font-size:11px"><?= nl2br(htmlspecialchars($c['observaciones'])) ?></span>
        <?php endif; ?>
      </td>
      <td class="footer-right" style="border-left:1px solid #333">
        <?php
          // SUB-TOTAL = suma bruta de todos los ítems (sin descontar nada)
          $sub_bruto = 0;
          foreach ($c['detalle'] as $dit) {
              $sub_bruto += (float)$dit['cantidad'] * (float)$dit['precio_unitario'];
          }
          $sub_bruto = round($sub_bruto, 2);

          // DESC./REBAJA = descuento_monto guardado O suma de descuentos por ítem
          $desc_mto_pdf = (float)($c['descuento_monto'] ?? 0);
          $desc_pct_pdf = (float)($c['descuento_porcentaje'] ?? 0);
          if ($desc_mto_pdf == 0 && !empty($c['detalle'])) {
              foreach ($c['detalle'] as $dit) {
                  $dsub = (float)$dit['cantidad'] * (float)$dit['precio_unitario'];
                  $dpct = (float)($dit['descuento_porcentaje'] ?? 0);
                  $dmto = $dpct > 0 ? round($dsub * $dpct / 100, 2) : (float)($dit['descuento_monto'] ?? 0);
                  $desc_mto_pdf += $dmto;
              }
              $desc_mto_pdf = round($desc_mto_pdf, 2);
          }

          $base_isv    = max(0, $sub_bruto - $desc_mto_pdf);
          $isv_final   = round($base_isv * 0.15, 2);
          $total_final = round($base_isv + $isv_final, 2);
        ?>
        <div class="subtotal-row">
          <span>SUB-TOTAL</span>
          <strong><?= $f($sub_bruto) ?></strong>
        </div>
        <?php if ($desc_mto_pdf > 0): ?>
        <div class="subtotal-row" style="color:#c0392b">
          <span>DESC./REBAJA<?= $desc_pct_pdf > 0 ? ' (' . $desc_pct_pdf . '%)' : '' ?></span>
          <strong><?= $f($desc_mto_pdf) ?></strong>
        </div>
        <?php endif; ?>
        <div class="subtotal-row">
          <span>ISV</span>
          <strong><?= $f($isv_final) ?></strong>
        </div>
        <div class="subtotal-row total-row">
          <span>TOTAL</span>
          <strong><?= $f($total_final) ?></strong>
        </div>
      </td>
    </tr>
  </table>
</div>

<!-- FIRMA -->
<div class="firma">
  <strong>Autorizado por: &nbsp; <?= $autorizadoPor ?></strong>
</div>

<script>window.onload = () => window.print();</script>
</body>
</html>
    <?php
    exit;
}

// ── EXCEL (.xls HTML table) ───────────────────────────────────
function generarExcel(array $c, array $sesion): void {
    $f     = fn($n) => number_format((float)$n, 2, '.', ',');
    $fecha = date('d/m/Y', strtotime($c['fecha']));
    $num   = strtoupper($c['numero_cotizacion']);
    $detalle   = $c['detalle'] ?? [];
    $estado    = $c['estado'] ?? '';
    $motivoRec = strtoupper($c['motivo_rechazo'] ?? '');

    [$elaboradoExcel, $telExcel] = resolverElaborado($c, $sesion);
    $autorizadoExcel = 'HENRY JOSUE GUDIEL DIAZ';

    $cliente = strtoupper($c['cliente']           ?? '—');
    $rtn     = $c['cliente_rtn']                  ?? '—';
    $dir     = strtoupper($c['cliente_direccion'] ?? '—');
    $tel     = $c['cliente_tel']                  ?? '—';
    $unidad  = strtoupper($c['unidad']            ?? '');
    $obs     = trim(($c['ot_cliente'] ?? '') . ' ' . ($c['orden_compra'] ?? '') . ' ' . ($c['observaciones'] ?? ''));

    $filename = "Cotizacion_{$num}.xls";
    header('Content-Type: application/vnd.ms-excel; charset=UTF-8');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    echo "\xEF\xBB\xBF"; // BOM UTF-8
    ?>
<html xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:x="urn:schemas-microsoft-com:office:excel"
      xmlns="http://www.w3.org/TR/REC-html40">
<head><meta charset="UTF-8">
<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets>
<x:ExcelWorksheet><x:Name>Cotizacion</x:Name>
<x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions>
</x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->
<style>
  body { font-family:Arial; font-size:11pt; }
  .titulo  { font-size:14pt; font-weight:bold; text-align:center; background:#DDDDDD; }
  .empresa { font-size:12pt; font-weight:bold; }
  .lbl     { font-weight:bold; }
  .th      { background:#DDDDDD; font-weight:bold; text-align:center; border:1px solid #333; }
  .num     { text-align:center; border:1px solid #CCC; }
  .desc    { text-align:left;   border:1px solid #CCC; }
  .monto   { text-align:right;  border:1px solid #CCC; }
  .empty   { height:18pt; border:1px solid #CCC; }
  .total-lbl { font-weight:bold; text-align:right; }
  .total-val { font-weight:bold; text-align:right; border:1px solid #999; }
  .grand-total { font-weight:bold; font-size:12pt; text-align:right; border-top:2px solid #333; }
  .rechazada { color:#CC0000; font-weight:bold; font-size:14pt; }
</style>
</head>
<body>
<table style="width:100%;border-collapse:collapse">

  <?php if ($estado === 'rechazada'): ?>
  <tr><td colspan="6" class="rechazada">*** COTIZACIÓN RECHAZADA ***</td></tr>
  <?php if ($motivoRec): ?>
  <tr><td colspan="6" style="color:#CC0000"><b>MOTIVO:</b> <?= htmlspecialchars($motivoRec) ?></td></tr>
  <?php endif; ?>
  <tr><td colspan="6"></td></tr>
  <?php endif; ?>

  <!-- ENCABEZADO EMPRESA -->
  <tr><td colspan="6" class="empresa">VENTAS AMERICA S. DE R.L</td></tr>
  <tr><td colspan="6">Col. San Sebastian, Frente a Cemcol — San Pedro Sula, Cortés</td></tr>
  <tr><td colspan="6">TEL. 9941-8647 | 9596-9903 | vamerhn@gmail.com</td></tr>
  <tr><td colspan="6"></td></tr>

  <!-- TÍTULO -->
  <tr><td colspan="6" class="titulo">COTIZACIÓN</td></tr>

  <!-- INFO CLIENTE -->
  <tr>
    <td class="lbl">CLIENTE:</td>
    <td colspan="2"><?= htmlspecialchars($cliente) ?></td>
    <td class="lbl" style="white-space:nowrap">ELABORADO POR:</td>
    <td colspan="2"><b><?= htmlspecialchars($elaboradoExcel) ?></b></td>
  </tr>
  <tr>
    <td class="lbl">RTN:</td>
    <td colspan="2"><?= htmlspecialchars($rtn) ?></td>
    <td class="lbl">TELÉFONO:</td>
    <td colspan="2"><?= htmlspecialchars($telExcel) ?></td>
  </tr>
  <tr>
    <td class="lbl">DIRECCIÓN:</td>
    <td colspan="2"><?= htmlspecialchars($dir) ?></td>
    <td class="lbl" style="white-space:nowrap">COTIZACIÓN NO.:</td>
    <td colspan="2"><b><?= htmlspecialchars($num) ?></b></td>
  </tr>
  <tr>
    <td class="lbl">TELÉFONO:</td>
    <td colspan="2"><?= htmlspecialchars($tel) ?></td>
    <td class="lbl">FECHA:</td>
    <td colspan="2"><?= htmlspecialchars($fecha) ?></td>
  </tr>
  <tr>
    <td class="lbl">UNIDAD/PLACA:</td>
    <td colspan="5"><b><?= htmlspecialchars($unidad) ?></b></td>
  </tr>
  <tr><td colspan="6"></td></tr>

  <!-- CABECERA TABLA (sin columna UNIDAD) -->
  <tr>
    <td class="th" style="width:40pt">ITEM</td>
    <td class="th" style="width:55pt">CÓDIGO</td>
    <td class="th">DESCRIPCIÓN</td>
    <td class="th" style="width:45pt">CANT.</td>
    <td class="th" style="width:90pt">P. UNITARIO</td>
    <td class="th" style="width:90pt">TOTAL</td>
  </tr>

  <!-- ÍTEMS -->
  <?php foreach ($detalle as $i => $it):
      $cant2    = (float)$it['cantidad'];
      $pu2      = (float)$it['precio_unitario'];
      $subtotal = (float)($it['subtotal_final'] ?? ($cant2 * $pu2));
  ?>
  <tr>
    <td class="num"><?= $i + 1 ?></td>
    <td class="num"><?= $i + 1 ?></td>
    <td class="desc"><?= htmlspecialchars(strtoupper($it['descripcion'])) ?></td>
    <td class="num"><?= ($cant2 == 0 || $pu2 == 0) ? '—' : ($cant2 == (int)$cant2 ? (int)$cant2 : $f($cant2)) ?></td>
    <td class="monto"><?= $pu2 == 0 ? '—' : $f($pu2) ?></td>
    <td class="monto"><?= $subtotal == 0 ? '—' : $f($subtotal) ?></td>
  </tr>
  <?php endforeach; ?>

  <!-- Filas vacías mínimo 20 -->
  <?php for ($e = 0; $e < max(0, 20 - count($detalle)); $e++): ?>
  <tr>
    <td class="empty"></td><td class="empty"></td>
    <td class="empty" style="color:#CCC">-</td>
    <td class="empty"></td>
    <td class="empty" style="text-align:right;color:#CCC">-</td>
    <td class="empty" style="text-align:right;color:#CCC">-</td>
  </tr>
  <?php endfor; ?>

  <tr><td colspan="6"></td></tr>

  <!-- OBSERVACIONES -->
  <?php if ($obs): ?>
  <tr><td class="lbl" colspan="6">OBSERVACIONES:</td></tr>
  <tr><td colspan="6"><?= htmlspecialchars($obs) ?></td></tr>
  <tr><td colspan="6"></td></tr>
  <?php endif; ?>

  <!-- TOTALES -->
  <?php
    // SUB-TOTAL = suma bruta de todos los ítems sin descontar
    $sub_bruto2 = 0;
    foreach ($c['detalle'] as $dit2b) {
        $sub_bruto2 += (float)$dit2b['cantidad'] * (float)$dit2b['precio_unitario'];
    }
    $sub_bruto2 = round($sub_bruto2, 2);

    $desc_mto_pdf2 = (float)($c['descuento_monto'] ?? 0);
    $desc_pct_pdf2 = (float)($c['descuento_porcentaje'] ?? 0);
    if ($desc_mto_pdf2 == 0 && !empty($c['detalle'])) {
        foreach ($c['detalle'] as $dit2) {
            $dsub2 = (float)$dit2['cantidad'] * (float)$dit2['precio_unitario'];
            $dpct2 = (float)($dit2['descuento_porcentaje'] ?? 0);
            $dmto2 = $dpct2 > 0 ? round($dsub2 * $dpct2 / 100, 2) : (float)($dit2['descuento_monto'] ?? 0);
            $desc_mto_pdf2 += $dmto2;
        }
        $desc_mto_pdf2 = round($desc_mto_pdf2, 2);
    }
    $base_isv2    = max(0, $sub_bruto2 - $desc_mto_pdf2);
    $isv_final2   = round($base_isv2 * 0.15, 2);
    $total_final2 = round($base_isv2 + $isv_final2, 2);
  ?>
  <tr>
    <td colspan="4"></td>
    <td class="total-lbl">SUB-TOTAL</td>
    <td class="total-val"><?= $f($sub_bruto2) ?></td>
  </tr>
  <?php if ($desc_mto_pdf2 > 0): ?>
  <tr style="color:#c0392b">
    <td colspan="4"></td>
    <td class="total-lbl">DESC./REBAJA<?= $desc_pct_pdf2 > 0 ? ' (' . $desc_pct_pdf2 . '%)' : '' ?></td>
    <td class="total-val"><?= $f($desc_mto_pdf2) ?></td>
  </tr>
  <?php endif; ?>
  <tr>
    <td colspan="4"></td>
    <td class="total-lbl">ISV</td>
    <td class="total-val"><?= $f($isv_final2) ?></td>
  </tr>
  <tr>
    <td colspan="4"></td>
    <td class="grand-total">TOTAL</td>
    <td class="grand-total"><?= $f($total_final2) ?></td>
  </tr>
  <tr><td colspan="6"></td></tr>

  <!-- FIRMA -->
  <tr><td colspan="6"><b>AUTORIZADO POR: &nbsp; <?= htmlspecialchars($autorizadoExcel) ?></b></td></tr>

</table>
</body>
</html>
<?php
    exit;
}

function responder(int $code, string $msg): void {
    http_response_code($code); echo $msg; exit;
}
