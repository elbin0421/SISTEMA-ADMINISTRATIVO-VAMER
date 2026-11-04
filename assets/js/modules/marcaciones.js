// ══════════════════════════════════════════════════════════
// marcaciones.js — Asistencia diaria (hora de entrada / salida)
// El estado de cada día lo calcula el servidor (MarcacionModel).
// ══════════════════════════════════════════════════════════

const MC_MESES = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
const MC_MESES_LARGO = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
const MC_DIAS_LETRA = ['D','L','M','M','J','V','S'];
const MC_DIAS_LARGO = ['domingo','lunes','martes','miércoles','jueves','viernes','sábado'];
const MC_ESTADOS = {
  puntual: 'Puntual', tardanza: 'Tardanza', salida_anticipada: 'Salida anticipada', falta_salida: 'Falta salida',
  ausente: 'Ausente', justificado: 'Justificado', inhabil: 'Día inhábil', pendiente: 'Sin marca todavía',
  futuro: 'Pendiente', na: 'Aún sin contrato',
};
const MC_ORIGENES = { manual: 'Manual', app_movil: 'App móvil', biometrico: 'Biométrico', importado: 'Importado' };
const MC_PRESENTE = ['puntual','tardanza','salida_anticipada','falta_salida','justificado'];

let mcVista = 'quincena', mcAnio = 0, mcMes = 0, mcQuin = 2, mcDia = '';
let mcMarcaSel = [];
let mcData = null, mcCatalogos = null, mcEmpSel = 0, mcFechaSel = '', mcIniciado = false, mcMarcaModo = 'nueva';

const mcPad = n => String(n).padStart(2, '0');
const mcHoy = () => new Date().toLocaleDateString('en-CA');
const mcUltimoDia = (y, m) => new Date(y, m, 0).getDate();
const mcEsc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function mcSumarDias(f, n) { const d = new Date(f + 'T00:00:00'); d.setDate(d.getDate() + n); return d.toLocaleDateString('en-CA'); }
function mcFmtCorta(f) { const [y, m, d] = f.split('-'); return `${+d} ${MC_MESES[+m - 1]}`; }
function mcFmtMin(min) { return `${Math.floor(min / 60)} h ${mcPad(min % 60)} min`; }
function mcFmtHoras(min) { return `${Math.floor(min / 60)}h ${mcPad(min % 60)}`; }

// ── Carga ────────────────────────────────────────────────
async function cargarMarcaciones() {
  if (!mcIniciado) {
    const hoy = new Date();
    mcAnio = hoy.getFullYear(); mcMes = hoy.getMonth() + 1; mcQuin = hoy.getDate() <= 15 ? 1 : 2; mcDia = mcHoy();
    const r = await api('controllers/MarcacionesController.php?action=catalogos');
    if (r.ok) {
      mcCatalogos = r.data;
      document.getElementById('mcMarcaDepto').innerHTML = '<option value="">+ Agregar departamento…</option>' + r.data.departamentos.map(d => `<option value="${d.id_departamento}">${mcEsc(d.nombre)}</option>`).join('');
      document.getElementById('mcDepto').innerHTML = '<option value="">Departamento: Todos</option>' +
        r.data.departamentos.map(d => `<option value="${d.id_departamento}">${mcEsc(d.nombre)}</option>`).join('');
    }
    mcIniciado = true;
    mcActualizarBotones();
  }
  mcCargar();
}

function mcRango() {
  if (mcVista === 'dia') return { desde: mcDia, hasta: mcDia };
  const ult = mcUltimoDia(mcAnio, mcMes);
  if (mcVista === 'mes') return { desde: `${mcAnio}-${mcPad(mcMes)}-01`, hasta: `${mcAnio}-${mcPad(mcMes)}-${mcPad(ult)}` };
  return mcQuin === 1
    ? { desde: `${mcAnio}-${mcPad(mcMes)}-01`, hasta: `${mcAnio}-${mcPad(mcMes)}-15` }
    : { desde: `${mcAnio}-${mcPad(mcMes)}-16`, hasta: `${mcAnio}-${mcPad(mcMes)}-${mcPad(ult)}` };
}

async function mcCargar() {
  document.getElementById('mcGrid').innerHTML = '<p class="loading">Cargando...</p>';
  const { desde, hasta } = mcRango();
  const emp = document.getElementById('mcEmpresa').value, dep = document.getElementById('mcDepto').value;
  const r = await api(`controllers/MarcacionesController.php?action=periodo&desde=${desde}&hasta=${hasta}&hoy=${mcHoy()}` +
    (emp ? `&empresa_id=${emp}` : '') + (dep ? `&departamento_id=${dep}` : ''));
  if (!r.ok) { document.getElementById('mcGrid').innerHTML = `<p style="color:var(--danger)">${mcEsc(r.data.error || 'Error al cargar la asistencia.')}</p>`; return; }
  mcData = r.data.data;
  // Día seleccionado: el último día laborable transcurrido dentro del período
  const fechas = mcData.dias.map(d => d.fecha);
  if (!mcFechaSel || !fechas.includes(mcFechaSel)) {
    const hoy = mcHoy();
    const cand = mcData.dias.filter(d => d.fecha <= hoy && d.dow !== 0).map(d => d.fecha);
    mcFechaSel = cand.length ? cand[cand.length - 1] : fechas[0];
  }
  if (!mcData.empleados.find(e => e.id === mcEmpSel)) mcEmpSel = mcData.empleados.length ? mcData.empleados[0].id : 0;
  mcRender();
}

