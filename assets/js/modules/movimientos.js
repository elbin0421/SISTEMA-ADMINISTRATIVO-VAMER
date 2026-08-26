// ══════════════════════════════════════════════════════════
// movimientos.js — Registro de Movimientos (MAERSK / ALPLA)
// ══════════════════════════════════════════════════════════

// ── LISTADO ──────────────────────────────────────────────────
let movimientosDataFull = [];

async function cargarMovimientos() {
  const tipo        = document.getElementById('filtroMovTipo')?.value        || 'todos';
  const estado      = document.getElementById('filtroMovEstado')?.value      || 'todos';
  const q           = document.getElementById('filtroMovBuscar')?.value      || '';
  const fechaDesde  = document.getElementById('filtroMovFechaDesde')?.value  || '';
  const fechaHasta  = document.getElementById('filtroMovFechaHasta')?.value  || '';
  const periodo     = (document.getElementById('filtroMovPeriodo')?.value    || '').trim().toLowerCase();

  const params = new URLSearchParams({ action: 'listar', tipo, estado, q });
  if (fechaDesde) params.set('fecha_desde', fechaDesde);
  if (fechaHasta) params.set('fecha_hasta', fechaHasta);

  const r = await api('controllers/MovimientosController.php?' + params.toString());
  const wrap = document.getElementById('tablaMovimientosWrap');
  if (!r.ok) { wrap.innerHTML = '<p class="error">Error al cargar movimientos.</p>'; return; }

  let datos = r.data.data || [];
  if (periodo) datos = datos.filter(m => (m.periodo || '').toLowerCase().includes(periodo));

  movimientosDataFull = datos;
  paginaActual['movimientos'] = 1;
  renderTablaMovimientos(datos);
}

function limpiarFiltrosMovimientos() {
  document.getElementById('filtroMovTipo').value = 'todos';
  document.getElementById('filtroMovEstado').value = 'todos';
  document.getElementById('filtroMovFechaDesde').value = '';
  document.getElementById('filtroMovFechaHasta').value = '';
  document.getElementById('filtroMovPeriodo').value = '';
  document.getElementById('filtroMovBuscar').value = '';
  cargarMovimientos();
}

function badgeMovEstado(estado) {
  const map = { pendiente: 'badge-yellow', facturado: 'badge-green', anulado: 'badge-red' };
  return `<span class="badge ${map[estado] || 'badge-gray'}">${estado}</span>`;
}

function renderTablaMovimientos(rows) {
  const wrap = document.getElementById('tablaMovimientosWrap');
  paginaActual['movimientos'] = paginaActual['movimientos'] || 1;
  const pag = paginar('movimientos', rows);

  if (!rows.length) {
    wrap.innerHTML = '<p style="color:var(--muted);text-align:center;padding:24px 0">Sin movimientos registrados.</p>';
    document.getElementById('paginaMovimientos').innerHTML = '';
    return;
  }

  wrap.innerHTML = `
    <table class="table-compact">
      <thead>
        <tr>
          <th>Fecha / Hora</th><th>Tipo</th><th>Cliente / Destino</th><th>Periodo</th>
          <th>Contenedor / Flete</th><th>Motorista / Placa</th>
          <th>Tarifa</th><th>Estado</th><th>Factura</th><th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        ${pag.slice.map(m => `
          <tr>
            <td>${m.fecha}${m.hora ? '<br><span class="td-sub">' + m.hora.slice(0,5) + '</span>' : ''}</td>
            <td><span class="badge badge-blue">${m.tipo}</span></td>
            <td>${m.cliente_nombre || '<span style="color:var(--muted)">—</span>'}${m.destino ? '<br><span class="td-sub">' + m.destino + '</span>' : ''}</td>
            <td>${m.periodo || '—'}</td>
            <td>${m.contenedor || '—'}${m.flete ? '<br><span class="td-sub">Flete: ' + m.flete + '</span>' : ''}</td>
            <td>${m.motorista || '—'}${m.placa ? '<br><span class="td-sub">' + m.placa + '</span>' : ''}</td>
            <td>${fmtMoneda(m.tarifa)}</td>
            <td>${badgeMovEstado(m.estado)}</td>
            <td>${m.numero_factura || '—'}</td>
            <td><div class="td-actions">
              <button class="btn btn-sm btn-secondary" onclick="verMovimiento(${m.id_movimiento})" title="Ver">👁️</button>
              <button class="btn btn-sm btn-secondary" onclick="pdfMovimiento(${m.id_movimiento})" title="PDF">📄</button>
              <button class="btn btn-sm btn-secondary" onclick="exportarMovimientoExcel(${m.id_movimiento})" title="Excel">⬇️</button>
              ${m.estado === 'pendiente' ? `
                <button class="btn btn-sm btn-secondary" onclick="abrirModalMovimiento(${m.id_movimiento})" title="Editar">✏️</button>
                <button class="btn btn-sm btn-danger" onclick="anularMovimiento(${m.id_movimiento})" title="Anular">🗑️</button>
              ` : ''}
            </div></td>
          </tr>
        `).join('')}
      </tbody>
    </table>`;
  renderPaginacion('movimientos', pag, 'paginaMovimientos');
}

