// ══════════════════════════════════════════════════════════
// reportes.js — Reportes
// Extraído de dashboard.js líneas 3972-4051
// ══════════════════════════════════════════════════════════

// ── REPORTES ──────────────────────────────────────────────
let reporteActual = 'ventas';
let reporteData   = [];

function switchReporte(tipo) {
  reporteActual = tipo;
  ['ventas','cxc','retenciones','rentabilidad','inventario'].forEach(t => {
    document.getElementById('rptab' + t.charAt(0).toUpperCase()+t.slice(1))?.classList.toggle('active', t===tipo);
  });
  document.getElementById('tablaReporte').innerHTML = '<p style="color:var(--muted);text-align:center;padding:40px">Haz clic en Consultar.</p>';
  document.getElementById('reporteKpis').style.display = 'none';
  document.getElementById('rpMes').style.display = tipo === 'cxc' ? 'none' : '';
}

async function ejecutarReporte() {
  document.getElementById('tablaReporte').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('reporteKpis').style.display = 'none';
  const mes  = document.getElementById('rpMes').value;
  const anio = document.getElementById('rpAnio').value;
  let url = `controllers/ReportesController.php?action=${reporteActual}&anio=${anio}`;
  if (mes) url += '&mes=' + mes;
  const r = await api(url);
  if (!r.ok) {
    document.getElementById('tablaReporte').innerHTML = '<p style="color:var(--danger)">' + (r.data?.error || 'Error al cargar reporte.') + '</p>';
    return;
  }
  reporteData = r.data.data || [];
  paginaActual['reporte'] = 1;
  renderReporte(r.data);
}

function renderReporte(data) {
  const rows = data.data || [];
  if (!rows.length) { document.getElementById('tablaReporte').innerHTML='<p class="empty-state">Sin datos para el período.</p>'; return; }
  const kpisEl = document.getElementById('reporteKpis');
  if (data.totales) {
    const t = data.totales;
    let kh = '<div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:4px">';
    Object.entries(t).forEach(([k,v]) => {
      const label = k.replace(/_/g,' ');
      const val   = typeof v === 'number' && v > 100 ? fmtMoneda(v) : v;
      kh += `<div class="kpi-card" style="min-width:130px"><div class="kpi-label">${label}</div><div class="kpi-val" style="font-size:16px">${val}</div></div>`;
    });
    kh += '</div>';
    kpisEl.innerHTML = kh;
    kpisEl.style.display = 'block';
  } else { kpisEl.style.display = 'none'; }
  const pag  = paginar('reporte', rows);
  const cols = Object.keys(rows[0]);
  let h = '<table><thead><tr>' + cols.map(c => `<th>${c.replace(/_/g,' ')}</th>`).join('') + '</tr></thead><tbody>';
  pag.slice.forEach(row => {
    h += '<tr>' + cols.map(c => {
      const v = row[c];
      if (v === null || v === undefined) return '<td>—</td>';
      if (!isNaN(parseFloat(v)) && String(v).match(/^\d+\.?\d*$/) && parseFloat(v) > 100 && String(v).includes('.'))
        return `<td>${fmtMoneda(parseFloat(v))}</td>`;
      return `<td>${v}</td>`;
    }).join('') + '</tr>';
  });
  h += '</tbody></table>';
  document.getElementById('tablaReporte').innerHTML = h;
  renderPaginacion('reporte', pag, 'paginaReporte');
}

function exportarReporteExcel() {
  const mes  = document.getElementById('rpMes').value;
  const anio = document.getElementById('rpAnio').value;
  let url = `controllers/ReportesController.php?action=${reporteActual}&format=excel&anio=${anio}`;
  if (mes) url += '&mes=' + mes;
  window.location.href = url;
}

// ── Loader + paginación ───────────────────────────────────
async function cargarModuloPlanillas() {
  planillasData  = [];
  especialesData = [];
  await cargarEmpleados();
}


