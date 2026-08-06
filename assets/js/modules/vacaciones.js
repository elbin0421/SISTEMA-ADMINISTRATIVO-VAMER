// ══════════════════════════════════════════════════════════
// vacaciones.js — Vacaciones
// Extraído de dashboard.js líneas 4496-4925
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════
//  MÓDULO VACACIONES
// ══════════════════════════════════════════════════════════════

let vacTab = 'resumen';
let vacHistorialData = [];
let vacEmpleadosCache = [];
let vacCalculo = null;
let vacEditandoDiasOriginal = 0;

// ── Registro en modTitles y router ───────────────────────────
modTitles['vacaciones'] = 'Vacaciones';

// ── TAB ──────────────────────────────────────────────────────
function tabVacaciones(tab) {
  vacTab = tab;
  document.getElementById('tabVacResumen').classList.toggle('active', tab === 'resumen');
  document.getElementById('tabVacHistorial').classList.toggle('active', tab === 'historial');
  document.getElementById('panelVacResumen').style.display   = tab === 'resumen'   ? '' : 'none';
  document.getElementById('panelVacHistorial').style.display = tab === 'historial' ? '' : 'none';
  if (tab === 'historial') cargarHistorialVacaciones();
}

// ── CARGA PRINCIPAL ───────────────────────────────────────────
async function cargarVacaciones() {
  try {
    await cargarEmpleadosVacCache(true);
    llenarFiltroVacEmpleado();
    await cargarResumenVacaciones();
  } catch(e) {
    console.error('Error cargando vacaciones:', e);
    toast('Error al cargar módulo de vacaciones.', 'error');
  }
}

async function cargarEmpleadosVacCache(forzar = false) {
  if (vacEmpleadosCache.length && !forzar) return;
  const r = await api('controllers/EmpleadoController.php?action=listar&estado=activo');
  if (r.ok && r.data.data) {
    vacEmpleadosCache = r.data.data;
  } else if (r.ok && Array.isArray(r.data)) {
    vacEmpleadosCache = r.data;
  } else {
    vacEmpleadosCache = [];
  }
}

function llenarFiltroVacEmpleado() {
  const sel = document.getElementById('filtroVacEmpleado');
  if (!sel) return;
  sel.innerHTML = '<option value="">Todos los empleados</option>' +
    vacEmpleadosCache.map(e => `<option value="${e.id_empleado}">${e.nombre}</option>`).join('');
}

// ── RESUMEN ───────────────────────────────────────────────────
async function cargarResumenVacaciones() {
  const wrap = document.getElementById('tablaVacResumenWrap');
  if (!wrap) return;
  wrap.innerHTML = '<p class="loading">Cargando...</p>';
  try {
    const r = await api('controllers/VacacionesController.php?action=resumen');
    if (!r.ok) { wrap.innerHTML = `<p class="empty-state" style="color:var(--danger)">${r.data.error || 'Error al cargar.'}</p>`; return; }

    const rows = r.data.data;
    if (!rows || !rows.length) { wrap.innerHTML = '<p class="empty-state">Sin empleados activos.</p>'; return; }

    const fL = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});

    let h = `<table style="font-size:12px">
      <thead><tr>
        <th>Empleado</th>
        <th style="text-align:center">Años</th>
        <th style="text-align:center">Días<br>corresponden</th>
        <th style="text-align:center">Días<br>usados</th>
        <th style="text-align:center">Días<br>pendientes</th>
        <th style="text-align:right">Salario<br>Diario</th>
        <th style="text-align:right">Monto<br>Vacacional</th>
        <th style="text-align:right">Total<br>Pagado</th>
      </tr></thead><tbody>`;

    rows.forEach(row => {
      const sinIngreso  = !row.fecha_ingreso;
      const diasUsados  = (+row.dias_descanso || 0) + (+row.dias_pagados || 0);
      const diasPend    = Math.max(0, row.dias_actuales - diasUsados);
      const colorPend   = diasPend > 0 ? 'color:#ff9800;font-weight:700' : 'color:var(--muted)';

      const badgeDias = row.dias_actuales === 0
        ? '<span style="color:var(--muted);font-size:10px">< 1 año</span>'
        : `<strong style="font-size:16px;color:var(--accent)">${row.dias_actuales}</strong>`;

      h += `<tr>
        <td>
          <strong>${row.nombre}</strong>
          <div style="font-size:10px;color:var(--muted)">${row.puesto || ''}${row.fecha_ingreso ? ' · ingreso: '+row.fecha_ingreso : ''}</div>
        </td>
        <td style="text-align:center">${sinIngreso ? '—' : row.anios_actuales}</td>
        <td style="text-align:center">${badgeDias}</td>
        <td style="text-align:center">
          ${diasUsados > 0
            ? `<span>${diasUsados}</span><div style="font-size:10px;color:var(--muted)">${row.dias_descanso>0?row.dias_descanso+' desc.':''}${row.dias_descanso>0&&row.dias_pagados>0?' / ':''}${row.dias_pagados>0?row.dias_pagados+' pag.':''}</div>`
            : '<span style="color:var(--muted)">—</span>'}
        </td>
        <td style="text-align:center"><span style="${colorPend}">${diasPend}</span></td>
        <td style="text-align:right">${fL(row.salario_diario)}</td>
        <td style="text-align:right;color:#4caf50">${fL(row.monto_actual)}</td>
        <td style="text-align:right">${row.monto_total_pagado > 0 ? fL(row.monto_total_pagado) : '—'}</td>
      </tr>`;
    });

    h += '</tbody></table>';
    wrap.innerHTML = h;
  } catch(e) {
    wrap.innerHTML = `<p class="empty-state" style="color:var(--danger)">Error: ${e.message}</p>`;
  }
}