async function verMovimiento(id) {
  document.getElementById('contenidoVerMov').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalVerMovimiento');

  let m = (datosModulo['movimientos'] || []).find(x => x.id_movimiento === id);
  if (!m) {
    const r = await api('controllers/MovimientosController.php?action=obtener&id=' + id);
    if (!r.ok) { document.getElementById('contenidoVerMov').innerHTML = '<p style="color:var(--danger)">Error al cargar el movimiento.</p>'; return; }
    m = r.data.data;
  }

  const fila = (lbl, val) => `<div><span style="color:var(--muted)">${lbl}:</span> <strong>${val ?? '—'}</strong></div>`;

  document.getElementById('contenidoVerMov').innerHTML = `
    <h4 style="margin-bottom:12px">🚛 Movimiento ${m.tipo} — ${badgeMovEstado(m.estado)}</h4>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px 16px;font-size:13px;margin-bottom:14px">
      ${fila('Fecha', m.fecha + (m.hora ? ' · ' + m.hora.slice(0,5) : ''))}
      ${fila('Periodo', m.periodo)}
      ${fila('Cliente', m.cliente_nombre)}
      ${fila('Destino', m.destino)}
      ${fila('OT', m.ot)}
      ${fila('Contenedor', m.contenedor)}
      ${fila('Flete', m.flete)}
      ${fila('Motorista', m.motorista)}
      ${fila('Placa', m.placa)}
      ${fila('Tarifa', fmtMoneda(m.tarifa))}
      ${fila('No. Factura', m.numero_factura)}
    </div>
    ${m.observacion ? `<div style="font-size:12px"><strong>Observación:</strong> ${m.observacion}</div>` : ''}`;

  window._movImprimirData = m;
}

function _htmlComprobanteMovimiento(m) {
  const fila = (lbl, val) => `<div><span class="lbl">${lbl}:</span> ${val ?? '—'}</div>`;
  return `<!DOCTYPE html><html><head><meta charset="UTF-8">
  <title>Movimiento ${m.tipo} ${m.ot || ''}</title>
  <style>
    body{font-family:Arial,sans-serif;font-size:12px;padding:20px;color:#111}
    h2{text-align:center;margin-bottom:2px}
    .info{display:grid;grid-template-columns:1fr 1fr;gap:6px 20px;margin:14px 0;font-size:12px;border:1px solid #ccc;padding:12px;border-radius:6px}
    .lbl{font-weight:700;color:#555}
    .tot{margin-top:14px;text-align:right;font-size:14px;font-weight:700}
    @media print{@page{margin:12mm}}
  </style></head><body>
  <h2>COMPROBANTE DE MOVIMIENTO</h2>
  <p style="text-align:center;color:#555;margin:2px">VENTAS AMERICA S. DE R.L / SOLDYMEG — ${m.tipo}</p>
  <div class="info">
    ${fila('Fecha', m.fecha + (m.hora ? ' · ' + m.hora.slice(0,5) : ''))}
    ${fila('Periodo', m.periodo)}
    ${fila('Cliente', m.cliente_nombre)}
    ${fila('Destino', m.destino)}
    ${fila('OT', m.ot)}
    ${fila('Contenedor', m.contenedor)}
    ${fila('Flete', m.flete)}
    ${fila('Motorista', m.motorista)}
    ${fila('Placa', m.placa)}
    ${fila('Estado', m.estado)}
    ${fila('No. Factura', m.numero_factura)}
  </div>
  ${m.observacion ? `<p><strong>Observación:</strong> ${m.observacion}</p>` : ''}
  <div class="tot">Tarifa: ${fmtMoneda(m.tarifa)}</div>
  <script>window.onload=()=>window.print()<\/script>
  </body></html>`;
}

