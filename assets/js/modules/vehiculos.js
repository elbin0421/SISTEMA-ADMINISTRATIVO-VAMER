// ══════════════════════════════════════════════════════════
// vehiculos.js — Vehículos
// Extraído de dashboard.js líneas 4265-4495
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════
// MÓDULO VEHÍCULOS
// ══════════════════════════════════════════════════════════════

let vehiculosData = [];

async function cargarVehiculos() {
  document.getElementById('tablaVehiculosWrap').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('buscarVehiculo').value = '';

  const estado = document.getElementById('filtroEstadoVehiculo').value;
  const url = estado === 'todos'
    ? 'controllers/VehiculosController.php?action=listar'
    : 'controllers/VehiculosController.php?action=listar&estado=activo';

  const r = await api(url);
  if (!r.ok) {
    document.getElementById('tablaVehiculosWrap').innerHTML = '<p style="color:var(--danger)">Error al cargar vehículos.</p>';
    return;
  }
  vehiculosData = r.data.data;
  renderTablaVehiculos(vehiculosData);
}

function renderTablaVehiculos(data) {
  const wrap = document.getElementById('tablaVehiculosWrap');
  if (!data.length) {
    wrap.innerHTML = '<p class="empty-state">No hay vehículos registrados.</p>';
    document.getElementById('paginaVehiculos').innerHTML = '';
    return;
  }
  const pag = paginar('vehiculos', data);
  let h = `<table>
    <thead>
      <tr>
        <th>Placa</th>
        <th>Marca / Modelo</th>
        <th>Año</th>
        <th>Color</th>
        <th>Cliente</th>
        <th>No. Motor</th>
        <th>No. Chasis</th>
        <th style="text-align:center">Estado</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>`;
  pag.slice.forEach(v => {
    const marca = [v.marca, v.modelo].filter(Boolean).join(' ') || '—';
    h += `<tr>
      <td><strong style="color:var(--accent);font-size:13px">${v.placa}</strong></td>
      <td>${marca}</td>
      <td>${v.anio || '—'}</td>
      <td>${v.color || '—'}</td>
      <td>${v.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${v.numero_motor || '—'}</td>
      <td style="font-size:11px;color:var(--muted)">${v.numero_chasis || '—'}</td>
      <td style="text-align:center">${badgeEstado(v.estado)}</td>
      <td>
        <div class="td-actions">
          <button class="btn btn-sm btn-secondary" onclick="editarVehiculo(${v.id_vehiculo})">Editar</button>
          <button class="btn btn-sm ${v.estado==='activo'?'btn-danger':'btn-secondary'}"
            onclick="toggleVehiculo(${v.id_vehiculo},'${v.estado==='activo'?'inactivo':'activo'}','${v.placa}')">
            ${v.estado==='activo'?'Dar de baja':'Reactivar'}
          </button>
        </div>
      </td>
    </tr>`;
  });
  h += '</tbody></table>';
  wrap.innerHTML = h;
  renderPaginacion('vehiculos', pag, 'paginaVehiculos');
}

function filtrarVehiculos() {
  const q = document.getElementById('buscarVehiculo').value.toLowerCase().trim();
  if (!q) { renderTablaVehiculos(vehiculosData); return; }
  paginaActual['vehiculos'] = 1;
  const filtrados = vehiculosData.filter(v =>
    (v.placa       || '').toLowerCase().includes(q) ||
    (v.marca       || '').toLowerCase().includes(q) ||
    (v.modelo      || '').toLowerCase().includes(q) ||
    (v.cliente     || '').toLowerCase().includes(q) ||
    (v.color       || '').toLowerCase().includes(q) ||
    (v.numero_motor|| '').toLowerCase().includes(q) ||
    (v.anio        || '').toString().includes(q)
  );
  renderTablaVehiculos(filtrados);
}

// ── MODAL NUEVO / EDITAR ─────────────────────────────────────

function abrirModalVehiculo() {
  document.getElementById('vId').value = '';
  document.getElementById('vClienteBuscar').value = '';
  document.getElementById('vClienteId').value = '';
  document.getElementById('sugerenciasClienteVehiculo').style.display = 'none';
  ['vPlaca','vMarca','vModelo','vColor','vMotor','vChasis','vObservaciones'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('vAnio').value = '';
  document.getElementById('tituloVehiculo').textContent = 'Nuevo Vehículo';
  document.getElementById('errVehiculo').style.display = 'none';
  abrirModal('modalVehiculo');
}

async function editarVehiculo(id) {
  const r = await api('controllers/VehiculosController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error al cargar vehículo.', 'error'); return; }
  const v = r.data.data;
  document.getElementById('vId').value              = v.id_vehiculo;
  document.getElementById('vClienteId').value       = v.cliente_id;
  document.getElementById('vPlaca').value           = v.placa       || '';
  document.getElementById('vMarca').value           = v.marca       || '';
  document.getElementById('vModelo').value          = v.modelo      || '';
  document.getElementById('vAnio').value            = v.anio        || '';
  document.getElementById('vColor').value           = v.color       || '';
  document.getElementById('vMotor').value           = v.numero_motor  || '';
  document.getElementById('vChasis').value          = v.numero_chasis || '';
  document.getElementById('vObservaciones').value   = v.observaciones || '';
  document.getElementById('errVehiculo').style.display = 'none';
  document.getElementById('tituloVehiculo').textContent = 'Editar Vehículo — ' + v.placa;
  // Mostrar cliente en el buscador
  const rc = await api('controllers/ClientesController.php?action=obtener&id=' + v.cliente_id);
  if (rc.ok) document.getElementById('vClienteBuscar').value = rc.data.data.nombre || '';
  abrirModal('modalVehiculo');
}

