<?php
// ============================================================
//  VAMER / SOLDYMEG — FacturaPDFController
//  Genera el PDF de factura replicando el formulario preimpreso
//  membretado VAMER (SAR Honduras).
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/FacturaModel.php';

$sesion = requireAuth();

$id = (int)($_GET['id'] ?? 0);
if (!$id) { http_response_code(400); echo 'ID requerido'; exit; }

$f = FacturaModel::obtener($id);
if (!$f) { http_response_code(404); echo 'Factura no encontrada'; exit; }

generarPDF($f);
exit;

function generarPDF(array $f): void {
    $fmt = fn($n) => number_format((float)$n, 2, '.', ',');

    // ── Número de factura formateado 000-001-01-00000021 ──
    $numFactura = $f['numero_factura'] ?? '';
    // Si ya viene formateado tal cual, se usa directo; si no, se arma con establecimiento/punto_emision
    if (strpos($numFactura, '-') === false && ctype_digit((string)$numFactura)) {
        $estab = str_pad($f['establecimiento'] ?? '001', 3, '0', STR_PAD_LEFT);
        $punto = str_pad($f['punto_emision']   ?? '01',  2, '0', STR_PAD_LEFT);
        $corr  = str_pad((string)$numFactura, 8, '0', STR_PAD_LEFT);
        $numFactura = "{$estab}-{$punto}-00-{$corr}";
    }
    $numParts = explode('-', $numFactura);
    $correlativoResaltado = end($numParts); // últimos dígitos en rojo

    $fecha = $f['fecha'] ?? date('Y-m-d');
    $fd = date('d', strtotime($fecha));
    $fm = date('m', strtotime($fecha));
    $fy = date('Y', strtotime($fecha));

    // ── Totales ──
    $subtotal   = (float)($f['subtotal'] ?? 0);
    $isv        = (float)($f['isv'] ?? 0);
    $total      = (float)($f['total'] ?? 0);
    $descPct    = (float)($f['descuento_porcentaje'] ?? 0);
    $descMonto  = (float)($f['descuento_monto'] ?? 0);

    // Rango autorizado / CAI
    $cai        = $f['cai_codigo'] ?? '';
    $fechaLimite= !empty($f['fecha_limite_emision']) ? date('d-M-Y', strtotime($f['fecha_limite_emision'])) : '';
    $rangoIni   = $f['rango_inicio'] ?? '';
    $rangoFin   = $f['rango_fin'] ?? '';

    // Cantidad en letras
    $helperPath = __DIR__ . '/../helpers/numero_a_letras.php';
    if (file_exists($helperPath)) require_once $helperPath;
    $cantidadLetras = function_exists('numeroALetras') ? numeroALetras($total) : '';

    header('Content-Type: text/html; charset=UTF-8');
    ?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Factura <?= htmlspecialchars($numFactura) ?></title>
<style>
  @page { size: letter; margin: 10mm; }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: 'Georgia', 'Times New Roman', serif;
    font-size: 10.5px;
    color: #1a1a1a;
    background: #cfe8e0;
    padding: 14px;
  }
  .hoja {
    background: #cfe8e0;
    max-width: 800px;
    margin: 0 auto;
    border: 2px solid #1a1a1a;
    padding: 14px 16px;
  }

  /* ── ENCABEZADO ── */
  .top { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 6px; }
  .logo-block { display: flex; gap: 10px; align-items: flex-start; }
  .logo-img { width: 68px; height: auto; flex-shrink: 0; }
  .empresa-nombre { font-size: 20px; font-weight: bold; letter-spacing: 1px; margin-top: 4px; }
  .empresa-datos { font-size: 20px; font-weight: bold; line-height: 1.25; margin-bottom: 2px; }
  .empresa-info { font-size: 10px; line-height: 1.5; margin-top: 3px; }
  .empresa-info div { display: flex; align-items: center; gap: 4px; }

  .factura-box { text-align: right; }
  .factura-box .titulo { font-size: 22px; font-weight: bold; letter-spacing: 2px; margin-bottom: 4px; }
  .factura-box .numero { font-size: 15px; font-weight: bold; }
  .factura-box .numero .rojo { color: #c0392b; }
  .fecha-tabla { border-collapse: collapse; margin-top: 6px; margin-left: auto; }
  .fecha-tabla th, .fecha-tabla td {
    border: 1px solid #1a1a1a; padding: 3px 14px; font-size: 9px; text-align: center;
    background: #b8d8ce;
  }
  .fecha-tabla th { font-weight: bold; }

  /* ── DATOS CLIENTE ── */
  .cliente-box { border: 1px solid #1a1a1a; margin-top: 6px; }
  .cliente-fila { display: flex; border-bottom: 1px solid #1a1a1a; }
  .cliente-fila:last-child { border-bottom: none; }
  .cliente-fila .label { font-weight: bold; padding: 4px 8px; white-space: nowrap; font-size: 11px; }
  .cliente-fila .valor { flex: 1; padding: 4px 8px; font-size: 11px; border-left: 1px solid #1a1a1a; }

  /* ── TABLA DE ÍTEMS ── */
  table.items { width: 100%; border-collapse: collapse; margin-top: 6px; }
  table.items thead th {
    background: #1a1a1a; color: #fff; padding: 6px 4px; font-size: 11px;
    text-transform: uppercase; letter-spacing: .5px; border: 1px solid #1a1a1a;
  }
  table.items tbody td {
    border: 1px solid #1a1a1a; height: 20px; font-size: 10.5px; padding: 2px 6px; vertical-align: top;
  }
  table.items tbody td.num { text-align: center; }
  table.items tbody td.monto { text-align: right; }

  /* ── PIE ── */
  .pie { display: flex; justify-content: space-between; margin-top: 6px; gap: 12px; }
  .pie-izq { flex: 1; font-size: 9.5px; }
  .pie-izq .orig-dup { margin-bottom: 8px; }
  .cantidad-letras { margin: 8px 0; border-bottom: 1px solid #1a1a1a; padding-bottom: 14px; }

  .totales-tabla { border-collapse: collapse; }
  .totales-tabla td {
    border: 1px solid #1a1a1a; font-size: 10px; padding: 3px 8px;
  }
  .totales-tabla td.lbl { background: #1a1a1a; color: #fff; font-weight: bold; text-align: right; min-width: 190px; }
  .totales-tabla td.val { background: #b8d8ce; text-align: right; min-width: 90px; font-weight: bold; }
  .totales-tabla tr.total-final td.lbl { background: #1a1a1a; font-size: 11px; }
  .totales-tabla tr.total-final td.val { font-size: 12px; }

  .cai-box { font-size: 10px; margin-top: 10px; line-height: 1.6; }
  .cai-box b { font-weight: bold; }

  .exonerado-tabla { border-collapse: collapse; margin-top: 6px; width: 100%; max-width: 340px; }
  .exonerado-tabla td { border: 1px solid #1a1a1a; font-size: 8px; padding: 2px 6px; }
  .exonerado-tabla td.head { font-weight: bold; background: #b8d8ce; }

  .firma-final { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 30px; }
  .firma-linea { border-top: 1px solid #1a1a1a; width: 220px; text-align: center; font-size: 9.5px; padding-top: 3px; }
  .lema { font-style: italic; font-size: 11px; font-weight: bold; }

  @media print {
    body { background: #fff; padding: 0; }
    .hoja { border: none; }
  }
</style>
</head>
<body>
<div class="hoja">

  <!-- ENCABEZADO -->
  <div class="top">
    <div class="logo-block">
      <img src="../assets/img/VAMER.png" alt="VAMER" class="logo-img" onerror="this.style.display='none'">
      <div>
        <div class="empresa-datos">VENTAS AMERICA SOCIEDAD DE<br>RESPONSABILIDAD LIMITADA</div>
        <div class="empresa-info">
          <div>📍 Col. San Sebastián, Calpules,<br>&nbsp;&nbsp;&nbsp;a dos cuadras de CA-13, San Pedro Sula, Cortés.</div>
          <div>📞 Cel: 9941-8647 &nbsp;|&nbsp; ✉️ vamerhn@gmail.com</div>
        </div>
      </div>
    </div>
    <div class="factura-box">
      <div class="titulo">FACTURA</div>
      <div class="numero">No. <?= htmlspecialchars(implode('-', array_slice($numParts, 0, -1))) ?>-<span class="rojo"><?= htmlspecialchars($correlativoResaltado) ?></span></div>
      <table class="fecha-tabla">
        <thead><tr><th>DIA</th><th>MES</th><th>AÑO</th></tr></thead>
        <tbody><tr><td><?= $fd ?></td><td><?= $fm ?></td><td><?= $fy ?></td></tr></tbody>
      </table>
    </div>
  </div>
  <div style="font-size:11px;font-weight:bold;margin-top:2px">RTN: 05019026315890</div>

  <!-- DATOS CLIENTE -->
  <div class="cliente-box">
    <div class="cliente-fila"><div class="label">Cliente:</div><div class="valor"><?= htmlspecialchars($f['cliente'] ?? '') ?></div></div>
    <div class="cliente-fila"><div class="label">RTN:</div><div class="valor"><?= htmlspecialchars($f['cliente_rtn'] ?? '') ?></div></div>
    <div class="cliente-fila"><div class="label">Dirección:</div><div class="valor"><?= htmlspecialchars($f['cliente_direccion'] ?? '') ?></div></div>
  </div>

  <!-- TABLA DE ITEMS -->
  <table class="items">
    <thead>
      <tr>
        <th style="width:8%">CANT.</th>
        <th style="width:52%">DESCRIPCION</th>
        <th style="width:18%">P. UNITARIO</th>
        <th style="width:22%">TOTAL</th>
      </tr>
    </thead>
    <tbody>
      <?php
        $filas = $f['detalle'] ?? [];
        $totalFilas = 19; // mismas filas que el formulario físico
        foreach ($filas as $d):
          $cant = (float)($d['cantidad'] ?? 0);
          $pu   = (float)($d['precio_unitario'] ?? 0);
          $tot  = (float)($d['subtotal_final'] ?? ($cant * $pu));
      ?>
      <tr>
        <td class="num"><?= $cant == 0 ? '—' : ($cant == (int)$cant ? (int)$cant : $cant) ?></td>
        <td><?= htmlspecialchars(strtoupper($d['descripcion'] ?? '')) ?></td>
        <td class="monto"><?= $pu == 0 ? '—' : $fmt($pu) ?></td>
        <td class="monto"><?= $tot == 0 ? '—' : $fmt($tot) ?></td>
      </tr>
      <?php endforeach; ?>
      <?php for ($i = count($filas); $i < $totalFilas; $i++): ?>
      <tr><td>&nbsp;</td><td></td><td></td><td></td></tr>
      <?php endfor; ?>
    </tbody>
  </table>

  <!-- PIE -->
  <div class="pie">
    <div class="pie-izq">
      <div class="orig-dup">Original: Cliente &nbsp;-&nbsp; Duplicado (a): Obligado Tributario Emisor</div>
      <div class="cantidad-letras">Cantidad en letras: <?= htmlspecialchars($cantidadLetras) ?></div>

      <div class="cai-box">
        <div><b>CAI:</b> <?= htmlspecialchars($cai) ?></div>
        <div><b>Fecha Límite de Emisión:</b> <?= htmlspecialchars($fechaLimite) ?></div>
        <div><b>Rango Autorizado:</b> <?= htmlspecialchars($rangoIni) ?> AL <?= htmlspecialchars($rangoFin) ?></div>
      </div>

      <table class="exonerado-tabla">
        <tr><td class="head" colspan="2">DATOS DE ADQUIRIENTE EXONERADO</td></tr>
        <tr><td>N° Correlativo de Orden de Compra Exenta</td><td></td></tr>
        <tr><td>N° Correlativo de Constancia de Registro Exonerado</td><td></td></tr>
        <tr><td>N° Identificativo del Registro de la SAG</td><td></td></tr>
      </table>
    </div>

    <div>
      <table class="totales-tabla">
        <tr><td class="lbl">DESC. Y REBAJAS OTORGADOS L</td><td class="val"><?= $descMonto > 0 ? $fmt($descMonto) : '' ?></td></tr>
        <tr><td class="lbl">IMPORTE EXONERADO L</td><td class="val"></td></tr>
        <tr><td class="lbl">IMPORTE EXENTO L</td><td class="val"></td></tr>
        <tr><td class="lbl">IMPORTE GRAVADO 15% L</td><td class="val"><?= $fmt($subtotal - $descMonto) ?></td></tr>
        <tr><td class="lbl">IMPORTE GRAVADO 18% L</td><td class="val"></td></tr>
        <tr><td class="lbl">ISV 15% L</td><td class="val"><?= $fmt($isv) ?></td></tr>
        <tr><td class="lbl">ISV 18% L</td><td class="val"></td></tr>
        <tr class="total-final"><td class="lbl">TOTAL A PAGAR L</td><td class="val"><?= $fmt($total) ?></td></tr>
      </table>
    </div>
  </div>

  <div class="firma-final">
    <div class="firma-linea">FIRMA DEL CLIENTE</div>
    <div class="lema">LA FACTURA ES BENEFICIO DE TODOS "EXÍJALA"</div>
  </div>

</div>
<script>window.onload = () => window.print();</script>
</body>
</html>
<?php
}