function imprimirMovimiento() {
  const m = window._movImprimirData;
  if (!m) return;
  const w = window.open('', '_blank');
  w.document.write(_htmlComprobanteMovimiento(m));
  w.document.close();
}

async function _obtenerMovimiento(id) {
  let m = (datosModulo['movimientos'] || []).find(x => x.id_movimiento === id);
  if (m) return m;
  const r = await api('controllers/MovimientosController.php?action=obtener&id=' + id);
  return (r.ok && r.data.data) ? r.data.data : null;
}

async function pdfMovimiento(id) {
  const m = await _obtenerMovimiento(id);
  if (!m) { toast('No se pudo cargar el movimiento.', 'error'); return; }
  const w = window.open('', '_blank');
  w.document.write(_htmlComprobanteMovimiento(m));
  w.document.close();
}

function exportarMovimientosListadoExcel() {
  if (!movimientosDataFull.length) { toast('Sin datos para exportar.', 'error'); return; }

  const fechaDesde = document.getElementById('filtroMovFechaDesde')?.value || '';
  const fechaHasta = document.getElementById('filtroMovFechaHasta')?.value || '';
  const periodo    = document.getElementById('filtroMovPeriodo')?.value    || '';

  const rows = [
    ['Fecha', 'Hora', 'Tipo', 'Periodo', 'Cliente', 'Destino', 'OT', 'Contenedor', 'Flete', 'Motorista', 'Placa', 'Tarifa', 'Estado', 'No. Factura'],
    ...movimientosDataFull.map(m => [
      m.fecha, m.hora ? m.hora.slice(0,5) : '', m.tipo, m.periodo || '',
      m.cliente_nombre || '', m.destino || '', m.ot || '', m.contenedor || '',
      m.flete || '', m.motorista || '', m.placa || '',
      parseFloat(m.tarifa || 0), m.estado, m.numero_factura || '',
    ]),
  ];

  const totalTarifa = movimientosDataFull.reduce((s, m) => s + parseFloat(m.tarifa || 0), 0);
  rows.push([]);
  rows.push(['', '', '', '', '', '', '', '', '', '', 'TOTAL', totalTarifa]);

  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [11,7,9,16,26,16,12,14,10,16,10,10,11,14].map(w => ({ wch: w }));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Movimientos');

  let nombre = 'Movimientos_MAERSK_ALPLA';
  if (fechaDesde || fechaHasta) nombre += `_${fechaDesde || 'inicio'}_a_${fechaHasta || 'hoy'}`;
  if (periodo) nombre += `_${periodo.replace(/\s+/g,'_')}`;
  XLSX.writeFile(wb, `${nombre}.xlsx`);
  toast('Excel generado.', 'success');
}