// ── Navegación ───────────────────────────────────────────
function mcActualizarBotones() {
  ['quincena','mes','dia'].forEach(v => document.getElementById('mcV' + v.charAt(0).toUpperCase() + v.slice(1)).classList.toggle('on', mcVista === v));
  document.getElementById('mcQuincenaBtns').style.display = mcVista === 'quincena' ? '' : 'none';
  document.getElementById('mcQ1').classList.toggle('on', mcQuin === 1);
  document.getElementById('mcQ2').classList.toggle('on', mcQuin === 2);
}
function mcSetVista(v) {
  if (v === 'dia') mcDia = mcFechaSel || mcHoy();
  mcVista = v; mcActualizarBotones(); mcCargar();
}
function mcSetQuincena(q) { mcQuin = q; mcActualizarBotones(); mcCargar(); }
function mcMover(dir) {
  if (mcVista === 'dia') { mcDia = mcSumarDias(mcDia, dir); mcFechaSel = mcDia; }
  else if (mcVista === 'mes') { mcMes += dir; }
  else {
    if (dir > 0) { if (mcQuin === 1) mcQuin = 2; else { mcQuin = 1; mcMes++; } }
    else { if (mcQuin === 2) mcQuin = 1; else { mcQuin = 2; mcMes--; } }
  }
  if (mcMes > 12) { mcMes = 1; mcAnio++; }
  if (mcMes < 1)  { mcMes = 12; mcAnio--; }
  mcActualizarBotones(); mcCargar();
}

// ── Render ───────────────────────────────────────────────
function mcClase(c, dow) { return (c.est === 'puntual' && dow === 6) ? 'mc-sabado' : 'mc-' + c.est; }

function mcCeldaHtml(c) {
  switch (c.est) {
    case 'ausente': return 'Aus.';
    case 'inhabil': case 'na': case 'futuro': return '–';
    case 'pendiente': return '·';
  }
  if (!c.e) return 'Just.';
  return `<i>${c.e}</i><i>${c.s || (c.est === 'falta_salida' ? 's/sal.' : '…')}</i>`;
}

function mcRender() {
  const d = mcData, cfg = d.config;
  // Subtítulo
  const empSel = document.getElementById('mcEmpresa');
  const empTxt = empSel.value ? empSel.options[empSel.selectedIndex].text : 'Todas las empresas';
  const alm = cfg.almuerzo_min >= 60 && cfg.almuerzo_min % 60 === 0 ? (cfg.almuerzo_min / 60) + ' h' : cfg.almuerzo_min + ' min';
  document.getElementById('mcSubtitulo').textContent = `${empTxt} · Empleados · Lun–Vie ${cfg.hora_entrada} – ${cfg.hora_salida} (${alm} almuerzo)` +
    (cfg.trabaja_sabado ? ` · Sábado ${cfg.sabado_entrada} – ${cfg.sabado_salida}` : ' · Sábado no laborable');
  // Navegador de período
  const { desde, hasta } = mcRango();
  const [y, m] = desde.split('-');
  if (mcVista === 'dia') {
    const dd = new Date(desde + 'T00:00:00');
    document.getElementById('mcNavTitulo').textContent = `${MC_DIAS_LARGO[dd.getDay()]} ${dd.getDate()} ${MC_MESES[dd.getMonth()]} ${dd.getFullYear()}`;
    document.getElementById('mcNavSub').textContent = 'Vista por día';
  } else if (mcVista === 'mes') {
    document.getElementById('mcNavTitulo').textContent = `${MC_MESES_LARGO[+m - 1]} ${y}`;
    document.getElementById('mcNavSub').textContent = 'Mes completo';
  } else {
    document.getElementById('mcNavTitulo').textContent = `${+desde.slice(8)} – ${+hasta.slice(8)} ${MC_MESES[+m - 1]} ${y}`;
    document.getElementById('mcNavSub').textContent = `${mcQuin}.ª quincena · corte de planilla ${+hasta.slice(8)} ${MC_MESES[+m - 1]}`;
  }
  // KPIs del período
  document.getElementById('mcKpiTard').textContent = d.kpis.tardanzas;
  document.getElementById('mcKpiAus').textContent  = d.kpis.ausencias;
  document.getElementById('mcKpiAsis').textContent = d.kpis.asistencia === null ? '—' : d.kpis.asistencia + '%';

  if (!d.empleados.length) { document.getElementById('mcGrid').innerHTML = '<p class="empty-state">No hay empleados para mostrar.</p>'; mcRenderSel(); return; }
  document.getElementById('mcGrid').innerHTML = mcVista === 'dia' ? mcTablaDia() : mcTablaGrid();
  mcLeyenda();
  mcRenderSel();
}

