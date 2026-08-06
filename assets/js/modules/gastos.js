// ══════════════════════════════════════════════════════════
// gastos.js — Gastos DMC / SAR Honduras
// Extraído de dashboard.js líneas 4926-5219
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════
//  MÓDULO GASTOS DMC / SAR HONDURAS
// ══════════════════════════════════════════════════════════════
let gastosData=[];
const MESES_GASTOS=['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
const CATS_GASTOS={materiales:'Materiales',servicios:'Servicios',alquiler:'Alquiler',combustible:'Combustible',publicidad:'Publicidad',mantenimiento:'Mantenimiento',sueldos:'Sueldos',honorarios:'Honorarios',utilities:'Utilities',otros:'Otros'};
function initFiltrosGastos(){const y=new Date().getFullYear();['filtroGastoAnio','gastoAnio'].forEach(id=>{const el=document.getElementById(id);if(!el)return;el.innerHTML='';for(let i=y+1;i>=y-3;i--)el.innerHTML+=`<option value="${i}"${i===y?' selected':''}>${i}</option>`;});const m=new Date().getMonth()+1;const mesEl=document.getElementById('filtroGastoMes');if(mesEl)mesEl.value=m;}
async function cargarGastos() {
  const anio   = document.getElementById('filtroGastoAnio')?.value    || '';
  const mes    = document.getElementById('filtroGastoMes')?.value     || '';
  const estado = document.getElementById('filtroGastoEstado')?.value  || '';
  const cat    = document.getElementById('filtroGastoCategoria')?.value|| '';
  const r = await api(`controllers/GastosController.php?action=listar&anio=${anio}&mes=${mes}&estado=${estado}&categoria=${cat}`);
  if (!r.ok) { toast('Error al cargar gastos.', 'error'); return; }
  gastosData = r.data.data || []; // items ya vienen incluidos desde el backend
  filtrarGastosLocal();
  if (mes && anio) cargarResumenGastos(mes, anio);
}

function filtrarGastosLocal() {
  const buscar = (document.getElementById('buscarGasto')?.value || '').toLowerCase().trim();
  const cat    = document.getElementById('filtroGastoCategoria')?.value || '';
  let filtrados = gastosData;
  if (cat) filtrados = filtrados.filter(g => g.categoria === cat);
  if (buscar) {
    filtrados = filtrados.filter(g =>
      (g.nombre_proveedor||'').toLowerCase().includes(buscar) ||
      (g.numero_factura||'').toLowerCase().includes(buscar) ||
      (g.rtn_proveedor||'').toLowerCase().includes(buscar)
    );
  }
  paginaActual['gastos'] = 1;
  renderTablaGastos(filtrados);
}

function renderTablaGastos(rows) {
  const wrap = document.getElementById('tablaGastosWrap');
  if (!wrap) return;
  wrap.style.overflowX = 'auto';
  if (!rows.length) { wrap.innerHTML = '<p class="empty-state">Sin registros.</p>'; return; }
  const pag = paginar('gastos', rows);
  const fL  = n => 'L. ' + Number(n||0).toLocaleString('es-HN', {minimumFractionDigits:2});
  let h = `<table style="min-width:1100px"><thead><tr>
    <th>Fecha</th><th>Proveedor / RTN</th><th>N° Documento</th>
    <th>Categoría</th><th>Descripción / Ítems</th>
    <th style="text-align:right">Subtotal</th><th style="text-align:right">ISV</th>
    <th style="text-align:right">Total</th><th>Ded.</th><th>Estado</th><th style="width:80px">Acciones</th>
  </tr></thead><tbody>`;
  pag.slice.forEach(g => {
    const eb  = g.estado==='declarado' ? '<span class="badge badge-green">Declarado</span>' : '<span class="badge badge-yellow">Pendiente</span>';
    const acc = g.estado==='declarado' ? '<span style="font-size:11px;color:var(--muted)">🔒</span>'
      : `<div class="td-actions" style="display:flex;gap:4px;flex-wrap:nowrap;white-space:nowrap"><button class="btn btn-sm btn-secondary" style="padding:4px 8px" onclick="editarGasto(${g.id_gasto})">✏️</button><button class="btn btn-sm btn-danger" style="padding:4px 8px" onclick="eliminarGasto(${g.id_gasto})">🗑️</button></div>`;
    const tieneItems = g.items && g.items.length > 1;
    let itemsHTML = '';
    if (tieneItems) {
      itemsHTML = `<table style="width:100%;font-size:11px;border-collapse:collapse;margin-top:4px">
        <thead><tr>
          <th style="text-align:left;padding:2px 6px;color:var(--muted)">Descripción</th>
          <th style="text-align:right;padding:2px 6px;color:var(--muted)">Cant.</th>
          <th style="text-align:right;padding:2px 6px;color:var(--muted)">Total</th>
        </tr></thead><tbody>`;
      g.items.forEach(it => {
        const cant2 = parseFloat(it.cantidad)||1;
        const totalItem = Math.round(cant2 * (parseFloat(it.monto)||0) * 100) / 100;
        itemsHTML += `<tr>
          <td style="padding:2px 6px">${it.descripcion}</td>
          <td style="text-align:right;padding:2px 6px">${cant2}</td>
          <td style="text-align:right;padding:2px 6px;font-weight:600">${fL(it.total_item||totalItem)}</td>
        </tr>`;
      });
      itemsHTML += '</tbody></table>';
    } else {
      itemsHTML = `<span style="font-size:13px">${g.descripcion}</span>`;
    }
    h += `<tr>
      <td style="white-space:nowrap;vertical-align:top">${g.fecha}</td>
      <td style="vertical-align:top"><strong>${g.nombre_proveedor}</strong><br><code style="font-size:10px;color:var(--muted)">${g.rtn_proveedor||'—'}</code></td>
      <td style="vertical-align:top;font-size:12px;white-space:nowrap">${g.numero_factura||'—'}</td>
      <td style="vertical-align:top"><span class="badge badge-gray">${CATS_GASTOS[g.categoria]||g.categoria}</span></td>
      <td style="min-width:260px">${itemsHTML}</td>
      <td style="text-align:right;vertical-align:top">${fL(g.subtotal)}</td>
      <td style="text-align:right;vertical-align:top">${g.tasa_isv}%/${fL(g.isv)}</td>
      <td style="text-align:right;vertical-align:top;font-weight:700;color:#4caf50">${fL(g.total)}</td>
      <td style="text-align:center;vertical-align:top">${g.deducible?'✅':'❌'}</td>
      <td style="vertical-align:top">${eb}</td>
      <td style="vertical-align:top">${acc}</td>
    </tr>`;
  });
  h += '</tbody></table>';
  wrap.innerHTML = h;
  renderPaginacion('gastos', pag, 'paginaGastos');
}

let gastoItems = [];

function abrirModalGasto() {
  document.getElementById('modalGastoTitulo').textContent = '🧾 Nuevo Gasto';
  ['gastoId','gastoNumDoc','gastoRTN','gastoProveedor','gastoObs'].forEach(id => {
    const e = document.getElementById(id); if (e) e.value = '';
  });
  document.getElementById('gastoFecha').value    = new Date().toISOString().split('T')[0];
  document.getElementById('gastoTipoDoc').value  = 'factura';
  document.getElementById('gastoCategoria').value= 'servicios';
  document.getElementById('gastoTasaISV').value  = '15';
  document.getElementById('gastoDeducible').checked = true;
  document.getElementById('gastoEstado').value   = 'pendiente';
  document.getElementById('errGasto').style.display = 'none';
  document.getElementById('rtnMsg').textContent  = '';
  const mes  = document.getElementById('filtroGastoMes')?.value  || (new Date().getMonth() + 1);
  const anio = document.getElementById('filtroGastoAnio')?.value || new Date().getFullYear();
  document.getElementById('gastoMes').value  = mes;
  document.getElementById('gastoAnio').value = anio;
  gastoItems = [];
  renderGastoItems();
  agregarItemGasto();
  abrirModal('modalGasto');
}

function validarRTN() {
  const rtnEl = document.getElementById('gastoRTN');
  const msgEl = document.getElementById('rtnMsg');
  if (!rtnEl || !msgEl) return;
  const rtn = (rtnEl.value || '').replace(/\D/g, '');
  if (!rtn) { msgEl.textContent = ''; msgEl.style.color = 'var(--muted)'; return; }
  if ([13, 14].includes(rtn.length)) {
    msgEl.textContent = '✓ RTN válido';
    msgEl.style.color = '#4caf50';
  } else {
    msgEl.textContent = 'RTN debe tener 13 o 14 dígitos';
    msgEl.style.color = 'var(--danger)';
  }
}

async function editarGasto(id) {
  const r = await api(`controllers/GastosController.php?action=obtener&id=${id}`);
  if (!r.ok) { toast('Error.', 'error'); return; }
  const g = r.data.data;
  if (g.estado === 'declarado') { toast('Gasto declarado: no puede editarse.', 'error'); return; }
  document.getElementById('modalGastoTitulo').textContent = '✏️ Editar Gasto';
  document.getElementById('gastoId').value       = g.id_gasto;
  document.getElementById('gastoFecha').value    = g.fecha;
  document.getElementById('gastoTipoDoc').value  = g.tipo_documento;
  document.getElementById('gastoNumDoc').value   = g.numero_factura || '';
  document.getElementById('gastoCategoria').value= g.categoria;
  document.getElementById('gastoRTN').value      = g.rtn_proveedor || '';
  document.getElementById('gastoProveedor').value= g.nombre_proveedor;
  document.getElementById('gastoTasaISV').value  = String(g.tasa_isv);
  document.getElementById('gastoDeducible').checked = !!+g.deducible;
  document.getElementById('gastoEstado').value   = g.estado;
  document.getElementById('gastoObs').value      = g.observaciones || '';
  document.getElementById('gastoMes').value      = g.mes_declaracion;
  document.getElementById('gastoAnio').value     = g.anio_declaracion;
  document.getElementById('errGasto').style.display = 'none';
  document.getElementById('rtnMsg').textContent  = '';
  gastoItems = (g.items && g.items.length)
    ? g.items.map(it => ({ descripcion: it.descripcion, cantidad: parseFloat(it.cantidad)||1, monto: parseFloat(it.monto) }))
    : [{ descripcion: g.descripcion, cantidad: 1, monto: parseFloat(g.subtotal) }];
  renderGastoItems();
  calcularGastoISV();
  validarRTN();
  abrirModal('modalGasto');
}

function agregarItemGasto(desc = '', cant = 1, monto = '') {
  gastoItems.push({ descripcion: desc, cantidad: cant, monto: monto === '' ? '' : parseFloat(monto) });
  renderGastoItems();
}

function quitarItemGasto(i) {
  gastoItems.splice(i, 1);
  renderGastoItems();
}

function renderGastoItems() {
  const tbody = document.getElementById('gastoItemsBody');
  if (!tbody) return;
  if (!gastoItems.length) {
    tbody.innerHTML = '<tr><td colspan="5" style="padding:10px;text-align:center;color:var(--muted);font-size:12px">Sin ítems. Haz clic en "+ Agregar ítem".</td></tr>';
    calcularGastoISV();
    return;
  }
  tbody.innerHTML = gastoItems.map((it, i) => {
    const cant = parseFloat(it.cantidad) || 1;
    const monto = parseFloat(it.monto) || 0;
    const total = Math.round(cant * monto * 100) / 100;
    return `<tr id="gastoFila_${i}">
      <td style="padding:5px 8px">
        <input type="text" value="${(it.descripcion||'').replace(/"/g,'&quot;')}" placeholder="Descripción del ítem"
          style="width:100%;padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:13px"
          oninput="gastoItems[${i}].descripcion=this.value">
      </td>
      <td style="padding:5px 8px">
        <input type="text" inputmode="decimal" value="${it.cantidad||1}"
          style="width:60px;padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:13px;text-align:right"
          oninput="gastoItems[${i}].cantidad=parseFloat(this.value.replace(',','.'))||1;actualizarTotalFilaGasto(${i})"
          onblur="this.value=gastoItems[${i}].cantidad">
      </td>
      <td style="padding:5px 8px">
        <input type="text" inputmode="decimal" value="${it.monto===''?'':it.monto}" placeholder="0.00"
          style="width:100px;padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:13px;text-align:right"
          oninput="gastoItems[${i}].monto=parseFloat(this.value.replace(',','.'))||0;actualizarTotalFilaGasto(${i})"
          onblur="this.value=gastoItems[${i}].monto||''">
      </td>
      <td id="gastoTotal_${i}" style="padding:5px 8px;text-align:right;font-weight:600;color:var(--accent);font-size:13px">L. ${total.toLocaleString('es-HN',{minimumFractionDigits:2})}</td>
      <td style="padding:5px 6px;text-align:center">
        <button type="button" style="background:none;border:none;color:var(--danger);cursor:pointer;font-size:16px;line-height:1" onclick="quitarItemGasto(${i})">✕</button>
      </td>
    </tr>`;
  }).join('');
  calcularGastoISV();
}

function actualizarTotalFilaGasto(i) {
  const cant  = parseFloat(gastoItems[i].cantidad) || 1;
  const monto = parseFloat(gastoItems[i].monto)    || 0;
  const total = Math.round(cant * monto * 100) / 100;
  const cel   = document.getElementById('gastoTotal_' + i);
  if (cel) cel.textContent = 'L. ' + total.toLocaleString('es-HN', {minimumFractionDigits:2});
  calcularGastoISV();
}

function calcularGastoISV() {
  const subtotal = gastoItems.reduce((a, it) => a + Math.round((parseFloat(it.cantidad)||1) * (parseFloat(it.monto)||0) * 100) / 100, 0);
  const tasa     = parseInt(document.getElementById('gastoTasaISV')?.value || 15);
  const isv      = Math.round(subtotal * tasa * 100) / 10000;
  const total    = subtotal + isv;
  const fL       = n => 'L. ' + n.toLocaleString('es-HN', {minimumFractionDigits: 2});
  const smEl = document.getElementById('gastoSubtotalMostrar');
  const ivEl = document.getElementById('gastoISVMostrar');
  const ttEl = document.getElementById('gastoTotalMostrar');
  if (smEl) smEl.textContent = fL(subtotal);
  if (ivEl) ivEl.textContent = fL(isv);
  if (ttEl) ttEl.textContent = fL(total);
}

async function guardarGasto() {
  const errEl = document.getElementById('errGasto');
  errEl.style.display = 'none';
  const id  = document.getElementById('gastoId').value;
  const rtn = (document.getElementById('gastoRTN').value || '').replace(/\D/g, '');
  if (!document.getElementById('gastoFecha').value)           { errEl.textContent='Fecha requerida.';     errEl.style.display='block'; return; }
  if (!document.getElementById('gastoProveedor').value.trim()){ errEl.textContent='Proveedor requerido.'; errEl.style.display='block'; return; }
  const itemsValidos = gastoItems.filter(it => it.descripcion?.trim() && parseFloat(it.monto) > 0);
  if (!itemsValidos.length) { errEl.textContent='Agrega al menos un ítem con descripción y monto.'; errEl.style.display='block'; return; }
  if (rtn && ![13,14].includes(rtn.length)) { errEl.textContent='RTN inválido.'; errEl.style.display='block'; return; }
  const body = {
    id: id ? +id : undefined,
    fecha:           document.getElementById('gastoFecha').value,
    tipo_documento:  document.getElementById('gastoTipoDoc').value,
    numero_factura:  document.getElementById('gastoNumDoc').value.trim() || null,
    categoria:       document.getElementById('gastoCategoria').value,
    rtn_proveedor:   rtn || null,
    nombre_proveedor:document.getElementById('gastoProveedor').value.trim(),
    tasa_isv:        parseInt(document.getElementById('gastoTasaISV').value) || 0,
    deducible:       document.getElementById('gastoDeducible').checked,
    mes_declaracion: parseInt(document.getElementById('gastoMes').value),
    anio_declaracion:parseInt(document.getElementById('gastoAnio').value),
    estado:          document.getElementById('gastoEstado').value,
    observaciones:   document.getElementById('gastoObs').value.trim() || null,
    items:           itemsValidos.map(it => ({ descripcion: it.descripcion.trim(), cantidad: parseFloat(it.cantidad)||1, monto: parseFloat(it.monto) })),
  };
  const btn = document.getElementById('btnGuardarGasto');
  if (btn) btn.disabled = true;
  const r = await api(`controllers/GastosController.php?action=${id?'actualizar':'crear'}`, { method:'POST', body:JSON.stringify(body) });
  if (btn) btn.disabled = false;
  if (r.ok) { cerrarModal('modalGasto'); toast(id?'Gasto actualizado.':'Gasto registrado.','success'); cargarGastos(); }
  else { errEl.textContent = r.data?.error || 'Error al guardar.'; errEl.style.display = 'block'; }
}

async function eliminarGasto(id){if(!await confirmDialog('¿Eliminar este registro?'))return;const r=await api('controllers/GastosController.php?action=eliminar',{method:'POST',body:JSON.stringify({id})});if(r.ok){toast('Gasto eliminado.','success');cargarGastos();}else toast(r.data?.error||'Error.','error');}
async function cargarResumenGastos(mes, anio) {
  const cont = document.getElementById('gastosResumen');
  const btnDiv = document.getElementById('gastosBtnDeclarar');
  if (!cont) return;
  const r = await api(`controllers/GastosController.php?action=resumen&mes=${mes}&anio=${anio}`);
  if (!r.ok) { cont.innerHTML = ''; if (btnDiv) btnDiv.style.display = 'none'; return; }
  const d = r.data.data || {};
  const fL = n => 'L. ' + Number(n||0).toLocaleString('es-HN', {minimumFractionDigits:2});
  cont.innerHTML = `
    <div class="kpi-card"><div class="kpi-label">Registros</div><div class="kpi-val">${d.total_registros||0}</div></div>
    <div class="kpi-card"><div class="kpi-label">Subtotal s/ISV</div><div class="kpi-val" style="color:#4caf50">${fL(d.total_subtotal)}</div></div>
    <div class="kpi-card"><div class="kpi-label">ISV Total</div><div class="kpi-val">${fL(d.total_isv)}</div></div>
    <div class="kpi-card"><div class="kpi-label">Total General</div><div class="kpi-val" style="color:#4caf50">${fL(d.total_general)}</div></div>
    <div class="kpi-card"><div class="kpi-label">Deducible ISR</div><div class="kpi-val" style="color:#2196f3">${fL(d.total_deducible)}</div></div>
    <div class="kpi-card"><div class="kpi-label">No Deducible</div><div class="kpi-val" style="color:var(--danger)">${fL(d.total_no_deducible)}</div></div>
    <div class="kpi-card"><div class="kpi-label">Pendiente SAR</div><div class="kpi-val" style="color:orange">${fL(d.total_pendiente)}</div></div>
    <div class="kpi-card"><div class="kpi-label">Declarado</div><div class="kpi-val" style="color:#4caf50">${fL(d.total_declarado)}</div></div>
  `;
  if (btnDiv) btnDiv.style.display = (parseFloat(d.total_pendiente) > 0) ? '' : 'none';
}

async function marcarPeriodoDeclarado(){const mes=parseInt(document.getElementById('filtroGastoMes')?.value||0);const anio=parseInt(document.getElementById('filtroGastoAnio')?.value||0);if(!mes||!anio){toast('Selecciona mes y año.','error');return;}if(!await confirmDialog(`¿Marcar todos los gastos pendientes de ${MESES_GASTOS[mes]} ${anio} como declarados?

No podrán editarse ni eliminarse después.`))return;const r=await api('controllers/GastosController.php?action=declarar_mes',{method:'POST',body:JSON.stringify({mes,anio})});if(r.ok){toast(`${r.data.actualizados} gasto(s) declarados.`,'success');cargarGastos();}else toast(r.data?.error||'Error.','error');}