async function exportarMovimientoExcel(id) {
  const m = await _obtenerMovimiento(id);
  if (!m) { toast('No se pudo cargar el movimiento.', 'error'); return; }

  const rows = [
    ['COMPROBANTE DE MOVIMIENTO — ' + m.tipo],
    ['VENTAS AMERICA S. DE R.L / SOLDYMEG'],
    [],
    ['Fecha', m.fecha + (m.hora ? ' ' + m.hora.slice(0,5) : '')],
    ['Periodo', m.periodo || ''],
    ['Cliente', m.cliente_nombre || ''],
    ['Destino', m.destino || ''],
    ['OT', m.ot || ''],
    ['Contenedor', m.contenedor || ''],
    ['Flete', m.flete || ''],
    ['Motorista', m.motorista || ''],
    ['Placa', m.placa || ''],
    ['Tarifa', parseFloat(m.tarifa || 0)],
    ['Estado', m.estado || ''],
    ['No. Factura', m.numero_factura || ''],
    ['Observación', m.observacion || ''],
  ];

  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [{ wch: 16 }, { wch: 40 }];
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Movimiento');
  XLSX.writeFile(wb, `Movimiento_${m.tipo}_${m.ot || m.id_movimiento}.xlsx`);
  toast('Excel generado.', 'success');
}

// ── CREAR / EDITAR ───────────────────────────────────────────
async function cargarMotoristasMovimiento() {
  const sel = document.getElementById('movMotorista');
  if (!sel) return;
  sel.innerHTML = '<option value="">— Seleccionar motorista —</option>';
  const r = await api('controllers/MovimientosController.php?action=motoristas');
  if (r.ok) {
    (r.data.data || []).forEach(e => {
      const opt = document.createElement('option');
      opt.value       = e.id_empleado;
      opt.textContent = e.nombre;
      sel.appendChild(opt);
    });
  } else {
    toast('No se pudo cargar la lista de motoristas.', 'error');
  }
}

async function abrirModalMovimiento(id = null) {
  document.getElementById('errMovimiento').style.display = 'none';
  document.getElementById('movId').value = '';
  document.getElementById('movClienteBuscar').value = '';
  document.getElementById('movClienteId').value = '';
  document.getElementById('sugerenciasClienteMov').style.display = 'none';
  ['movTipo','movPeriodo','movFecha','movHora','movFlete','movDestino','movOt','movContenedor',
   'movChasis','movPlaca','movTarifa','movObservacion'
  ].forEach(f => { const el = document.getElementById(f); if (el) el.value = ''; });
  await cargarMotoristasMovimiento();

  document.getElementById('tituloModalMovimiento').textContent = id ? '🚛 Editar Movimiento' : '🚛 Registrar Movimiento';
  document.getElementById('btnGuardarMovimiento').textContent  = id ? 'Guardar Cambios' : 'Registrar Movimiento';

  if (!id) {
    document.getElementById('movFecha').value = new Date().toISOString().slice(0,10);
  } else {
    const r = await api('controllers/MovimientosController.php?action=obtener&id=' + id);
    if (!r.ok) { toast('No se pudo cargar el movimiento.', 'error'); return; }
    const m = r.data.data;
    document.getElementById('movId').value          = m.id_movimiento;
    document.getElementById('movTipo').value         = m.tipo;
    document.getElementById('movPeriodo').value      = m.periodo || '';
    document.getElementById('movFecha').value        = m.fecha;
    document.getElementById('movHora').value         = m.hora ? m.hora.slice(0,5) : '';
    document.getElementById('movFlete').value        = m.flete || '';
    document.getElementById('movDestino').value      = m.destino || '';
    document.getElementById('movOt').value           = m.ot || '';
    document.getElementById('movContenedor').value   = m.contenedor || '';
    document.getElementById('movChasis').value       = m.chasis || '';
    document.getElementById('movPlaca').value        = m.placa || '';
    const selMot = document.getElementById('movMotorista');
    if (m.motorista_id) {
      if (![...selMot.options].some(o => o.value == m.motorista_id)) {
        const opt = document.createElement('option');
        opt.value = m.motorista_id; opt.textContent = (m.motorista || 'Motorista') + ' (inactivo/no encontrado)';
        selMot.appendChild(opt);
      }
      selMot.value = m.motorista_id;
    } else if (m.motorista) {
      // Compatibilidad con movimientos antiguos guardados solo con nombre (sin id)
      const opt = document.createElement('option');
      opt.value = ''; opt.textContent = m.motorista + ' (registro antiguo, seleccione de nuevo)';
      selMot.appendChild(opt);
      selMot.value = '';
    }
    document.getElementById('movTarifa').value       = m.tarifa;
    document.getElementById('movObservacion').value  = m.observacion || '';
    if (m.cliente_id) {
      document.getElementById('movClienteId').value    = m.cliente_id;
      document.getElementById('movClienteBuscar').value = m.cliente_nombre || '';
    }
  }
  abrirModal('modalMovimiento');
}

