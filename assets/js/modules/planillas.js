// ══════════════════════════════════════════════════════════
// planillas.js — Empleados, Planillas, 14vo/Aguinaldo
// Extraído de dashboard.js líneas 3102-3971
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// FASE 5 — PLANILLA + REPORTES
// ══════════════════════════════════════════════════════════

const SEGURO_POR_UBICACION = { SOLDYMEG: 359.74, VESTA: 215.84 };
const HE_POR_UBICACION     = { SOLDYMEG: 70,     VESTA: 85     };

// ── EMPLEADOS ─────────────────────────────────────────────
let empleadosData = [];

async function cargarEmpleados() {
  document.getElementById('tablaEmpleados').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoEmp').value;
  const r = await api('controllers/EmpleadoController.php?action=listar&estado=' + estado);
  if (!r.ok) { document.getElementById('tablaEmpleados').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  empleadosData = r.data.data;
  paginaActual['empleados'] = 1;
  renderTablaEmpleados(empleadosData);
}

function filtrarEmpleados() {
  const q = document.getElementById('buscarEmpleado').value.toLowerCase().trim();
  paginaActual['empleados'] = 1;
  if (!q) { renderTablaEmpleados(empleadosData); return; }
  renderTablaEmpleados(empleadosData.filter(e =>
    (e.nombres||'').toLowerCase().includes(q) ||
    (e.apellidos||'').toLowerCase().includes(q) ||
    (e.nombre||'').toLowerCase().includes(q) ||
    (e.puesto||'').toLowerCase().includes(q) ||
    (e.ubicacion||'').toLowerCase().includes(q)
  ));
}

function renderTablaEmpleados(rows) {
  const pag = paginar('empleados', rows);
  let h = `<table><thead><tr>
    <th>Nombre</th><th>Empresa</th><th>Ubicación</th><th>Departamento</th><th>Puesto</th><th>Contrato</th>
    <th>Salario Mensual</th><th>Sal. Quincenal</th><th>Seguro</th><th>Estado</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin empleados</td></tr>';
  pag.slice.forEach(e => {
    const empresaBadge = e.empresa_nombre ? `<span class="badge badge-green">${e.empresa_nombre}</span>` : '—';
    const ubicBadge = e.ubicacion === 'VESTA'
      ? `<span class="badge badge-blue">VESTA</span>`
      : `<span class="badge badge-gray">SOLDYMEG</span>`;
    const quince = fmtMoneda(parseFloat(e.salario_mensual||0)/2);
    const seguro = e.seguro_privado != null ? parseFloat(e.seguro_privado) : 0;
    h += `<tr>
      <td><strong>${e.nombre}</strong>${e.identidad?`<br><small style="color:var(--muted)">${e.identidad}</small>`:''}</td>
      <td>${empresaBadge}</td>
      <td>${ubicBadge}</td>
      <td>${e.departamento_nombre||e.puesto||'—'}</td>
      <td>${e.puesto||'—'}</td>
      <td><span class="badge badge-blue">${(e.tipo_contrato||'').replace('_',' ')}</span></td>
      <td>${fmtMoneda(e.salario_mensual)}</td>
      <td style="color:var(--accent)">${quince}</td>
      <td style="font-size:12px">${fmtMoneda(seguro)}</td>
      <td>${badgeEstado(e.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="editarEmpleado(${e.id_empleado})">Editar</button>
        ${e.estado==='activo'
          ? `<button class="btn btn-sm btn-danger" onclick="cambiarEstadoEmpleado(${e.id_empleado},'inactivo','${e.nombre.replace(/'/g,"\\'")}')">Inactivar</button>`
          : `<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoEmpleado(${e.id_empleado},'activo','${e.nombre.replace(/'/g,"\\'")}')">Activar</button>`}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaEmpleados').innerHTML = h;
  renderPaginacion('empleados', pag, 'paginaEmpleados');
}

function empAutoSeguro() {
  const ub  = document.getElementById('empUbicacion').value;
  document.getElementById('empSeguro').value = SEGURO_POR_UBICACION[ub] || 0;
}

// Helper: cargar departamentos en un <select>
async function cargarDepartamentosSelect(selectId, valorActual = '') {
  const sel = document.getElementById(selectId);
  if (!sel) return;
  sel.innerHTML = '<option value="">— Sin asignar —</option>';
  try {
    const r = await api('controllers/DepartamentoController.php?action=listar&estado=activo');
    if (r.ok) {
      (r.data.data || []).forEach(d => {
        const opt = document.createElement('option');
        opt.value = d.id_departamento;
        opt.textContent = d.nombre;
        if (String(d.id_departamento) === String(valorActual)) opt.selected = true;
        sel.appendChild(opt);
      });
    }
  } catch(e) { /* tabla aún no existe — continuar sin departamentos */ }
}

async function abrirModalEmpleado() {
  document.getElementById('empId').value = '';
  document.getElementById('tituloEmpleado').textContent = 'Nuevo Empleado';
  ['empNombres','empApellidos','empIdentidad','empTelefono','empCorreo','empDireccion',
   'empPuesto','empBanco','empCuenta','empIHSS','empRAP'].forEach(id => document.getElementById(id).value='');
  document.getElementById('empSalario').value        = '';
  document.getElementById('empUbicacion').value      = 'SOLDYMEG';
  document.getElementById('empEmpresaId').value      = '1';
  document.getElementById('empSeguro').value         = SEGURO_POR_UBICACION['SOLDYMEG'];
  document.getElementById('empContrato').value       = 'tiempo_completo';
  document.getElementById('empFechaIngreso').value   = new Date().toISOString().slice(0,10);
  document.getElementById('empAplicaIHSS').checked   = false;
  document.getElementById('empAplicaRAP').checked    = false;
  document.getElementById('empAplicaISR').checked    = false;
  document.getElementById('errEmpleado').style.display = 'none';
  await cargarDepartamentosSelect('empDepartamento', '');
  abrirModal('modalEmpleado');
}

async function editarEmpleado(id) {
  const r = await api('controllers/EmpleadoController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error cargando empleado.','error'); return; }
  const e = r.data.data;
  document.getElementById('empId').value             = e.id_empleado;
  document.getElementById('tituloEmpleado').textContent = 'Editar — ' + e.nombre;
  document.getElementById('empNombres').value   = e.nombres || '';
  document.getElementById('empApellidos').value = e.apellidos || '';
  document.getElementById('empUbicacion').value      = e.ubicacion  || 'SOLDYMEG';
  document.getElementById('empEmpresaId').value      = e.empresa_id || '1';
  document.getElementById('empIdentidad').value      = e.identidad  || '';
  document.getElementById('empTelefono').value       = e.telefono   || '';
  document.getElementById('empCorreo').value         = e.correo     || '';
  document.getElementById('empDireccion').value      = e.direccion  || '';
  document.getElementById('empPuesto').value         = e.puesto     || '';
  document.getElementById('empContrato').value       = e.tipo_contrato;
  document.getElementById('empSalario').value        = e.salario_mensual;
  document.getElementById('empFechaIngreso').value   = e.fecha_ingreso || '';
  document.getElementById('empIHSS').value           = e.ihss_numero  || '';
  document.getElementById('empRAP').value            = e.rap_numero   || '';
  document.getElementById('empBanco').value          = e.banco        || '';
  document.getElementById('empCuenta').value         = e.cuenta_banco || '';
  document.getElementById('empAplicaIHSS').checked   = !!+e.aplica_ihss;
  document.getElementById('empAplicaRAP').checked    = !!+e.aplica_rap;
  document.getElementById('empAplicaISR').checked    = !!+e.aplica_isr;
  document.getElementById('empSeguro').value         = e.seguro_privado != null ? parseFloat(e.seguro_privado) : SEGURO_POR_UBICACION[e.ubicacion||'SOLDYMEG'];
  document.getElementById('errEmpleado').style.display = 'none';
  await cargarDepartamentosSelect('empDepartamento', e.departamento_id || '');
  abrirModal('modalEmpleado');
}

async function guardarEmpleado() {
  const id             = document.getElementById('empId').value;
  const nombres  = document.getElementById('empNombres').value.trim();
  const apellidos= document.getElementById('empApellidos').value.trim();
  const errEl  = document.getElementById('errEmpleado');
  errEl.style.display = 'none';
  if (!nombres || !apellidos) { errEl.textContent='Nombres y apellidos son requeridos.'; errEl.style.display='block'; return; }
  const body = {
    id:              id ? +id : undefined,
    nombres,
    apellidos,
    ubicacion:       document.getElementById('empUbicacion').value,
    empresa_id:      document.getElementById('empEmpresaId')?.value || null,
    departamento_id: document.getElementById('empDepartamento').value || null,
    identidad:       document.getElementById('empIdentidad').value.trim(),
    telefono:        document.getElementById('empTelefono').value.trim(),
    correo:          document.getElementById('empCorreo').value.trim(),
    direccion:       document.getElementById('empDireccion').value.trim(),
    puesto:          document.getElementById('empPuesto').value.trim(),
    tipo_contrato:   document.getElementById('empContrato').value,
    salario_mensual: parseFloat(document.getElementById('empSalario').value)||0,
    fecha_ingreso:   document.getElementById('empFechaIngreso').value,
    ihss_numero:     document.getElementById('empIHSS').value.trim(),
    rap_numero:      document.getElementById('empRAP').value.trim(),
    banco:           document.getElementById('empBanco').value.trim(),
    cuenta_banco:    document.getElementById('empCuenta').value.trim(),
    aplica_ihss:     document.getElementById('empAplicaIHSS').checked ? 1 : 0,
    aplica_rap:      document.getElementById('empAplicaRAP').checked  ? 1 : 0,
    aplica_isr:      document.getElementById('empAplicaISR').checked  ? 1 : 0,
    seguro_privado:  parseFloat(document.getElementById('empSeguro').value)||0,
  };
  const action = id ? 'actualizar' : 'crear';
  const r = await api('controllers/EmpleadoController.php?action=' + action, {method:'POST',body:JSON.stringify(body)});
  if (r.ok) { cerrarModal('modalEmpleado'); toast(id?'Empleado actualizado.':'Empleado creado.','success'); cargarEmpleados(); }
  else { errEl.textContent = r.data.error||'Error.'; errEl.style.display='block'; }
}

async function cambiarEstadoEmpleado(id, estado, nombre) {
  if (!await confirmDialog(`¿Deseas ${estado==='activo'?'activar':'inactivar'} a ${nombre}?`)) return;
  const r = await api('controllers/EmpleadoController.php?action=cambiar_estado',{method:'POST',body:JSON.stringify({id,estado})});
  if (r.ok) { toast(`Empleado ${estado}.`,'success'); cargarEmpleados(); }
  else toast(r.data.error||'Error.','error');
}

// ── PLANILLAS ─────────────────────────────────────────────
let planillasData    = [];
let planQuincenaSeleccionada = '1ra';
let planEmpleadosExtras = []; // [{empleado_id, nombre, ubicacion, salario, horas_extra, dias_faltados, abono_prestamo, abono_vale}]

function selQuincena(q) {
  planQuincenaSeleccionada = q;
  document.querySelectorAll('.quincena-btn').forEach(el => {
    const sel = el.dataset.q === q;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  // Si ya se cargaron los empleados, re-renderizar para mostrar/ocultar seguro
  if (planEmpleadosExtras.length) renderExtrasTable();
  document.getElementById('planPreview').style.display = 'none';
}

async function cargarPlanillas() {
  document.getElementById('tablaPlanillas').innerHTML = '<p class="loading">Cargando...</p>';
  const empId = document.getElementById('planFiltroEmpresaLista')?.value || '';
  const r = await api('controllers/PlanillaController.php?action=listar' + (empId ? '&empresa_id='+empId : ''));
  if (!r.ok) { document.getElementById('tablaPlanillas').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  planillasData = (r.data.data || []).filter(p => p.quincena !== 'catorceavo' && p.quincena !== 'aguinaldo');
  if (planillasData.length) {
    const last = planillasData[0];
    document.getElementById('kpiPlanSalarios').textContent  = fmtMoneda(last.total_salarios);
    document.getElementById('kpiPlanNeto').textContent      = fmtMoneda(last.total_neto);
    document.getElementById('kpiPlanEmpleados').textContent = last.total_empleados || '—';
  }
  paginaActual['planillas_list'] = 1;
  renderTablaPlanillas(planillasData);
}

function renderTablaPlanillas(rows) {
  const meses = ['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  const pag = paginar('planillas_list', rows);
  let h = `<table><thead><tr>
    <th>Período</th><th>Empresa</th><th>Quincena</th><th>Fecha Pago</th>
    <th>Total Salarios</th><th>Deducciones</th><th>Neto a Pagar</th>
    <th>Estado</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="9" class="empty-state">Sin planillas generadas</td></tr>';
  pag.slice.forEach(p => {
    const periodo = (meses[+p.periodo_mes]||'') + ' ' + p.periodo_anio;
    h += `<tr>
      <td><strong>${periodo}</strong></td>
      <td>${p.empresa_nombre?`<span class="badge badge-green">${p.empresa_nombre}</span>`:'—'}</td>
      <td><span class="badge badge-blue">${p.quincena||'1ra'} Quincena</span></td>
      <td>${p.fecha_pago}</td>
      <td>${fmtMoneda(p.total_salarios)}</td>
      <td style="color:var(--danger)">${fmtMoneda(p.total_deducciones)}</td>
      <td><strong style="color:var(--accent)">${fmtMoneda(p.total_neto)}</strong></td>
      <td>${badgeEstado(p.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetallePlanilla(${p.id_planilla})">Ver</button>
        <a href="controllers/ReportesController.php?action=planilla_pdf&id=${p.id_planilla}" target="_blank" class="btn btn-sm btn-secondary">📄 PDF</a>
        <a href="controllers/ReportesController.php?action=planilla_excel&id=${p.id_planilla}" class="btn btn-sm btn-secondary">⬇️ Excel</a>
        ${p.estado==='borrador' ? `<button class="btn btn-sm btn-secondary" onclick="editarPlanilla(${p.id_planilla})">✏️ Editar</button>` : ''}
        ${p.estado==='borrador' ? `<button class="btn btn-sm btn-primary" onclick="cerrarPlanilla(${p.id_planilla})">✓ Cerrar</button>` : ''}
        ${p.estado==='borrador' ? `<button class="btn btn-sm btn-danger"  onclick="eliminarPlanilla(${p.id_planilla})">Eliminar</button>` : ''}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaPlanillas').innerHTML = h;
  renderPaginacion('planillas_list', pag, 'paginaPlanillas');
}

function abrirModalGenerarPlanilla() {
  const now = new Date();
  planQuincenaSeleccionada = '1ra';
  document.querySelectorAll('.quincena-btn').forEach(el => {
    el.style.borderColor = el.dataset.q==='1ra' ? 'var(--accent)' : 'var(--border)';
    el.style.background  = el.dataset.q==='1ra' ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('planMes').value       = now.getMonth()+1;
  document.getElementById('planAnio').value      = now.getFullYear();
  document.getElementById('planFechaPago').value = now.toISOString().slice(0,10);
  document.getElementById('planObs').value       = '';
  document.getElementById('planPreview').style.display = 'none';
  document.getElementById('errPlanilla').style.display = 'none';
  const filtroEmp = document.getElementById('planFiltroEmpresa');
  if (filtroEmp) filtroEmp.value = '';
  document.getElementById('planExtrasWrap').innerHTML =
    '<p style="color:var(--muted);font-size:13px">Haz clic en "Cargar empleados" para ver la tabla de ajustes.</p>';
  planEmpleadosExtras = [];
  abrirModal('modalGenerarPlanilla');
}

async function cargarExtrasEmpleados() {
  const empresaId = document.getElementById('planFiltroEmpresa')?.value || '';
  const url = 'controllers/EmpleadoController.php?action=listar&estado=activo' + (empresaId ? `&empresa_id=${empresaId}` : '');
  const r = await api(url);
  if (!r.ok) { toast('Error cargando empleados.','error'); return; }
  planEmpleadosExtras = r.data.data.map(e => ({
    empleado_id:    e.id_empleado,
    nombre:         e.nombre,
    empresa_nombre: e.empresa_nombre || '',
    ubicacion:      e.ubicacion || 'SOLDYMEG',
    salario_mensual:parseFloat(e.salario_mensual||0),
    seguro_privado: parseFloat(e.seguro_privado) || 0,
    horas_extra:    0,
    dias_faltados:  0,
    abono_prestamo: 0,
    abono_vale:     0,
    viatico_s1:0, viatico_s2:0, viatico_s3:0, viatico_s4:0,
    aplicar_seguro: true,
  }));
  renderExtrasTable();
}

function calcNetoExtra(e) {
  const quince = e.salario_mensual / 2;
  const tHE    = HE_POR_UBICACION[e.ubicacion] || 70;
  const mHE    = (e.horas_extra   || 0) * tHE;
  const mFalt  = (quince / 15) * (e.dias_faltados || 0);
  const es2da      = planQuincenaSeleccionada === '2da';
  const aplicarSeg = es2da && (e.aplicar_seguro === true || e.aplicar_seguro === 1);
  const seguro     = aplicarSeg ? (parseFloat(e.seguro_privado) || 0) : 0;
  const viaticos = (e.viatico_s1||0)+(e.viatico_s2||0)+(e.viatico_s3||0)+(e.viatico_s4||0);
  const ded    = mFalt + seguro + (e.abono_prestamo || 0) + (e.abono_vale || 0);
  return { quince, mHE, mFalt, seguro, ded, viaticos, neto: quince + mHE + viaticos - ded };
}

function renderExtrasTable() {
  if (!planEmpleadosExtras.length) {
    document.getElementById('planExtrasWrap').innerHTML = '<p style="color:var(--muted)">Sin empleados activos.</p>';
    return;
  }
  const es2da = planQuincenaSeleccionada === '2da';
  const viaLabel1 = es2da ? 'VIÁTICOS S.3' : 'VIÁTICOS S.1';
  const viaLabel2 = es2da ? 'VIÁTICOS S.4' : 'VIÁTICOS S.2';
  let h = `<table style="min-width:1100px"><thead><tr>
    <th style="text-align:left">Empleado</th>
    <th>Empresa</th>
    <th>Ubic.</th>
    <th>Sal. Quincenal</th>
    <th>H. Extra<br><small style="font-weight:400;opacity:.8">SOLD=L.70 | VEST=L.85</small></th>
    <th>Días Faltados</th>
    <th>Abono Préstamo</th>
    <th>Abono Vale</th>
    <th style="color:#e8a020">${viaLabel1}</th>
    <th style="color:#e8a020">${viaLabel2}</th>
    <th>Seguro Priv.<br><small style="font-weight:400;opacity:.8">${es2da ? 'Aplica en 2da ✓' : 'Solo 2da quincena'}</small></th>
    <th>Est. Neto</th>
  </tr></thead><tbody>`;

  planEmpleadosExtras.forEach((e, i) => {
    // Garantizar que aplicar_seguro tenga valor booleano definido
    if (e.aplicar_seguro === undefined || e.aplicar_seguro === null) e.aplicar_seguro = true;
    const checked = e.aplicar_seguro === true || e.aplicar_seguro === 1;
    const { quince, mHE, seguro, neto } = calcNetoExtra(e);
    const style = 'width:100%;padding:5px 7px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right';
    const chkStyle = 'width:16px;height:16px;accent-color:var(--accent);cursor:pointer';
    const montoSeguro = parseFloat(e.seguro_privado) || 0;

    h += `<tr>
      <td style="text-align:left"><strong>${e.nombre}</strong></td>
      <td style="text-align:center">${e.empresa_nombre?`<span class="badge badge-green">${e.empresa_nombre}</span>`:'—'}</td>
      <td style="text-align:center"><span class="badge ${e.ubicacion==='VESTA'?'badge-blue':'badge-gray'}">${e.ubicacion}</span></td>
      <td>${fmtMoneda(quince)}</td>
      <td><input type="number" min="0" step="0.5" value="${e.horas_extra||0}" style="${style}"
          onchange="extrasChange(${i},'horas_extra',this.value)"></td>
      <td><input type="number" min="0" step="0.5" value="${e.dias_faltados||0}" style="${style}"
          onchange="extrasChange(${i},'dias_faltados',this.value)"></td>
      <td><input type="number" min="0" step="0.01" value="${e.abono_prestamo||0}" style="${style}"
          onchange="extrasChange(${i},'abono_prestamo',this.value)"></td>
      <td><input type="number" min="0" step="0.01" value="${e.abono_vale||0}" style="${style}"
          onchange="extrasChange(${i},'abono_vale',this.value)"></td>
      <td><input type="number" min="0" step="0.01"
          value="${es2da ? (e.viatico_s3||0) : (e.viatico_s1||0)}"
          style="${style};border-color:rgba(232,160,32,.5)"
          onchange="extrasChange(${i}, '${es2da ? 'viatico_s3' : 'viatico_s1'}', this.value)"></td>
      <td><input type="number" min="0" step="0.01"
          value="${es2da ? (e.viatico_s4||0) : (e.viatico_s2||0)}"
          style="${style};border-color:rgba(232,160,32,.5)"
          onchange="extrasChange(${i}, '${es2da ? 'viatico_s4' : 'viatico_s2'}', this.value)"></td>
      <td style="text-align:center">
        <div style="font-size:11px;color:var(--muted);margin-bottom:3px">${es2da ? fmtMoneda(montoSeguro) : '—'}</div>
        <input type="checkbox" style="${chkStyle}" ${checked ? 'checked' : ''} ${!es2da ? 'disabled title="Solo aplica en 2da quincena"' : ''}
          onchange="extrasChange(${i},'aplicar_seguro',this.checked)" id="chkSeg_${i}">
      </td>
      <td id="extraNeto_${i}" style="font-weight:600;color:${neto>=0?'var(--accent)':'var(--danger)'}">${fmtMoneda(neto)}</td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('planExtrasWrap').innerHTML = h;
}

function extrasChange(idx, campo, valor) {
  if (campo === 'aplicar_seguro') {
    planEmpleadosExtras[idx][campo] = valor; // boolean from checkbox
  } else {
    planEmpleadosExtras[idx][campo] = parseFloat(valor) || 0;
  }
  const e   = planEmpleadosExtras[idx];
  const { neto } = calcNetoExtra(e);
  const el  = document.getElementById('extraNeto_' + idx);
  if (el) {
    el.textContent = fmtMoneda(neto);
    el.style.color = neto >= 0 ? 'var(--accent)' : 'var(--danger)';
  }
}

async function previsualizarPlanilla() {
  const mes      = document.getElementById('planMes').value;
  const anio     = document.getElementById('planAnio').value;
  const quincena = planQuincenaSeleccionada;
  const empId = document.getElementById('planFiltroEmpresa')?.value || '';
  const r = await api(`controllers/PlanillaController.php?action=previsualizar&mes=${mes}&anio=${anio}&quincena=${quincena}${empId?'&empresa_id='+empId:''}`);

  if (!r.ok) { toast(r.data.error||'Error.','error'); return; }
  const t = r.data.data.totales;
  document.getElementById('pvEmpleados').textContent   = t.total_empleados;
  document.getElementById('pvSalarios').textContent    = fmtMoneda(t.total_salarios);
  document.getElementById('pvDeducciones').textContent = fmtMoneda(t.total_deducciones);
  document.getElementById('pvNeto').textContent        = fmtMoneda(t.total_neto);
  document.getElementById('planPreview').style.display = 'block';
}

async function verDetallePlanilla(id) {
  document.getElementById('contenidoDetallePlanilla').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('footerDetallePlanilla').innerHTML = '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetallePlanilla\')">Cerrar</button>';
  abrirModal('modalDetallePlanilla');
  const r = await api('controllers/PlanillaController.php?action=obtener&id='+id);
  if (!r.ok) { document.getElementById('contenidoDetallePlanilla').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  const p = r.data.data;
  const meses=['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
  const periodo  = meses[+p.periodo_mes] + ' ' + p.periodo_anio;
  const quincena = p.quincena || '1ra';
  let h = `<h4>📋 Planilla ${quincena} Quincena — ${periodo} ${badgeEstado(p.estado)}</h4>
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:14px;font-size:13px">
    <div><div style="color:var(--muted);font-size:11px">EMPLEADOS</div><strong>${p.detalle ? p.detalle.length : p.total_empleados || '—'}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">TOTAL SALARIOS</div><strong>${fmtMoneda(p.total_salarios)}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">DEDUCCIONES</div><strong style="color:var(--danger)">${fmtMoneda(p.total_deducciones)}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">NETO A PAGAR</div><strong style="color:var(--accent)">${fmtMoneda(p.total_neto)}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">FECHA PAGO</div><strong>${p.fecha_pago}</strong></div>
  </div>
  <div class="table-wrap"><table>
    <thead><tr>
      <th>Empleado</th><th>Ubic.</th><th>Sal. Quincenal</th>
      <th>H.Extra</th><th>Monto HE</th>
      <th style="color:#e8a020">Viáticos</th>
      <th>Días Falt.</th><th>Desc.</th>
      <th>Seguro</th><th>Abono Prest.</th><th>Abono Vale</th>
      <th>Total Ded.</th><th>NETO A PAGAR</th><th>Boucher</th>
    </tr></thead>
    <tbody>`;
  p.detalle.forEach(d => {
    const ubicBadge = d.ubicacion==='VESTA'
      ? `<span class="badge badge-blue">VESTA</span>`
      : `<span class="badge badge-gray">SOLDYMEG</span>`;
    h += `<tr>
      <td><strong>${d.empleado}</strong><br><small style="color:var(--muted)">${d.puesto||''}</small></td>
      <td>${ubicBadge}</td>
      <td>${fmtMoneda(d.salario_base)}</td>
      <td style="text-align:center">${parseFloat(d.horas_extra||0)>0 ? d.horas_extra : '—'}</td>
      <td>${parseFloat(d.monto_horas_extra||0)>0 ? fmtMoneda(d.monto_horas_extra) : '—'}</td>
      <td style="color:#e8a020;font-weight:600">${(+d.viatico_s1||0)+(+d.viatico_s2||0)+(+d.viatico_s3||0)+(+d.viatico_s4||0)>0?fmtMoneda((+d.viatico_s1||0)+(+d.viatico_s2||0)+(+d.viatico_s3||0)+(+d.viatico_s4||0)):'—'}</td>
      <td style="text-align:center">${parseFloat(d.dias_faltados||0)>0 ? d.dias_faltados : '—'}</td>
      <td style="color:var(--danger)">${parseFloat(d.monto_dias_faltados||0)>0 ? fmtMoneda(d.monto_dias_faltados) : '—'}</td>
      <td>${fmtMoneda(d.seguro_privado)}</td>
      <td>${parseFloat(d.abono_prestamo||0)>0 ? fmtMoneda(d.abono_prestamo) : '—'}</td>
      <td>${parseFloat(d.abono_vale||0)>0 ? fmtMoneda(d.abono_vale) : '—'}</td>
      <td style="color:var(--danger)">${fmtMoneda(d.total_deducciones)}</td>
      <td><strong style="color:var(--accent)">${fmtMoneda(d.salario_neto)}</strong></td>
      <td><a href="controllers/ReportesController.php?action=boucher_pdf&id=${id}&empleado_id=${d.empleado_id}" target="_blank" class="btn btn-sm btn-secondary" title="Generar boucher individual">🧾</a></td>
    </tr>`;
  });
  h += `</tbody></table></div>`;
  document.getElementById('contenidoDetallePlanilla').innerHTML = h;
  document.getElementById('footerDetallePlanilla').innerHTML = `
    <button class="btn btn-secondary" onclick="cerrarModal('modalDetallePlanilla')">Cerrar</button>
    <a href="controllers/ReportesController.php?action=planilla_pdf&id=${id}" target="_blank" class="btn btn-secondary">📄 PDF</a>
    <a href="controllers/ReportesController.php?action=planilla_excel&id=${id}" class="btn btn-secondary">⬇️ Excel</a>
    <a href="controllers/ReportesController.php?action=boucher_todos_pdf&id=${id}" target="_blank" class="btn btn-primary">🧾 Generar Todos los Bouchers</a>
    ${p.estado==='borrador' ? `<button class="btn btn-primary" onclick="cerrarModal('modalDetallePlanilla');cerrarPlanilla(${id})">✓ Cerrar Planilla</button>` : ''}
  `;
}

async function cerrarPlanilla(id) {
  if (!await confirmDialog('¿Cerrar esta planilla? No podrá eliminarse ni modificarse después.')) return;
  const r = await api('controllers/PlanillaController.php?action=cerrar',{method:'POST',body:JSON.stringify({id})});
  if (r.ok) { toast('Planilla cerrada.','success'); cargarPlanillas(); }
  else toast(r.data.error||'Error.','error');
}

async function editarPlanilla(id) {
  const r = await api('controllers/PlanillaController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error cargando planilla.', 'error'); return; }
  const p = r.data.data;
  document.getElementById('errPlanilla').style.display = 'none';
  planQuincenaSeleccionada = p.quincena || '1ra';
  document.querySelectorAll('.quincena-btn').forEach(el => {
    el.style.borderColor = el.dataset.q === planQuincenaSeleccionada ? 'var(--accent)' : 'var(--border)';
    el.style.background  = el.dataset.q === planQuincenaSeleccionada ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('planMes').value       = p.periodo_mes;
  document.getElementById('planAnio').value      = p.periodo_anio;
  document.getElementById('planFechaPago').value = p.fecha_pago;
  document.getElementById('planObs').value       = p.observaciones || '';
  const filtroEmpEdit = document.getElementById('planFiltroEmpresa');
  if (filtroEmpEdit) filtroEmpEdit.value = p.empresa_id || '';

  // Reconstruir extras desde detalle guardado — PRESERVANDO todos los valores
  planEmpleadosExtras = (p.detalle || []).map(d => ({
    empleado_id:    d.empleado_id,
    nombre:         d.empleado,
    empresa_nombre: d.empresa_nombre || '',
    ubicacion:      d.ubicacion || 'SOLDYMEG',
    salario_mensual:(parseFloat(d.salario_base) * 2),
    seguro_privado: parseFloat(d.seguro_privado || 0),
    horas_extra:    parseFloat(d.horas_extra    || 0),
    dias_faltados:  parseFloat(d.dias_faltados  || 0),
    abono_prestamo: parseFloat(d.abono_prestamo || 0),
    abono_vale:     parseFloat(d.abono_vale     || 0),
    viatico_s1:     parseFloat(d.viatico_s1     || 0),
    viatico_s2:     parseFloat(d.viatico_s2     || 0),
    viatico_s3:     parseFloat(d.viatico_s3     || 0),
    viatico_s4:     parseFloat(d.viatico_s4     || 0),
    aplicar_seguro: d.aplicar_seguro !== undefined
      ? !!+d.aplicar_seguro
      : (parseFloat(d.seguro_privado || 0) > 0),
  }));

  renderExtrasTable();
  document.getElementById('planPreview').style.display = 'none';
  window._planillaEditandoId = id;
  abrirModal('modalGenerarPlanilla');
}

async function confirmarGenerarPlanilla() {
  const errEl = document.getElementById('errPlanilla');
  errEl.style.display = 'none';
  if (!document.getElementById('planMes').value || !document.getElementById('planAnio').value) {
    errEl.textContent='Selecciona mes y año.'; errEl.style.display='block'; return;
  }
  const editandoId = window._planillaEditandoId ? +window._planillaEditandoId : 0;
  const body = {
    mes:          +document.getElementById('planMes').value,
    anio:         +document.getElementById('planAnio').value,
    quincena:     planQuincenaSeleccionada,
    fecha_pago:   document.getElementById('planFechaPago').value,
    observaciones:document.getElementById('planObs').value.trim(),
    excluir_id:   editandoId,
    empresa_id:   document.getElementById('planFiltroEmpresa')?.value || 0,
    extras:       planEmpleadosExtras.map(e => ({
      empleado_id:    e.empleado_id,
      seguro_privado: e.seguro_privado || 0,
      horas_extra:    e.horas_extra    || 0,
      dias_faltados:  e.dias_faltados  || 0,
      abono_prestamo: e.abono_prestamo || 0,
      abono_vale:     e.abono_vale     || 0,
      viatico_s1:     e.viatico_s1     || 0,
      viatico_s2:     e.viatico_s2     || 0,
      viatico_s3:     e.viatico_s3     || 0,
      viatico_s4:     e.viatico_s4     || 0,
      aplicar_seguro: e.aplicar_seguro === true || e.aplicar_seguro === 1,
    })),
  };

  // Edición: eliminar la planilla anterior ANTES de generar la nueva
  if (editandoId) {
    const rDel = await api('controllers/PlanillaController.php?action=eliminar', {
      method: 'POST', body: JSON.stringify({ id: editandoId })
    });
    if (!rDel.ok) {
      errEl.textContent = 'Error al reemplazar planilla anterior: ' + (rDel.data.error || '');
      errEl.style.display = 'block'; return;
    }
    window._planillaEditandoId = null;
    body.excluir_id = 0; // Ya eliminada, sin nada que excluir
  }

  const r = await api('controllers/PlanillaController.php?action=generar', {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) {
    cerrarModal('modalGenerarPlanilla');
    toast('Planilla ' + planQuincenaSeleccionada + ' quincena guardada correctamente.', 'success');
    cargarPlanillas();
  } else {
    errEl.textContent = r.data.error || 'Error al generar planilla.';
    errEl.style.display = 'block';
  }
}

async function eliminarPlanilla(id) {
  if (!await confirmDialog('¿Eliminar esta planilla borrador?')) return;
  const r = await api('controllers/PlanillaController.php?action=eliminar',{method:'POST',body:JSON.stringify({id})});
  if (r.ok) { toast('Planilla eliminada.','success'); cargarPlanillas(); }
  else toast(r.data.error||'Error.','error');
}

function switchTabPlanilla(tab) {
  document.getElementById('tabEmpleados').classList.toggle('active',  tab==='empleados');
  document.getElementById('tabPlanillas').classList.toggle('active',  tab==='planillas');
  document.getElementById('tabEspeciales').classList.toggle('active', tab==='especiales');
  document.getElementById('panelEmpleados').style.display  = tab==='empleados'  ? '' : 'none';
  document.getElementById('panelPlanillas').style.display  = tab==='planillas'  ? '' : 'none';
  document.getElementById('panelEspeciales').style.display = tab==='especiales' ? '' : 'none';
  if (tab==='planillas')  cargarPlanillas();
  if (tab==='empleados' && !empleadosData.length) cargarEmpleados();
  if (tab==='especiales') cargarEspeciales();
}


// ── PLANILLAS ESPECIALES (14vo / Aguinaldo) ───────────────
let especialesData        = [];
let espTipoSeleccionado   = 'catorceavo';
let espEmpleados          = [];
let _espEditandoId        = null;

function selTipoEspecial(tipo) {
  espTipoSeleccionado = tipo;
  document.querySelectorAll('.especial-tipo-btn').forEach(el => {
    el.style.borderColor = el.dataset.tipo===tipo ? 'var(--accent)' : 'var(--border)';
    el.style.background  = el.dataset.tipo===tipo ? 'rgba(232,160,32,.12)' : '';
  });
  actualizarInfoPeriodo();
  if (espEmpleados.length) renderTablaEspEmpleados();
  document.getElementById('espPreview').style.display = 'none';
}

function actualizarInfoPeriodo() {
  const anio = parseInt(document.getElementById('espAnio')?.value || new Date().getFullYear());
  const label = espTipoSeleccionado === 'catorceavo'
    ? `1 Jul ${anio-1} → 30 Jun ${anio}` : `1 Nov ${anio-1} → 31 Oct ${anio}`;
  const el = document.getElementById('espPeriodoLabel');
  if (el) el.textContent = label;
}

function calcMontoEsp(emp) {
  const anio = parseInt(document.getElementById('espAnio')?.value || new Date().getFullYear());
  const sal  = parseFloat(emp.salario_mensual) || 0;
  const periodoIni = espTipoSeleccionado==='catorceavo' ? new Date(`${anio-1}-07-01`) : new Date(`${anio-1}-11-01`);
  const periodoFin = espTipoSeleccionado==='catorceavo' ? new Date(`${anio}-06-30`)   : new Date(`${anio}-10-31`);
  const totalDias  = Math.round((periodoFin-periodoIni)/86400000)+1;
  const ingreso    = emp.fecha_ingreso ? new Date(emp.fecha_ingreso) : periodoIni;
  const iniEf      = ingreso > periodoIni ? ingreso : periodoIni;
  const diasTrab   = Math.max(0, Math.round((periodoFin-iniEf)/86400000)+1);
  const meses      = Math.round(diasTrab/(totalDias/12)*100)/100;
  const monto      = emp.excluido ? 0 : Math.round(sal*(diasTrab/totalDias)*100)/100;
  return { monto, meses, diasTrab, totalDias };
}

function abrirModalGenerarEspecial() {
  espTipoSeleccionado = 'catorceavo'; _espEditandoId = null; espEmpleados = [];
  document.querySelectorAll('.especial-tipo-btn').forEach(el => {
    el.style.borderColor = el.dataset.tipo==='catorceavo' ? 'var(--accent)' : 'var(--border)';
    el.style.background  = el.dataset.tipo==='catorceavo' ? 'rgba(232,160,32,.12)' : '';
  });
  const now = new Date();
  if (document.getElementById('espAnio'))      document.getElementById('espAnio').value      = now.getFullYear();
  if (document.getElementById('espFechaPago')) document.getElementById('espFechaPago').value = now.toISOString().slice(0,10);
  if (document.getElementById('espObs'))       document.getElementById('espObs').value       = '';
  if (document.getElementById('errEspecial'))  document.getElementById('errEspecial').style.display = 'none';
  if (document.getElementById('espPreview'))   document.getElementById('espPreview').style.display  = 'none';
  if (document.getElementById('espExtrasWrap')) document.getElementById('espExtrasWrap').innerHTML =
    '<p style="color:var(--muted);font-size:13px">Haz clic en "Cargar empleados".</p>';
  if (document.getElementById('tituloEspecial')) document.getElementById('tituloEspecial').textContent = '📋 Generar Planilla Especial';
  const espEmpSel = document.getElementById('espFiltroEmpresa');
  if (espEmpSel) espEmpSel.value = '0';
  actualizarInfoPeriodo();
  abrirModal('modalGenerarEspecial');
}

async function cargarEmpEspeciales() {
  const espEmpId = document.getElementById('espFiltroEmpresa')?.value || '';
  const url = 'controllers/EmpleadoController.php?action=listar&estado=activo' + (espEmpId && espEmpId!=='0' ? '&empresa_id='+espEmpId : '');
  const r = await api(url);
  if (!r.ok) { toast('Error cargando empleados.','error'); return; }
  espEmpleados = (r.data.data||[]).map(e => ({
    empleado_id:    e.id_empleado,
    nombre:         e.nombre,
    empresa_nombre: e.empresa_nombre || '',
    ubicacion:      e.ubicacion || 'SOLDYMEG',
    salario_mensual:parseFloat(e.salario_mensual||0),
    fecha_ingreso:  e.fecha_ingreso || null,
    excluido:       false,
  }));
  renderTablaEspEmpleados();
}

function renderTablaEspEmpleados() {
  if (!espEmpleados.length) { document.getElementById('espExtrasWrap').innerHTML='<p style="color:var(--muted)">Sin empleados activos.</p>'; return; }
  const label = espTipoSeleccionado==='catorceavo' ? 'Catorceavo' : 'Aguinaldo';
  let h = `<table style="min-width:680px"><thead><tr>
    <th style="width:32px;text-align:center">✗</th>
    <th style="text-align:left">Empleado</th>
    <th>Empresa</th><th>Ubic.</th>
    <th>Salario Mensual</th><th>Fecha Ingreso</th>
    <th>Meses en período</th><th>${label} estimado</th>
  </tr></thead><tbody>`;
  espEmpleados.forEach((e,i) => {
    const {monto,meses} = calcMontoEsp(e);
    h += `<tr style="${e.excluido?'opacity:.45':''}">
      <td style="text-align:center"><input type="checkbox" ${e.excluido?'checked':''}
        style="width:16px;height:16px;accent-color:var(--danger);cursor:pointer"
        onchange="espToggleExcluir(${i},this.checked)"></td>
      <td style="text-align:left"><strong>${e.nombre}</strong></td>
      <td style="text-align:center">${e.empresa_nombre?`<span class="badge badge-green">${e.empresa_nombre}</span>`:'—'}</td>
      <td style="text-align:center"><span class="badge ${e.ubicacion==='VESTA'?'badge-blue':'badge-gray'}">${e.ubicacion}</span></td>
      <td>${fmtMoneda(e.salario_mensual)}</td>
      <td style="font-size:12px;color:var(--muted)">${e.fecha_ingreso||'—'}</td>
      <td id="espMeses_${i}" style="text-align:center;color:var(--muted);font-size:13px">${e.excluido?'—':meses}</td>
      <td id="espMonto_${i}" style="font-weight:600;color:${e.excluido?'var(--danger)':'var(--accent)'}">
        ${e.excluido?'EXCLUIDO':fmtMoneda(monto)}</td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('espExtrasWrap').innerHTML = h;
}

function espToggleExcluir(idx, excluido) {
  espEmpleados[idx].excluido = excluido;
  const {monto,meses} = calcMontoEsp(espEmpleados[idx]);
  const tr = document.getElementById(`espMonto_${idx}`)?.closest('tr');
  if (tr) tr.style.opacity = excluido ? '.45' : '1';
  const mEl=document.getElementById(`espMonto_${idx}`), msEl=document.getElementById(`espMeses_${idx}`);
  if (mEl)  { mEl.textContent=excluido?'EXCLUIDO':fmtMoneda(monto); mEl.style.color=excluido?'var(--danger)':'var(--accent)'; }
  if (msEl)   msEl.textContent = excluido?'—':meses;
  document.getElementById('espPreview').style.display = 'none';
}

async function previsualizarEspecial() {
  const anio=document.getElementById('espAnio').value;
  const excluidos=espEmpleados.filter(e=>e.excluido).map(e=>e.empleado_id).join(',');
  const r=await api(`controllers/PlanillaEspecialController.php?action=previsualizar&tipo=${espTipoSeleccionado}&anio=${anio}&excluidos=${excluidos}`);
  if(!r.ok){toast(r.data.error||'Error.','error');return;}
  const t=r.data.data.totales;
  document.getElementById('pvEspEmpleados').textContent=t.total_empleados;
  document.getElementById('pvEspExcluidos').textContent=t.excluidos;
  document.getElementById('pvEspNeto').textContent=fmtMoneda(t.total_neto);
  document.getElementById('espPreview').style.display='block';
}

async function confirmarGenerarEspecial() {
  const errEl=document.getElementById('errEspecial'); errEl.style.display='none';
  const anio=parseInt(document.getElementById('espAnio')?.value||0);
  if(!anio){errEl.textContent='Selecciona el año.';errEl.style.display='block';return;}
  const excluidos=espEmpleados.filter(e=>e.excluido).map(e=>e.empleado_id);
  const espEmpId = document.getElementById('espFiltroEmpresa')?.value || 0;
  const body={tipo:espTipoSeleccionado,anio,fecha_pago:document.getElementById('espFechaPago').value,
    observaciones:document.getElementById('espObs').value.trim(),excluidos,excluir_id:_espEditandoId||0,empresa_id:+espEmpId||0};
  const r=await api('controllers/PlanillaEspecialController.php?action=generar',{method:'POST',body:JSON.stringify(body)});
  if(r.ok){
    cerrarModal('modalGenerarEspecial');
    toast(`Planilla de ${espTipoSeleccionado==='catorceavo'?'Catorceavo':'Aguinaldo'} ${anio} generada.`,'success');
    cargarEspeciales();
  } else { errEl.textContent=r.data.error||'Error al generar.'; errEl.style.display='block'; }
}

async function cargarEspeciales() {
  const el=document.getElementById('tablaEspeciales');
  if(!el) return;
  el.innerHTML='<p class="loading">Cargando...</p>';
  const empEspId = document.getElementById('planFiltroEmpresaEsp')?.value || '';
  const r=await api('controllers/PlanillaEspecialController.php?action=listar' + (empEspId ? '&empresa_id='+empEspId : ''));
  if(!r.ok){el.innerHTML='<p style="color:var(--danger)">Error.</p>';return;}
  especialesData=(r.data.data||[]).filter(p=>p.quincena==='catorceavo'||p.quincena==='aguinaldo');
  const cat14=especialesData.find(p=>p.quincena==='catorceavo');
  const agui =especialesData.find(p=>p.quincena==='aguinaldo');
  const k1=document.getElementById('kpiEspCatorceavo'), k2=document.getElementById('kpiEspAguinaldo');
  if(k1) k1.textContent=cat14?fmtMoneda(cat14.total_neto):'—';
  if(k2) k2.textContent=agui ?fmtMoneda(agui.total_neto) :'—';
  renderTablaEspeciales(especialesData);
}

function renderTablaEspeciales(rows) {
  const labels={catorceavo:'1️⃣4️⃣ Catorceavo',aguinaldo:'🎄 Aguinaldo'};
  let h=`<table><thead><tr><th>Tipo</th><th>Empresa</th><th>Año</th><th>Fecha Pago</th><th>Empleados</th><th>Total Neto</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>`;
  if(!rows.length) h+='<tr><td colspan="8" class="empty-state">Sin planillas especiales generadas</td></tr>';
  rows.forEach(p=>{
    const empBadge = p.empresa_nombre ? `<span class="badge badge-green">${p.empresa_nombre}</span>` : '—';
    h+=`<tr>
      <td><strong>${labels[p.quincena]||p.quincena}</strong></td>
      <td>${empBadge}</td>
      <td>${p.periodo_anio}</td><td>${p.fecha_pago}</td>
      <td style="text-align:center">${p.total_empleados||'—'}</td>
      <td><strong style="color:var(--accent)">${fmtMoneda(p.total_neto)}</strong></td>
      <td>${badgeEstado(p.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleEspecial(${p.id_planilla})">Ver</button>
        <a href="controllers/ReportesController.php?action=planilla_pdf&id=${p.id_planilla}" target="_blank" class="btn btn-sm btn-secondary">📄 PDF</a>
        <a href="controllers/ReportesController.php?action=planilla_excel&id=${p.id_planilla}" class="btn btn-sm btn-secondary">⬇️ Excel</a>
        ${p.estado==='borrador'?`<button class="btn btn-sm btn-secondary" onclick="editarEspecial(${p.id_planilla})">✏️ Editar</button>`:''}
        ${p.estado==='borrador'?`<button class="btn btn-sm btn-primary" onclick="cerrarEspecial(${p.id_planilla})">✓ Cerrar</button>`:''}
        ${p.estado==='borrador'?`<button class="btn btn-sm btn-danger" onclick="eliminarEspecial(${p.id_planilla})">Eliminar</button>`:''}
      </div></td>
    </tr>`;
  });
  h+='</tbody></table>';
  const el=document.getElementById('tablaEspeciales'); if(el) el.innerHTML=h;
}

async function cerrarEspecial(id) {
  if(!await confirmDialog('¿Cerrar esta planilla?')) return;
  const r=await api('controllers/PlanillaEspecialController.php?action=cerrar',{method:'POST',body:JSON.stringify({id})});
  if(r.ok){toast('Planilla cerrada.','success');cargarEspeciales();}
  else toast(r.data.error||'Error.','error');
}

async function eliminarEspecial(id) {
  if(!await confirmDialog('¿Eliminar esta planilla borrador?')) return;
  const r=await api('controllers/PlanillaEspecialController.php?action=eliminar',{method:'POST',body:JSON.stringify({id})});
  if(r.ok){toast('Planilla eliminada.','success');cargarEspeciales();}
  else toast(r.data.error||'Error.','error');
}

async function editarEspecial(id) {
  const r = await api('controllers/PlanillaEspecialController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error cargando planilla.','error'); return; }
  const p = r.data.data;
  espTipoSeleccionado = p.quincena || 'catorceavo';
  _espEditandoId      = id;
  const espEmpSelEdit = document.getElementById('espFiltroEmpresa');
  if (espEmpSelEdit) espEmpSelEdit.value = p.empresa_id || '0';
  document.querySelectorAll('.especial-tipo-btn').forEach(el => {
    el.style.borderColor = el.dataset.tipo===espTipoSeleccionado ? 'var(--accent)' : 'var(--border)';
    el.style.background  = el.dataset.tipo===espTipoSeleccionado ? 'rgba(232,160,32,.12)' : '';
  });
  if (document.getElementById('espAnio'))      document.getElementById('espAnio').value      = p.periodo_anio;
  if (document.getElementById('espFechaPago')) document.getElementById('espFechaPago').value = p.fecha_pago;
  if (document.getElementById('espObs'))       document.getElementById('espObs').value       = p.observaciones || '';
  if (document.getElementById('errEspecial'))  document.getElementById('errEspecial').style.display = 'none';
  if (document.getElementById('espPreview'))   document.getElementById('espPreview').style.display  = 'none';
  if (document.getElementById('tituloEspecial')) document.getElementById('tituloEspecial').textContent = '✏️ Editar Planilla Especial';
  // Reconstruir lista de empleados desde detalle guardado
  espEmpleados = (p.detalle || []).map(d => ({
    empleado_id:    d.empleado_id,
    nombre:         d.empleado,
    empresa_nombre: d.empresa_nombre || '',
    ubicacion:      d.ubicacion || 'SOLDYMEG',
    salario_mensual:parseFloat(d.salario_base || 0),
    fecha_ingreso:  d.fecha_ingreso || null,
    excluido:       d.observaciones === 'EXCLUIDO',
  }));
  actualizarInfoPeriodo();
  renderTablaEspEmpleados();
  abrirModal('modalGenerarEspecial');
}

async function verDetalleEspecial(id) {
  abrirModal('modalDetalleEspecial');
  document.getElementById('contenidoDetalleEspecial').innerHTML='<p class="loading">Cargando...</p>';
  document.getElementById('footerDetalleEspecial').innerHTML=`<button class="btn btn-secondary" onclick="cerrarModal('modalDetalleEspecial')">Cerrar</button>`;
  const r=await api('controllers/PlanillaEspecialController.php?action=obtener&id='+id);
  if(!r.ok){document.getElementById('contenidoDetalleEspecial').innerHTML='<p style="color:var(--danger)">Error.</p>';return;}
  const p=r.data.data;
  const labels={catorceavo:'1️⃣4️⃣ Catorceavo',aguinaldo:'🎄 Aguinaldo'};
  let h=`<h4>${labels[p.quincena]||p.quincena} ${p.periodo_anio} ${badgeEstado(p.estado)}</h4>
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:14px;font-size:13px">
    <div><div style="color:var(--muted);font-size:11px">EMPLEADOS</div><strong>${p.detalle?p.detalle.filter(d=>d.observaciones!=='EXCLUIDO').length:'—'}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">EXCLUIDOS</div><strong style="color:var(--danger)">${p.detalle?p.detalle.filter(d=>d.observaciones==='EXCLUIDO').length:'—'}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">TOTAL NETO</div><strong style="color:var(--accent)">${fmtMoneda(p.total_neto)}</strong></div>
    <div><div style="color:var(--muted);font-size:11px">FECHA PAGO</div><strong>${p.fecha_pago}</strong></div>
  </div>
  <div class="table-wrap"><table>
    <thead><tr><th>Empleado</th><th>Empresa</th><th>Ubic.</th><th>Sal. Mensual</th><th>Fecha Ingreso</th><th>Estado</th><th>Monto</th><th>Boucher</th></tr></thead><tbody>`;
  (p.detalle||[]).forEach(d=>{
    const excl=d.observaciones==='EXCLUIDO';
    h+=`<tr style="${excl?'opacity:.5':''}">
      <td><strong>${d.empleado}</strong><br><small style="color:var(--muted)">${d.puesto||''}</small></td>
      <td>${d.empresa_nombre?`<span class="badge badge-green">${d.empresa_nombre}</span>`:'—'}</td>
      <td>${d.ubicacion==='VESTA'?'<span class="badge badge-blue">VESTA</span>':'<span class="badge badge-gray">SOLDYMEG</span>'}</td>
      <td>${fmtMoneda(d.salario_base)}</td>
      <td style="font-size:12px;color:var(--muted)">${d.fecha_ingreso||'—'}</td>
      <td>${excl?'<span class="badge badge-red">EXCLUIDO</span>':'<span class="badge badge-green">Incluido</span>'}</td>
      <td><strong style="color:${excl?'var(--danger)':'var(--accent)'}">${excl?'—':fmtMoneda(d.salario_neto)}</strong></td>
      <td>${excl?'—':`<a href="controllers/ReportesController.php?action=boucher_pdf&id=${id}&empleado_id=${d.empleado_id}" target="_blank" class="btn btn-sm btn-secondary" title="Generar boucher individual">🧾</a>`}</td>
    </tr>`;
  });
  h+='</tbody></table></div>';
  document.getElementById('contenidoDetalleEspecial').innerHTML=h;
  document.getElementById('footerDetalleEspecial').innerHTML=`
    <button class="btn btn-secondary" onclick="cerrarModal('modalDetalleEspecial')">Cerrar</button>
    <a href="controllers/ReportesController.php?action=boucher_todos_pdf&id=${id}" target="_blank" class="btn btn-primary">🧾 Generar Todos los Bouchers</a>
    ${p.estado==='borrador'?`<button class="btn btn-primary" onclick="cerrarModal('modalDetalleEspecial');cerrarEspecial(${id})">✓ Cerrar Planilla</button>`:''}`;
}