async function guardarVehiculo() {
  const id        = document.getElementById('vId').value;
  const clienteId = +document.getElementById('vClienteId').value;
  const placa     = document.getElementById('vPlaca').value.trim().toUpperCase();
  const errEl     = document.getElementById('errVehiculo');
  errEl.style.display = 'none';

  if (!clienteId) { errEl.textContent = 'Selecciona un cliente.';  errEl.style.display = 'block'; return; }
  if (!placa)     { errEl.textContent = 'La placa es obligatoria.'; errEl.style.display = 'block'; return; }

  const body = {
    id:            id ? +id : undefined,
    cliente_id:    clienteId,
    placa,
    marca:         document.getElementById('vMarca').value.trim(),
    modelo:        document.getElementById('vModelo').value.trim(),
    anio:          document.getElementById('vAnio').value  || null,
    color:         document.getElementById('vColor').value.trim(),
    numero_motor:  document.getElementById('vMotor').value.trim(),
    numero_chasis: document.getElementById('vChasis').value.trim(),
    observaciones: document.getElementById('vObservaciones').value.trim(),
  };

  const action = id ? 'editar' : 'crear';
  const r = await api('controllers/VehiculosController.php?action=' + action, {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) {
    cerrarModal('modalVehiculo');
    toast(id ? 'Vehículo actualizado.' : 'Vehículo registrado correctamente.', 'success');
    cargarVehiculos();
  } else {
    errEl.textContent = r.data.error || 'Error al guardar.';
    errEl.style.display = 'block';
  }
}

async function toggleVehiculo(id, nuevoEstado, placa) {
  const label = nuevoEstado === 'activo' ? 'Reactivar' : 'Dar de baja';
  if (!await confirmDialog(`¿${label} el vehículo ${placa}?`)) return;
  const r = await api('controllers/VehiculosController.php?action=eliminar', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) {
    toast(nuevoEstado === 'activo' ? 'Vehículo reactivado.' : `Vehículo ${placa} dado de baja.`, 'success');
    cargarVehiculos();
  } else {
    toast(r.data.error || 'Error.', 'error');
  }
}

// ── BUSCAR CLIENTE en modal vehículo ─────────────────────────
let buscarClienteVehTimer = null;
function buscarClienteVehiculo() {
  clearTimeout(buscarClienteVehTimer);
  const q = document.getElementById('vClienteBuscar').value.trim();
  if (q.length < 2) { document.getElementById('sugerenciasClienteVehiculo').style.display = 'none'; return; }
  buscarClienteVehTimer = setTimeout(async () => {
    const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasClienteVehiculo');
    if (!r.data.data.length) { div.style.display = 'none'; return; }
    div.innerHTML = r.data.data.map(c =>
      `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)"
        onmousedown="selClienteVehiculo(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
        ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.tipo_cliente==='empresa'?'🏢':'👤'} ${c.rtn||''}</span>
      </div>`
    ).join('');
    div.style.display = 'block';
  }, 300);
}

function selClienteVehiculo(id, nombre) {
  document.getElementById('vClienteId').value    = id;
  document.getElementById('vClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteVehiculo').style.display = 'none';
}

// ── MAYÚSCULAS GLOBALES EN INPUTS DE TEXTO ───────────────────
// Convierte a mayúsculas el valor REAL del input (no solo CSS)
// Excluye: password, number, date, email, url, selects, buscadores de autocomplete
(function aplicarMayusculas() {
  const EXCLUIR_TIPOS  = new Set(['password','number','date','email','url','search','time']);
  const EXCLUIR_IDS    = new Set([
    'buscarCliente','buscarProveedor','buscarMaterial',
    'buscarVehiculo','otClienteBuscar','cotDirClienteBuscar',
    'vClienteBuscar','buscarClienteFactura','buscarClientePago',
    'buscarOrden','buscarCompra'
  ]);

  function toUpper(e) {
    const el = e.target;
    if (el.tagName !== 'INPUT' && el.tagName !== 'TEXTAREA') return;
    if (EXCLUIR_TIPOS.has(el.type)) return;
    if (EXCLUIR_IDS.has(el.id)) return;
    if (el.classList.contains('no-upper')) return;
    const pos = el.selectionStart;
    el.value = el.value.toUpperCase();
    try { el.setSelectionRange(pos, pos); } catch(_) {}
  }

  // Delegación en document — captura inputs en modales y dinámicos
  document.addEventListener('input', toUpper, true);
})();

