// ══════════════════════════════════════════════════════════
// facturar_multiple.js — Facturar Múltiples Cotizaciones
// Extraído de dashboard.js líneas 4052-4264
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// FACTURAR MÚLTIPLES COTIZACIONES
// ══════════════════════════════════════════════════════════
let multiCotMetodoSelec = '';
let multiCotsSeleccionadas = new Set(); // ids seleccionados
let multiCotsDisponibles   = [];        // {id_cotizacion, numero_cotizacion, total, ...}

function abrirModalFacturarMultiple() {
  multiCotMetodoSelec = '';
  multiCotsSeleccionadas.clear();
  multiCotsDisponibles = [];
  document.getElementById('multiCotClienteBuscar').value = '';
  document.getElementById('multiCotClienteId').value = '';
  document.getElementById('multiCotListaWrap').style.display  = 'none';
  document.getElementById('multiCotSinCots').style.display    = 'none';
  document.getElementById('multiCotMetodoWrap').style.display = 'none';
  document.getElementById('btnConfirmarMulti').style.display  = 'none';
  document.getElementById('errFacturarMulti').style.display   = 'none';
  document.getElementById('sugerenciasClienteMulti').style.display = 'none';
  document.querySelectorAll('.metodo-btn[data-mmulti]').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  abrirModal('modalFacturarMultiple');
}

async function buscarClienteMultiCot() {
  const q = document.getElementById('multiCotClienteBuscar').value.trim();
  const sug = document.getElementById('sugerenciasClienteMulti');
  if (q.length < 2) { sug.style.display = 'none'; return; }
  const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
  if (!r.ok || !r.data.data.length) { sug.style.display = 'none'; return; }
  sug.innerHTML = r.data.data.map(c =>
    `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)"
      onmousedown="selClienteMultiCot(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
      ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.rtn||''}</span>
    </div>`
  ).join('');
  sug.style.display = 'block';
}

async function selClienteMultiCot(id, nombre) {
  document.getElementById('multiCotClienteId').value = id;
  document.getElementById('multiCotClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteMulti').style.display = 'none';
  multiCotsSeleccionadas.clear();
  await cargarCotizacionesMultiCot(id);
}

async function cargarCotizacionesMultiCot(cliente_id) {
  // Usar endpoint dedicado: solo aprobadas del cliente sin factura activa
  const r = await api('controllers/CotizacionesController.php?action=listar_cliente&cliente_id=' + cliente_id);
  if (!r.ok) { toast('Error cargando cotizaciones.', 'error'); return; }
  multiCotsDisponibles = r.data.data || [];

  const listaEl   = document.getElementById('multiCotLista');
  const wrapEl    = document.getElementById('multiCotListaWrap');
  const sinCotsEl = document.getElementById('multiCotSinCots');

  if (!multiCotsDisponibles.length) {
    wrapEl.style.display    = 'none';
    sinCotsEl.style.display = 'block';
    document.getElementById('multiCotMetodoWrap').style.display = 'none';
    document.getElementById('btnConfirmarMulti').style.display  = 'none';
    return;
  }
  sinCotsEl.style.display = 'none';
  wrapEl.style.display    = 'block';

  listaEl.innerHTML = multiCotsDisponibles.map(c => `
    <div class="cot-check-item" id="cot-item-${c.id_cotizacion}" onclick="toggleCotMulti(${c.id_cotizacion})">
      <input type="checkbox" id="chkCot-${c.id_cotizacion}" onclick="event.stopPropagation();"
        onchange="toggleCotMulti(${c.id_cotizacion})">
      <div style="flex:1">
        <div style="font-weight:600;font-family:monospace">${c.numero_cotizacion}</div>
        <div style="font-size:11px;color:var(--muted)">${c.fecha} ${c.ot_cliente ? '· OT: '+c.ot_cliente : ''} ${c.orden_compra ? '· OC: '+c.orden_compra : ''}</div>
      </div>
      <div style="font-weight:600;color:var(--accent)">${fmtMoneda(c.total)}</div>
    </div>`).join('');

  actualizarResumenMulti();
}

function toggleCotMulti(id) {
  const chk = document.getElementById('chkCot-' + id);
  const item = document.getElementById('cot-item-' + id);
  if (multiCotsSeleccionadas.has(id)) {
    multiCotsSeleccionadas.delete(id);
    chk.checked = false;
    item.classList.remove('selected');
  } else {
    multiCotsSeleccionadas.add(id);
    chk.checked = true;
    item.classList.add('selected');
  }
  actualizarResumenMulti();
}