async function buscarClienteMov() {
  const q = document.getElementById('movClienteBuscar').value.trim();
  const sug = document.getElementById('sugerenciasClienteMov');
  document.getElementById('movClienteId').value = '';
  if (q.length < 2) { sug.style.display = 'none'; return; }
  const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
  if (!r.ok || !r.data.data.length) { sug.style.display = 'none'; return; }
  sug.innerHTML = r.data.data.map(c =>
    `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)"
      onmousedown="selClienteMov(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
      ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.rtn||''}</span>
    </div>`
  ).join('');
  sug.style.display = 'block';
}

function selClienteMov(id, nombre) {
  document.getElementById('movClienteId').value = id;
  document.getElementById('movClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteMov').style.display = 'none';
}

async function guardarMovimiento() {
  const errEl = document.getElementById('errMovimiento');
  errEl.style.display = 'none';

  const id = document.getElementById('movId').value;
  const body = {
    tipo:         document.getElementById('movTipo').value,
    periodo:      document.getElementById('movPeriodo').value.trim(),
    fecha:        document.getElementById('movFecha').value,
    hora:         document.getElementById('movHora').value,
    flete:        document.getElementById('movFlete').value.trim(),
    destino:      document.getElementById('movDestino').value.trim(),
    cliente_id:   document.getElementById('movClienteId').value || null,
    ot:           document.getElementById('movOt').value.trim(),
    contenedor:   document.getElementById('movContenedor').value.trim(),
    chasis:       document.getElementById('movChasis').value.trim(),
    placa:        document.getElementById('movPlaca').value.trim(),
    motorista_id: document.getElementById('movMotorista').value || null,
    motorista:    document.getElementById('movMotorista').value
                    ? document.getElementById('movMotorista').selectedOptions[0].textContent.replace(/\s*\(.*\)$/, '')
                    : '',
    tarifa:       parseFloat(document.getElementById('movTarifa').value || 0),
    observacion:  document.getElementById('movObservacion').value.trim(),
  };

  if (!body.tipo) { errEl.textContent = 'Selecciona el tipo (MAERSK/ALPLA).'; errEl.style.display = 'block'; return; }
  if (!body.fecha) { errEl.textContent = 'La fecha es requerida.'; errEl.style.display = 'block'; return; }
  if (isNaN(body.tarifa) || body.tarifa < 0) { errEl.textContent = 'La tarifa no es válida.'; errEl.style.display = 'block'; return; }

  const btn = document.getElementById('btnGuardarMovimiento');
  btn.disabled = true;
  try {
    let r;
    if (id) {
      body.id = parseInt(id, 10);
      r = await api('controllers/MovimientosController.php?action=editar', { method:'POST', body: JSON.stringify(body) });
    } else {
      r = await api('controllers/MovimientosController.php?action=crear', { method:'POST', body: JSON.stringify(body) });
    }
    if (r.ok) {
      cerrarModal('modalMovimiento');
      toast(id ? 'Movimiento actualizado.' : 'Movimiento registrado.', 'success');
      cargarMovimientos();
    } else {
      errEl.textContent = r.data.error || 'Error al guardar.'; errEl.style.display = 'block';
    }
  } finally {
    btn.disabled = false;
  }
}

