// ══════════════════════════════════════════════════════════
// pagos.js — Pagos de Clientes / CxC
// Extraído de dashboard.js líneas 2806-3101
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// FASE 4 — MÓDULO PAGOS DE CLIENTES
// ══════════════════════════════════════════════════════════
let pagosData   = [];
let cxcData     = [];
let tabPagosActual = 'pagos';

// ── Loaders ──────────────────────────────────────────────
// loaders defined above
async function cargarModuloPagos() {
  await Promise.all([cargarKPIsPagos(), cargarPagos(), cargarCxC(), llenarSelectClientesCxC()]);
}

async function cargarKPIsPagos() {
  const r = await api('controllers/PagosController.php?action=kpis');
  if (!r.ok) return;
  const k = r.data.data;
  document.getElementById('kpiPagosTotal').textContent       = k.total_pagos        || '0';
  document.getElementById('kpiPagosCobrado').textContent     = fmtMoneda(k.total_cobrado   || 0);
  document.getElementById('kpiPagosNeto').textContent        = fmtMoneda(k.total_neto      || 0);
  document.getElementById('kpiPagosRetenciones').textContent = fmtMoneda((parseFloat(k.total_isr||0) + parseFloat(k.total_isv||0)));
}

async function cargarPagos() {
  document.getElementById('tablaPagos').innerHTML = '<p class="loading">Cargando...</p>';
  const mes    = document.getElementById('pagosFiltroMes').value;
  const anio   = document.getElementById('pagosFiltroAnio').value;
  const metodo = document.getElementById('pagosFiltroMetodo').value;
  let url = 'controllers/PagosController.php?action=listar';
  if (mes)    url += '&mes='    + mes;
  if (anio)   url += '&anio='   + anio;
  if (metodo) url += '&metodo_pago=' + metodo;
  const r = await api(url);
  if (!r.ok) { document.getElementById('tablaPagos').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  pagosData = r.data.data;
  document.getElementById('buscarPago').value = '';
  paginaActual['pagos'] = 1;
  renderTablaPagos(pagosData);
}

function filtrarPagos() {
  const q = document.getElementById('buscarPago').value.toLowerCase().trim();
  paginaActual['pagos'] = 1;
  if (!q) { renderTablaPagos(pagosData); return; }
  renderTablaPagos(pagosData.filter(p =>
    p.cliente.toLowerCase().includes(q) ||
    p.numero_factura.toLowerCase().includes(q) ||
    (p.referencia && p.referencia.toLowerCase().includes(q))
  ));
}

function renderTablaPagos(rows) {
  const pag = paginar('pagos', rows);
  const tieneRetenciones = rows.some(p => parseFloat(p.retencion_isr||0) > 0 || parseFloat(p.retencion_isv||0) > 0);
  let h = `<table><thead><tr>
    <th>Fecha</th><th>Factura</th><th>Cliente</th>
    <th>Monto</th>${tieneRetenciones ? '<th>Ret. ISR</th><th>Ret. ISV</th><th>Neto</th>' : ''}
    <th>Método</th><th>Referencia</th><th>Usuario</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += `<tr><td colspan="${tieneRetenciones?10:7}" class="empty-state">Sin pagos registrados</td></tr>`;
  const metodoIcon = { efectivo:'💵', tarjeta:'💳', transferencia:'🏦' };
  pag.slice.forEach(p => {
    const retISR = parseFloat(p.retencion_isr||0);
    const retISV = parseFloat(p.retencion_isv||0);
    h += `<tr>
      <td style="white-space:nowrap">${p.fecha}</td>
      <td><strong style="font-family:monospace;font-size:12px">${p.numero_factura}</strong></td>
      <td>${p.cliente}</td>
      <td><strong>${fmtMoneda(p.monto)}</strong></td>
      ${tieneRetenciones ? `
        <td style="color:var(--danger)">${retISR > 0 ? fmtMoneda(retISR) : '—'}</td>
        <td style="color:var(--danger)">${retISV > 0 ? fmtMoneda(retISV) : '—'}</td>
        <td style="color:var(--success)">${fmtMoneda(p.monto_neto)}</td>
      ` : ''}
      <td>${metodoIcon[p.metodo_pago]||''} ${p.metodo_pago}</td>
      <td style="font-size:12px;color:var(--muted)">${p.referencia||'—'}</td>
      <td style="font-size:12px">${p.usuario}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetallePago(${p.id_pago})">Ver</button>
        <button class="btn btn-sm btn-danger" onclick="anularPago(${p.id_pago},'${p.numero_factura}')">Anular</button>
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaPagos').innerHTML = h;
  renderPaginacion('pagos', pag, 'paginaPagos');
}

// ── Cuentas por Cobrar ───────────────────────────────────
async function cargarCxC() {
  document.getElementById('tablaCxC').innerHTML = '<p class="loading">Cargando...</p>';
  const cliente_id = document.getElementById('cxcFiltroCliente').value;
  let url = 'controllers/PagosController.php?action=cuentas_cobrar';
  if (cliente_id) url += '&cliente_id=' + cliente_id;
  const r = await api(url);
  if (!r.ok) { document.getElementById('tablaCxC').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  cxcData = r.data.data;
  document.getElementById('buscarCxC').value = '';
  paginaActual['cxc'] = 1;
  renderTablaCxC(cxcData);
}

function filtrarCxC() {
  const q = document.getElementById('buscarCxC').value.toLowerCase().trim();
  paginaActual['cxc'] = 1;
  if (!q) { renderTablaCxC(cxcData); return; }
  renderTablaCxC(cxcData.filter(f =>
    f.cliente.toLowerCase().includes(q) ||
    f.numero_factura.toLowerCase().includes(q)
  ));
}

function renderTablaCxC(rows) {
  const pag = paginar('cxc', rows);
  const totalPendiente = rows.reduce((s, r) => s + parseFloat(r.saldo_pendiente||0), 0);
  document.getElementById('cxcTotalPendiente').textContent = fmtMoneda(totalPendiente);
  let h = `<table><thead><tr>
    <th>Factura</th><th>Cliente</th><th>RTN</th><th>Fecha</th>
    <th>Total</th><th>Pagado</th><th>Saldo</th><th>Crédito</th><th>Estado crédito</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin cuentas pendientes ✅</td></tr>';
  pag.slice.forEach(f => {
    const diasCredito    = parseInt(f.dias_credito || 0);
    const diasTransc     = parseInt(f.dias_transcurridos || f.dias_vencido || 0);
    const diasVencido    = parseInt(f.dias_vencido || 0);
    const diasRestantes  = parseInt(f.dias_restantes || 0);

    // Columna "Crédito"
    const colCredito = diasCredito > 0
      ? `<span style="font-size:12px">${diasCredito}d</span>`
      : `<span style="font-size:11px;color:var(--muted)">Contado</span>`;

    // Columna "Estado crédito"
    let badgeCredito = '';
    if (diasCredito === 0) {
      // Sin crédito - vence al emitir
      if (diasTransc === 0)
        badgeCredito = `<span class="badge badge-al-dia">Al día</span>`;
      else
        badgeCredito = `<span class="badge badge-vencido">Vencido ${diasTransc}d</span>`;
    } else if (diasRestantes > 5) {
      badgeCredito = `<span class="badge badge-al-dia">Vigente · ${diasRestantes}d rest.</span>`;
    } else if (diasRestantes >= 0) {
      badgeCredito = `<span class="badge badge-por-vencer">Por vencer · ${diasRestantes}d</span>`;
    } else {
      badgeCredito = `<span class="badge badge-vencido">Vencido ${Math.abs(diasRestantes)}d</span>`;
    }

    h += `<tr>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.cliente_rtn||'—'}</td>
      <td style="white-space:nowrap">${f.fecha}</td>
      <td>${fmtMoneda(f.total)}</td>
      <td style="color:var(--success)">${fmtMoneda(f.total_pagado)}</td>
      <td><strong style="color:var(--danger)">${fmtMoneda(f.saldo_pendiente)}</strong></td>
      <td style="text-align:center">${colCredito}</td>
      <td>${badgeCredito}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-success" onclick="abrirPagoFactura(${f.id_factura},'${f.numero_factura}',${f.total},${f.total - f.total_pagado})">💳 Pagar</button>
        <button class="btn btn-sm btn-secondary" onclick="verHistorialCliente(${f.id_factura},'${f.cliente}')">Historial</button>
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaCxC').innerHTML = h;
  renderPaginacion('cxc', pag, 'paginaCxC');
}

async function llenarSelectClientesCxC() {
  const sel = document.getElementById('cxcFiltroCliente');
  if (sel.options.length > 1) return; // ya cargado
  const r = await api('controllers/ClientesController.php?action=listar&estado=activo');
  if (!r.ok) return;
  r.data.data.forEach(c => {
    const o = document.createElement('option');
    o.value = c.id_cliente;
    o.textContent = c.nombre;
    sel.appendChild(o);
  });
}

// ── Detalle y anulación de pago ──────────────────────────
async function verDetallePago(id) {
  document.getElementById('contenidoDetallePago').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('footerDetallePago').innerHTML =
    '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetallePago\')">Cerrar</button>';
  abrirModal('modalDetallePago');
  // Buscar en los datos ya cargados
  const pago = pagosData.find(p => p.id_pago === id);
  if (!pago) { document.getElementById('contenidoDetallePago').innerHTML = '<p style="color:var(--danger)">No encontrado.</p>'; return; }
  const retISR = parseFloat(pago.retencion_isr||0);
  const retISV = parseFloat(pago.retencion_isv||0);
  const tieneRet = retISR > 0 || retISV > 0;
  const metodoIcon = { efectivo:'💵 Efectivo', tarjeta:'💳 Tarjeta', transferencia:'🏦 Transferencia' };
  let h = `
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;font-size:13px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:12px">
    <div><span style="color:var(--muted)">Factura:</span> <strong style="font-family:monospace">${pago.numero_factura}</strong></div>
    <div><span style="color:var(--muted)">Fecha:</span> ${pago.fecha}</div>
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${pago.cliente}</strong></div>
    <div><span style="color:var(--muted)">Método:</span> ${metodoIcon[pago.metodo_pago]||pago.metodo_pago}</div>
    ${pago.referencia ? `<div style="grid-column:1/-1"><span style="color:var(--muted)">Referencia:</span> ${pago.referencia}</div>` : ''}
    <div><span style="color:var(--muted)">Registrado por:</span> ${pago.usuario}</div>
    <div><span style="color:var(--muted)">Concepto:</span> ${pago.concepto||'—'}</div>
  </div>
  <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;font-size:13px;line-height:2.2">
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">Monto bruto:</span> <strong>${fmtMoneda(pago.monto)}</strong></div>
    ${tieneRet ? `
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Retención ISR 1%:</span> <span style="color:var(--danger)">${fmtMoneda(retISR)}</span></div>
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Retención ISV 12.5%:</span> <span style="color:var(--danger)">${fmtMoneda(retISV)}</span></div>
    <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:6px;margin-top:4px">
      <span style="font-weight:600">Neto recibido:</span>
      <strong style="color:var(--success);font-size:16px">${fmtMoneda(pago.monto_neto)}</strong>
    </div>` : `
    <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:6px;margin-top:4px">
      <span style="font-weight:600">Neto recibido:</span>
      <strong style="color:var(--success);font-size:16px">${fmtMoneda(pago.monto)}</strong>
    </div>`}
  </div>`;
  document.getElementById('contenidoDetallePago').innerHTML = h;
  // Botón anular en footer
  const footer = document.getElementById('footerDetallePago');
  const btnAnular = document.createElement('button');
  btnAnular.className = 'btn btn-danger';
  btnAnular.textContent = 'Anular Pago';
  btnAnular.onclick = () => { cerrarModal('modalDetallePago'); anularPago(id, pago.numero_factura); };
  footer.prepend(btnAnular);
}

async function verHistorialCliente(factura_id, clienteNombre) {
  const cxcRow = cxcData.find(f => f.id_factura === factura_id);
  if (!cxcRow) { toast('No se encontró la factura en la lista.', 'error'); return; }
  await abrirHistorialCliente(cxcRow.cliente_id || cxcRow.id_factura, clienteNombre, cxcRow);
}

async function abrirHistorialCliente(cliente_id, clienteNombre, cxcRow) {
  document.getElementById('historialClienteNombre').textContent = clienteNombre;
  document.getElementById('tablaHistorialPagos').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalHistorialPagos');
  // Cargar historial por cliente_id
  const r = await api('controllers/PagosController.php?action=historial_cliente&cliente_id=' + cliente_id);
  if (!r.ok) { document.getElementById('tablaHistorialPagos').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const pagos = r.data.data;
  // Calcular resumen
  const totCobrado     = pagos.reduce((s,p) => s + parseFloat(p.monto||0), 0);
  const totRetenciones = pagos.reduce((s,p) => s + parseFloat(p.retencion_isr||0) + parseFloat(p.retencion_isv||0), 0);
  const totNeto        = pagos.reduce((s,p) => s + parseFloat(p.monto_neto||0), 0);
  document.getElementById('histResTotal').textContent       = pagos.length;
  document.getElementById('histResCobrado').textContent     = fmtMoneda(totCobrado);
  document.getElementById('histResRetenciones').textContent = fmtMoneda(totRetenciones);
  document.getElementById('histResNeto').textContent        = fmtMoneda(totNeto);
  if (!pagos.length) {
    document.getElementById('tablaHistorialPagos').innerHTML = '<p class="empty-state">Sin pagos registrados para este cliente.</p>';
    return;
  }
  const metodoIcon = { efectivo:'💵', tarjeta:'💳', transferencia:'🏦' };
  let h = `<table><thead><tr><th>Fecha</th><th>Factura</th><th>Monto</th><th>Ret. ISR</th><th>Ret. ISV</th><th>Neto</th><th>Método</th><th>Referencia</th></tr></thead><tbody>`;
  pagos.forEach(p => {
    h += `<tr>
      <td>${p.fecha}</td>
      <td style="font-family:monospace;font-size:12px">${p.numero_factura}</td>
      <td><strong>${fmtMoneda(p.monto)}</strong></td>
      <td style="color:var(--danger)">${parseFloat(p.retencion_isr||0)>0 ? fmtMoneda(p.retencion_isr) : '—'}</td>
      <td style="color:var(--danger)">${parseFloat(p.retencion_isv||0)>0 ? fmtMoneda(p.retencion_isv) : '—'}</td>
      <td style="color:var(--success)">${fmtMoneda(p.monto_neto)}</td>
      <td>${metodoIcon[p.metodo_pago]||''} ${p.metodo_pago}</td>
      <td style="font-size:12px;color:var(--muted)">${p.referencia||'—'}</td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaHistorialPagos').innerHTML = h;
}

async function anularPago(id, numeroFactura) {
  if (!await confirmDialog(`¿Anular el pago de la factura ${numeroFactura}? Se revertirá el estado de la factura.`)) return;
  const r = await api('controllers/PagosController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) {
    toast('Pago anulado correctamente.', 'success');
    cargarModuloPagos();
  } else {
    toast(r.data.error || 'Error al anular.', 'error');
  }
}

// ── Tabs ─────────────────────────────────────────────────
function switchTabPagos(tab) {
  tabPagosActual = tab;
  document.getElementById('tabPagos').classList.toggle('active', tab === 'pagos');
  document.getElementById('tabCxC').classList.toggle('active', tab === 'cxc');
  document.getElementById('panelHistorialPagos').style.display = tab === 'pagos' ? '' : 'none';
  document.getElementById('panelCxC').style.display            = tab === 'cxc'   ? '' : 'none';
}


