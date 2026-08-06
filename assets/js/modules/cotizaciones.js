// ══════════════════════════════════════════════════════════
// cotizaciones.js — Cotizaciones
// Extraído de dashboard.js líneas 1625-2022
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// COTIZACIONES
// ══════════════════════════════════════════════════════════
let cotizacionesData = [];
let itemsCotDir      = [];

async function cargarCotizaciones() {
  document.getElementById('tablaCotizaciones').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoCot').value;
  const r = await api('controllers/CotizacionesController.php?action=listar' + (estado ? '&estado=' + estado : ''));
  if (!r.ok) { document.getElementById('tablaCotizaciones').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  cotizacionesData = r.data.data;
  document.getElementById('buscarCotizacion').value = '';
  paginaActual['cotizaciones'] = 1;
  renderTablaCotizaciones(cotizacionesData);
}

function filtrarCotizaciones() {
  const q = document.getElementById('buscarCotizacion').value.toLowerCase().trim();
  paginaActual['cotizaciones'] = 1;
  if (!q) { renderTablaCotizaciones(cotizacionesData); return; }
  renderTablaCotizaciones(cotizacionesData.filter(c =>
    c.numero_cotizacion.toLowerCase().includes(q) ||
    c.cliente.toLowerCase().includes(q) ||
    (c.numero_orden  && c.numero_orden.toLowerCase().includes(q))  ||
    (c.ot_cliente    && c.ot_cliente.toLowerCase().includes(q))    ||
    (c.orden_compra  && c.orden_compra.toLowerCase().includes(q))
  ));
}

function renderTablaCotizaciones(rows) {
  const pag = paginar('cotizaciones', rows);
  let h = '<table><thead><tr><th>Número</th><th>Cliente</th><th>Unidad</th><th>OT Cliente</th><th>OC</th><th>Modo</th><th>Fecha</th><th>Total</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="8" class="empty-state">Sin cotizaciones</td></tr>';
  pag.slice.forEach(c => {
    const estadosBtns=[];
    const esAdmin=(rol||'').toLowerCase()==='administrador';
    if(c.estado==='pendiente') estadosBtns.push(`<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoCot(${c.id_cotizacion},'pendiente_aprobacion')">📤 Solicitar Aprobación</button>`);
    if(c.estado==='pendiente_aprobacion'&&esAdmin) estadosBtns.push(`<button class="btn btn-sm btn-success" onclick="cambiarEstadoCot(${c.id_cotizacion},'aprobada')">✓ Aprobar</button>`,`<button class="btn btn-sm btn-danger" onclick="cambiarEstadoCot(${c.id_cotizacion},'rechazada')">✗ Rechazar</button>`);
    if(c.estado==='pendiente_aprobacion'&&!esAdmin) estadosBtns.push(`<span style="font-size:11px;color:var(--muted);padding:4px 8px">⏳ Esperando aprobación</span>`);
    if(c.estado==='aprobada') estadosBtns.push(`<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoCot(${c.id_cotizacion},'enviada')">📨 Marcar Enviada</button>`);
    if(c.estado==='enviada') estadosBtns.push(`<button class="btn btn-sm btn-success" onclick="cambiarEstadoCot(${c.id_cotizacion},'aprobada_cliente')">✅ Aprobada por Cliente</button>`,`<button class="btn btn-sm btn-danger" onclick="cambiarEstadoCot(${c.id_cotizacion},'rechazada')">✗ Rechazada por Cliente</button>`);
    if(c.estado==='aprobada_cliente') estadosBtns.push(`<span class="badge badge-green" style="padding:5px 10px">✅ Listo para facturar</span>`);
    h += `<tr>
      <td><strong>${c.numero_cotizacion}</strong></td>
      <td>${c.cliente}</td>
      <td>${c.unidad ? `<span class="badge ${c.unidad==='VESTA'?'badge-blue':'badge-gray'}">${c.unidad}</span>` : '<span style="color:var(--muted)">—</span>'}</td>
      <td><span style="font-family:monospace;font-size:12px">${c.ot_cliente || '<span style="color:var(--muted)">—</span>'}</span></td>
      <td><span style="font-family:monospace;font-size:12px">${c.orden_compra || '<span style="color:var(--muted)">—</span>'}</span></td>
      <td><span class="badge ${c.modo === 'POST_TRABAJO' ? 'badge-blue' : 'badge-gray'}">${c.modo === 'POST_TRABAJO' ? 'Post OT' : 'Directa'}</span></td>
      <td>${c.fecha}</td>
      <td><strong>${fmtMoneda(c.total)}</strong></td>
      <td>${badgeEstado(c.estado)}${c.estado==='rechazada'&&c.motivo_rechazo?`<div style="font-size:10px;color:var(--danger);margin-top:2px" title="${c.motivo_rechazo}">↳ ${c.motivo_rechazo.length>32?c.motivo_rechazo.slice(0,32)+'…':c.motivo_rechazo}</div>`:''}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleCot(${c.id_cotizacion})">Ver</button>
        <a href="controllers/CotizacionPDFController.php?action=pdf&id=${c.id_cotizacion}" target="_blank" class="btn btn-sm btn-secondary">📄 PDF</a>
        <button class="btn btn-sm btn-secondary" onclick="exportarCotizacionExcel(${c.id_cotizacion})">⬇️ Excel</button>
        ${estadosBtns.join('')}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaCotizaciones').innerHTML = h;
  renderPaginacion('cotizaciones', pag, 'paginaCotizaciones');
}

async function verDetalleCot(id) {
  document.getElementById('contenidoDetalleCot').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalDetalleCot');
  const r = await api('controllers/CotizacionesController.php?action=obtener&id=' + id);
  if (!r.ok) { document.getElementById('contenidoDetalleCot').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const c = r.data.data;

  const refStyle = 'font-family:monospace;font-size:13px;font-weight:600;color:var(--text)';

  let h = `<h4>📑 ${c.numero_cotizacion} ${badgeEstado(c.estado)}</h4>
  ${c.estado === 'rechazada' ? `
  <div style="background:#2a0a0a;border:1px solid #c00;border-radius:8px;padding:10px 14px;margin-bottom:12px">
    <div style="color:#ff4444;font-weight:700;font-size:13px;letter-spacing:1px">✗ COTIZACIÓN RECHAZADA</div>
    ${c.motivo_rechazo ? `<div style="color:#ff8888;font-size:12px;margin-top:4px">MOTIVO: ${c.motivo_rechazo}</div>` : ''}
  </div>` : ''}
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${c.cliente}</strong></div>
    <div><span style="color:var(--muted)">Modo:</span> ${c.modo === 'POST_TRABAJO' ? '📋 Post OT' : '✏️ Directa'}</div>
    <div><span style="color:var(--muted)">Fecha:</span> ${c.fecha}</div>
    <div><span style="color:var(--muted)">Vigencia:</span> ${c.vigencia_dias} días</div>
    ${c.numero_orden ? `<div><span style="color:var(--muted)">OT origen:</span> <strong>${c.numero_orden}</strong></div>` : ''}
  </div>

  <!-- Referencias del cliente -->
  <div style="background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:12px 16px;margin-bottom:14px">
    <div style="font-size:11px;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:10px;font-weight:600">📌 Referencias del Cliente</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;align-items:end">
      <div>
        <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:4px">OT Cliente</label>
        ${c.estado === 'facturada'
          ? `<div style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;font-family:monospace;font-size:13px">${c.ot_cliente || '<span style="color:var(--muted)">—</span>'}</div>`
          : `<input type="text" id="editOtCliente" value="${c.ot_cliente || ''}" placeholder="Ej: 4007731855"
          style="width:100%;padding:7px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;font-family:monospace;outline:none">`
        }
      </div>
      <div>
        <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:4px">Orden de Compra (OC)</label>
        ${c.estado === 'facturada'
          ? `<div style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;font-family:monospace;font-size:13px">${c.orden_compra || '<span style="color:var(--muted)">—</span>'}</div>`
          : `<input type="text" id="editOrdenCompra" value="${c.orden_compra || ''}" placeholder="Ej: 5503905114"
          style="width:100%;padding:7px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;font-family:monospace;outline:none">`
        }
      </div>
    </div>
    ${c.estado !== 'facturada' ? `
    <div style="margin-top:10px;display:flex;align-items:center;gap:10px">
      <button class="btn btn-sm btn-secondary" onclick="guardarReferencias(${c.id_cotizacion})">💾 Guardar referencias</button>
      <span id="refGuardadoMsg" style="font-size:12px;color:var(--success);display:none">✔ Guardado</span>
    </div>` : `<div style="margin-top:8px;font-size:11px;color:var(--muted)">🔒 Facturada — referencias de solo lectura.</div>`}
  </div>

  <div class="section-title">📋 Detalle</div>
  <div class="table-wrap"><table>
    <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal base</th><th>Subtotal final</th></tr></thead>
    <tbody>`;
  c.detalle.forEach(d => {
    const tipo = d.tipo === 'mano_obra' ? '👷 Mano de obra' : '📦 Material';
    h += `<tr><td>${tipo}</td><td>${d.descripcion}</td><td>${d.cantidad}</td>
          <td>${fmtMoneda(d.precio_unitario)}</td>
          <td>${fmtMoneda(d.subtotal_base)}</td>
          <td><strong>${fmtMoneda(d.subtotal_final)}</strong></td></tr>`;
  });
  h += `</tbody></table></div>
  <div style="text-align:right;margin-top:14px;font-size:13px;line-height:2;color:var(--muted)">
    Materiales: ${fmtMoneda(c.subtotal_materiales)}<br>
    Mano de obra: ${fmtMoneda(c.subtotal_mano_obra)}<br>
    Subtotal: ${fmtMoneda(c.subtotal_comercial)}<br>
    ISV 15%: ${fmtMoneda(c.isv)}<br>
    <strong style="font-size:16px;color:var(--accent)">TOTAL: ${fmtMoneda(c.total)}</strong>
  </div>`;
  if (c.observaciones) h += `<p style="font-size:12px;color:var(--muted);margin-top:10px">${c.observaciones}</p>`;
  document.getElementById('contenidoDetalleCot').innerHTML = h;

  // Botón "Facturar" — solo si cotización está aprobada
  let btnFac = document.getElementById('btnFacturarCot');
  if (!btnFac) {
    btnFac = document.createElement('button');
    btnFac.id = 'btnFacturarCot';
    btnFac.className = 'btn btn-primary';
    btnFac.textContent = '🧾 Facturar';
    btnFac.onclick = () => abrirModalFacturar(currentCotId);
    document.getElementById('footerDetalleCot').prepend(btnFac);
  }
  currentCotId = c.id_cotizacion;
  btnFac.style.display = c.estado === 'aprobada_cliente' ? 'inline-flex' : 'none';

  // Botones PDF y Excel en footer (crear si no existen)
  const footerCot = document.getElementById('footerDetalleCot');
  if (!document.getElementById('btnCotPDF')) {
    const lnkPDF = document.createElement('a');
    lnkPDF.id = 'btnCotPDF';
    lnkPDF.className = 'btn btn-secondary';
    lnkPDF.textContent = '📄 PDF';
    lnkPDF.target = '_blank';
    footerCot.prepend(lnkPDF);

    const lnkXLS = document.createElement('a');
    lnkXLS.id = 'btnCotExcel';
    lnkXLS.className = 'btn btn-secondary';
    lnkXLS.textContent = '⬇️ Excel';
    footerCot.prepend(lnkXLS);
  }
  document.getElementById('btnCotPDF').href   = 'controllers/CotizacionPDFController.php?action=pdf&id='   + c.id_cotizacion;
  document.getElementById('btnCotExcel').onclick = () => exportarCotizacionExcel(c.id_cotizacion);
  document.getElementById('btnCotExcel').removeAttribute('href');
}

async function guardarReferencias(cotizacion_id) {
  const ot_cliente   = document.getElementById('editOtCliente').value.trim();
  const orden_compra = document.getElementById('editOrdenCompra').value.trim();
  const r = await api('controllers/CotizacionesController.php?action=actualizar_referencias', {
    method: 'POST',
    body: JSON.stringify({ id: cotizacion_id, ot_cliente, orden_compra })
  });
  if (r.ok) {
    const msg = document.getElementById('refGuardadoMsg');
    msg.style.display = 'inline';
    setTimeout(() => { msg.style.display = 'none'; }, 2500);
    cargarCotizaciones();
  } else {
    toast(r.data.error || 'Error al guardar referencias.', 'error');
  }
}

async function cambiarEstadoCot(id, estado) {
  if (estado === 'rechazada') {
    // Modal de motivo de rechazo
    const motivo = await pedirMotivoRechazo();
    if (motivo === null) return; // canceló
    const r = await api('controllers/CotizacionesController.php?action=cambiar_estado', {
      method: 'POST', body: JSON.stringify({ id, estado, motivo_rechazo: motivo })
    });
    if (r.ok) { toast('Cotización rechazada.', 'success'); cargarCotizaciones(); }
    else toast(r.data.error || 'Error.', 'error');
    return;
  }
  const esAdmin=(rol||'').toLowerCase()==='administrador';
  if(estado==='aprobada'&&!esAdmin){toast('Solo el Administrador puede aprobar cotizaciones.','error');return;}
  const labels={pendiente_aprobacion:'enviar a aprobación del Administrador',aprobada:'aprobar esta cotización',enviada:'marcar como enviada al cliente',aprobada_cliente:'registrar que el cliente aprobó (habilitará Facturar)',rechazada:'registrar el rechazo'};
  if(!await confirmDialog(`¿Deseas ${labels[estado]||'cambiar el estado de esta cotización'}?`))return;
  const r=await api('controllers/CotizacionesController.php?action=cambiar_estado',{method:'POST',body:JSON.stringify({id,estado})});
  if(r.ok){toast('Estado actualizado.','success');cargarCotizaciones();}
  else toast(r.data.error||'Error.','error');
}

function pedirMotivoRechazo() {
  return new Promise(resolve => {
    // Crear mini-modal inline
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;display:flex;align-items:center;justify-content:center';
    overlay.innerHTML = `
      <div style="background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:24px;width:380px;max-width:95vw">
        <h4 style="margin:0 0 6px;font-size:15px">✗ Rechazar Cotización</h4>
        <p style="font-size:12px;color:var(--muted);margin:0 0 14px">Ingresa el motivo del rechazo (requerido)</p>
        <textarea id="_motivoRechazoCot" rows="3" placeholder="Ej: PRECIO FUERA DE PRESUPUESTO..."
          style="width:100%;padding:9px 11px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px;outline:none;resize:vertical;font-family:inherit;text-transform:uppercase;box-sizing:border-box"></textarea>
        <div id="_errMotivoRechazo" style="color:var(--danger);font-size:12px;margin-top:6px;display:none">El motivo es requerido.</div>
        <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">
          <button class="btn btn-secondary" id="_btnCancelRechazo">Cancelar</button>
          <button class="btn btn-danger"    id="_btnConfRechazo">✗ Rechazar</button>
        </div>
      </div>`;
    document.body.appendChild(overlay);
    const ta  = overlay.querySelector('#_motivoRechazoCot');
    const err = overlay.querySelector('#_errMotivoRechazo');
    ta.addEventListener('input', () => { ta.value = ta.value.toUpperCase(); });
    ta.focus();
    overlay.querySelector('#_btnCancelRechazo').onclick = () => { document.body.removeChild(overlay); resolve(null); };
    overlay.querySelector('#_btnConfRechazo').onclick   = () => {
      const v = ta.value.trim();
      if (!v) { err.style.display='block'; return; }
      document.body.removeChild(overlay);
      resolve(v.toUpperCase());
    };
  });
}

// ── COTIZACIÓN DESDE OT (botón en detalle OT) ────────────────
async function generarCotizacionDesdeOT(orden_id) {
  if (!await confirmDialog('¿Generar cotización desde esta OT? Se usarán los materiales y mano de obra registrados.')) return;
  const r = await api('controllers/CotizacionesController.php?action=desde_ot', {
    method: 'POST', body: JSON.stringify({ orden_id, vigencia_dias: 15 })
  });
  if (r.ok) {
    toast(`Cotización ${r.data.cotizacion.numero_cotizacion} generada correctamente.`, 'success');
    cerrarModal('modalDetalleOT');
    // Navegar al módulo cotizaciones
    document.querySelector('.nav-item[data-module="cotizaciones"]').click();
  } else toast(r.data.error || 'Error.', 'error');
}

// ── COTIZACIÓN DIRECTA ───────────────────────────────────────
function abrirModalCotizacionDirecta() {
  itemsCotDir = [];
  document.getElementById('cotDirClienteBuscar').value = '';
  document.getElementById('cotDirClienteId').value = '';
  document.getElementById('cotDirVigencia').value = '15';
  document.getElementById('cotDirObs').value = '';
  document.getElementById('cotDirOtCliente').value = '';
  document.getElementById('cotDirOrdenCompra').value = '';
  document.getElementById('cotDirDesc').value = '';
  document.getElementById('cotDirCant').value = '1';
  document.getElementById('cotDirPrecio').value = '';
  document.getElementById('cotDirPlaca').value = '';
  document.getElementById('errCotDir').style.display = 'none';
  const selVeh = document.getElementById('cotDirVehiculoSelect');
  if (selVeh) selVeh.innerHTML = '<option value="">— Sin vehículo / No aplica —</option>';
  renderItemsCotDir();
  abrirModal('modalCotizacionDirecta');
}

let buscarClienteCotDirTimer = null;
function buscarClienteCotDir() {
  clearTimeout(buscarClienteCotDirTimer);
  const q = document.getElementById('cotDirClienteBuscar').value.trim();
  if (q.length < 2) { document.getElementById('sugerenciasClienteCotDir').style.display = 'none'; return; }
  buscarClienteCotDirTimer = setTimeout(async () => {
    const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasClienteCotDir');
    if (!r.data.data.length) { div.style.display = 'none'; return; }
    div.innerHTML = r.data.data.map(c =>
      `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="selClienteCotDir(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
        ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.rtn || ''}</span>
      </div>`
    ).join('');
    div.style.display = 'block';
  }, 300);
}

function selClienteCotDir(id, nombre) {
  document.getElementById('cotDirClienteId').value = id;
  document.getElementById('cotDirClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteCotDir').style.display = 'none';
  cargarVehiculosCotDir(id);
}

async function cargarVehiculosCotDir(clienteId) {
  const sel = document.getElementById('cotDirVehiculoSelect');
  if (!sel) return;
  sel.innerHTML = '<option value="">Cargando...</option>';
  try {
    const r = await api('controllers/VehiculosController.php?action=por_cliente&cliente_id=' + clienteId);
    sel.innerHTML = '<option value="">— Sin vehículo / No aplica —</option>';
    if (r.ok && r.data.data.length) {
      r.data.data.forEach(v => {
        const label = `${v.placa}${v.marca ? ' — ' + v.marca : ''}${v.modelo ? ' ' + v.modelo : ''}${v.anio ? ' ' + v.anio : ''}`;
        sel.innerHTML += `<option value="${v.id_vehiculo}" data-placa="${v.placa}">${label}</option>`;
      });
    } else {
      sel.innerHTML += '<option value="" disabled>— Sin vehículos registrados —</option>';
    }
  } catch(e) {
    sel.innerHTML = '<option value="">— Error al cargar —</option>';
  }
}

function autoLlenarPlacaCotDir() {
  const sel = document.getElementById('cotDirVehiculoSelect');
  const opt = sel.options[sel.selectedIndex];
  if (!opt || !opt.value) return;
  document.getElementById('cotDirPlaca').value = opt.dataset.placa || '';
}

function agregarItemCotDir() {
  const desc   = document.getElementById('cotDirDesc').value.trim();
  const tipo   = document.getElementById('cotDirTipo').value;
  const cant   = parseFloat(document.getElementById('cotDirCant').value);
  const precio = parseFloat(document.getElementById('cotDirPrecio').value);
  if (!desc || isNaN(cant) || cant <= 0 || isNaN(precio) || precio < 0) {
    toast('Completa descripción, cantidad y precio.', 'warn'); return;
  }
  itemsCotDir.push({ descripcion: desc, tipo, cantidad: cant, precio_unitario: precio });
  document.getElementById('cotDirDesc').value = '';
  document.getElementById('cotDirCant').value = '1';
  document.getElementById('cotDirPrecio').value = '';
  renderItemsCotDir();
}

function renderItemsCotDir() {
  const tbody = document.getElementById('itemsCotDirBody');
  if (!itemsCotDir.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Sin ítems</td></tr>';
    document.getElementById('cotDirSubtotalMostrar').textContent = 'L. 0.00';
    document.getElementById('cotDirTotalMostrar').textContent    = 'L. 0.00';
    return;
  }
  tbody.innerHTML = itemsCotDir.map((it, i) => {
    const sub = it.cantidad * it.precio_unitario;
    return `<tr>
      <td><span class="badge ${it.tipo === 'mano_obra' ? 'badge-yellow' : 'badge-blue'}">${it.tipo === 'mano_obra' ? 'MO' : it.tipo === 'otro' ? 'Otro' : 'Mat.'}</span></td>
      <td>${it.descripcion}</td><td>${it.cantidad}</td>
      <td>${fmtMoneda(it.precio_unitario)}</td>
      <td>${fmtMoneda(sub)}</td>
      <td><button class="btn btn-sm btn-danger" onclick="quitarItemCotDir(${i})">✕</button>
          <button class="btn btn-sm btn-secondary" onclick="guardarItemEnCatalogo('${it.descripcion.replace(/'/g,"\\'")}','${it.tipo}',${it.precio_unitario})" title="Guardar al catálogo de precios">💾</button></td>
    </tr>`;
  }).join('');
  const subtotal = itemsCotDir.reduce((a, it) => a + it.cantidad * it.precio_unitario, 0);
  // Los precios ingresados ya llevan margen. Solo se agrega ISV 15%.
  const totalEst = subtotal * 1.15;
  document.getElementById('cotDirSubtotalMostrar').textContent = fmtMoneda(subtotal);
  document.getElementById('cotDirTotalMostrar').textContent    = fmtMoneda(totalEst);
}

function quitarItemCotDir(i) { itemsCotDir.splice(i, 1); renderItemsCotDir(); }

async function guardarCotizacionDirecta() {
  const clienteId = +document.getElementById('cotDirClienteId').value;
  const errEl     = document.getElementById('errCotDir');
  errEl.style.display = 'none';
  if (!clienteId)          { errEl.textContent = 'Selecciona un cliente.';            errEl.style.display = 'block'; return; }
  if (!itemsCotDir.length) { errEl.textContent = 'Agrega al menos un ítem.';          errEl.style.display = 'block'; return; }
  const body = {
    cliente_id:    clienteId,
    vigencia_dias: +document.getElementById('cotDirVigencia').value || 15,
    observaciones: document.getElementById('cotDirObs').value.trim(),
    ot_cliente:    document.getElementById('cotDirOtCliente').value.trim(),
    orden_compra:  document.getElementById('cotDirOrdenCompra').value.trim(),
    unidad:        document.getElementById('cotDirPlaca').value.trim(),
    items: itemsCotDir,
  };
  const r = await api('controllers/CotizacionesController.php?action=directa', {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) {
    cerrarModal('modalCotizacionDirecta');
    toast(`Cotización ${r.data.cotizacion.numero_cotizacion} creada.`, 'success');
    cargarCotizaciones();
  } else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