// ── HISTORIAL ─────────────────────────────────────────────────
async function cargarHistorialVacaciones() {
  const wrap   = document.getElementById('tablaVacHistorialWrap');
  wrap.innerHTML = '<p class="loading">Cargando...</p>';

  const empId  = document.getElementById('filtroVacEmpleado')?.value || '';
  const estado = document.getElementById('filtroVacEstado')?.value   || 'todos';

  let url = 'controllers/VacacionesController.php?action=listar';
  if (empId)  url += '&empleado_id=' + empId;
  if (estado && estado !== 'todos') url += '&estado=' + estado;

  const r = await api(url);
  if (!r.ok) { wrap.innerHTML = '<p class="empty-state">Error al cargar.</p>'; return; }
  vacHistorialData = r.data.data;
  renderTablaVacHistorial(vacHistorialData);
}

function renderTablaVacHistorial(rows) {
  const wrap = document.getElementById('tablaVacHistorialWrap');
  if (!rows.length) { wrap.innerHTML = '<p class="empty-state">Sin registros de vacaciones.</p>'; document.getElementById('paginaVacHistorial').innerHTML=''; return; }

  const pag  = paginar('vacHistorial', rows);
  const fL   = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});

  let h = `<table>
    <thead><tr>
      <th>Empleado</th>
      <th>Período laboral</th>
      <th style="text-align:center">Años</th>
      <th style="text-align:center">Días</th>
      <th style="text-align:center">Tipo</th>
      <th style="text-align:right">Monto</th>
      <th>Fecha registro</th>
      <th style="text-align:center">Estado</th>
      <th>Observaciones</th>
      <th>Acción</th>
    </tr></thead><tbody>`;

  pag.slice.forEach(v => {
    const tipoBadge = v.tipo === 'pago'
      ? '<span class="badge badge-green">💰 Pago</span>'
      : '<span class="badge badge-blue">🏖️ Descanso</span>';
    const monto = v.tipo === 'pago' ? fL(v.monto_vacaciones) : '—';
    const estadoBadge = {
      tomada:  '<span class="badge badge-blue">Tomada</span>',
      pagada:  '<span class="badge badge-green">Pagada</span>',
      anulada: '<span class="badge badge-red">Anulada</span>',
      pendiente:'<span class="badge">Pendiente</span>',
    }[v.estado] || v.estado;

    h += `<tr>
      <td><strong>${v.empleado}</strong><div style="font-size:11px;color:var(--muted)">${v.puesto||''}</div></td>
      <td style="font-size:12px">${v.fecha_inicio} → ${v.fecha_fin}</td>
      <td style="text-align:center">${v.anios_laborados}</td>
      <td style="text-align:center"><strong style="color:var(--accent)">${v.dias_correspondientes}</strong></td>
      <td style="text-align:center">${tipoBadge}</td>
      <td style="text-align:right">${monto}</td>
      <td style="font-size:12px">${v.fecha_registro}</td>
      <td style="text-align:center">${estadoBadge}</td>
      <td style="font-size:11px;color:var(--muted)">${v.observaciones || '—'}</td>
      <td>
        <div class="td-actions">
          ${v.estado !== 'anulada'
            ? `<button class="btn btn-sm btn-secondary" onclick="editarVacacion(${v.id_vacacion})">Editar</button>
               <button class="btn btn-sm btn-danger"    onclick="anularVacacion(${v.id_vacacion})">Anular</button>`
            : '<span style="color:var(--muted);font-size:11px">—</span>'}
        </div>
      </td>
    </tr>`;
  });
  h += '</tbody></table>';
  wrap.innerHTML = h;
  renderPaginacion('vacHistorial', pag, 'paginaVacHistorial');
}

