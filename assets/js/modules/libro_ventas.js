// ══════════════════════════════════════════════════════════
// libro_ventas.js — Libro de Ventas
// Extraído de dashboard.js líneas 2611-2691
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// FASE 3 — LIBRO DE VENTAS
// ══════════════════════════════════════════════════════════
function initLibroVentas() {
  // Setear mes/año actuales en los selects
  const now = new Date();
  const mesActual  = String(now.getMonth() + 1).padStart(2, '0');
  const anioActual = String(now.getFullYear());
  const selMes  = document.getElementById('libroMes');
  const selAnio = document.getElementById('libroAnio');
  if (selMes)  selMes.value  = mesActual;
  if (selAnio) selAnio.value = anioActual;
}

let libroVentasDataActual = null;

// Valores a mostrar de una fila del Libro. Las facturas anuladas salen sin
// cliente ni RTN, con valores en cero y la palabra ANULADA en la columna Cliente.
function filaLibroVentas(f) {
  const anulada = f.estado === 'anulada';
  return {
    anulada,
    cliente:  anulada ? 'ANULADA' : (f.cliente || ''),
    rtn:      anulada ? '' : (f.rtn_cliente || ''),
    subtotal: anulada ? 0 : parseFloat(f.subtotal || 0),
    isv:      anulada ? 0 : parseFloat(f.isv || 0),
    total:    anulada ? 0 : parseFloat(f.total || 0),
    cai:      f.cai_codigo || '',
    ref:      f.numero_cotizacion || f.numero_orden || '',
  };
}