function mcTablaGrid() {
  const d = mcData;
  let h = '<table class="mc-grid"><thead><tr><th class="fix">Empleado</th>';
  d.dias.forEach(x => {
    h += `<th class="${x.dow === 6 ? 'sat' : x.dow === 0 ? 'sun' : ''}">${MC_DIAS_LETRA[x.dow]}<small>${+x.fecha.slice(8)}</small></th>`;
  });
  h += '<th class="mc-tot">Horas</th><th class="mc-tot">Tard.</th><th class="mc-tot">Aus.</th><th class="mc-tot">Asist.</th></tr></thead><tbody>';
  d.empleados.forEach(e => {
    h += `<tr><td class="fix">${mcEsc(e.nombre.split(' ').slice(0, 2).join(' '))}</td>`;
    d.dias.forEach(x => {
      const c = e.celdas[x.fecha];
      const sel = (e.id === mcEmpSel && x.fecha === mcFechaSel) ? ' sel' : '';
      h += `<td><div class="mc-c ${mcClase(c, x.dow)}${sel}" data-e="${e.id}" data-f="${x.fecha}" onclick="mcSelCelda(${e.id},'${x.fecha}')">${mcCeldaHtml(c)}</div></td>`;
    });
    h += `<td class="mc-tot"><b>${mcFmtHoras(e.tot.min_trab)}</b></td><td class="mc-tot">${e.tot.tardanzas}</td><td class="mc-tot">${e.tot.ausencias}</td>
      <td class="mc-tot"><b>${e.tot.asistencia === null ? '—' : e.tot.asistencia + '%'}</b></td></tr>`;
  });
  return h + '</tbody></table>';
}

function mcTablaDia() {
  const d = mcData, f = d.dias[0].fecha, dow = d.dias[0].dow;
  let h = `<table style="width:100%"><thead><tr><th>Empleado</th><th>Entrada</th><th>Salida</th><th>Estado</th><th>Horas</th><th>H. extra</th><th>Origen</th></tr></thead><tbody>`;
  d.empleados.forEach(e => {
    const c = e.celdas[f], sel = e.id === mcEmpSel ? 'background:var(--bg)' : '';
    h += `<tr style="cursor:pointer;${sel}" onclick="mcSelCelda(${e.id},'${f}')" data-e="${e.id}" data-f="${f}">
      <td><strong>${mcEsc(e.nombre)}</strong><div style="font-size:10px;color:var(--muted)">${mcEsc(e.puesto || '')}</div></td>
      <td>${c.e || '—'}</td><td>${c.s || '—'}</td>
      <td><span class="mc-c ${mcClase(c, dow)}" style="display:inline-block;padding:3px 10px;cursor:pointer">${MC_ESTADOS[c.est]}${c.est === 'tardanza' ? ' · ' + c.min_tarde + ' min' : ''}</span></td>
      <td>${c.min_trab ? mcFmtMin(c.min_trab) : '—'}</td><td>${c.min_extra ? mcFmtMin(c.min_extra) : '—'}</td><td>${c.origen ? MC_ORIGENES[c.origen] : '—'}</td></tr>`;
  });
  return h + '</tbody></table>';
}

function mcLeyenda() {
  const cfg = mcData.config;
  const it = (cls, txt) => `<span><i class="${cls}"></i>${txt}</span>`;
  document.getElementById('mcLegend').innerHTML =
    it('mc-puntual', 'Puntual') + it('mc-tardanza', 'Tardanza') + it('mc-salida_anticipada', 'Salida anticipada') + it('mc-falta_salida', 'Falta salida') +
    it('mc-ausente', 'Ausente') + it('mc-justificado', 'Justificado') +
    (cfg.trabaja_sabado ? it('mc-sabado', `Sábado (medio día, hasta ${cfg.sabado_salida})`) : '') + it('mc-inhabil', 'Domingo inhábil');
}

// ── Selección y detalle ──────────────────────────────────
function mcSelCelda(empId, fecha) {
  mcEmpSel = empId; mcFechaSel = fecha;
  document.querySelectorAll('#mcGrid .mc-c.sel').forEach(el => el.classList.remove('sel'));
  document.querySelectorAll('#mcGrid [data-e]').forEach(el => {
    if (+el.dataset.e === empId && el.dataset.f === fecha && el.classList.contains('mc-c')) el.classList.add('sel');
    if (mcVista === 'dia' && el.tagName === 'TR') el.style.background = +el.dataset.e === empId ? 'var(--bg)' : '';
  });
  mcRenderSel();
}

function mcCeldaActual() {
  if (!mcData) return null;
  const e = mcData.empleados.find(x => x.id === mcEmpSel);
  return e && e.celdas[mcFechaSel] ? { e, c: e.celdas[mcFechaSel] } : null;
}