// ── MODAL ─────────────────────────────────────────────────────
async function abrirModalVacacion(empId = null, modoEditar = false, datosEditar = null) {
  await cargarEmpleadosVacCache();

  // Título y campo ID oculto
  document.querySelector('#modalVacacion h4').textContent = modoEditar ? '✏️ Editar Vacaciones' : '🏖️ Registrar Vacaciones';
  document.getElementById('vacId').value = modoEditar && datosEditar ? datosEditar.id_vacacion : '';

  // Llenar select empleados
  const sel = document.getElementById('vacEmpleadoId');
  sel.innerHTML = '<option value="">— Seleccionar empleado —</option>' +
    vacEmpleadosCache.map(e => `<option value="${e.id_empleado}">${e.nombre}</option>`).join('');
  sel.disabled = modoEditar; // en edición no se cambia el empleado

  // Reset / llenar según modo
  vacCalculo=null;vacEditandoDiasOriginal=0;
  document.getElementById('errVacacion').style.display='none';
  document.getElementById('vacPreviewCalculo').style.display='none';
  const _pr=document.getElementById('vacPanelDiasAUsar');if(_pr)_pr.style.display='none';
  document.getElementById('vacInfoEmpleado').style.display='none';
  document.getElementById('vacNotaPago').style.display='none';
  const _da=document.getElementById('vacDiasAUsar');if(_da)_da.value='';
  const _mp=document.getElementById('vacMontoParcial');if(_mp)_mp.textContent='—';
  const _dd=document.getElementById('vacDiasDisponibles');if(_dd)_dd.textContent='—';
  document.getElementById('btnGuardarVacacion').disabled=modoEditar?false:true;
  document.getElementById('btnGuardarVacacion').textContent=modoEditar?'Guardar Cambios':'Registrar Vacaciones';

  if (modoEditar && datosEditar) {
    vacEditandoDiasOriginal=parseInt(datosEditar.dias_correspondientes)||0;
    sel.value=datosEditar.empleado_id;
    document.getElementById('vacFechaInicio').value=datosEditar.fecha_inicio;
    document.getElementById('vacFechaFin').value=datosEditar.fecha_fin;
    document.getElementById('vacFechaRegistro').value=datosEditar.fecha_registro;
    document.getElementById('vacTipo').value=datosEditar.tipo;
    document.getElementById('vacObs').value=datosEditar.observaciones||'';
    const [rCalc,rRes]=await Promise.all([api(`controllers/VacacionesController.php?action=calcular&empleado_id=${datosEditar.empleado_id}&fecha_inicio=${datosEditar.fecha_inicio}&fecha_fin=${datosEditar.fecha_fin}`),api('controllers/VacacionesController.php?action=resumen')]);
    const fLv=n=>'L. '+Number(n||0).toLocaleString('es-HN',{minimumFractionDigits:2});
    const c=rCalc.ok?rCalc.data.calculo:{};
    let diasPend=0,diasAct=0;
    if(rRes.ok){const er=rRes.data.data.find(e=>e.id_empleado==datosEditar.empleado_id);if(er){diasAct=+er.dias_actuales||0;const du=(+er.dias_descanso||0)+(+er.dias_pagados||0);diasPend=Math.max(0,diasAct-du);}}
    const pool=diasPend+vacEditandoDiasOriginal;
    vacCalculo={...c,dias_correspondientes:diasAct||c.dias_correspondientes||vacEditandoDiasOriginal,dias_disponibles:pool,salario_diario:c.salario_diario||0};
    document.getElementById('vacPreviewCalculo').style.display='';
    const _an=document.getElementById('vacAnios');if(_an)_an.textContent=(c.anios_laborados||0)+' años';
    const _di=document.getElementById('vacDias');if(_di)_di.textContent=diasAct+' días';
    const _sd=document.getElementById('vacSDiario');if(_sd)_sd.textContent=fLv(c.salario_diario||0);
    const _mo=document.getElementById('vacMonto');if(_mo)_mo.textContent=fLv(c.monto_vacaciones||0);
    const _pan=document.getElementById('vacPanelDiasAUsar');if(_pan)_pan.style.display='';
    const _inp=document.getElementById('vacDiasAUsar');if(_inp)_inp.value=vacEditandoDiasOriginal;
    recalcularParcial();onTipoVacChange();
    document.getElementById('btnGuardarVacacion').disabled=false;
  } else {
    if (empId) sel.value = empId;
    document.getElementById('vacFechaInicio').value   = '';
    document.getElementById('vacFechaFin').value      = new Date().toISOString().slice(0,10);
    document.getElementById('vacFechaRegistro').value = new Date().toISOString().slice(0,10);
    document.getElementById('vacTipo').value          = 'descanso';
    document.getElementById('vacObs').value           = '';
    if (empId) await onCambioEmpleadoVac();
  }

  abrirModal('modalVacacion');
}