async function cargarLibroVentas() {
  const mes  = document.getElementById('libroMes').value;
  const anio = document.getElementById('libroAnio').value;
  document.getElementById('tablaLibro').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('libroResumen').style.display = 'none';
  libroVentasDataActual = null;

  const r = await api(`controllers/FacturacionController.php?action=libro_ventas&mes=${mes}&anio=${anio}`);
  if (!r.ok) { document.getElementById('tablaLibro').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  const data = r.data.data;
  libroVentasDataActual = { mes, anio, ...data };

  // Actualizar resumen
  document.getElementById('libroTotalFacturas').textContent = data.total_facturas;
  document.getElementById('libroTotalSubtotal').textContent = fmtMoneda(data.total_subtotal);
  document.getElementById('libroTotalISV').textContent      = fmtMoneda(data.total_isv);
  document.getElementById('libroTotalGeneral').textContent  = fmtMoneda(data.total_general);
  document.getElementById('libroResumen').style.display     = 'grid';

  if (!data.filas.length) {
    document.getElementById('tablaLibro').innerHTML = '<p class="empty-state">Sin facturas para este período</p>';
    return;
  }

  let h = `<table>
    <thead><tr>
      <th>No.</th><th>Número Factura</th><th>Fecha</th>
      <th>Cliente</th><th>RTN Cliente</th>
      <th>OT / Cotización</th><th>Subtotal</th><th>ISV 15%</th>
      <th>Total</th><th>CAI</th><th>Estado</th>
    </tr></thead><tbody>`;

  data.filas.forEach((f, i) => {
    const v = filaLibroVentas(f);
    h += `<tr>
      <td style="color:var(--muted);font-size:12px">${i + 1}</td>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.fecha}</td>
      <td>${v.anulada ? '<strong style="color:var(--danger)">ANULADA</strong>' : v.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${v.rtn || '—'}</td>
      <td style="font-size:11px">${v.ref || '—'}</td>
      <td>${fmtMoneda(v.subtotal)}</td>
      <td>${fmtMoneda(v.isv)}</td>
      <td><strong style="color:${v.anulada ? 'var(--muted)' : 'var(--accent)'}">${fmtMoneda(v.total)}</strong></td>
      <td style="font-family:monospace;font-size:10px;word-break:break-all">${v.cai || '—'}</td>
      <td>${badgeEstado(f.estado)}</td>
    </tr>`;
  });

  // Fila de totales
  h += `<tr style="background:var(--bg);font-weight:600;border-top:2px solid var(--border)">
    <td colspan="6" style="text-align:right;color:var(--muted);font-size:12px">TOTALES DEL PERÍODO</td>
    <td>${fmtMoneda(data.total_subtotal)}</td>
    <td>${fmtMoneda(data.total_isv)}</td>
    <td style="color:var(--accent)">${fmtMoneda(data.total_general)}</td>
    <td colspan="2"></td>
  </tr>`;
  h += '</tbody></table>';
  document.getElementById('tablaLibro').innerHTML = h;
}

// Inicializar libro de ventas cuando se active el módulo
document.querySelectorAll('.nav-item[data-module]').forEach(el => {
  if (el.dataset.module === 'libro_ventas') {
    el.addEventListener('click', function() { initLibroVentas(); });
  }
});

const MESES_LIBRO_VENTAS = {
  '01':'Enero','02':'Febrero','03':'Marzo','04':'Abril','05':'Mayo','06':'Junio',
  '07':'Julio','08':'Agosto','09':'Septiembre','10':'Octubre','11':'Noviembre','12':'Diciembre',
};

function exportarLibroVentasExcel() {
  if (!libroVentasDataActual || !libroVentasDataActual.filas) { toast('Consulta un período primero.', 'warn'); return; }
  const d = libroVentasDataActual;

  const rows = [
    ['LIBRO DE VENTAS'],
    [`${MESES_LIBRO_VENTAS[d.mes] || d.mes} ${d.anio}`],
    [],
    ['No.','Número Factura','Fecha','Cliente','RTN Cliente','OT / Cotización','Subtotal','ISV 15%','Total','CAI','Estado'],
    ...d.filas.map((f, i) => {
      const v = filaLibroVentas(f);
      return [
        i + 1, f.numero_factura, f.fecha, v.cliente, v.rtn, v.ref,
        v.subtotal, v.isv, v.total, v.cai, f.estado,
      ];
    }),
    [],
    ['', '', '', '', '', 'TOTALES DEL PERÍODO', parseFloat(d.total_subtotal || 0), parseFloat(d.total_isv || 0), parseFloat(d.total_general || 0), '', ''],
  ];

  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [5,20,11,26,14,16,12,12,12,40,12].map(w => ({ wch: w }));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Libro de Ventas');
  XLSX.writeFile(wb, `Libro_Ventas_${d.mes}_${d.anio}.xlsx`);
}

function exportarLibroVentasPDF() {
  if (!libroVentasDataActual || !libroVentasDataActual.filas) { toast('Consulta un período primero.', 'warn'); return; }
  const d = libroVentasDataActual;
  const periodo = `${MESES_LIBRO_VENTAS[d.mes] || d.mes} ${d.anio}`;

  const filasHtml = d.filas.map((f, i) => {
    const v = filaLibroVentas(f);
    return `<tr>
      <td>${i + 1}</td>
      <td style="font-family:monospace">${f.numero_factura}</td>
      <td>${f.fecha}</td>
      <td>${v.anulada ? '<strong>ANULADA</strong>' : v.cliente}</td>
      <td>${v.rtn || '—'}</td>
      <td>${v.ref || '—'}</td>
      <td style="text-align:right">${fmtMoneda(v.subtotal)}</td>
      <td style="text-align:right">${fmtMoneda(v.isv)}</td>
      <td style="text-align:right;font-weight:700">${fmtMoneda(v.total)}</td>
      <td style="font-family:monospace;font-size:8px;word-break:break-all">${v.cai || '—'}</td>
      <td>${f.estado}</td>
    </tr>`;
  }).join('');

  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8">
  <title>Libro de Ventas ${periodo}</title>
  <style>
    body{font-family:Arial,sans-serif;font-size:11px;padding:20px;color:#111}
    h2{text-align:center;margin-bottom:2px}
    p.sub{text-align:center;color:#555;margin:2px 0 16px}
    table{width:100%;border-collapse:collapse}
    th,td{border:1px solid #ccc;padding:4px 6px;font-size:10px}
    th{background:#f0f0f0;text-align:left}
    tfoot td{font-weight:700;background:#f7f7f7}
    .resumen{display:flex;gap:24px;justify-content:center;margin-bottom:16px;font-size:12px}
    .resumen div{text-align:center}
    .resumen strong{display:block;font-size:15px}
    @media print{@page{size:landscape;margin:10mm}}
  </style></head><body>
  <h2>LIBRO DE VENTAS</h2>
  <p class="sub">VENTAS AMERICA S. DE R.L — Período: ${periodo}</p>
  <div class="resumen">
    <div>Facturas emitidas<strong>${d.total_facturas}</strong></div>
    <div>Subtotal<strong>${fmtMoneda(d.total_subtotal)}</strong></div>
    <div>ISV 15%<strong>${fmtMoneda(d.total_isv)}</strong></div>
    <div>Total general<strong>${fmtMoneda(d.total_general)}</strong></div>
  </div>
  <table>
    <thead><tr>
      <th>No.</th><th>Número Factura</th><th>Fecha</th><th>Cliente</th><th>RTN Cliente</th>
      <th>OT / Cotización</th><th>Subtotal</th><th>ISV 15%</th><th>Total</th><th>CAI</th><th>Estado</th>
    </tr></thead>
    <tbody>${filasHtml}</tbody>
    <tfoot><tr>
      <td colspan="6" style="text-align:right">TOTALES DEL PERÍODO</td>
      <td style="text-align:right">${fmtMoneda(d.total_subtotal)}</td>
      <td style="text-align:right">${fmtMoneda(d.total_isv)}</td>
      <td style="text-align:right">${fmtMoneda(d.total_general)}</td>
      <td colspan="2"></td>
    </tr></tfoot>
  </table>
  <script>window.onload=()=>window.print()<\/script>
  </body></html>`;
  const w = window.open('', '_blank');
  w.document.write(html);
  w.document.close();
}