function actualizarResumenMulti() {
  const count = multiCotsSeleccionadas.size;
  const total = multiCotsDisponibles
    .filter(c => multiCotsSeleccionadas.has(c.id_cotizacion))
    .reduce((s, c) => s + parseFloat(c.total || 0), 0);

  document.getElementById('multiCotCount').textContent = count;
  document.getElementById('multiCotTotal').textContent = fmtMoneda(total);

  const metodoWrap = document.getElementById('multiCotMetodoWrap');
  const btnConf    = document.getElementById('btnConfirmarMulti');
  if (count > 0) {
    metodoWrap.style.display = 'block';
    btnConf.style.display    = 'inline-flex';
  } else {
    metodoWrap.style.display = 'none';
    btnConf.style.display    = 'none';
    multiCotMetodoSelec = '';
    document.querySelectorAll('.metodo-btn[data-mmulti]').forEach(el => {
      el.style.borderColor = 'var(--border)'; el.style.background = '';
    });
  }
}

function selMetodoMulti(metodo) {
  multiCotMetodoSelec = metodo;
  document.querySelectorAll('.metodo-btn[data-mmulti]').forEach(el => {
    const sel = el.dataset.mmulti === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  const notaEl = document.getElementById('multiNotaMetodo');
  notaEl.style.display = 'block';
  if (metodo === 'credito') {
    notaEl.textContent = '📋 Crédito: la factura quedará en estado Pendiente hasta registrar el pago.';
  } else {
    notaEl.textContent = '✅ Efectivo: la factura se marcará como Pagada automáticamente.';
  }
}

async function confirmarFacturarMultiple() {
  const errEl = document.getElementById('errFacturarMulti');
  errEl.style.display = 'none';

  const cliente_id = document.getElementById('multiCotClienteId').value;
  if (!cliente_id) {
    errEl.textContent = 'Selecciona un cliente.'; errEl.style.display = 'block'; return;
  }
  if (!multiCotsSeleccionadas.size) {
    errEl.textContent = 'Selecciona al menos una cotización.'; errEl.style.display = 'block'; return;
  }
  if (!multiCotMetodoSelec) {
    errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return;
  }

  // Verificar CAI activo
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    errEl.textContent = 'No hay CAI activo. Configure el CAI antes de facturar.';
    errEl.style.display = 'block'; return;
  }

  // Convertir Set a array de enteros
  const ids = Array.from(multiCotsSeleccionadas).map(id => parseInt(id, 10));
  const totalCots = ids.length;

  const body = {
    cotizacion_ids: ids,
    metodo_pago:    multiCotMetodoSelec,
    observaciones:  (document.getElementById('multiCotObs').value || '').trim() || null,
  };

  // Deshabilitar botón mientras procesa
  const btn = document.getElementById('btnConfirmarMulti');
  const btnTexto = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Procesando...';

  try {
    const r = await api('controllers/FacturacionController.php?action=facturar_multiple', {
      method: 'POST',
      body: JSON.stringify(body),
    });
    if (r.ok && r.data.factura) {
      cerrarModal('modalFacturarMultiple');
      const f = r.data.factura;
      const emoji = f.estado === 'pagada' ? '✅' : '📋';
      toast(`${emoji} Factura ${f.numero_factura} emitida · ${totalCots} cotizaciones · ${f.estado}.`, 'success');
      if (typeof cargarFacturacion    === 'function') cargarFacturacion();
      if (typeof cargarCotizaciones   === 'function') cargarCotizaciones();
    } else {
      errEl.textContent = (r.data && r.data.error) ? r.data.error : 'Error al emitir la factura.';
      errEl.style.display = 'block';
    }
  } catch (e) {
    errEl.textContent = 'Error de conexión: ' + e.message;
    errEl.style.display = 'block';
  } finally {
    btn.disabled = false;
    btn.textContent = btnTexto;
  }
}

async function inactivarCAI(id) {
  if (!await confirmDialog('¿Inactivar este CAI? Ya no se podrá usar para facturar.')) return;
  const r = await api('controllers/FacturacionController.php?action=cai_inactivar', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) {
    toast('CAI inactivado correctamente.', 'success');
    cargarModuloCAI();
  } else {
    toast(r.data.error || 'Error al inactivar.', 'error');
  }
}