async function editarVacacion(id) {
  const r = await api('controllers/VacacionesController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error al cargar registro.', 'error'); return; }
  await abrirModalVacacion(null, true, r.data.data);
}

function onCambioEmpleadoVac() {
  const empId = document.getElementById('vacEmpleadoId').value;
  if (!empId) { document.getElementById('vacInfoEmpleado').style.display='none'; return; }

  const emp = vacEmpleadosCache.find(e => e.id_empleado == empId);
  if (!emp) return;

  const fL = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});
  document.getElementById('vacSalarioMensual').textContent = fL(emp.salario_mensual);
  document.getElementById('vacSalarioDiario').textContent  = fL(emp.salario_mensual / 30);
  document.getElementById('vacFechaIngreso').textContent   = emp.fecha_ingreso || '—';
  document.getElementById('vacInfoEmpleado').style.display = '';

  // Prellenar fecha inicio con fecha de ingreso
  if (emp.fecha_ingreso && !document.getElementById('vacFechaInicio').value) {
    document.getElementById('vacFechaInicio').value = emp.fecha_ingreso;
  }
  calcularPreviewVac();
}

async function calcularPreviewVac() {
  const empId      = document.getElementById('vacEmpleadoId').value;
  const fechaIni   = document.getElementById('vacFechaInicio').value;
  const fechaFin   = document.getElementById('vacFechaFin').value;
  const previewEl  = document.getElementById('vacPreviewCalculo');
  const btnGuardar = document.getElementById('btnGuardarVacacion');
  const esEdicion  = !!document.getElementById('vacId').value;

  if (!empId || !fechaIni || !fechaFin) { previewEl.style.display='none'; if(!esEdicion) btnGuardar.disabled=true; return; }

  try {
    const r = await api(`controllers/VacacionesController.php?action=calcular&empleado_id=${empId}&fecha_inicio=${fechaIni}&fecha_fin=${fechaFin}`);
    if (!r.ok) { previewEl.style.display='none'; if(!esEdicion) btnGuardar.disabled=true; return; }

    const c   = r.data.calculo;
    vacCalculo = c;
    const fL  = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});

    document.getElementById('vacAnios').textContent   = c.anios_laborados + ' años';
    document.getElementById('vacDias').textContent    = c.aplica ? c.dias_correspondientes + ' días' : 'Sin derecho';
    document.getElementById('vacSDiario').textContent = fL(c.salario_diario);
    document.getElementById('vacMonto').textContent   = fL(c.monto_vacaciones);

    // Calcular días ya usados
    const rResumen = await api(`controllers/VacacionesController.php?action=resumen`);
    if (rResumen.ok) {
      const empRow = rResumen.data.data.find(e => e.id_empleado == empId);
      if (empRow) {
        const usados=(empRow.dias_descanso||0)+(empRow.dias_pagados||0);
        const disponibles=Math.max(0,c.dias_correspondientes-usados);
        if(!vacEditandoDiasOriginal){
          vacCalculo.dias_disponibles=disponibles;
          const _ddc=document.getElementById('vacDiasDisponibles');if(_ddc)_ddc.textContent=disponibles+' días';
          const inputDias=document.getElementById('vacDiasAUsar');if(inputDias&&!inputDias.value)inputDias.value=disponibles;
        }
      }
    }

    previewEl.style.display='';
    if(!vacEditandoDiasOriginal){
      const _pdA=document.getElementById('vacPanelDiasAUsar');if(_pdA)_pdA.style.display=c.aplica?'':'none';
      recalcularParcial();onTipoVacChange();btnGuardar.disabled=!c.aplica;
    }
  } catch(e) {
    previewEl.style.display='none'; if(!esEdicion) btnGuardar.disabled=true;
  }
}

