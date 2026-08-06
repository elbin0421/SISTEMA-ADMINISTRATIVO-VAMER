// ══════════════════════════════════════════════════════════
// facturacion.js — Facturación
// Extraído de dashboard.js líneas 2023-2610
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// FASE 3 — FACTURACIÓN
// ══════════════════════════════════════════════════════════
let facturasData          = [];
let metodoPagoFacSeleccionado = '';

// ── KPIs + tabla ─────────────────────────────────────────
async function cargarFacturacion() {
  cargarKPIsFacturacion();
  cargarFacturas();
}

async function cargarKPIsFacturacion() {
  const r = await api('controllers/FacturacionController.php?action=kpis');
  if (!r.ok) return;
  const k = r.data.data;
  document.getElementById('kpiFacTotal').textContent    = k.total_mes      || '0';
  document.getElementById('kpiFacMonto').textContent    = fmtMoneda(k.monto_mes || 0);
  document.getElementById('kpiFacPendientes').textContent = k.pendientes_cobro || '0';
  document.getElementById('kpiFacAnuladas').textContent = k.anuladas_mes    || '0';
}

async function cargarFacturas() {
  document.getElementById('tablaFacturas').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoFac').value;
  const r = await api('controllers/FacturacionController.php?action=listar' + (estado ? '&estado=' + estado : ''));
  if (!r.ok) { document.getElementById('tablaFacturas').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  facturasData = r.data.data;
  document.getElementById('buscarFactura').value = '';
  paginaActual['facturacion'] = 1;
  renderTablaFacturas(facturasData);
}

function filtrarFacturas() {
  const q = document.getElementById('buscarFactura').value.toLowerCase().trim();
  paginaActual['facturacion'] = 1;
  if (!q) { renderTablaFacturas(facturasData); return; }
  renderTablaFacturas(facturasData.filter(f =>
    f.numero_factura.toLowerCase().includes(q) ||
    f.cliente.toLowerCase().includes(q) ||
    (f.numero_cotizacion && f.numero_cotizacion.toLowerCase().includes(q))
  ));
}

function renderTablaFacturas(rows) {
  const pag = paginar('facturacion', rows);
  let h = '<table><thead><tr><th>Número</th><th>Cliente</th><th>RTN</th><th>Cotización</th><th>Fecha</th><th>Subtotal</th><th>ISV</th><th>Total</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin facturas</td></tr>';
  pag.slice.forEach(f => {
    h += `<tr>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.cliente_rtn || '—'}</td>
      <td>${f.numero_cotizacion || '<span style="color:var(--muted)">—</span>'}</td>
      <td>${f.fecha}</td>
      <td>${fmtMoneda(f.subtotal)}</td>
      <td>${fmtMoneda(f.isv)}</td>
      <td><strong style="color:var(--accent)">${fmtMoneda(f.total)}</strong></td>
      <td>${badgeEstado(f.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleFactura(${f.id_factura})">Ver</button>
        <a href="controllers/FacturaPDFController.php?id=${f.id_factura}" target="_blank" class="btn btn-sm btn-secondary">📄 PDF</a>
        ${f.estado !== 'anulada' && f.estado !== 'pagada' ? `<button class="btn btn-sm btn-danger" onclick="abrirAnulacion(${f.id_factura},'${f.numero_factura}')">Anular</button>` : ''}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaFacturas').innerHTML = h;
  renderPaginacion('facturacion', pag, 'paginaFacturas');
}

// ── DETALLE FACTURA ──────────────────────────────────────
async function verDetalleFactura(id) {
  document.getElementById('contenidoDetalleFactura').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('footerDetalleFactura').innerHTML = '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetalleFactura\')">Cerrar</button>';
  abrirModal('modalDetalleFactura');
  const r = await api('controllers/FacturacionController.php?action=obtener&id=' + id);
  if (!r.ok) { document.getElementById('contenidoDetalleFactura').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const f = r.data.data;

  let h = `
  <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:12px">
    <div>
      <h4 style="font-family:monospace;font-size:18px;margin-bottom:4px">${f.numero_factura}</h4>
      <div style="font-size:12px;color:var(--muted)">CAI: <span style="font-family:monospace">${f.cai_codigo || 'N/A'}</span></div>
      ${f.fecha_limite_emision ? `<div style="font-size:12px;color:var(--muted)">Fecha límite emisión: ${f.fecha_limite_emision}</div>` : ''}
    </div>
    <div style="text-align:right">${badgeEstado(f.estado)}<br><span style="font-size:13px;color:var(--muted)">${f.fecha}</span></div>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${f.cliente}</strong></div>
    <div><span style="color:var(--muted)">RTN:</span> ${f.cliente_rtn || '—'}</div>
    <div><span style="color:var(--muted)">Dirección:</span> ${f.cliente_direccion || '—'}</div>
    <div><span style="color:var(--muted)">Teléfono:</span> ${f.cliente_tel || '—'}</div>
    ${f.numero_cotizacion ? `<div><span style="color:var(--muted)">Cotización:</span> ${f.numero_cotizacion}</div>` : ''}
    ${f.numero_orden ? `<div><span style="color:var(--muted)">OT:</span> ${f.numero_orden}</div>` : ''}
    <div><span style="color:var(--muted)">Método de pago:</span> ${f.metodo_pago || '—'}</div>
    <div><span style="color:var(--muted)">Emitida por:</span> ${f.usuario}</div>
  </div>
  <div class="section-title">📋 Detalle de servicios</div>
  <div class="table-wrap"><table>
    <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal</th></tr></thead>
    <tbody>`;
  f.detalle.forEach(d => {
    const tipo = d.tipo === 'mano_obra' ? '👷' : '📦';
    h += `<tr><td>${tipo}</td><td>${d.descripcion}</td><td>${d.cantidad}</td>
          <td>${fmtMoneda(d.precio_unitario)}</td>
          <td>${fmtMoneda(d.subtotal_final)}</td></tr>`;
  });
  h += `</tbody></table></div>
  <div style="text-align:right;margin-top:14px;font-size:13px;line-height:2.2;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px">
    <span style="color:var(--muted)">Subtotal (sin ISV):</span> ${fmtMoneda(f.subtotal)}<br>
    <span style="color:var(--muted)">ISV 15%:</span> ${fmtMoneda(f.isv)}<br>
    <strong style="font-size:18px;color:var(--accent)">TOTAL: ${fmtMoneda(f.total)}</strong>
  </div>`;
  if (f.observaciones) h += `<p style="font-size:12px;color:var(--muted);margin-top:10px">${f.observaciones}</p>`;
  document.getElementById('contenidoDetalleFactura').innerHTML = h;

  // Footer dinámico según estado
  const footer = document.getElementById('footerDetalleFactura');
  footer.innerHTML = `
    <button class="btn btn-secondary" onclick="cerrarModal('modalDetalleFactura')">Cerrar</button>
    <a href="controllers/FacturaPDFController.php?id=${id}" target="_blank" class="btn btn-primary">📄 Generar PDF</a>
  `;
}

// ── FACTURA DIRECTA (sin cotización) ────────────────────
let fdMetodoSeleccionado = '';
let fdItemCount = 0;

async function abrirModalFacturaDirecta() {
  // Verificar CAI activo
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    toast('No hay CAI activo. Configure el CAI antes de facturar.', 'error');
    setTimeout(() => abrirModalCAI(), 800);
    return;
  }
  // Reset
  fdMetodoSeleccionado = '';
  fdItemCount = 0;
  document.getElementById('fdItemsWrap').innerHTML = '';
  document.getElementById('fdObservaciones').value = '';
  document.getElementById('fdReferencia').value = '';
  document.getElementById('fdRefGrupo').style.display = 'none';
  document.getElementById('fdNotaMetodo').style.display = 'none';
  document.getElementById('errFacturaDirecta').style.display = 'none';
  document.getElementById('fdFecha').value = new Date().toISOString().slice(0, 10);
  document.querySelectorAll('.fd-metodo-btn').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  fdRecalcular();
  // Cargar clientes en select
  const sel = document.getElementById('fdClienteId');
  sel.innerHTML = '<option value="">— Seleccionar cliente —</option>';
  const rCli = await api('controllers/ClientesController.php?action=listar');
  if (rCli.ok && rCli.data.data) {
    rCli.data.data.forEach(c => {
      const o = document.createElement('option');
      o.value = c.id_cliente;
      o.textContent = c.nombre + (c.rtn ? ' (' + c.rtn + ')' : '');
      sel.appendChild(o);
    });
  }
  fdAgregarItem(); // Un ítem inicial
  abrirModal('modalFacturaDirecta');
}

function fdAgregarItem() {
  fdItemCount++;
  const idx = fdItemCount;
  const wrap = document.getElementById('fdItemsWrap');
  const div = document.createElement('div');
  div.id = 'fdItem_' + idx;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 2fr 90px 110px 30px;gap:6px;align-items:center;background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:8px 10px';
  div.innerHTML = `
    <select id="fdTipo_${idx}" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
      <option value="otro">Servicio / Otro</option>
      <option value="mano_obra">Mano de obra</option>
      <option value="material">Material</option>
    </select>
    <input type="text" id="fdDesc_${idx}" placeholder="Descripción *" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
    <input type="number" id="fdCant_${idx}" value="1" min="0.01" step="0.01" placeholder="Cant." oninput="fdRecalcular()" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right">
    <input type="number" id="fdPrecio_${idx}" value="" min="0" step="0.01" placeholder="Precio unit." oninput="fdRecalcular()" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right">
    <button onclick="fdEliminarItem(${idx})" style="background:none;border:none;color:var(--danger);font-size:18px;cursor:pointer;padding:0" title="Eliminar">×</button>
  `;
  wrap.appendChild(div);
}

function fdEliminarItem(idx) {
  const el = document.getElementById('fdItem_' + idx);
  if (el) el.remove();
  fdRecalcular();
}

function fdRecalcular() {
  let subtotal = 0;
  document.querySelectorAll('[id^="fdCant_"]').forEach(el => {
    const idx = el.id.split('_')[1];
    const cant   = parseFloat(el.value)                                   || 0;
    const precio = parseFloat(document.getElementById('fdPrecio_' + idx)?.value) || 0;
    subtotal += cant * precio;
  });
  const isv   = subtotal * 0.15;
  const total = subtotal + isv;
  document.getElementById('fdSubtotal').textContent = fmtMoneda(subtotal);
  document.getElementById('fdISV').textContent      = fmtMoneda(isv);
  document.getElementById('fdTotal').textContent    = fmtMoneda(total);
}

function fdSelMetodo(metodo) {
  fdMetodoSeleccionado = metodo;
  document.querySelectorAll('.fd-metodo-btn').forEach(el => {
    const sel = el.dataset.mfd === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('fdRefGrupo').style.display = 'none';
  const notaEl = document.getElementById('fdNotaMetodo');
  if (metodo === 'credito') {
    notaEl.textContent = '📋 Crédito: la factura quedará en estado "Pendiente" hasta registrar el pago.';
    notaEl.style.display = 'block';
  } else {
    notaEl.textContent = '✅ Contado: la factura se marcará como "Pagada" automáticamente.';
    notaEl.style.display = 'block';
  }
}

async function confirmarFacturaDirecta() {
  const errEl = document.getElementById('errFacturaDirecta');
  errEl.style.display = 'none';
  const cliente_id = +document.getElementById('fdClienteId').value;
  if (!cliente_id)              { errEl.textContent = 'Selecciona un cliente.';           errEl.style.display = 'block'; return; }
  if (!fdMetodoSeleccionado)    { errEl.textContent = 'Selecciona un método de pago.';    errEl.style.display = 'block'; return; }

  // Recopilar ítems
  const items = [];
  let itemsValidos = true;
  document.querySelectorAll('[id^="fdItem_"]').forEach(row => {
    const idx     = row.id.split('_')[1];
    const desc    = document.getElementById('fdDesc_'   + idx)?.value.trim();
    const cant    = parseFloat(document.getElementById('fdCant_'  + idx)?.value);
    const precio  = parseFloat(document.getElementById('fdPrecio_' + idx)?.value);
    const tipo    = document.getElementById('fdTipo_'   + idx)?.value;
    if (!desc || !cant || !precio || cant <= 0 || precio <= 0) { itemsValidos = false; return; }
    items.push({ tipo, descripcion: desc, cantidad: cant, precio_unitario: precio });
  });
  if (items.length === 0 || !itemsValidos) {
    errEl.textContent = 'Completa todos los ítems (descripción, cantidad y precio son requeridos).';
    errEl.style.display = 'block'; return;
  }

  const payload = {
    cliente_id,
    metodo_pago:   fdMetodoSeleccionado,
    referencia_pago: document.getElementById('fdReferencia').value.trim() || null,
    observaciones:   document.getElementById('fdObservaciones').value.trim() || null,
    fecha:           document.getElementById('fdFecha').value,
    items,
  };

  const r = await api('controllers/FacturacionController.php?action=facturar_directo', {
    method: 'POST',
    body: JSON.stringify(payload)
  });
  if (r.ok) {
    cerrarModal('modalFacturaDirecta');
    const estado = r.data.factura.estado;
    const emoji  = estado === 'pagada' ? '✅' : '📋';
    toast(`${emoji} Factura ${r.data.factura.numero_factura} emitida (${estado}).`, 'success');
    cargarFacturacion();
  } else {
    errEl.textContent = r.data.error || 'Error al emitir la factura.';
    errEl.style.display = 'block';
  }
}

// ── FACTURAR DESDE COTIZACIÓN ────────────────────────────
let facturarCotId = null;

async function abrirModalFacturar(cotizacion_id) {
  facturarCotId = cotizacion_id;
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    toast('No hay CAI activo. Configure el CAI antes de facturar.', 'error');
    setTimeout(() => abrirModalCAI(), 800);
    return;
  }
  facturarMetodoPago = '';
  document.querySelectorAll('.metodo-cot-btn').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  document.getElementById('facturarCotRefGrupo').style.display   = 'none';
  document.getElementById('facturarCotRef').value                = '';
  document.getElementById('errFacturarCot').style.display        = 'none';
  document.getElementById('facturarCotNotaMetodo').style.display = 'none';
  const resEl = document.getElementById('facturarCotResumen');
  if (resEl) resEl.innerHTML = '<p style="color:var(--muted);font-size:12px">Cargando resumen...</p>';
  abrirModal('modalFacturarCotizacion');

  if (!resEl) return; // modal viejo sin panel de resumen: nada más que hacer

  const rCot = await api('controllers/CotizacionesController.php?action=obtener&id=' + cotizacion_id);
  if (!rCot.ok) { resEl.innerHTML = '<p style="color:var(--danger);font-size:12px">Error cargando cotización.</p>'; return; }
  const c = rCot.data.data;
  const subBruto = (c.detalle || []).reduce((a,d) => a + (d.cantidad * d.precio_unitario), 0);
  const descMto  = parseFloat(c.descuento_monto || 0);
  const descPct  = parseFloat(c.descuento_porcentaje || 0);
  const baseIsv  = Math.max(0, subBruto - descMto);
  const isv      = Math.round(baseIsv * 0.15 * 100) / 100;
  const total    = Math.round((baseIsv + isv) * 100) / 100;

  let resumen = `
    <div style="font-size:12px;color:var(--muted);margin-bottom:8px;font-weight:600;text-transform:uppercase;letter-spacing:.5px">
      Resumen — ${c.numero_cotizacion}
    </div>
    <div style="font-size:12px;color:var(--muted);margin-bottom:10px">
      Cliente: <strong style="color:var(--text)">${c.cliente || '—'}</strong>
    </div>
    <div style="display:flex;justify-content:space-between;padding:3px 0;font-size:13px;color:var(--muted)">
      <span>Materiales</span><span>${fmtMoneda(c.subtotal_materiales)}</span>
    </div>
    <div style="display:flex;justify-content:space-between;padding:3px 0;font-size:13px;color:var(--muted)">
      <span>Mano de obra</span><span>${fmtMoneda(c.subtotal_mano_obra)}</span>
    </div>
    <div style="display:flex;justify-content:space-between;padding:4px 0;font-size:13px;border-top:1px solid var(--border);margin-top:4px">
      <span style="color:var(--muted)">SUB-TOTAL</span><strong>${fmtMoneda(subBruto)}</strong>
    </div>`;
  if (descMto > 0) {
    resumen += `<div style="display:flex;justify-content:space-between;padding:3px 0;font-size:13px;color:#c0392b">
      <span>DESC./REBAJA${descPct > 0 ? ' (' + descPct + '%)' : ''}</span>
      <strong>${fmtMoneda(descMto)}</strong>
    </div>`;
  }
  resumen += `
    <div style="display:flex;justify-content:space-between;padding:3px 0;font-size:13px;color:var(--muted)">
      <span>ISV 15%</span><strong style="color:var(--text)">${fmtMoneda(isv)}</strong>
    </div>
    <div style="display:flex;justify-content:space-between;padding:6px 0;border-top:2px solid var(--border);margin-top:4px">
      <strong style="font-size:14px">TOTAL A FACTURAR</strong>
      <strong style="font-size:15px;color:var(--accent)">${fmtMoneda(total)}</strong>
    </div>`;
  resEl.innerHTML = resumen;
}

let facturarMetodoPago = '';

function facturarCotSelMetodo(metodo) {
  facturarMetodoPago = metodo;
  document.querySelectorAll('.metodo-cot-btn').forEach(el => {
    const sel = el.dataset.mcot === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('facturarCotRefGrupo').style.display = 'none';
  const notaEl = document.getElementById('facturarCotNotaMetodo');
  if (metodo === 'credito') {
    notaEl.textContent = '📋 Crédito: la factura quedará en estado "Pendiente" hasta registrar el pago.';
    notaEl.style.display = 'block';
  } else {
    notaEl.textContent = '✅ Contado: la factura se marcará como "Pagada" automáticamente.';
    notaEl.style.display = 'block';
  }
}

async function confirmarFacturarCotizacion() {
  const errEl = document.getElementById('errFacturarCot');
  errEl.style.display = 'none';
  if (!facturarMetodoPago) {
    errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return;
  }
  const ref = document.getElementById('facturarCotRef').value.trim();
  const r = await api('controllers/FacturacionController.php?action=facturar', {
    method: 'POST',
    body: JSON.stringify({ cotizacion_id: facturarCotId, metodo_pago: facturarMetodoPago, referencia_pago: ref || null })
  });
  if (r.ok) {
    cerrarModal('modalFacturarCotizacion');
    const estado = r.data.factura.estado;
    const emoji  = estado === 'pagada' ? '✅' : '📋';
    toast(`${emoji} Factura ${r.data.factura.numero_factura} emitida (${estado}).`, 'success');
    cargarFacturacion();
    cargarCotizaciones();
  } else {
    errEl.textContent = r.data.error || 'Error al generar factura.';
    errEl.style.display = 'block';
  }
}

// ── PAGO DE FACTURA ──────────────────────────────────────
function abrirPagoFactura(factura_id, numero, total, subtotal) {
  metodoPagoFacSeleccionado = '';
  document.getElementById('pagoFacturaId').value       = factura_id;
  document.getElementById('pagoFacturaSubtotal').value = subtotal || 0;
  document.getElementById('pagoFacturaInfo').textContent = `Factura: ${numero} | Total: ${fmtMoneda(total)}`;
  document.getElementById('pagoSaldoPendiente').textContent = fmtMoneda(total);
  document.getElementById('pagoMonto').value  = '';
  document.getElementById('pagoFecha').value  = new Date().toISOString().slice(0, 10);
  document.getElementById('pagoRefFac').value = '';
  document.getElementById('pagoRefGrupoFac').style.display = 'none';
  document.getElementById('errPago').style.display = 'none';
  // Reset retenciones
  document.getElementById('chkRetencionISR').checked = false;
  document.getElementById('chkRetencionISV').checked = false;
  document.getElementById('retencionISRGrupo').style.display = 'none';
  document.getElementById('retencionISVGrupo').style.display = 'none';
  document.getElementById('pagoRetencionISR').value = '';
  document.getElementById('pagoRetencionISV').value = '';
  document.getElementById('pagoResumenNeto').style.display = 'none';
  // Reset botones método
  document.querySelectorAll('.metodo-pago-btn[data-mfac]').forEach(el => {
    el.style.borderColor = 'var(--border)';
    el.style.background  = '';
  });

  // Cargar saldo pendiente real desde el servidor
  api('controllers/FacturacionController.php?action=obtener&id=' + factura_id).then(r => {
    if (r.ok) {
      const f = r.data.data;
      const subtotalReal = parseFloat(f.subtotal) || 0;
      document.getElementById('pagoFacturaSubtotal').value = subtotalReal;
      // Calcular ya pagado
      api('controllers/FacturacionController.php?action=saldo_pendiente&id=' + factura_id).then(rs => {
        if (rs.ok && rs.data.pendiente !== undefined) {
          document.getElementById('pagoSaldoPendiente').textContent = fmtMoneda(rs.data.pendiente);
          document.getElementById('pagoMonto').value = rs.data.pendiente.toFixed(2);
          pagoRecalcular();
        }
      });
    }
  });

  abrirModal('modalRegistrarPago');
}

function pagoToggleRetencion(tipo) {
  const chk   = document.getElementById(tipo === 'isr' ? 'chkRetencionISR' : 'chkRetencionISV');
  const grupo = document.getElementById(tipo === 'isr' ? 'retencionISRGrupo' : 'retencionISVGrupo');
  grupo.style.display = chk.checked ? 'block' : 'none';
  pagoRecalcular();
}

function pagoRecalcular() {
  const monto     = parseFloat(document.getElementById('pagoMonto').value)    || 0;
  const subtotal  = parseFloat(document.getElementById('pagoFacturaSubtotal').value) || 0;
  const chkISR    = document.getElementById('chkRetencionISR').checked;
  const chkISV    = document.getElementById('chkRetencionISV').checked;

  // Calcular retenciones sobre el subtotal proporcional al monto pagado
  // Si el monto pagado es igual al total, la base es el subtotal completo
  const retISR = chkISR ? parseFloat((subtotal * 0.01).toFixed(2))   : 0;
  const retISV = chkISV ? parseFloat((subtotal * 0.125).toFixed(2))  : 0;
  const neto   = parseFloat((monto - retISR - retISV).toFixed(2));

  if (chkISR) document.getElementById('pagoRetencionISR').value = retISR.toFixed(2);
  if (chkISV) document.getElementById('pagoRetencionISV').value = retISV.toFixed(2);

  const tieneRetencion = chkISR || chkISV;
  const resumen = document.getElementById('pagoResumenNeto');
  resumen.style.display = (tieneRetencion && monto > 0) ? 'block' : 'none';
  if (tieneRetencion) {
    document.getElementById('resNBruto').textContent = fmtMoneda(monto);
    document.getElementById('resNISR').textContent   = chkISR ? `− ${fmtMoneda(retISR)}` : 'L. 0.00';
    document.getElementById('resNISV').textContent   = chkISV ? `− ${fmtMoneda(retISV)}` : 'L. 0.00';
    document.getElementById('resNNeto').textContent  = fmtMoneda(neto);
  }
}

function selMetodoPagoFac(metodo) {
  metodoPagoFacSeleccionado = metodo;
  document.querySelectorAll('.metodo-pago-btn[data-mfac]').forEach(el => {
    const sel = el.dataset.mfac === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('pagoRefGrupoFac').style.display =
    (metodo === 'tarjeta' || metodo === 'transferencia') ? 'block' : 'none';
}

async function confirmarPago() {
  const id    = +document.getElementById('pagoFacturaId').value;
  const monto = parseFloat(document.getElementById('pagoMonto').value);
  const fecha = document.getElementById('pagoFecha').value;
  const ref   = document.getElementById('pagoRefFac').value.trim();
  const errEl = document.getElementById('errPago');
  errEl.style.display = 'none';
  if (!metodoPagoFacSeleccionado) { errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return; }
  if (!monto || monto <= 0)       { errEl.textContent = 'Ingresa un monto válido.';       errEl.style.display = 'block'; return; }

  const retencion_isr = document.getElementById('chkRetencionISR').checked
    ? parseFloat(document.getElementById('pagoRetencionISR').value) || 0 : 0;
  const retencion_isv = document.getElementById('chkRetencionISV').checked
    ? parseFloat(document.getElementById('pagoRetencionISV').value) || 0 : 0;

  const r = await api('controllers/FacturacionController.php?action=registrar_pago', {
    method: 'POST',
    body: JSON.stringify({
      factura_id: id, monto, fecha,
      metodo_pago: metodoPagoFacSeleccionado,
      referencia: ref,
      retencion_isr, retencion_isv
    })
  });
  if (r.ok) {
    cerrarModal('modalRegistrarPago');
    const d = r.data;
    let msg = `Pago de ${fmtMoneda(monto)} registrado.`;
    if (retencion_isr > 0 || retencion_isv > 0) {
      msg += ` Neto recibido: ${fmtMoneda(d.monto_neto)}.`;
    }
    if (d.pendiente > 0) {
      msg += ` Saldo pendiente: ${fmtMoneda(d.pendiente)}.`;
    } else {
      msg += ` Factura pagada ✅`;
    }
    toast(msg, 'success');
    cargarFacturas();
  } else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ── ANULACIÓN ────────────────────────────────────────────
function abrirAnulacion(factura_id, numero) {
  document.getElementById('anularFacturaId').value = factura_id;
  document.getElementById('anularFacturaInfo').textContent = `Factura: ${numero}`;
  document.getElementById('anularMotivo').value = '';
  document.getElementById('errAnular').style.display = 'none';
  abrirModal('modalAnularFactura');
}

async function confirmarAnulacion() {
  const id     = +document.getElementById('anularFacturaId').value;
  const motivo = document.getElementById('anularMotivo').value.trim();
  const errEl  = document.getElementById('errAnular');
  errEl.style.display = 'none';
  if (!motivo) { errEl.textContent = 'El motivo es requerido.'; errEl.style.display = 'block'; return; }
  const r = await api('controllers/FacturacionController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id, motivo })
  });
  if (r.ok) { cerrarModal('modalAnularFactura'); toast('Factura anulada.', 'success'); cargarFacturas(); }
  else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ── CAI ──────────────────────────────────────────────────
async function abrirModalCAI() {
  document.getElementById('errCAI').style.display = 'none';
  document.getElementById('caiCodigo').value = '';
  document.getElementById('caiInicio').value = '';
  document.getElementById('caiFin').value    = '';
  document.getElementById('caiFechaLimite').value = '';
  document.getElementById('caiEstablecimiento').value = '001';

  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  const info = document.getElementById('caiActualInfo');
  if (rCai.ok && rCai.data.data) {
    const c = rCai.data.data;
    info.innerHTML = `<strong style="color:var(--success)">✅ CAI activo</strong><br>
      <span style="font-family:monospace;font-size:12px">${c.cai}</span><br>
      Correlativo actual: <strong style="font-family:monospace">${c.correlativo_actual}</strong><br>
      Rango: ${c.rango_inicio} — ${c.rango_fin}<br>
      Límite: ${c.fecha_limite_emision}`;
  } else {
    info.innerHTML = '<span style="color:var(--danger)">⚠️ Sin CAI activo. Configura uno para poder facturar.</span>';
  }
  abrirModal('modalCAI');
}

async function guardarCAI() {
  const errEl = document.getElementById('errCAI');
  errEl.style.display = 'none';
  const body = {
    cai:                  document.getElementById('caiCodigo').value.trim(),
    rango_inicio:         document.getElementById('caiInicio').value.trim(),
    rango_fin:            document.getElementById('caiFin').value.trim(),
    fecha_limite_emision: document.getElementById('caiFechaLimite').value,
    establecimiento:      document.getElementById('caiEstablecimiento').value.trim() || '001',
    punto_emision:        '001',
    tipo_documento:       '01',
  };
  if (!body.cai || !body.rango_inicio || !body.rango_fin || !body.fecha_limite_emision) {
    errEl.textContent = 'Todos los campos marcados son requeridos.'; errEl.style.display = 'block'; return;
  }
  const r = await api('controllers/FacturacionController.php?action=cai_crear', {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) { cerrarModal('modalCAI'); toast('CAI registrado correctamente.', 'success'); }
  else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