function mcRenderSel() {
  if (!mcData) return;
  // KPI "presentes" del día seleccionado
  const lista = mcData.empleados.filter(e => e.celdas[mcFechaSel] && e.celdas[mcFechaSel].est !== 'na');
  const pres  = lista.filter(e => MC_PRESENTE.includes(e.celdas[mcFechaSel].est) && e.celdas[mcFechaSel].e).length;
  document.getElementById('mcKpiPresentes').textContent = `${pres} / ${lista.length}`;
  document.getElementById('mcKpiPresentesLbl').textContent = `Presentes ${mcFmtCorta(mcFechaSel)}`;

  const box = document.getElementById('mcDetalle'), cur = mcCeldaActual();
  if (!cur) { box.innerHTML = '<h5>Detalle del día</h5><p class="empty-state" style="padding:20px 0">Selecciona una casilla.</p>'; return; }
  const { e, c } = cur, dt = new Date(mcFechaSel + 'T00:00:00'), dow = dt.getDay();
  const fechaLarga = `${MC_DIAS_LARGO[dt.getDay()].replace(/^./, s => s.toUpperCase())} ${dt.getDate()} de ${MC_MESES_LARGO[dt.getMonth()].toLowerCase()}`;
  let banner = MC_ESTADOS[c.est];
  if (c.est === 'tardanza') banner += ` · ${c.min_tarde} min`;
  if (c.est === 'salida_anticipada') banner += ` · ${c.min_ant} min`;
  let ult = '';
  if (c.fecha_edicion) {
    const f = c.fecha_edicion.replace(' ', 'T'), x = new Date(f);
    ult = `Última edición: ${mcEsc(c.editor || '—')}, ${x.getDate()} ${MC_MESES[x.getMonth()]} ${mcPad(x.getHours())}:${mcPad(x.getMinutes())}`;
  }
  box.innerHTML = `<h5>Detalle del día</h5>
    <div class="nm">${mcEsc(e.nombre)}</div><div class="dt">${fechaLarga}</div>
    <div class="mc-badge ${mcClase(c, dow)}">${banner}</div>
    <div class="mc-row"><span>Entrada</span><b>${c.e || '—'}</b></div>
    <div class="mc-row"><span>Salida</span><b>${c.s || '—'}</b></div>
    <div class="mc-row"><span>Horas trabajadas</span><b>${c.min_trab ? mcFmtMin(c.min_trab) : '—'}</b></div>
    <div class="mc-row"><span>Horas extra</span><b>${c.min_extra ? mcFmtMin(c.min_extra) : '—'}</b></div>
    <div class="mc-row"><span>Origen</span><b>${c.origen ? MC_ORIGENES[c.origen] : '—'}</b></div>
    <div style="font-size:12px;color:var(--muted);margin:10px 0 4px">Observación</div>
    <div style="border:1px solid var(--border);border-radius:7px;padding:8px 10px;min-height:36px;font-size:13px">${mcEsc(c.obs || '')}</div>
    ${c.just ? `<div style="font-size:12px;margin-top:8px;color:#3b9be0">Justificación: ${mcEsc(c.just)}</div>` : ''}
    <div style="display:flex;gap:8px;margin-top:14px">
      <button class="btn btn-primary" style="flex:1" onclick="mcAbrirCorregir()">${c.id && (c.e || c.s) ? 'Corregir marca' : 'Registrar marca'}</button>
      <button class="btn btn-secondary" style="flex:1" onclick="mcAbrirJust()">Justificar</button>
    </div>
    ${c.id && (c.e || c.s) ? `<button class="btn btn-sm btn-danger" style="margin-top:8px;width:100%" onclick="mcEliminarMarca(${c.id})">Eliminar marca</button>` : ''}
    <div style="font-size:11px;color:var(--muted);margin-top:10px">${ult}</div>`;
}

// ── Registrar / corregir marca ───────────────────────────
function mcEmpsModal() {
  const emp = mcMarcaModo === 'nueva' ? document.getElementById('mcMarcaEmpresa').value : '';
  return (mcCatalogos?.empleados || []).filter(e => !emp || e.empresa_id == emp);
}
function mcFiltroEmpresa() { document.getElementById('mcMarcaBuscar').focus(); mcBuscarEmp(); }

