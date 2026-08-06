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

async function cargarLibroVentas() {
  const mes  = document.getElementById('libroMes').value;
  const anio = document.getElementById('libroAnio').value;
  document.getElementById('tablaLibro').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('libroResumen').style.display = 'none';

  const r = await api(`controllers/FacturacionController.php?action=libro_ventas&mes=${mes}&anio=${anio}`);
  if (!r.ok) { document.getElementById('tablaLibro').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  const data = r.data.data;

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
      <th>Total</th><th>Método</th><th>Estado</th>
    </tr></thead><tbody>`;

  data.filas.forEach((f, i) => {
    const anulada = f.estado === 'anulada';
    const ref = f.numero_cotizacion || f.numero_orden || '—';
    h += `<tr style="${anulada ? 'opacity:.5;text-decoration:line-through' : ''}">
      <td style="color:var(--muted);font-size:12px">${i + 1}</td>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.fecha}</td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.rtn_cliente || '—'}</td>
      <td style="font-size:11px">${ref}</td>
      <td>${fmtMoneda(f.subtotal)}</td>
      <td>${fmtMoneda(f.isv)}</td>
      <td><strong style="color:${anulada ? 'var(--muted)' : 'var(--accent)'}">${fmtMoneda(f.total)}</strong></td>
      <td><span class="badge badge-gray">${f.metodo_pago || '—'}</span></td>
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