async function anularMovimiento(id) {
  if (!await confirmDialog('¿Anular este movimiento? Esta acción no se puede deshacer.')) return;
  const r = await api('controllers/MovimientosController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) { toast('Movimiento anulado.', 'success'); cargarMovimientos(); }
  else { toast(r.data.error || 'Error al anular.', 'error'); }
}

// ══════════════════════════════════════════════════════════
// FACTURAR MÚLTIPLES MOVIMIENTOS
// ══════════════════════════════════════════════════════════
let multiMovMetodoSelec  = '';
let multiMovsSeleccionadas = new Set();
let multiMovsDisponibles   = [];

function abrirModalFacturarMovimientos() {
  multiMovMetodoSelec = '';
  multiMovsSeleccionadas.clear();
  multiMovsDisponibles = [];
  document.getElementById('multiMovClienteBuscar').value = '';
  document.getElementById('multiMovClienteId').value = '';
  document.getElementById('multiMovListaWrap').style.display  = 'none';
  document.getElementById('multiMovSinMovs').style.display    = 'none';
  document.getElementById('multiMovMetodoWrap').style.display = 'none';
  document.getElementById('btnConfirmarMultiMov').style.display = 'none';
  document.getElementById('errFacturarMov').style.display     = 'none';
  document.getElementById('sugerenciasClienteMultiMov').style.display = 'none';
  document.querySelectorAll('.metodo-btn[data-mmov]').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  abrirModal('modalFacturarMovimientos');
}

async function buscarClienteMultiMov() {
  const q = document.getElementById('multiMovClienteBuscar').value.trim();
  const sug = document.getElementById('sugerenciasClienteMultiMov');
  if (q.length < 2) { sug.style.display = 'none'; return; }
  const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
  if (!r.ok || !r.data.data.length) { sug.style.display = 'none'; return; }
  sug.innerHTML = r.data.data.map(c =>
    `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)"
      onmousedown="selClienteMultiMov(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
      ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.rtn||''}</span>
    </div>`
  ).join('');
  sug.style.display = 'block';
}

async function selClienteMultiMov(id, nombre) {
  document.getElementById('multiMovClienteId').value = id;
  document.getElementById('multiMovClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteMultiMov').style.display = 'none';
  multiMovsSeleccionadas.clear();
  await cargarMovimientosPendientesMulti(id);
}

async function cargarMovimientosPendientesMulti(cliente_id) {
  const r = await api('controllers/MovimientosController.php?action=pendientes_cliente&cliente_id=' + cliente_id);
  if (!r.ok) { toast('Error cargando movimientos pendientes.', 'error'); return; }
  multiMovsDisponibles = r.data.data || [];

  const listaEl   = document.getElementById('multiMovLista');
  const wrapEl    = document.getElementById('multiMovListaWrap');
  const sinMovsEl = document.getElementById('multiMovSinMovs');

  if (!multiMovsDisponibles.length) {
    wrapEl.style.display    = 'none';
    sinMovsEl.style.display = 'block';
    document.getElementById('multiMovMetodoWrap').style.display  = 'none';
    document.getElementById('btnConfirmarMultiMov').style.display = 'none';
    return;
  }
  sinMovsEl.style.display = 'none';
  wrapEl.style.display    = 'block';

  listaEl.innerHTML = multiMovsDisponibles.map(m => `
    <div class="cot-check-item" id="mov-item-${m.id_movimiento}" onclick="toggleMovMulti(${m.id_movimiento})">
      <input type="checkbox" id="chkMov-${m.id_movimiento}" onclick="event.stopPropagation();"
        onchange="toggleMovMulti(${m.id_movimiento})">
      <div style="flex:1">
        <div style="font-weight:600">${m.tipo} ${m.ot ? '· OT: ' + m.ot : ''}</div>
        <div style="font-size:11px;color:var(--muted)">
          ${m.fecha} ${m.contenedor ? '· Cont: '+m.contenedor : ''} ${m.chasis ? '· Chasis: '+m.chasis : ''} ${m.placa ? '· Placa: '+m.placa : ''}
        </div>
      </div>
      <div style="font-weight:600;color:var(--accent)">${fmtMoneda(m.tarifa)}</div>
    </div>`).join('');

  actualizarResumenMultiMov();
}

function toggleMovMulti(id) {
  const chk  = document.getElementById('chkMov-' + id);
  const item = document.getElementById('mov-item-' + id);
  if (multiMovsSeleccionadas.has(id)) {
    multiMovsSeleccionadas.delete(id);
    chk.checked = false;
    item.classList.remove('selected');
  } else {
    multiMovsSeleccionadas.add(id);
    chk.checked = true;
    item.classList.add('selected');
  }
  actualizarResumenMultiMov();
}

function actualizarResumenMultiMov() {
  const count = multiMovsSeleccionadas.size;
  const total = multiMovsDisponibles
    .filter(m => multiMovsSeleccionadas.has(m.id_movimiento))
    .reduce((s, m) => s + parseFloat(m.tarifa || 0), 0);

  document.getElementById('multiMovCount').textContent = count;
  document.getElementById('multiMovTotal').textContent = fmtMoneda(total);

  const metodoWrap = document.getElementById('multiMovMetodoWrap');
  const btnConf    = document.getElementById('btnConfirmarMultiMov');
  if (count > 0) {
    metodoWrap.style.display = 'block';
    btnConf.style.display    = 'inline-flex';
  } else {
    metodoWrap.style.display = 'none';
    btnConf.style.display    = 'none';
    multiMovMetodoSelec = '';
    document.querySelectorAll('.metodo-btn[data-mmov]').forEach(el => {
      el.style.borderColor = 'var(--border)'; el.style.background = '';
    });
  }
}

function selMetodoMultiMov(metodo) {
  multiMovMetodoSelec = metodo;
  document.querySelectorAll('.metodo-btn[data-mmov]').forEach(el => {
    const sel = el.dataset.mmov === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  const notaEl = document.getElementById('multiMovNotaMetodo');
  notaEl.style.display = 'block';
  notaEl.textContent = metodo === 'credito'
    ? '📋 Crédito: la factura quedará en estado Pendiente hasta registrar el pago.'
    : '✅ Efectivo: la factura se marcará como Pagada automáticamente.';
}

async function confirmarFacturarMovimientos() {
  const errEl = document.getElementById('errFacturarMov');
  errEl.style.display = 'none';

  const cliente_id = document.getElementById('multiMovClienteId').value;
  if (!cliente_id) { errEl.textContent = 'Selecciona un cliente.'; errEl.style.display = 'block'; return; }
  if (!multiMovsSeleccionadas.size) { errEl.textContent = 'Selecciona al menos un movimiento.'; errEl.style.display = 'block'; return; }
  if (!multiMovMetodoSelec) { errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return; }

  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    errEl.textContent = 'No hay CAI activo. Configure el CAI antes de facturar.';
    errEl.style.display = 'block'; return;
  }

  const ids = Array.from(multiMovsSeleccionadas).map(id => parseInt(id, 10));
  const totalMovs = ids.length;

  const body = {
    movimiento_ids: ids,
    metodo_pago:    multiMovMetodoSelec,
    observaciones:  (document.getElementById('multiMovObs').value || '').trim() || null,
  };

  const btn = document.getElementById('btnConfirmarMultiMov');
  const btnTexto = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Procesando...';

  try {
    const r = await api('controllers/FacturacionController.php?action=facturar_movimientos', {
      method: 'POST',
      body: JSON.stringify(body),
    });
    if (r.ok && r.data.factura) {
      cerrarModal('modalFacturarMovimientos');
      const f = r.data.factura;
      const emoji = f.estado === 'pagada' ? '✅' : '📋';
      toast(`${emoji} Factura ${f.numero_factura} emitida · ${totalMovs} movimientos · ${f.estado}.`, 'success');
      if (typeof cargarFacturacion  === 'function') cargarFacturacion();
      if (typeof cargarMovimientos  === 'function') cargarMovimientos();
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