function mcBuscarEmp() {
  const inp = document.getElementById('mcMarcaBuscar'); if (inp.disabled) return;
  const box = document.getElementById('mcMarcaSug');
  const norm = s => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  const q = norm(inp.value.trim());
  const actual = (mcCatalogos?.empleados || []).find(e => e.id_empleado == document.getElementById('mcMarcaEmp').value);
  if (actual && norm(actual.nombre) !== q) document.getElementById('mcMarcaEmp').value = '';
  const res = mcEmpsModal().filter(e => !q || norm(e.nombre).includes(q)).slice(0, 10);
  box.innerHTML = res.length ? res.map(e => `<div onmousedown="mcElegirEmp(${e.id_empleado})" style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)">
      <strong>${mcEsc(e.nombre)}</strong> <span style="font-size:11px;color:var(--muted)">${mcEsc(e.puesto || '')}</span></div>`).join('')
    : '<div style="padding:8px 12px;font-size:12px;color:var(--muted)">Sin resultados</div>';
  box.style.display = '';
}
function mcElegirEmp(id) {
  const e = (mcCatalogos?.empleados || []).find(x => x.id_empleado == id); if (!e) return;
  if (mcMarcaModo === 'nueva') {
    if (!mcMarcaSel.includes(+id)) mcMarcaSel.push(+id);
    document.getElementById('mcMarcaBuscar').value = '';
    mcRenderChips();
    document.getElementById('mcMarcaBuscar').focus();
  } else {
    document.getElementById('mcMarcaEmp').value = e.id_empleado;
    document.getElementById('mcMarcaBuscar').value = e.nombre;
  }
  document.getElementById('mcMarcaSug').style.display = 'none';
}
function mcRenderChips() {
  const emps = mcCatalogos?.empleados || [];
  document.getElementById('mcMarcaChips').innerHTML = mcMarcaSel.map(id => {
    const e = emps.find(x => x.id_empleado == id);
    return `<span style="background:var(--bg);border:1px solid var(--border);border-radius:14px;padding:2px 4px 2px 10px;font-size:12px">${mcEsc(e ? e.nombre : '#' + id)}
      <a style="cursor:pointer;padding:0 6px;color:var(--muted)" onclick="mcQuitarSel(${id})">✕</a></span>`;
  }).join('');
  document.getElementById('mcMarcaCont').textContent = mcMarcaSel.length ? `${mcMarcaSel.length} empleado(s) seleccionado(s)` : 'Busca y elige uno o varios empleados.';
}
function mcQuitarSel(id) { mcMarcaSel = mcMarcaSel.filter(x => x !== id); mcRenderChips(); }
function mcLimpiarSel() { mcMarcaSel = []; mcRenderChips(); }
function mcAgregarTodos() {
  mcEmpsModal().forEach(e => { if (!mcMarcaSel.includes(+e.id_empleado)) mcMarcaSel.push(+e.id_empleado); });
  mcRenderChips();
}
function mcAgregarDepto() {
  const sel = document.getElementById('mcMarcaDepto'), dep = sel.value; if (!dep) return;
  mcEmpsModal().filter(e => e.departamento_id == dep).forEach(e => { if (!mcMarcaSel.includes(+e.id_empleado)) mcMarcaSel.push(+e.id_empleado); });
  sel.value = ''; mcRenderChips();
}

function mcAbrirMarca() {
  mcMarcaModo = 'nueva';
  document.getElementById('mcMarcaTitulo').textContent = 'Registrar marca';
  document.getElementById('mcMarcaErr').style.display = 'none';
  document.getElementById('mcMarcaBuscar').disabled = false; document.getElementById('mcMarcaFecha').disabled = false;
  document.getElementById('mcMarcaEmp').value = ''; document.getElementById('mcMarcaBuscar').value = '';
  mcMarcaSel = []; mcRenderChips(); document.getElementById('mcMarcaMulti').style.display = ''; document.getElementById('mcMarcaSobre').checked = false;
  document.getElementById('mcMarcaEmpresa').value = document.getElementById('mcEmpresa').value;
  document.getElementById('mcMarcaBuscar').placeholder = '🔍 Buscar y agregar empleados...';
  document.getElementById('mcMarcaFecha').value = mcHoy();
  document.getElementById('mcMarcaEntrada').value = ''; document.getElementById('mcMarcaSalida').value = '';
  document.getElementById('mcMarcaOrigen').value = 'manual'; document.getElementById('mcMarcaObs').value = '';
  document.getElementById('mcBtnAhora').style.display = '';
  abrirModal('modalMarca');
}

function mcAbrirCorregir() {
  const cur = mcCeldaActual(); if (!cur) return;
  const { e, c } = cur, existe = c.id && (c.e || c.s);
  mcMarcaModo = existe ? 'corregir' : 'nueva';
  document.getElementById('mcMarcaTitulo').textContent = existe ? 'Corregir marca' : 'Registrar marca';
  document.getElementById('mcMarcaErr').style.display = 'none';
  document.getElementById('mcMarcaEmp').value = e.id; document.getElementById('mcMarcaBuscar').value = e.nombre;
  document.getElementById('mcMarcaMulti').style.display = 'none';
  mcMarcaSel = [e.id];
  document.getElementById('mcMarcaBuscar').disabled = true;
  document.getElementById('mcMarcaFecha').value = mcFechaSel; document.getElementById('mcMarcaFecha').disabled = true;
  document.getElementById('mcMarcaEntrada').value = c.e || ''; document.getElementById('mcMarcaSalida').value = c.s || '';
  document.getElementById('mcMarcaOrigen').value = c.origen || 'manual'; document.getElementById('mcMarcaObs').value = c.obs || '';
  document.getElementById('mcBtnAhora').style.display = (!existe && mcFechaSel === mcHoy()) ? '' : 'none';
  abrirModal('modalMarca');
}

function mcResumenLote(r) {
  let m = `${r.guardados} marca(s) registrada(s).`;
  if (r.omitidos?.length) m += ` Omitidos (ya tenían marca): ${r.omitidos.length}.`;
  return m;
}
function mcMostrarLote(r, err) {
  const det = [];
  if (r.omitidos?.length) det.push('Omitidos (ya tenían marca): ' + r.omitidos.join(', '));
  if (r.errores?.length) det.push(...r.errores);
  if (!det.length) return false;
  err.innerHTML = det.map(mcEsc).join('<br>'); err.style.display = 'block'; return true;
}

