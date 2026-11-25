// ══════════════════════════════════════════════════════════
// solicitudes.js — Solicitud → decisión OT / COT → Factura
// ══════════════════════════════════════════════════════════
const SOL_URL = 'controllers/SolicitudesController.php';
let solicitudesData = [], solDecidiendo = null;
const solEsc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

async function cargarSolicitudes() {
  document.getElementById('tablaSolicitudes').innerHTML = '<p class="loading">Cargando...</p>';
  const est = document.getElementById('filtroEstadoSol').value;
  const r = await api(`${SOL_URL}?action=listar` + (est ? '&estado=' + est : ''));
  if (!r.ok) { document.getElementById('tablaSolicitudes').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  solicitudesData = r.data.data;
  document.getElementById('buscarSol').value = '';
  paginaActual['solicitudes'] = 1;
  renderTablaSolicitudes(solicitudesData);
}

function filtrarSolicitudes() {
  const q = document.getElementById('buscarSol').value.toLowerCase().trim();
  paginaActual['solicitudes'] = 1;
  renderTablaSolicitudes(!q ? solicitudesData : solicitudesData.filter(s =>
    [s.numero_solicitud, s.cliente, s.placa, s.descripcion, s.numero_orden, s.numero_cotizacion, s.numero_factura].some(v => v && String(v).toLowerCase().includes(q))));
}

function solBadge(s) {
  const m = { pendiente: ['badge-yellow', 'Pendiente'], en_ot: ['badge-blue', 'En O.T.'], en_cotizacion: ['badge-green', 'En Cotización'], anulada: ['badge-red', 'Anulada'] }[s.estado] || ['badge-gray', s.estado];
  return `<span class="badge ${m[0]}">${m[1]}</span>` + (s.prioridad === 'urgente' ? ' <span class="badge badge-red">Urgente</span>' : '');
}

function solProceso(s) {
  if (s.estado === 'pendiente' || s.estado === 'anulada') return '<span style="color:var(--muted)">—</span>';
  const pasos = s.decision === 'ot'
    ? [s.numero_orden, s.numero_cotizacion, s.numero_factura] : [s.numero_cotizacion, s.numero_orden, s.numero_factura];
  const etq = s.decision === 'ot' ? ['O.T.', 'COT', 'FAC'] : ['COT', 'O.T.', 'FAC'];
  return pasos.map((p, i) => p ? `<span class="badge badge-gray" title="${etq[i]}">${solEsc(p)}</span>` : '').filter(Boolean).join(' → ');
}

function renderTablaSolicitudes(rows) {
  const pag = paginar('solicitudes', rows);
  let h = '<table><thead><tr><th>Solicitud</th><th>Fecha</th><th>Solicitó</th><th>Cliente</th><th>Tipo</th><th>Descripción</th><th>Unidad</th><th>Estado</th><th>Proceso</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin solicitudes</td></tr>';
  pag.slice.forEach(s => {
    const desc = s.descripcion.length > 60 ? s.descripcion.slice(0, 60) + '…' : s.descripcion;
    h += `<tr>
      <td><strong>${solEsc(s.numero_solicitud)}</strong></td><td>${s.fecha}</td><td>${solEsc(s.solicitante || '—')}</td><td>${solEsc(s.cliente)}</td><td>${s.decision === 'ot' ? '🔩 O.T.' : '📑 COT'}</td>
      <td title="${solEsc(s.descripcion)}">${solEsc(desc)}</td><td>${solEsc(s.placa || '—')}</td>
      <td>${solBadge(s)}</td><td>${solProceso(s)}</td>
      <td><div class="td-actions">${s.estado === 'pendiente' ? `
        <button class="btn btn-sm btn-success" onclick="abrirSolicitud(${s.id_solicitud})">▶ Abrir ${s.decision === 'ot' ? 'O.T.' : 'Cotización'}</button>
        <button class="btn btn-sm btn-secondary" onclick="editarSolicitud(${s.id_solicitud})">Editar</button>
        <button class="btn btn-sm btn-danger" onclick="anularSolicitud(${s.id_solicitud})">Anular</button>` : ''}
        ${s.estado === 'en_ot' ? `<button class="btn btn-sm btn-secondary" onclick="navegarModulo('ordenes')">Ir a O.T.</button>` : ''}
        ${s.estado === 'en_cotizacion' ? `<button class="btn btn-sm btn-secondary" onclick="navegarModulo('cotizaciones')">Ir a Cotizaciones</button>` : ''}
      </div></td></tr>`;
  });
  document.getElementById('tablaSolicitudes').innerHTML = h + '</tbody></table>';
  renderPaginacion('solicitudes', pag, 'paginaSolicitudes');
}

// ── Formulario ───────────────────────────────────────────
let solLineas = [], solItems = [];

function solSetTipo(t) {
  document.getElementById('solTipo').value = t;
  document.getElementById('solSecOT').style.display = t === 'ot' ? '' : 'none';
  document.getElementById('solSecCOT').style.display = t === 'cotizacion' ? '' : 'none';
  document.getElementById('solBtnOT').classList.toggle('btn-primary', t === 'ot');
  document.getElementById('solBtnOT').classList.toggle('btn-secondary', t !== 'ot');
  document.getElementById('solBtnCOT').classList.toggle('btn-primary', t === 'cotizacion');
  document.getElementById('solBtnCOT').classList.toggle('btn-secondary', t !== 'cotizacion');
}

function solRenderLineas() {
  const w = document.getElementById('solDescWrap');
  w.innerHTML = !solLineas.length ? '<p style="color:var(--muted);font-size:12px;padding:4px 0">Sin líneas. Presiona "+ Trabajo" para agregar.</p>'
    : solLineas.map((l, i) => `<div style="display:flex;align-items:center;gap:6px;margin-bottom:6px">
        <input type="text" value="${solEsc(l)}" oninput="solLineas[${i}]=this.value" style="flex:1;padding:6px 10px;background:var(--sidebar);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        <button type="button" onclick="solQuitarLinea(${i})" style="background:none;border:none;color:var(--danger);cursor:pointer;font-size:18px;padding:0 4px;line-height:1">✕</button></div>`).join('');
}
function solAgregarLinea() { solLineas.push('Trabajo ' + (solLineas.length + 1)); solRenderLineas(); }
function solQuitarLinea(i) { solLineas.splice(i, 1); solLineas = solLineas.map((l, k) => /^Trabajo \d+$/.test(l) ? 'Trabajo ' + (k + 1) : l); solRenderLineas(); }

function solRenderItems() {
  const b = document.getElementById('solItemsBody');
  b.innerHTML = !solItems.length ? '<tr><td colspan="6" class="empty-state">Sin ítems</td></tr>' : solItems.map((it, i) => `<tr>
    <td><span class="badge ${it.tipo === 'mano_obra' ? 'badge-yellow' : 'badge-blue'}">${it.tipo === 'mano_obra' ? 'MO' : it.tipo === 'otro' ? 'Otro' : 'Mat.'}</span></td>
    <td>${solEsc(it.descripcion)}</td><td>${it.cantidad}</td><td>${fmtMoneda(it.precio_unitario)}</td><td>${fmtMoneda(it.cantidad * it.precio_unitario)}</td>
    <td><button type="button" class="btn btn-sm btn-danger" onclick="solItems.splice(${i},1);solRenderItems()">✕</button></td></tr>`).join('');
}
function solAgregarItem() {
  const desc = document.getElementById('solItDesc').value.trim(), cant = parseFloat(document.getElementById('solItCant').value), pre = parseFloat(document.getElementById('solItPrecio').value);
  if (!desc || isNaN(cant) || cant <= 0 || isNaN(pre) || pre < 0) { toast('Completa descripción, cantidad y precio.', 'warn'); return; }
  solItems.push({ descripcion: desc, tipo: document.getElementById('solItTipo').value, cantidad: cant, precio_unitario: pre });
  document.getElementById('solItDesc').value = ''; document.getElementById('solItCant').value = '1'; document.getElementById('solItPrecio').value = '';
  solRenderItems();
}

async function abrirModalSolicitud(s) {
  document.getElementById('solId').value = s ? s.id_solicitud : '';
  document.getElementById('tituloSolicitud').textContent = s ? 'Editar ' + s.numero_solicitud : 'Nueva Solicitud';
  document.getElementById('errSolicitud').style.display = 'none';
  document.getElementById('solSugerencias').style.display = 'none';
  document.getElementById('solSolicitante').value = s ? (s.solicitante || '') : (document.getElementById('sidebarNombre')?.textContent || '');
  document.getElementById('solPrioridad').value = s ? s.prioridad : 'normal';
  document.getElementById('solClienteId').value = s ? s.cliente_id : '';
  document.getElementById('solClienteBuscar').value = s ? s.cliente : '';
  solLineas = s && s.decision === 'ot' ? s.descripcion.split('\n').filter(l => l.trim()) : [];
  solItems = s && s.decision === 'cotizacion' && s.items_json ? JSON.parse(s.items_json) : [];
  solRenderLineas(); solRenderItems(); solSetTipo(s ? s.decision : 'ot');
  abrirModal('modalSolicitud');
  await solCargarVehiculos(s ? s.cliente_id : 0, s ? s.vehiculo_id : null);
}

async function editarSolicitud(id) {
  const r = await api(`${SOL_URL}?action=obtener&id=${id}`);
  if (!r.ok) { toast(r.data?.error || 'No se pudo cargar.', 'error'); return; }
  abrirModalSolicitud(r.data.data);
}

let solTimer = null;
function buscarClienteSol() {
  clearTimeout(solTimer);
  document.getElementById('solClienteId').value = '';
  const q = document.getElementById('solClienteBuscar').value.trim(), box = document.getElementById('solSugerencias');
  if (q.length < 2) { box.style.display = 'none'; return; }
  solTimer = setTimeout(async () => {
    const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
    if (!r.ok || !r.data.data.length) { box.style.display = 'none'; return; }
    box.innerHTML = r.data.data.map(c => `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="solElegirCliente(${c.id_cliente})" data-n="${solEsc(c.nombre)}">${solEsc(c.nombre)} <span style="color:var(--muted);font-size:11px">${solEsc(c.rtn || '')}</span></div>`).join('');
    box.style.display = 'block';
  }, 300);
}
function solElegirCliente(id) {
  const el = [...document.querySelectorAll('#solSugerencias div')].find(d => d.getAttribute('onmousedown').includes(`(${id})`));
  document.getElementById('solClienteId').value = id;
  document.getElementById('solClienteBuscar').value = el ? el.dataset.n : '';
  document.getElementById('solSugerencias').style.display = 'none';
  solCargarVehiculos(id);
}

async function solCargarVehiculos(clienteId, sel = null) {
  const el = document.getElementById('solVehiculoSel');
  if (!clienteId) { el.innerHTML = '<option value="">— Seleccione un cliente —</option>'; return; }
  const r = await api('controllers/VehiculosController.php?action=por_cliente&cliente_id=' + clienteId);
  const v = r.ok ? r.data.data : [];
  el.innerHTML = '<option value="">— Sin vehículo / No aplica —</option>' + v.map(x =>
    `<option value="${x.id_vehiculo}">Unidad ${solEsc(x.placa)}${x.marca ? ' — ' + solEsc(x.marca) : ''}${x.modelo ? ' — ' + solEsc(x.modelo) : ''}${x.anio ? ' ' + x.anio : ''}</option>`).join('');
  if (sel) el.value = sel;
}

async function guardarSolicitud() {
  const err = document.getElementById('errSolicitud'), id = document.getElementById('solId').value, tipo = document.getElementById('solTipo').value;
  const body = { id, cliente_id: +document.getElementById('solClienteId').value, vehiculo_id: +document.getElementById('solVehiculoSel').value || null,
    prioridad: document.getElementById('solPrioridad').value, decision: tipo,
    descripcion: tipo === 'ot' ? solLineas.map(l => l.trim()).filter(Boolean).join('\n') : '', items: tipo === 'cotizacion' ? solItems : [] };
  const fallo = m => { err.textContent = m; err.style.display = 'block'; };
  if (!body.cliente_id) return fallo('Selecciona un cliente de la lista.');
  if (tipo === 'ot' && !body.descripcion) return fallo('La descripción del trabajo es requerida.');
  if (tipo === 'cotizacion' && !solItems.length) return fallo('Agrega al menos un ítem a la cotización.');
  const r = await api(`${SOL_URL}?action=${id ? 'editar' : 'crear'}`, { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) return fallo(r.data?.error || 'Error al guardar.');
  cerrarModal('modalSolicitud'); toast(id ? 'Solicitud actualizada.' : 'Solicitud enviada.', 'success');
  cargarSolicitudes(); cargarNotifSolicitudes();
}

async function anularSolicitud(id) {
  if (!(await confirmDialog('¿Anular esta solicitud?'))) return;
  const r = await api(`${SOL_URL}?action=anular`, { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo anular.', 'error'); return; }
  toast('Solicitud anulada.', 'success'); cargarSolicitudes();
}

// ── Abrir la solicitud en su pantalla (O.T. o Cotización) para guardarla ──
async function abrirSolicitud(id) {
  document.getElementById('notifSolPanel').style.display = 'none';
  const r = await api(`${SOL_URL}?action=obtener&id=${id}`);
  if (!r.ok) { toast(r.data?.error || 'No se pudo cargar la solicitud.', 'error'); return; }
  const s = r.data.data;
  if (s.estado !== 'pendiente') { toast('Esta solicitud ya fue procesada.', 'warn'); cargarNotifSolicitudes(); return; }
  const set = (i, v) => { const el = document.getElementById(i); if (el) el.value = v ?? ''; };

  if (s.decision === 'ot') {
    navegarModulo('ordenes');
    await abrirModalOT();
    set('otClienteId', s.cliente_id); set('otClienteBuscar', s.cliente);
    await cargarVehiculosOT(s.cliente_id);
    if (s.vehiculo_id) { set('otVehiculoSelect', s.vehiculo_id); autoLlenarVehiculoOT(); }
    lineasTrabajo = (s.descripcion || '').split('\n').filter(l => l.trim()); renderLineasTrabajo();
    set('otObs', `Solicitud ${s.numero_solicitud} — solicitó: ${s.solicitante || ''}`);
    window.__solOtId = s.id_solicitud;
    toast('Revisa la O.T. y guárdala: quedará enlazada a la solicitud.', 'info');
  } else {
    navegarModulo('cotizaciones');
    abrirModalCotizacionDirecta();
    set('cotDirClienteId', s.cliente_id); set('cotDirClienteBuscar', s.cliente);
    itemsCotDir = s.items_json ? JSON.parse(s.items_json) : []; renderItemsCotDir();
    set('cotDirObs', `Solicitud ${s.numero_solicitud} — solicitó: ${s.solicitante || ''}`);
    await cargarVehiculosCotDir(s.cliente_id);
    if (s.vehiculo_id) { set('cotDirVehiculoSelect', s.vehiculo_id); autoLlenarPlacaCotDir(); }
    window.__solCotId = s.id_solicitud;
    toast('Revisa la cotización y guárdala: quedará enlazada a la solicitud.', 'info');
  }
}

async function solicitudVincularOT(ordenId) {
  const id = window.__solOtId; window.__solOtId = null;
  if (!id || !ordenId) return;
  const r = await api(`${SOL_URL}?action=vincular_ot`, { method: 'POST', body: JSON.stringify({ id, orden_id: ordenId }) });
  if (!r.ok) toast('La O.T. se creó, pero no se pudo enlazar a la solicitud: ' + (r.data?.error || ''), 'warn');
  cargarNotifSolicitudes();
}

async function solicitudVincularCot(cotId) {
  const id = window.__solCotId; window.__solCotId = null;
  if (!id || !cotId) return;
  const r = await api(`${SOL_URL}?action=vincular_cot`, { method: 'POST', body: JSON.stringify({ id, cotizacion_id: cotId }) });
  if (!r.ok) toast('La cotización se creó, pero no se pudo enlazar a la solicitud: ' + (r.data?.error || ''), 'warn');
  cargarNotifSolicitudes();
}

// ── Notificaciones en Inicio ─────────────────────────────
let solNotifTimer = null;
async function cargarNotifSolicitudes() {
  const wrap = document.getElementById('notifSolWrap'); if (!wrap) return;
  const r = await api(`${SOL_URL}?action=listar&estado=pendiente`);
  if (!r.ok) { wrap.style.display = 'none'; return; }
  const rows = r.data.data;
  wrap.style.display = 'flex';
  const badge = document.getElementById('notifSolBadge');
  badge.textContent = rows.length; badge.style.display = rows.length ? '' : 'none';
  document.getElementById('notifSolPanel').innerHTML = !rows.length
    ? '<div style="padding:16px;font-size:13px;color:var(--muted);text-align:center">No hay solicitudes pendientes</div>'
    : rows.map(s => `<div onclick="abrirSolicitud(${s.id_solicitud})" style="padding:10px 14px;border-bottom:1px solid var(--border);cursor:pointer">
        <div style="display:flex;justify-content:space-between;gap:8px;font-size:13px"><strong>${solEsc(s.numero_solicitud)}</strong>
          <span>${s.decision === 'ot' ? '🔩 O.T.' : '📑 Cotización'}${s.prioridad === 'urgente' ? ' <span class="badge badge-red">Urgente</span>' : ''}</span></div>
        <div style="font-size:12px">${solEsc(s.cliente)}</div>
        <div style="font-size:11px;color:var(--muted)">Solicitó: ${solEsc(s.solicitante || '—')} · ${s.fecha}</div></div>`).join('');
  if (!solNotifTimer) solNotifTimer = setInterval(() => { if (document.getElementById('notifSolWrap')) cargarNotifSolicitudes(); }, 60000);
}
function toggleNotifSol() { const p = document.getElementById('notifSolPanel'); p.style.display = p.style.display === 'none' ? 'block' : 'none'; }
document.addEventListener('click', e => { const p = document.getElementById('notifSolPanel'); if (p && p.style.display !== 'none' && !e.target.closest('#notifSolWrap')) p.style.display = 'none'; });
