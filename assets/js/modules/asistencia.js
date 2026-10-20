// ══════════════════════════════════════════════════════════
// asistencia.js — Tiempo Extra y Días Faltados
// La planilla carga solo las cantidades (ver planillas.js).
// ══════════════════════════════════════════════════════════

let asistenciaData = [];
let asistenciaEmpleados = [];

const ASIS_TIPOS = { horas_extra: 'Horas extra', dia_faltado: 'Día faltado' };

function escAsis(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

async function cargarEmpleadosAsistencia() {
  if (asistenciaEmpleados.length) return;
  const r = await api('controllers/AsistenciaController.php?action=empleados');
  if (r.ok) asistenciaEmpleados = r.data.data;
}

async function cargarAsistencia() {
  await cargarEmpleadosAsistencia();
  const selF = document.getElementById('asisEmpleadoFiltro');
  if (selF.options.length <= 1) {
    const v = selF.value;
    selF.innerHTML = '<option value="">Todos los empleados</option>' +
      asistenciaEmpleados.map(e => `<option value="${e.id_empleado}">${escAsis(e.nombre)}</option>`).join('');
    selF.value = v;
  }
  document.getElementById('tablaAsistenciaWrap').innerHTML = '<p class="loading">Cargando...</p>';
  const q = new URLSearchParams({ action: 'listar' });
  [['asisDesde','desde'],['asisHasta','hasta'],['asisTipoFiltro','tipo'],['asisEstadoFiltro','estado'],['asisEmpleadoFiltro','empleado_id']]
    .forEach(([id, k]) => { const v = document.getElementById(id).value; if (v) q.set(k, v); });
  const r = await api('controllers/AsistenciaController.php?' + q.toString());
  if (!r.ok) { document.getElementById('tablaAsistenciaWrap').innerHTML = `<p style="color:var(--danger)">${escAsis(r.data.error || 'Error al cargar registros.')}</p>`; return; }
  asistenciaData = r.data.data;
  paginaActual['asistencia'] = 1;
  renderTablaAsistencia(asistenciaData);
}

function renderTablaAsistencia(data) {
  const wrap = document.getElementById('tablaAsistenciaWrap');
  if (!data.length) { wrap.innerHTML = '<p class="empty-state">No hay registros.</p>'; document.getElementById('paginaAsistencia').innerHTML = ''; return; }
  const pag = paginar('asistencia', data);
  let h = `<table><thead><tr><th>Fecha</th><th>Empleado</th><th>Tipo</th><th>Cantidad</th><th>Motivo</th><th>Planilla</th><th>Acciones</th></tr></thead><tbody>`;
  pag.slice.forEach(r => {
    const hx = r.tipo === 'horas_extra';
    const cant = parseFloat(r.cantidad);
    const plan = r.planilla_id
      ? `<span class="badge badge-green">${r.quincena} ${String(r.periodo_mes).padStart(2,'0')}/${r.periodo_anio}</span>`
      : '<span class="badge badge-yellow">Pendiente</span>';
    h += `<tr>
      <td>${r.fecha}</td>
      <td>${escAsis(r.empleado)}</td>
      <td>${hx ? '⏱️' : '📅'} ${ASIS_TIPOS[r.tipo]}</td>
      <td><strong>${cant} ${hx ? (cant === 1 ? 'hora' : 'horas') : (cant === 1 ? 'día' : 'días')}</strong></td>
      <td style="font-size:12px">${escAsis(r.motivo || '—')}</td>
      <td>${plan}</td>
      <td class="actions">${r.planilla_id ? '' : `
        <button class="btn btn-sm btn-secondary" onclick="abrirModalAsistencia(${r.id_registro})">✏️</button>
        <button class="btn btn-sm btn-danger" onclick="eliminarAsistencia(${r.id_registro})">🗑️</button>`}</td>
    </tr>`;
  });
  wrap.innerHTML = h + '</tbody></table>';
  renderPaginacion('asistencia', pag, 'paginaAsistencia');
}

function alCambiarTipoAsistencia() {
  const hx = document.getElementById('asisTipo').value === 'horas_extra';
  document.getElementById('asisCantidadLabel').textContent = hx ? 'Cantidad de horas *' : 'Cantidad de días *';
  document.getElementById('asisCantidad').step = hx ? '0.25' : '0.5';
}

async function abrirModalAsistencia(id = 0) {
  await cargarEmpleadosAsistencia();
  document.getElementById('errAsistencia').style.display = 'none';
  document.getElementById('asisEmpleado').innerHTML = '<option value="">— Seleccionar empleado —</option>' +
    asistenciaEmpleados.map(e => `<option value="${e.id_empleado}">${escAsis(e.nombre)}</option>`).join('');
  document.getElementById('asisId').value = id || '';
  document.getElementById('tituloAsistencia').textContent = id ? 'Editar Registro' : 'Nuevo Registro';
  if (id) {
    const r = await api('controllers/AsistenciaController.php?action=obtener&id=' + id);
    if (!r.ok) { toast(r.data.error || 'Error al cargar el registro.', 'error'); return; }
    const x = r.data.data;
    document.getElementById('asisEmpleado').value = x.empleado_id;
    document.getElementById('asisFecha').value    = x.fecha;
    document.getElementById('asisTipo').value     = x.tipo;
    document.getElementById('asisCantidad').value = parseFloat(x.cantidad);
    document.getElementById('asisMotivo').value   = x.motivo || '';
  } else {
    document.getElementById('asisEmpleado').value = '';
    document.getElementById('asisFecha').value    = new Date().toLocaleDateString('en-CA');
    document.getElementById('asisTipo').value     = 'horas_extra';
    document.getElementById('asisCantidad').value = '';
    document.getElementById('asisMotivo').value   = '';
  }
  alCambiarTipoAsistencia();
  abrirModal('modalAsistencia');
}

async function guardarAsistencia() {
  const err = document.getElementById('errAsistencia');
  err.style.display = 'none';
  const id = document.getElementById('asisId').value;
  const body = {
    id: +id || 0,
    empleado_id: +document.getElementById('asisEmpleado').value || 0,
    fecha: document.getElementById('asisFecha').value,
    tipo: document.getElementById('asisTipo').value,
    cantidad: parseFloat(document.getElementById('asisCantidad').value) || 0,
    motivo: document.getElementById('asisMotivo').value.trim(),
  };
  const r = await api('controllers/AsistenciaController.php?action=' + (id ? 'editar' : 'crear'), { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
  cerrarModal('modalAsistencia');
  toast(id ? 'Registro actualizado.' : 'Registro guardado.');
  cargarAsistencia();
}

async function eliminarAsistencia(id) {
  if (!await confirmDialog('¿Eliminar este registro?')) return;
  const r = await api('controllers/AsistenciaController.php?action=eliminar', { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data.error || 'No se pudo eliminar.', 'error'); return; }
  toast('Registro eliminado.');
  cargarAsistencia();
}