async function mcGuardarMarca() {
  const err = document.getElementById('mcMarcaErr'); err.style.display = 'none';
  const body = {
    empleado_id: +document.getElementById('mcMarcaEmp').value || 0, fecha: document.getElementById('mcMarcaFecha').value,
    hora_entrada: document.getElementById('mcMarcaEntrada').value, hora_salida: document.getElementById('mcMarcaSalida').value,
    origen: document.getElementById('mcMarcaOrigen').value, observacion: document.getElementById('mcMarcaObs').value.trim(),
  };
  if (mcMarcaModo === 'nueva') {
    if (!mcMarcaSel.length) { err.textContent = 'Selecciona al menos un empleado.'; err.style.display = 'block'; return; }
    const r = await api('controllers/MarcacionesController.php?action=lote', { method: 'POST',
      body: JSON.stringify({ ...body, modo: 'guardar', empleados: mcMarcaSel, sobrescribir: document.getElementById('mcMarcaSobre').checked }) });
    if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
    mcFechaSel = body.fecha; mcEmpSel = mcMarcaSel[0];
    if (mcMostrarLote(r.data, err)) { toast(mcResumenLote(r.data), 'warn'); mcCargar(); return; }  // deja el modal abierto con el detalle
    cerrarModal('modalMarca'); toast(mcResumenLote(r.data)); mcCargar(); return;
  }
  if (!body.empleado_id) { err.textContent = 'Selecciona el empleado.'; err.style.display = 'block'; return; }
  const r = await api('controllers/MarcacionesController.php?action=guardar', { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
  cerrarModal('modalMarca'); toast('Marca guardada.');
  mcEmpSel = body.empleado_id; mcFechaSel = body.fecha;
  mcCargar();
}

async function mcMarcarAhora() {
  const err = document.getElementById('mcMarcaErr'); err.style.display = 'none';
  const ahora = new Date(), hora = `${mcPad(ahora.getHours())}:${mcPad(ahora.getMinutes())}`;
  if (!mcMarcaSel.length) { err.textContent = 'Selecciona al menos un empleado.'; err.style.display = 'block'; return; }
  const r = await api('controllers/MarcacionesController.php?action=lote', { method: 'POST',
    body: JSON.stringify({ modo: 'ahora', empleados: mcMarcaSel, fecha: mcHoy(), hora }) });
  if (!r.ok) { err.textContent = r.data.error || 'No se pudo marcar.'; err.style.display = 'block'; return; }
  mcEmpSel = mcMarcaSel[0]; mcFechaSel = mcHoy();
  if (r.data.errores?.length) { err.innerHTML = r.data.errores.map(mcEsc).join('<br>'); err.style.display = 'block'; toast(`${r.data.guardados} marcado(s) a las ${hora}.`, 'warn'); mcCargar(); return; }
  cerrarModal('modalMarca'); toast(`${r.data.guardados} empleado(s) marcado(s) a las ${hora}.`); mcCargar();
}

async function mcEliminarMarca(id) {
  if (!await confirmDialog('¿Eliminar la marca de este día? El día volverá a contarse según no haya marca.')) return;
  const r = await api('controllers/MarcacionesController.php?action=eliminar', { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data.error || 'No se pudo eliminar.', 'error'); return; }
  toast('Marca eliminada.'); mcCargar();
}

// ── Justificar ───────────────────────────────────────────
function mcAbrirJust() {
  const cur = mcCeldaActual(); if (!cur) return;
  document.getElementById('mcJustErr').style.display = 'none';
  document.getElementById('mcJustInfo').textContent = `${cur.e.nombre} — ${mcFmtCorta(mcFechaSel)} (${MC_ESTADOS[cur.c.est]})`;
  document.getElementById('mcJustMotivo').value = cur.c.just || '';
  document.getElementById('mcJustQuitar').style.display = cur.c.justificado ? '' : 'none';
  abrirModal('modalJustificar');
}
async function mcEnviarJust(extra) {
  const err = document.getElementById('mcJustErr'); err.style.display = 'none';
  const r = await api('controllers/MarcacionesController.php?action=justificar', { method: 'POST',
    body: JSON.stringify({ empleado_id: mcEmpSel, fecha: mcFechaSel, ...extra }) });
  if (!r.ok) { err.textContent = r.data.error || 'Error.'; err.style.display = 'block'; return; }
  cerrarModal('modalJustificar'); toast(extra.quitar ? 'Justificación eliminada.' : 'Día justificado.'); mcCargar();
}
function mcGuardarJust() { mcEnviarJust({ justificacion: document.getElementById('mcJustMotivo').value.trim() }); }
function mcQuitarJust() { mcEnviarJust({ quitar: true }); }

// ── Horario ──────────────────────────────────────────────
async function mcAbrirConfig() {
  const r = await api('controllers/MarcacionesController.php?action=config');
  if (!r.ok) { toast(r.data.error || 'Error al cargar el horario.', 'error'); return; }
  const c = r.data.data;
  document.getElementById('mcCfgErr').style.display = 'none';
  document.getElementById('mcCfgEntrada').value = c.hora_entrada; document.getElementById('mcCfgSalida').value = c.hora_salida;
  document.getElementById('mcCfgAlmuerzo').value = c.almuerzo_min; document.getElementById('mcCfgSabado').value = c.trabaja_sabado;
  document.getElementById('mcCfgSabEntrada').value = c.sabado_entrada; document.getElementById('mcCfgSabSalida').value = c.sabado_salida;
  document.getElementById('mcCfgTol').value = c.tolerancia_min;
  abrirModal('modalMcConfig');
}
async function mcGuardarConfig() {
  const err = document.getElementById('mcCfgErr'); err.style.display = 'none';
  const body = {
    hora_entrada: document.getElementById('mcCfgEntrada').value, hora_salida: document.getElementById('mcCfgSalida').value,
    almuerzo_min: +document.getElementById('mcCfgAlmuerzo').value, trabaja_sabado: +document.getElementById('mcCfgSabado').value,
    sabado_entrada: document.getElementById('mcCfgSabEntrada').value, sabado_salida: document.getElementById('mcCfgSabSalida').value,
    tolerancia_min: +document.getElementById('mcCfgTol').value,
  };
  const r = await api('controllers/MarcacionesController.php?action=config_guardar', { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
  cerrarModal('modalMcConfig'); toast('Horario guardado.'); mcCargar();
}

// ── Excel / Imprimir ─────────────────────────────────────
function mcTextoPlano(c) {
  switch (c.est) {
    case 'ausente': return 'AUSENTE';
    case 'inhabil': case 'na': case 'futuro': case 'pendiente': return '';
  }
  if (!c.e) return 'JUSTIFICADO';
  return `${c.e}-${c.s || 's/sal.'}`;
}

function mcExportarExcel() {
  if (!mcData || !mcData.empleados.length) { toast('No hay datos para exportar.', 'warn'); return; }
  const { desde, hasta } = mcRango(), d = mcData;
  const head = ['Empleado', ...d.dias.map(x => `${+x.fecha.slice(8)} ${MC_DIAS_LETRA[x.dow]}`), 'Horas', 'Tardanzas', 'Ausencias', '% Asistencia'];
  const rows = [['ASISTENCIA DIARIA'], [`${desde} al ${hasta}`], [], head,
    ...d.empleados.map(e => [e.nombre, ...d.dias.map(x => mcTextoPlano(e.celdas[x.fecha])), mcFmtHoras(e.tot.min_trab), e.tot.tardanzas, e.tot.ausencias, e.tot.asistencia === null ? '' : e.tot.asistencia / 100])];
  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [{ wch: 28 }, ...d.dias.map(() => ({ wch: 12 })), { wch: 9 }, { wch: 10 }, { wch: 10 }, { wch: 12 }];
  const det = [['Empleado','Fecha','Día','Entrada','Salida','Estado','Min. tarde','Horas trabajadas','Horas extra','Origen','Observación','Justificación']];
  d.empleados.forEach(e => d.dias.forEach(x => {
    const c = e.celdas[x.fecha];
    if (['inhabil','na','futuro','pendiente'].includes(c.est) && !c.id) return;
    det.push([e.nombre, x.fecha, MC_DIAS_LARGO[x.dow], c.e || '', c.s || '', MC_ESTADOS[c.est], c.min_tarde || 0,
      c.min_trab ? +(c.min_trab / 60).toFixed(2) : 0, c.min_extra ? +(c.min_extra / 60).toFixed(2) : 0, c.origen ? MC_ORIGENES[c.origen] : '', c.obs || '', c.just || '']);
  }));
  const ws2 = XLSX.utils.aoa_to_sheet(det);
  ws2['!cols'] = [28,11,11,9,9,18,10,16,11,12,32,32].map(w => ({ wch: w }));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Asistencia'); XLSX.utils.book_append_sheet(wb, ws2, 'Detalle');
  XLSX.writeFile(wb, `Asistencia_${desde}_${hasta}.xlsx`);
}

function mcImprimir() {
  if (!mcData || !mcData.empleados.length) { toast('No hay datos para imprimir.', 'warn'); return; }
  const { desde, hasta } = mcRango(), d = mcData, cfg = d.config;
  const col = { puntual: '#d9f2e6', sabado: '#cdeeeb', tardanza: '#fbe9b7', salida_anticipada: '#fbd9c2', falta_salida: '#e3dafb', ausente: '#f8cfcf', justificado: '#cfe5f8' };
  let h = '<table><thead><tr><th>Empleado</th>' + d.dias.map(x => `<th>${MC_DIAS_LETRA[x.dow]}<br>${+x.fecha.slice(8)}</th>`).join('') + '<th>Horas</th><th>Tard.</th><th>Aus.</th><th>Asist.</th></tr></thead><tbody>';
  d.empleados.forEach(e => {
    h += `<tr><td class="n">${mcEsc(e.nombre)}</td>`;
    d.dias.forEach(x => {
      const c = e.celdas[x.fecha], k = (c.est === 'puntual' && x.dow === 6) ? 'sabado' : c.est;
      h += `<td style="background:${col[k] || '#eee'}">${c.e ? `${c.e}<br>${c.s || 's/sal.'}` : (c.est === 'ausente' ? 'Aus.' : c.est === 'justificado' ? 'Just.' : '–')}</td>`;
    });
    h += `<td><b>${mcFmtHoras(e.tot.min_trab)}</b></td><td>${e.tot.tardanzas}</td><td>${e.tot.ausencias}</td><td><b>${e.tot.asistencia === null ? '—' : e.tot.asistencia + '%'}</b></td></tr>`;
  });
  h += '</tbody></table>';
  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Asistencia ${desde} a ${hasta}</title>
  <style>body{font-family:Arial,sans-serif;font-size:9px;padding:12px;color:#111}h2{margin:0}p{margin:2px 0 10px;color:#555;font-size:10px}
  table{border-collapse:collapse;width:100%}th,td{border:1px solid #bbb;padding:2px 3px;text-align:center}th{background:#eee}td.n{text-align:left;font-weight:700;white-space:nowrap}
  @media print{@page{size:landscape;margin:8mm}}</style></head><body>
  <h2>ASISTENCIA DIARIA — VENTAS AMERICA S. DE R.L</h2>
  <p>Período: ${desde} al ${hasta} · Lun–Vie ${cfg.hora_entrada}–${cfg.hora_salida} · Sábado ${cfg.trabaja_sabado ? cfg.sabado_entrada + '–' + cfg.sabado_salida : 'no laborable'} · Tardanzas: ${d.kpis.tardanzas} · Ausencias: ${d.kpis.ausencias} · Asistencia: ${d.kpis.asistencia === null ? '—' : d.kpis.asistencia + '%'}</p>
  ${h}<script>window.onload=()=>window.print()<\/script></body></html>`;
  const w = window.open('', '_blank');
  if (!w) { toast('Permite las ventanas emergentes para imprimir.', 'warn'); return; }
  w.document.write(html); w.document.close();
}

// ── Enviar a Tiempo Extra y Faltas ───────────────────────
const MC_SYNC_ACC = { nuevo: 'Nuevo', actualiza: 'Actualiza', igual: 'Ya enviado', en_planilla: 'En planilla', manual: 'Ya existe (manual)' };
function mcSyncBody(aplicar) {
  const { desde, hasta } = mcRango();
  return { desde, hasta, hoy: mcHoy(), empresa_id: +document.getElementById('mcEmpresa').value || 0, departamento_id: +document.getElementById('mcDepto').value || 0,
    incluir_extra: document.getElementById('mcSyncExtra').checked, incluir_faltas: document.getElementById('mcSyncFaltas').checked,
    min_extra_minimo: +document.getElementById('mcSyncMin').value || 30, aplicar };
}
function mcAbrirSync() {
  const { desde, hasta } = mcRango();
  document.getElementById('mcSyncInfo').textContent = `Período: ${mcFmtCorta(desde)} al ${mcFmtCorta(hasta)} — solo empleados activos. Los ausentes justificados no se envían.`;
  document.getElementById('mcSyncErr').style.display = 'none';
  abrirModal('modalMcSync'); mcPrevSync();
}
async function mcPrevSync() {
  const box = document.getElementById('mcSyncPrev'), err = document.getElementById('mcSyncErr'), btn = document.getElementById('mcSyncBtn');
  err.style.display = 'none'; box.innerHTML = '<p class="loading" style="padding:12px">Calculando...</p>'; btn.disabled = true;
  const r = await api('controllers/MarcacionesController.php?action=enviar_tiempo_extra', { method: 'POST', body: JSON.stringify(mcSyncBody(false)) });
  if (!r.ok) { box.innerHTML = ''; err.textContent = r.data.error || 'Error al calcular.'; err.style.display = 'block'; return; }
  const it = r.data.items, rs = r.data.resumen;
  box.innerHTML = it.length ? `<table style="width:100%;font-size:12px"><thead><tr><th>Empleado</th><th>Fecha</th><th>Tipo</th><th>Cant.</th><th>Acción</th></tr></thead><tbody>` +
    it.map(i => `<tr><td>${mcEsc(i.empleado)}</td><td>${mcFmtCorta(i.fecha)}</td><td>${i.tipo === 'horas_extra' ? 'Horas extra' : 'Día faltado'}</td>
      <td>${i.tipo === 'horas_extra' ? i.cantidad + ' h' : i.cantidad + ' d'}</td><td>${MC_SYNC_ACC[i.accion]}</td></tr>`).join('') + '</tbody></table>'
    : '<p class="empty-state" style="padding:16px">No hay horas extra ni faltas para enviar en este período.</p>';
  document.getElementById('mcSyncRes').textContent = `Nuevos: ${rs.nuevo} · Actualizan: ${rs.actualiza} · Ya enviados: ${rs.igual} · En planilla: ${rs.en_planilla} · Ya existen manuales: ${rs.manual}`;
  btn.disabled = (rs.nuevo + rs.actualiza) === 0;
}
async function mcEnviarSync() {
  const err = document.getElementById('mcSyncErr'); err.style.display = 'none';
  const r = await api('controllers/MarcacionesController.php?action=enviar_tiempo_extra', { method: 'POST', body: JSON.stringify(mcSyncBody(true)) });
  if (!r.ok) { err.textContent = r.data.error || 'No se pudo enviar.'; err.style.display = 'block'; return; }
  const rs = r.data.resumen;
  cerrarModal('modalMcSync'); toast(`Enviado a Tiempo Extra y Faltas: ${rs.nuevo} nuevo(s), ${rs.actualiza} actualizado(s).`);
}