function recalcularParcial() {
  if (!vacCalculo) return;
  const fL         = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});
  const inputDias  = document.getElementById('vacDiasAUsar');
  const maxDias    = vacCalculo.dias_disponibles ?? vacCalculo.dias_correspondientes;
  let diasAUsar    = parseInt(inputDias.value) || maxDias;

  // Validar rango
  if (diasAUsar < 1) diasAUsar = 1;
  if (diasAUsar > maxDias) { diasAUsar = maxDias; inputDias.value = maxDias; }

  const montoParcial=vacCalculo.salario_diario*diasAUsar;
  vacCalculo.dias_a_usar=diasAUsar;vacCalculo.monto_parcial=montoParcial;
  const _mp2=document.getElementById('vacMontoParcial');if(_mp2)_mp2.textContent=fL(montoParcial);
  const dispShow=Math.max(0,maxDias-diasAUsar);
  const _dd2=document.getElementById('vacDiasDisponibles');
  if(_dd2){_dd2.textContent=dispShow+(dispShow===1?' día':' días');_dd2.style.color=dispShow>0?'var(--warning,#f59e0b)':'var(--muted)';}
  onTipoVacChange();
}

function onTipoVacChange() {
  const tipo   = document.getElementById('vacTipo').value;
  const notaEl = document.getElementById('vacNotaPago');
  const notaMon = document.getElementById('vacNotaMonto');
  if (tipo === 'pago' && vacCalculo) {
    const fL     = n => 'L. ' + Number(n).toLocaleString('es-HN', {minimumFractionDigits:2});
    const monto  = vacCalculo.monto_parcial ?? vacCalculo.monto_vacaciones;
    notaMon.textContent = fL(monto);
    notaEl.style.display = '';
  } else {
    notaEl.style.display = 'none';
  }
}

async function guardarVacacion() {
  const errEl = document.getElementById('errVacacion');
  errEl.style.display = 'none';

  const id       = document.getElementById('vacId').value;
  const diasInput = document.getElementById('vacDiasAUsar');
  const diasAUsar = parseInt(diasInput?.value) || (vacCalculo?.dias_correspondientes ?? 0);

  const body = {
    empleado_id:    +document.getElementById('vacEmpleadoId').value,
    fecha_inicio:    document.getElementById('vacFechaInicio').value,
    fecha_fin:       document.getElementById('vacFechaFin').value,
    tipo:            document.getElementById('vacTipo').value,
    fecha_registro:  document.getElementById('vacFechaRegistro').value,
    observaciones:   document.getElementById('vacObs').value.trim(),
    dias_a_usar:     diasAUsar,
  };

  if (!body.empleado_id || !body.fecha_inicio || !body.fecha_fin) {
    errEl.textContent = 'Completa todos los campos requeridos.'; errEl.style.display='block'; return;
  }

  const esEdicion = !!id;
  if (esEdicion) body.id = +id;

  const action = esEdicion ? 'editar' : 'registrar';
  const r = await api('controllers/VacacionesController.php?action=' + action, {
    method: 'POST', body: JSON.stringify(body)
  });

  if (r.ok) {
    cerrarModal('modalVacacion');
    toast(esEdicion ? 'Vacaciones actualizadas.' : 'Vacaciones registradas correctamente.', 'success');
    cargarVacaciones();
    if (vacTab === 'historial') cargarHistorialVacaciones();
  } else {
    errEl.textContent = r.data.error || 'Error al guardar.'; errEl.style.display='block';
  }
}

async function anularVacacion(id) {
  if (!await confirmDialog('¿Anular este registro de vacaciones?')) return;
  const r = await api('controllers/VacacionesController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) { toast('Registro anulado.', 'success'); cargarHistorialVacaciones(); cargarResumenVacaciones(); }
  else toast(r.data.error || 'Error.', 'error');
}

// ── Estilos tab ───────────────────────────────────────────────
(function() {
  const s = document.createElement('style');
  s.textContent = `
    .tab-vac {
      background:none; border:none; border-bottom:3px solid transparent;
      padding:8px 16px; color:var(--muted); font-size:13px; cursor:pointer;
      font-family:inherit; transition:.2s;
    }
    .tab-vac.active { color:var(--accent); border-bottom-color:var(--accent); font-weight:600; }
    .tab-vac:hover:not(.active) { color:var(--text); }
    .badge-red { background:#c00229; color:#fff; }
    .badge-green { background:#1a472a; color:#81c784; }
  `;
  document.head.appendChild(s);
})();

