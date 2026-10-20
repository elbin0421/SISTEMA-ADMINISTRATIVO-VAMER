// ══════════════════════════════════════════════════════════
// recibos.js — Recibos (viáticos / adelantos / abonos a préstamo)
// Se integran a la planilla quincenal (ver planillas.js).
// ══════════════════════════════════════════════════════════

let recibosData = [];
let recibosEmpleados = [];

const RECIBO_CONCEPTOS = {
  viaticos:         { label: 'VIATICOS',            efecto: '➕ suma en planilla' },
  adelanto_salario: { label: 'ADELANTO DE SALARIO', efecto: '➖ deducción' },
  abono_prestamo:   { label: 'ABONO PRESTAMO',      efecto: '➖ deducción' },
  otro:             { label: 'OTRO',                efecto: 'sin efecto en planilla' },
};

const RECIBO_EMPRESA = {
  nombre:    'VENTAS AMERICA SOCIEDAD DE RESPONSABILIDAD LIMITADA',
  direccion: 'Col. San Sebastián, Calpules, a dos cuadras de CA-13, San Pedro Sula, Cortés.',
  contacto:  'Cel: 9941-8647 | vamerhn@gmail.com',
  rtn:       '05019026315890',
};

function escRec(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

// ── Número a letras (Lempiras, formato del recibo) ───────
function _recLeerEntero(n) {
  const U = ['','UN','DOS','TRES','CUATRO','CINCO','SEIS','SIETE','OCHO','NUEVE','DIEZ','ONCE','DOCE','TRECE','CATORCE','QUINCE','DIECISEIS','DIECISIETE','DIECIOCHO','DIECINUEVE','VEINTE','VEINTIUN','VEINTIDOS','VEINTITRES','VEINTICUATRO','VEINTICINCO','VEINTISEIS','VEINTISIETE','VEINTIOCHO','VEINTINUEVE'];
  const D = ['','','','TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA','OCHENTA','NOVENTA'];
  const C = ['','CIENTO','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS','QUINIENTOS','SEISCIENTOS','SETECIENTOS','OCHOCIENTOS','NOVECIENTOS'];
  const grupo = x => {
    if (x === 100) return 'CIEN';
    let s = ''; const c = Math.floor(x / 100), r = x % 100;
    if (c) s += C[c] + ' ';
    if (r < 30) s += U[r];
    else { s += D[Math.floor(r / 10)]; if (r % 10) s += ' Y ' + U[r % 10]; }
    return s.trim();
  };
  const mill = Math.floor(n / 1e6), mil = Math.floor((n % 1e6) / 1000), res = n % 1000;
  const p = [];
  if (mill) p.push(mill === 1 ? 'UN MILLON' : _recLeerEntero(mill) + ' MILLONES');
  if (mil)  p.push(mil === 1 ? 'MIL' : grupo(mil) + ' MIL');
  if (res)  p.push(grupo(res));
  return p.join(' ');
}
function numeroALetrasRecibo(num) {
  num = Math.round(parseFloat(num || 0) * 100) / 100;
  const ent = Math.floor(num), dec = Math.round((num - ent) * 100);
  let t = ent === 0 ? 'CERO' : _recLeerEntero(ent).replace(/UN$/, 'UNO');
  return `${t} CON ${String(dec).padStart(2, '0')}/100`;
}

function fechaLimiteRecibo(f) {
  if (!f) return '';
  const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  const [y, mo, d] = f.split('-');
  return `${d}-${m[+mo - 1]}-${y}`;
}

// ── Listado ──────────────────────────────────────────────
async function cargarRecibos() {
  document.getElementById('tablaRecibosWrap').innerHTML = '<p class="loading">Cargando...</p>';
  const q = new URLSearchParams({ action: 'listar' });
  const d = document.getElementById('recDesde').value, h = document.getElementById('recHasta').value;
  const e = document.getElementById('recEstado').value;
  if (d) q.set('desde', d); if (h) q.set('hasta', h); if (e) q.set('estado', e);
  const r = await api('controllers/RecibosController.php?' + q.toString());
  if (!r.ok) { document.getElementById('tablaRecibosWrap').innerHTML = '<p style="color:var(--danger)">Error al cargar recibos.</p>'; return; }
  recibosData = r.data.data;
  filtrarRecibos();
}

function filtrarRecibos() {
  const t = (document.getElementById('recBuscar').value || '').toLowerCase();
  paginaActual['recibos'] = 1;
  renderTablaRecibos(recibosData.filter(x => !t || (x.numero + ' ' + x.empleado_nombre).toLowerCase().includes(t)));
}

function renderTablaRecibos(data) {
  const wrap = document.getElementById('tablaRecibosWrap');
  if (!data.length) { wrap.innerHTML = '<p class="empty-state">No hay recibos.</p>'; document.getElementById('paginaRecibos').innerHTML = ''; return; }
  const pag = paginar('recibos', data);
  let h = `<table><thead><tr><th>Número</th><th>Fecha</th><th>Empleado</th><th>Concepto</th><th>Total</th><th>Planilla</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>`;
  pag.slice.forEach(r => {
    const anulado = r.estado === 'anulado';
    const tipos = (r.tipos || '').split(',').filter(Boolean).map(t => RECIBO_CONCEPTOS[t]?.label || t).join(', ');
    const plan = r.planilla_id ? `<span class="badge badge-green">${r.quincena} ${String(r.periodo_mes).padStart(2,'0')}/${r.periodo_anio}</span>`
                               : (anulado ? '—' : '<span class="badge badge-yellow">Pendiente</span>');
    const bloqueado = anulado || r.planilla_id;
    h += `<tr style="${anulado ? 'opacity:.55' : ''}">
      <td><strong style="font-family:monospace;font-size:12px">${escRec(r.numero)}</strong></td>
      <td>${r.fecha}</td>
      <td>${escRec(r.empleado_nombre)}</td>
      <td style="font-size:12px">${escRec(tipos)}${r.semana ? ` <span class="badge badge-yellow">S.${r.semana}</span>` : ''}</td>
      <td><strong>${fmtMoneda(r.total)}</strong></td>
      <td>${plan}</td>
      <td>${anulado ? '<span class="badge badge-red">Anulado</span>' : '<span class="badge badge-green">Emitido</span>'}</td>
      <td class="actions">
        <button class="btn btn-sm btn-secondary" onclick="pdfRecibo(${r.id_recibo})">📄 PDF</button>
        ${bloqueado ? '' : `<button class="btn btn-sm btn-secondary" onclick="abrirModalRecibo(${r.id_recibo})">✏️</button>
        <button class="btn btn-sm btn-danger" onclick="anularRecibo(${r.id_recibo})">Anular</button>`}
      </td></tr>`;
  });
  h += '</tbody></table>';
  wrap.innerHTML = h;
  renderPaginacion('recibos', pag, 'paginaRecibos');
}

// ── Crear / editar ───────────────────────────────────────
async function cargarEmpleadosRecibo() {
  if (recibosEmpleados.length) return;
  const r = await api('controllers/RecibosController.php?action=empleados');
  if (r.ok) recibosEmpleados = r.data.data;
}

function opcionesConceptoRecibo(sel) {
  return Object.entries(RECIBO_CONCEPTOS).map(([k, v]) =>
    `<option value="${k}" ${k === sel ? 'selected' : ''}>${v.label}</option>`).join('');
}

function agregarLineaRecibo(l = {}) {
  const wrap = document.getElementById('recLineasWrap');
  if (wrap.children.length >= 5) { toast('Máximo 5 líneas por recibo.', 'warn'); return; }
  const div = document.createElement('div');
  div.className = 'rec-linea';
  div.style.cssText = 'display:grid;grid-template-columns:190px 1fr 120px 32px;gap:8px;margin-bottom:6px;align-items:center';
  div.innerHTML = `
    <select class="rl-tipo" style="padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px">${opcionesConceptoRecibo(l.concepto_tipo || 'viaticos')}</select>
    <input type="text" class="rl-desc" placeholder="Descripción (Ej: Viáticos de la semana del ...)" value="${escRec(l.descripcion || '')}" maxlength="255">
    <input type="number" class="rl-monto" placeholder="0.00" min="0" step="0.01" value="${l.monto ?? ''}" oninput="calcTotalesRecibo()">
    <button type="button" class="btn btn-sm btn-danger" onclick="this.parentElement.remove();calcTotalesRecibo()">✕</button>`;
  wrap.appendChild(div);
  calcTotalesRecibo();
}

function calcTotalesRecibo() {
  let sub = 0;
  document.querySelectorAll('#recLineasWrap .rl-monto').forEach(i => sub += parseFloat(i.value) || 0);
  const ret = parseFloat(document.getElementById('recRetenciones').value) || 0;
  document.getElementById('recSubtotalTxt').textContent = fmtMoneda(sub);
  document.getElementById('recTotalTxt').textContent = fmtMoneda(sub - ret);
  const btn = document.getElementById('btnAddLineaRecibo');
  if (btn) btn.style.display = document.querySelectorAll('#recLineasWrap .rec-linea').length >= 5 ? 'none' : '';
}

function alSeleccionarEmpleadoRecibo() {
  const e = recibosEmpleados.find(x => String(x.id_empleado) === String(document.getElementById('recEmpleado').value));
  document.getElementById('recRtn').value = e?.identidad || '';
  document.getElementById('recDireccion').value = e?.direccion || '';
}

async function abrirModalRecibo(id = 0) {
  await cargarEmpleadosRecibo();
  document.getElementById('errRecibo').style.display = 'none';
  document.getElementById('recEmpleado').innerHTML = '<option value="">— Seleccionar empleado —</option>' +
    recibosEmpleados.map(e => `<option value="${e.id_empleado}">${escRec(e.nombre)}</option>`).join('');
  document.getElementById('recLineasWrap').innerHTML = '';
  document.getElementById('recId').value = id || '';
  document.getElementById('tituloRecibo').textContent = id ? 'Editar Recibo' : 'Nuevo Recibo';
  if (id) {
    const r = await api('controllers/RecibosController.php?action=obtener&id=' + id);
    if (!r.ok) { toast(r.data.error || 'Error al cargar el recibo.', 'error'); return; }
    const x = r.data.data;
    document.getElementById('recEmpleado').value = x.empleado_id;
    document.getElementById('recFecha').value = x.fecha;
    document.getElementById('recSemana').value = x.semana || '';
    document.getElementById('recRtn').value = x.rtn || '';
    document.getElementById('recDireccion').value = x.direccion || '';
    document.getElementById('recObs').value = x.observaciones || '';
    document.getElementById('recRetenciones').value = x.retenciones || 0;
    x.detalle.forEach(l => agregarLineaRecibo(l));
  } else {
    document.getElementById('recEmpleado').value = '';
    document.getElementById('recFecha').value = new Date().toLocaleDateString('en-CA');
    document.getElementById('recSemana').value = '';
    document.getElementById('recRtn').value = '';
    document.getElementById('recDireccion').value = '';
    document.getElementById('recObs').value = '';
    document.getElementById('recRetenciones').value = 0;
    agregarLineaRecibo();
  }
  calcTotalesRecibo();
  abrirModal('modalRecibo');
}

async function guardarRecibo() {
  const err = document.getElementById('errRecibo');
  err.style.display = 'none';
  const id = document.getElementById('recId').value;
  const detalle = [...document.querySelectorAll('#recLineasWrap .rec-linea')].map(div => ({
    concepto_tipo: div.querySelector('.rl-tipo').value,
    descripcion:   div.querySelector('.rl-desc').value.trim(),
    monto:         parseFloat(div.querySelector('.rl-monto').value) || 0,
  }));
  const body = {
    id: +id || 0,
    empleado_id: +document.getElementById('recEmpleado').value || 0,
    fecha: document.getElementById('recFecha').value,
    semana: +document.getElementById('recSemana').value || 0,
    rtn: document.getElementById('recRtn').value.trim(),
    direccion: document.getElementById('recDireccion').value.trim(),
    observaciones: document.getElementById('recObs').value.trim(),
    retenciones: parseFloat(document.getElementById('recRetenciones').value) || 0,
    detalle,
  };
  const r = await api('controllers/RecibosController.php?action=' + (id ? 'editar' : 'crear'), { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
  cerrarModal('modalRecibo');
  toast(id ? 'Recibo actualizado.' : 'Recibo creado.');
  await cargarRecibos();
  if (!id && r.data.id) pdfRecibo(r.data.id);
}

async function anularRecibo(id) {
  if (!await confirmDialog('¿Anular este recibo? El número quedará usado como ANULADO.')) return;
  const r = await api('controllers/RecibosController.php?action=anular', { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data.error || 'No se pudo anular.', 'error'); return; }
  toast('Recibo anulado.');
  cargarRecibos();
}

// ── Serie ────────────────────────────────────────────────
async function abrirModalSerieRecibos() {
  document.getElementById('errSerieRecibos').style.display = 'none';
  const r = await api('controllers/RecibosController.php?action=serie');
  const s = r.ok ? r.data.data : null;
  document.getElementById('serPrefijo').value     = s?.prefijo || '000-001-01';
  document.getElementById('serInicio').value      = s?.rango_inicio || 1;
  document.getElementById('serFin').value         = s?.rango_fin || 100000;
  document.getElementById('serActual').value      = s?.correlativo_actual ?? 0;
  document.getElementById('serFechaLimite').value = s?.fecha_limite_emision || '';
  document.getElementById('serSiguienteTxt').textContent = s
    ? `Próximo número: ${s.prefijo}-${String(Math.max(+s.correlativo_actual + 1, +s.rango_inicio)).padStart(8, '0')}` : '';
  abrirModal('modalSerieRecibos');
}

async function guardarSerieRecibos() {
  const err = document.getElementById('errSerieRecibos');
  err.style.display = 'none';
  const body = {
    prefijo: document.getElementById('serPrefijo').value.trim(),
    rango_inicio: +document.getElementById('serInicio').value,
    rango_fin: +document.getElementById('serFin').value,
    correlativo_actual: +document.getElementById('serActual').value,
    fecha_limite_emision: document.getElementById('serFechaLimite').value,
  };
  const r = await api('controllers/RecibosController.php?action=serie_guardar', { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { err.textContent = r.data.error || 'Error al guardar.'; err.style.display = 'block'; return; }
  cerrarModal('modalSerieRecibos');
  toast('Serie guardada.');
}

// ── PDF (formato del recibo VAMER) ───────────────────────
async function pdfRecibo(id) {
  const r = await api('controllers/RecibosController.php?action=obtener&id=' + id);
  if (!r.ok) { toast(r.data.error || 'Error al generar el PDF.', 'error'); return; }
  const x = r.data.data;
  const logo = new URL('assets/img/VAMER.png', location.href).href;
  const fmt = n => parseFloat(n || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const [fy, fm, fd] = x.fecha.split('-');
  const partes = x.numero.split('-');
  const corr = partes.pop();
  const prefijo = partes.join('-');

  let filas = '';
  for (let i = 0; i < 5; i++) {
    const l = x.detalle[i];
    filas += l
      ? `<tr><td class="c">${RECIBO_CONCEPTOS[l.concepto_tipo]?.label || ''}${l.concepto_tipo === 'viaticos' && x.semana ? `<br><span style="font-weight:400;font-size:9px">SEMANA ${x.semana}</span>` : ''}</td><td>${escRec(l.descripcion)}</td><td class="n">${fmt(l.monto)}</td><td class="n">${fmt(l.monto)}</td></tr>`
      : '<tr><td>&nbsp;</td><td></td><td></td><td></td></tr>';
  }
  const anulado = x.estado === 'anulado';

  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Recibo ${escRec(x.numero)}</title>
  <style>
    @page{size:letter;margin:12mm}
    *{box-sizing:border-box}
    body{font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#111;margin:0;position:relative}
    .top{display:flex;justify-content:space-between;align-items:flex-start;gap:12px}
    .emp{display:flex;gap:10px;align-items:flex-start;flex:1}
    .emp img{width:78px;height:78px;object-fit:contain}
    .emp h1{font-size:13px;margin:0 0 3px}
    .emp p{margin:1px 0;font-size:10px}
    .rec{width:215px;text-align:right}
    .rec h2{margin:0;font-size:22px;letter-spacing:1px}
    .rec .no{font-size:12px;font-weight:700;margin:4px 0 6px}
    .rec .no span{color:#c00000}
    .fecha{display:inline-block;border:1.5px solid #111;border-radius:4px;text-align:center}
    .fecha table{border-collapse:collapse}
    .fecha td{padding:2px 12px;text-align:center;border-left:1px solid #111}
    .fecha td:first-child{border-left:0}
    .fecha .h{font-size:8px;font-weight:700;border-bottom:1px solid #111}
    .box{display:flex;border:1.5px solid #111;border-radius:4px;margin-top:6px;min-height:24px}
    .box b{width:90px;padding:5px 8px;border-right:1.5px solid #111;font-size:10px}
    .box div{padding:5px 8px;flex:1}
    table.det{width:100%;border-collapse:collapse;margin-top:10px}
    table.det th{background:#111;color:#fff;font-size:10px;padding:6px;text-align:center}
    table.det td{border:1px solid #111;padding:7px 6px;height:30px;font-size:10.5px}
    table.det td.c{text-align:center;font-weight:700}
    table.det td.n{text-align:right;width:95px}
    .letras{border:1.5px solid #111;border-radius:4px;padding:6px 8px;margin-top:8px;font-size:11px}
    .bottom{display:flex;justify-content:space-between;gap:16px;margin-top:10px;align-items:flex-start}
    .auth{font-size:10px;line-height:1.7}
    .tot{width:250px;background:#111;color:#fff;border-radius:4px;padding:8px 12px}
    .tot div{display:flex;justify-content:space-between;padding:3px 0;font-size:11px}
    .tot .g{border-top:1px solid #888;margin-top:3px;padding-top:6px;font-size:13px;font-weight:700}
    .firmas{display:flex;justify-content:space-around;margin-top:70px}
    .firmas div{width:40%;border-top:1.5px solid #111;text-align:center;padding-top:5px;font-weight:700;font-size:10px}
    .anulado{position:absolute;top:300px;left:90px;font-size:90px;color:rgba(200,0,0,.25);transform:rotate(-20deg);font-weight:700}
  </style></head><body>
  ${anulado ? '<div class="anulado">ANULADO</div>' : ''}
  <div class="top">
    <div class="emp">
      <img src="${logo}" alt="VAMER" onerror="this.style.display='none'">
      <div>
        <h1>${RECIBO_EMPRESA.nombre}</h1>
        <p>${RECIBO_EMPRESA.direccion}</p>
        <p>${RECIBO_EMPRESA.contacto}</p>
        <p><b>RTN: ${RECIBO_EMPRESA.rtn}</b></p>
      </div>
    </div>
    <div class="rec">
      <h2>RECIBO</h2>
      <div class="no">No. ${escRec(prefijo)}-<span>${escRec(corr)}</span></div>
      <div class="fecha"><table><tr><td class="h">DIA</td><td class="h">MES</td><td class="h">AÑO</td></tr>
        <tr><td>${fd}</td><td>${fm}</td><td>${fy}</td></tr></table></div>
    </div>
  </div>
  <div class="box"><b>Empleado:</b><div>${escRec(x.empleado_nombre)}</div></div>
  <div class="box"><b>RTN:</b><div>${escRec(x.rtn || '')}</div></div>
  <div class="box"><b>Dirección:</b><div>${escRec(x.direccion || '')}</div></div>
  <table class="det"><thead><tr><th style="width:130px">CONCEPTO</th><th>DESCRIPCIÓN</th><th>P. UNITARIO</th><th>TOTAL</th></tr></thead>
    <tbody>${filas}</tbody></table>
  <div class="letras"><b>Cantidad en letras:</b> ${numeroALetrasRecibo(x.total)}</div>
  <div class="bottom">
    <div class="auth">
      <div><b>Fecha Límite de Emisión:</b> ${fechaLimiteRecibo(x.fecha_limite_emision)}</div>
      <div><b>Rango Autorizado:</b> ${escRec(x.rango_autorizado || '')}</div>
    </div>
    <div class="tot">
      <div><span>SUBTOTAL</span><span>L. ${fmt(x.subtotal)}</span></div>
      <div><span>RETENCIONES</span><span>L. ${fmt(x.retenciones)}</span></div>
      <div class="g"><span>TOTAL</span><span>L. ${fmt(x.total)}</span></div>
    </div>
  </div>
  <div class="firmas"><div>ENTREGUÉ CONFORME</div><div>RECIBI CONFORME</div></div>
  <script>window.onload=()=>setTimeout(()=>window.print(),300)<\/script>
  </body></html>`;
  const w = window.open('', '_blank');
  if (!w) { toast('Permite las ventanas emergentes para ver el PDF.', 'warn'); return; }
  w.document.write(html);
  w.document.close();
}
