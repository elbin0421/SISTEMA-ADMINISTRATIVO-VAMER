// ══════════════════════════════════════════════════════════
// inicio.js — Inicio / KPIs del dashboard
// Extraído de dashboard.js líneas 273-399
// ══════════════════════════════════════════════════════════

// ── INICIO / KPIs ────────────────────────────────────────────
let _chartIngresos = null;

function navegarModulo(mod) {
  const el = document.querySelector(`.nav-item[data-module="${mod}"]`);
  if (el) el.click();
}

async function cargarInicio() {
  const [rKpi, rGraf] = await Promise.all([
    api('controllers/DashboardController.php?action=kpis'),
    api('controllers/DashboardController.php?action=grafico_ventas'),
  ]);

  if (rKpi.ok) {
    const d = rKpi.data.data;

    // Ventas del día
    const elVD = document.getElementById('kpiVentasDia');
    if (elVD) elVD.textContent = fmtMoneda(d.ventas_dia?.monto || 0);
    const elVDC = document.getElementById('kpiVentasDiaCant');
    if (elVDC) elVDC.textContent = (d.ventas_dia?.cant || 0) + ' facturas';

    // CxC
    const elCxC = document.getElementById('kpiCxC');
    if (elCxC) elCxC.textContent = fmtMoneda(d.cxc?.monto || 0);
    const elCxCC = document.getElementById('kpiCxCCant');
    if (elCxCC) elCxCC.textContent = (d.cxc?.cant || 0) + ' facturas pendientes';

    // OC pendientes de factura
    const elOC = document.getElementById('kpiOCPend');
    if (elOC) elOC.textContent = fmtMoneda(d.oc_pend?.monto || 0);
    const elOCC = document.getElementById('kpiOCPendCant');
    if (elOCC) elOCC.textContent = (d.oc_pend?.cant || 0) + ' cots. sin facturar';

    // OT en proceso
    const elOT = document.getElementById('kpiOTProceso');
    if (elOT) elOT.textContent = d.ot_proceso || 0;

    // Stock bajo mínimo
    const elSB = document.getElementById('kpiStockBajo');
    if (elSB) elSB.textContent = d.stock_bajo || 0;

    // Cotizaciones recientes
    const elCot = document.getElementById('inicioCotizaciones');
    if (elCot) {
      const cots = d.cotizaciones || [];
      if (!cots.length) {
        elCot.innerHTML = '<p style="color:var(--muted);font-size:13px;padding:8px 0">Sin cotizaciones recientes.</p>';
      } else {
        elCot.innerHTML = cots.map(c => `
          <div style="display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border);font-size:13px">
            <div>
              <div style="font-weight:600;font-family:monospace">${c.numero_cotizacion}</div>
              <div style="color:var(--muted);font-size:11px">${c.cliente} · ${c.fecha}</div>
            </div>
            <div style="text-align:right">
              <div style="font-weight:600;color:var(--accent)">${fmtMoneda(c.total)}</div>
              <div>${badgeEstado(c.estado)}</div>
            </div>
          </div>`).join('');
      }
    }

    // OT recientes
    const elOTR = document.getElementById('otRecientes');
    if (elOTR) {
      const rows = d.ot_recientes || [];
      let h = '<table><thead><tr><th>OT</th><th>Cliente</th><th>Vehículo</th><th>Apertura</th><th>Estado</th></tr></thead><tbody>';
      if (!rows.length) h += '<tr><td colspan="5" class="empty-state">Sin órdenes recientes</td></tr>';
      rows.forEach(o => {
        const veh = [o.marca, o.modelo, o.placa].filter(Boolean).join(' ') || '—';
        h += `<tr>
          <td><strong>${o.numero_orden}</strong></td>
          <td>${o.cliente}</td>
          <td style="font-size:12px;color:var(--muted)">${veh}</td>
          <td style="font-size:12px">${o.fecha_apertura}</td>
          <td>${badgeEstado(o.estado)}</td>
        </tr>`;
      });
      h += '</tbody></table>';
      elOTR.innerHTML = h;
    }
  }

  // Gráfico
  const canvas = document.getElementById('graficoIngresos');
  const loading = document.getElementById('graficoLoading');
  if (canvas && rGraf.ok) {
    if (loading) loading.style.display = 'none';
    if (_chartIngresos) { _chartIngresos.destroy(); _chartIngresos = null; }
    const rows = rGraf.data.data || [];
    const textColor = '#888';
    _chartIngresos = new Chart(canvas, {
      type: 'bar',
      data: {
        labels: rows.map(r => r.label),
        datasets: [{
          label: 'Ingresos (L.)',
          data: rows.map(r => parseFloat(r.total)),
          backgroundColor: 'rgba(232,160,32,0.75)',
          borderColor: 'rgba(232,160,32,1)',
          borderWidth: 2,
          borderRadius: 6,
          hoverBackgroundColor: 'rgba(232,160,32,0.95)',
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: { callbacks: { label: ctx => ' ' + fmtMoneda(ctx.parsed.y) } }
        },
        scales: {
          x: { ticks: { color: textColor, font: { size: 11 } }, grid: { display: false } },
          y: {
            ticks: { color: textColor, font: { size: 11 }, callback: v => 'L.' + (v >= 1000 ? (v/1000).toFixed(0)+'k' : v) },
            grid: { color: 'rgba(128,128,128,.1)' }
          }
        }
      }
    });
    if (!rows.length && loading) { loading.textContent = 'Sin datos de ventas aún.'; loading.style.display = 'flex'; }
  }
}

