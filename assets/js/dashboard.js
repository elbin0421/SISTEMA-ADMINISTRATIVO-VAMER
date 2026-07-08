// ── GLOBALES ─────────────────────────────────────────────────

// ── MAPA MÓDULO → GRUPO ──────────────────────────────────────
const MODULE_GROUP = {
  usuarios: 'admin', roles: 'admin',
  clientes: 'operaciones', inventario: 'operaciones', compras: 'operaciones',
  proveedores: 'operaciones', ordenes: 'operaciones',
  cotizaciones: 'comercial', facturacion: 'comercial', cai: 'comercial',
  libro_ventas: 'comercial', pagos: 'comercial',
  planillas: 'rrhh',
  reportes: 'analisis',
};

function toggleGrupo(grpId, forceOpen = null) {
  // En modo mini: expandir sidebar completo primero
  if (document.body.classList.contains('sb-mini') && forceOpen !== false) {
    document.body.classList.remove('sb-mini');
  }

  const grp    = document.getElementById('grp-' + grpId);
  const header = grp?.querySelector('.nav-group-header');
  const body   = grp?.querySelector('.nav-group-body');
  if (!grp || !header || !body) return;

  const isOpen = body.classList.contains('open');
  const shouldOpen = forceOpen !== null ? forceOpen : !isOpen;

  if (shouldOpen) {
    body.classList.add('open');
    header.classList.add('open');
  } else {
    body.classList.remove('open');
    header.classList.remove('open');
  }
}

function marcarGrupoActivo(modulo) {
  document.querySelectorAll('.nav-group').forEach(g => g.classList.remove('has-active'));
  const grpId = MODULE_GROUP[modulo];
  if (grpId) {
    const grp = document.getElementById('grp-' + grpId);
    if (grp) {
      grp.classList.add('has-active');
      // Abrir el grupo solo si el sidebar está expandido
      if (!document.body.classList.contains('sb-mini')) {
        toggleGrupo(grpId, true);
      }
    }
  }
}
let materialRapidoCallback = false;
let materialRapidoNombre   = '';
let currentCotId           = null;

// ── AUTH ─────────────────────────────────────────────────────
const token  = localStorage.getItem('sm_token') || '';
const nombre = localStorage.getItem('sm_nombre') || '—';
const rol    = localStorage.getItem('sm_rol')    || '—';
document.getElementById('sidebarNombre').textContent = nombre;
document.getElementById('sidebarRol').textContent    = rol;
if (!token) { window.location.href = 'login.html'; }
fetch('controllers/AuthController.php?action=verificar', { credentials:'include' })
  .then(r => r.json()).then(d => { if (!d.ok) { localStorage.clear(); window.location.href='login.html'; } });

// ── MENÚ MÓVIL ───────────────────────────────────────────────
const sidebar = document.getElementById('sidebar');
// ── SIDEBAR ──────────────────────────────────────────────
function isMobile() { return window.innerWidth <= 768; }

function toggleSidebar() {
  document.body.classList.toggle('sb-mini');
}

document.getElementById('btnMenuToggle').addEventListener('click', toggleSidebar);

// En mobile arranca colapsado
if (isMobile()) document.body.classList.add('sb-mini');

// ── RELOJ ────────────────────────────────────────────────────
function updateClock() {
  const now = new Date();
  document.getElementById('clock').textContent = now.toLocaleDateString('es-HN') + ' ' + now.toLocaleTimeString('es-HN',{hour:'2-digit',minute:'2-digit',second:'2-digit'});
}
updateClock(); setInterval(updateClock, 1000);

// ── NAVEGACIÓN ───────────────────────────────────────────────
const modTitles = { inicio:'Inicio', clientes:'Clientes', vehiculos:'Vehículos', inventario:'Inventario', requisiciones:'Requisiciones de Materiales', compras:'Compras', proveedores:'Proveedores', ordenes:'Órdenes de Trabajo', usuarios:'Usuarios', roles:'Roles y Permisos', cotizaciones:'Cotizaciones', catalogo:'Catálogo de Precios', facturacion:'Facturación', libro_ventas:'Libro de Ventas', vacaciones:'Vacaciones', gastos:'Gastos DMC / SAR Honduras' };
document.querySelectorAll('.nav-item[data-module]').forEach(el => {
  el.addEventListener('click', function() {
    const mod = this.dataset.module;
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.module').forEach(m => m.classList.remove('active'));
    this.classList.add('active');
    document.getElementById('mod-' + mod).classList.add('active');
    document.getElementById('topbarTitle').textContent = modTitles[mod] || mod;
    marcarGrupoActivo(mod);
    // En mobile colapsar al navegar
    if (isMobile()) document.body.classList.add('sb-mini');
    const loaders = {
      clientes: cargarClientes, vehiculos: cargarVehiculos, inventario: cargarInventario, compras: cargarCompras,
      proveedores: cargarProveedores, ordenes: cargarOrdenes, usuarios: cargarUsuarios,
      roles: cargarRoles, cotizaciones: cargarCotizaciones, facturacion: cargarFacturacion,
      catalogo: cargarCatalogo, requisiciones: cargarRequisiciones,
      libro_ventas: () => {},
      pagos:     () => { if (typeof cargarModuloPagos    === 'function') cargarModuloPagos(); },
      planillas: () => { if (typeof cargarModuloPlanillas=== 'function') cargarModuloPlanillas(); },
      vacaciones: () => { if (typeof cargarVacaciones=== 'function') cargarVacaciones(); },
      gastos: () => { initFiltrosGastos(); cargarGastos(); },
      reportes:  () => {},
      cai:       () => cargarModuloCAI(),
    };
    if (loaders[mod]) loaders[mod]();
    if (mod === 'inicio') cargarInicio();
  });
});

// ── LOGOUT ───────────────────────────────────────────────────
document.getElementById('btnLogout').addEventListener('click', async () => {
  await fetch('controllers/AuthController.php?action=logout', { credentials:'include' });
  localStorage.clear(); window.location.href = 'login.html';
});

// ── API ──────────────────────────────────────────────────────
async function api(url, opts = {}) {
  opts.credentials = 'include';
  opts.headers = { 'Content-Type':'application/json', ...(opts.headers||{}) };
  const res = await fetch(url, opts);
  const data = await res.json();
  return { ok: res.ok, status: res.status, data };
}


// ══════════════════════════════════════════════════════════
// SISTEMA DE PAGINACIÓN REUTILIZABLE
// ══════════════════════════════════════════════════════════
const PER_PAGE = 10;
const paginaActual = {};
const datosModulo  = {};

function paginar(modulo, rows) {
  datosModulo[modulo] = rows;
  if (!paginaActual[modulo]) paginaActual[modulo] = 1;
  const total  = rows.length;
  const pages  = Math.max(1, Math.ceil(total / PER_PAGE));
  if (paginaActual[modulo] > pages) paginaActual[modulo] = pages;
  const inicio = (paginaActual[modulo] - 1) * PER_PAGE;
  return {
    slice: rows.slice(inicio, inicio + PER_PAGE),
    total, pages, pagina: paginaActual[modulo],
    desde: total ? inicio + 1 : 0,
    hasta: Math.min(inicio + PER_PAGE, total)
  };
}

function renderPaginacion(modulo, pag, contenedorId) {
  if (pag.pages <= 1 && pag.total === 0) return '';
  const cont = document.getElementById(contenedorId);
  if (!cont) return;
  const info = `<span style="color:var(--muted);font-size:12px">Mostrando ${pag.desde}–${pag.hasta} de ${pag.total}</span>`;
  if (pag.pages <= 1) { cont.innerHTML = `<div style="padding:8px 0">${info}</div>`; return; }
  let btns = '';
  // Anterior
  btns += `<button onclick="irPagina('${modulo}',${pag.pagina-1})" ${pag.pagina===1?'disabled':''} class="btn btn-sm btn-secondary">‹</button>`;
  // Páginas
  for (let i = 1; i <= pag.pages; i++) {
    if (pag.pages > 7 && (i > 2 && i < pag.pagina-1)) { if (i===3) btns+='<span style="color:var(--muted);padding:0 4px">…</span>'; continue; }
    if (pag.pages > 7 && (i > pag.pagina+1 && i < pag.pages-1)) { if (i===pag.pagina+2) btns+='<span style="color:var(--muted);padding:0 4px">…</span>'; continue; }
    btns += `<button onclick="irPagina('${modulo}',${i})" class="btn btn-sm ${i===pag.pagina?'btn-primary':'btn-secondary'}">${i}</button>`;
  }
  // Siguiente
  btns += `<button onclick="irPagina('${modulo}',${pag.pagina+1})" ${pag.pagina===pag.pages?'disabled':''} class="btn btn-sm btn-secondary">›</button>`;
  cont.innerHTML = `<div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;padding:10px 0">${info}<div style="display:flex;gap:4px;flex-wrap:wrap">${btns}</div></div>`;
}

function irPagina(modulo, pagina) {
  const pages = Math.ceil((datosModulo[modulo]||[]).length / PER_PAGE);
  paginaActual[modulo] = Math.max(1, Math.min(pagina, pages));
  const renders = {
    clientes:       () => renderTablaClientes(datosModulo[modulo]),
    vehiculos:      () => renderTablaVehiculos(datosModulo[modulo]),
    vacHistorial:   () => renderTablaVacHistorial(vacHistorialData),
    inventario:     () => renderTablaInventario(datosModulo[modulo]),
    compras:        () => renderTablaCompras(datosModulo[modulo]),
    proveedores:    () => renderTablaProveedores(datosModulo[modulo]),
    ordenes:        () => renderTablaOrdenes(datosModulo[modulo]),
    cotizaciones:   () => renderTablaCotizaciones(datosModulo[modulo]),
    facturacion:    () => renderTablaFacturas(datosModulo[modulo]),
    pagos:          () => renderTablaPagos(datosModulo[modulo]),
    cxc:            () => renderTablaCxC(datosModulo[modulo]),
    empleados:      () => renderTablaEmpleados(datosModulo[modulo]),
    planillas_list: () => renderTablaPlanillas(datosModulo[modulo]),
    reporte:        () => renderReporte({ data: datosModulo[modulo] }),
  };
  if (renders[modulo]) renders[modulo]();
}

// ── PRECIO VENTA AUTO ────────────────────────────────────────
function calcPrecioVenta() {
  const compra = parseFloat(document.getElementById('mPrecioC').value || 0);
  if (compra > 0) {
    const venta = (compra * 1.35).toFixed(2);
    document.getElementById('mPrecioV').value = venta;
  } else {
    document.getElementById('mPrecioV').value = '';
  }
}

// ── RENDER CHECKBOXES TÉCNICOS ───────────────────────────────
function renderCheckboxesTecnicos(wrap, seleccionados = []) {
  if (!tecnicosCache.length) {
    wrap.innerHTML = '<p style="color:var(--muted);font-size:13px">Sin empleados activos registrados.</p>';
    return;
  }
  // Usar div clickeable para evitar problemas de z-index con label
  const container = document.createElement('div');
  tecnicosCache.forEach(t => {
    const isChecked = seleccionados.includes(t.id_empleado);
    const item = document.createElement('div');
    item.style.cssText = 'display:flex;align-items:center;gap:10px;padding:7px 6px;border-radius:6px;cursor:pointer;font-size:13px;transition:background .1s';
    item.innerHTML = `
      <input type="checkbox" class="chkTecnico" value="${t.id_empleado}"
        ${isChecked ? 'checked' : ''}
        style="width:16px;height:16px;accent-color:var(--accent);cursor:pointer;flex-shrink:0">
      <span>${t.nombre}${t.puesto ? ` <small style="color:var(--muted)">(${t.puesto})</small>` : ''}</span>`;
    // Click en cualquier parte del div marca/desmarca
    item.addEventListener('click', function(e) {
      if (e.target.type !== 'checkbox') {
        const cb = this.querySelector('input[type=checkbox]');
        cb.checked = !cb.checked;
      }
      this.style.background = this.querySelector('input').checked ? 'rgba(232,160,32,.12)' : '';
    });
    if (isChecked) item.style.background = 'rgba(232,160,32,.12)';
    container.appendChild(item);
  });
  wrap.innerHTML = '';
  wrap.appendChild(container);
}

// ── TOAST ────────────────────────────────────────────────────
const toastIcons = { success:'✅', error:'❌', info:'ℹ️', warn:'⚠️' };
function toast(msg, type = 'success', dur = 3500) {
  const el = document.createElement('div');
  el.className = `toast toast-${type}`;
  el.innerHTML = `<span class="toast-icon">${toastIcons[type]}</span><span class="toast-msg">${msg}</span><span class="toast-close">✕</span>`;
  el.addEventListener('click', () => rmToast(el));
  document.getElementById('toast-container').appendChild(el);
  setTimeout(() => rmToast(el), dur);
}
function rmToast(el) { if (el.classList.contains('removing')) return; el.classList.add('removing'); setTimeout(() => el.remove(), 250); }

// ── CONFIRM ──────────────────────────────────────────────────
let confirmRes = null;
document.getElementById('confirmOk').addEventListener('click',     () => { closeConfirm(); if (confirmRes) confirmRes(true);  });
document.getElementById('confirmCancel').addEventListener('click', () => { closeConfirm(); if (confirmRes) confirmRes(false); });
function closeConfirm() { document.getElementById('confirmBg').classList.remove('open'); }
function confirmDialog(msg) { document.getElementById('confirmMsg').textContent = msg; document.getElementById('confirmBg').classList.add('open'); return new Promise(r => { confirmRes = r; }); }

// ── HELPERS ──────────────────────────────────────────────────
function cerrarModal(id) { const el = document.getElementById(id); el.classList.remove('open'); el.classList.remove('sobre-modal'); }
function abrirModal(id)  { document.getElementById(id).classList.add('open'); }
function fmtMoneda(n)    { return 'L. ' + parseFloat(n||0).toLocaleString('es-HN', {minimumFractionDigits:2, maximumFractionDigits:2}); }
function badgeEstado(e) {
  const map = { activo:'badge-green', inactivo:'badge-red', borrador:'badge-gray', en_proceso:'badge-yellow', finalizada:'badge-green', facturada:'badge-blue', anulada:'badge-red', pendiente:'badge-yellow', pagada:'badge-green', aprobada:'badge-green', aprobada_cliente:'badge-green', enviada:'badge-blue', rechazada:'badge-red', pendiente_aprobacion:'badge-orange' };
  return `<span class="badge ${map[e]||'badge-gray'}">${e.replace('_',' ')}</span>`;
}

// ── INICIO / KPIs ────────────────────────────────────────────
let _chartIngresos = null;

function navegarModulo(mod) {
  const el = document.querySelector(`.nav-item[data-module="${mod}"]`);
  if (el) el.click();
}

async function cargarInicio() {
  const [rKpi, rGraf] = await Promise.all([
    api('controllers/DashboardController.php?action=kpis'),
    api('controllers/DashboardController.php?action=grafico_ventas'),
  ]);

  if (rKpi.ok) {
    const d = rKpi.data.data;

    // Ventas del día
    const elVD = document.getElementById('kpiVentasDia');
    if (elVD) elVD.textContent = fmtMoneda(d.ventas_dia?.monto || 0);
    const elVDC = document.getElementById('kpiVentasDiaCant');
    if (elVDC) elVDC.textContent = (d.ventas_dia?.cant || 0) + ' facturas';

    // CxC
    const elCxC = document.getElementById('kpiCxC');
    if (elCxC) elCxC.textContent = fmtMoneda(d.cxc?.monto || 0);
    const elCxCC = document.getElementById('kpiCxCCant');
    if (elCxCC) elCxCC.textContent = (d.cxc?.cant || 0) + ' facturas pendientes';

    // OC pendientes de factura
    const elOC = document.getElementById('kpiOCPend');
    if (elOC) elOC.textContent = fmtMoneda(d.oc_pend?.monto || 0);
    const elOCC = document.getElementById('kpiOCPendCant');
    if (elOCC) elOCC.textContent = (d.oc_pend?.cant || 0) + ' cots. sin facturar';

    // OT en proceso
    const elOT = document.getElementById('kpiOTProceso');
    if (elOT) elOT.textContent = d.ot_proceso || 0;

    // Stock bajo mínimo
    const elSB = document.getElementById('kpiStockBajo');
    if (elSB) elSB.textContent = d.stock_bajo || 0;

    // Cotizaciones recientes
    const elCot = document.getElementById('inicioCotizaciones');
    if (elCot) {
      const cots = d.cotizaciones || [];
      if (!cots.length) {
        elCot.innerHTML = '<p style="color:var(--muted);font-size:13px;padding:8px 0">Sin cotizaciones recientes.</p>';
      } else {
        elCot.innerHTML = cots.map(c => `
          <div style="display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--border);font-size:13px">
            <div>
              <div style="font-weight:600;font-family:monospace">${c.numero_cotizacion}</div>
              <div style="color:var(--muted);font-size:11px">${c.cliente} · ${c.fecha}</div>
            </div>
            <div style="text-align:right">
              <div style="font-weight:600;color:var(--accent)">${fmtMoneda(c.total)}</div>
              <div>${badgeEstado(c.estado)}</div>
            </div>
          </div>`).join('');
      }
    }

    // OT recientes
    const elOTR = document.getElementById('otRecientes');
    if (elOTR) {
      const rows = d.ot_recientes || [];
      let h = '<table><thead><tr><th>OT</th><th>Cliente</th><th>Vehículo</th><th>Apertura</th><th>Estado</th></tr></thead><tbody>';
      if (!rows.length) h += '<tr><td colspan="5" class="empty-state">Sin órdenes recientes</td></tr>';
      rows.forEach(o => {
        const veh = [o.marca, o.modelo, o.placa].filter(Boolean).join(' ') || '—';
        h += `<tr>
          <td><strong>${o.numero_orden}</strong></td>
          <td>${o.cliente}</td>
          <td style="font-size:12px;color:var(--muted)">${veh}</td>
          <td style="font-size:12px">${o.fecha_apertura}</td>
          <td>${badgeEstado(o.estado)}</td>
        </tr>`;
      });
      h += '</tbody></table>';
      elOTR.innerHTML = h;
    }
  }

  // Gráfico
  const canvas = document.getElementById('graficoIngresos');
  const loading = document.getElementById('graficoLoading');
  if (canvas && rGraf.ok) {
    if (loading) loading.style.display = 'none';
    if (_chartIngresos) { _chartIngresos.destroy(); _chartIngresos = null; }
    const rows = rGraf.data.data || [];
    const textColor = '#888';
    _chartIngresos = new Chart(canvas, {
      type: 'bar',
      data: {
        labels: rows.map(r => r.label),
        datasets: [{
          label: 'Ingresos (L.)',
          data: rows.map(r => parseFloat(r.total)),
          backgroundColor: 'rgba(232,160,32,0.75)',
          borderColor: 'rgba(232,160,32,1)',
          borderWidth: 2,
          borderRadius: 6,
          hoverBackgroundColor: 'rgba(232,160,32,0.95)',
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: { callbacks: { label: ctx => ' ' + fmtMoneda(ctx.parsed.y) } }
        },
        scales: {
          x: { ticks: { color: textColor, font: { size: 11 } }, grid: { display: false } },
          y: {
            ticks: { color: textColor, font: { size: 11 }, callback: v => 'L.' + (v >= 1000 ? (v/1000).toFixed(0)+'k' : v) },
            grid: { color: 'rgba(128,128,128,.1)' }
          }
        }
      }
    });
    if (!rows.length && loading) { loading.textContent = 'Sin datos de ventas aún.'; loading.style.display = 'flex'; }
  }
}

// ── CLIENTES ─────────────────────────────────────────────────
let clientesData = [];

async function cargarClientes() {
  document.getElementById('tablaClientes').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoCliente').value;
  const r = await api('controllers/ClientesController.php?action=listar&estado=' + estado);
  if (!r.ok) { document.getElementById('tablaClientes').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  clientesData = r.data.data;
  document.getElementById('buscarCliente').value = '';
  renderTablaClientes(clientesData);
}

function filtrarClientes() {
  const q = document.getElementById('buscarCliente').value.toLowerCase().trim();
  paginaActual['clientes'] = 1;
  if (!q) { renderTablaClientes(clientesData); return; }
  const filtrados = clientesData.filter(c =>
    c.nombre.toLowerCase().includes(q) ||
    (c.rtn    && c.rtn.toLowerCase().includes(q)) ||
    (c.telefono && c.telefono.includes(q)) ||
    (c.correo && c.correo.toLowerCase().includes(q))
  );
  renderTablaClientes(filtrados);
}

function renderTablaClientes(rows) {
  const estado = document.getElementById('filtroEstadoCliente').value;
  const esInactivo = estado === 'inactivo';
  const pag = paginar('clientes', rows);
  let h = '<table><thead><tr><th>#</th><th>Nombre</th><th>Tipo</th><th>RTN</th><th>Teléfono</th><th>Correo</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="7" class="empty-state">Sin clientes</td></tr>';
  pag.slice.forEach(c => {
    const accionEstado = esInactivo
      ? `<button class="btn btn-sm btn-success" onclick="cambiarEstadoCliente(${c.id_cliente},'activo')">Reactivar</button>`
      : `<button class="btn btn-sm btn-danger"  onclick="cambiarEstadoCliente(${c.id_cliente},'inactivo')">Desactivar</button>`;
    h += `<tr>
      <td>${c.id_cliente}</td>
      <td><strong>${c.nombre}</strong>${c.contacto ? '<br><small style="color:var(--muted)">'+c.contacto+'</small>' : ''}</td>
      <td>${c.tipo_cliente === 'empresa' ? '🏢 Empresa' : '👤 Natural'}</td>
      <td>${c.rtn||'—'}</td><td>${c.telefono||'—'}</td><td>${c.correo||'—'}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="editarCliente(${c.id_cliente})">Editar</button>
        ${accionEstado}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaClientes').innerHTML = h;
  renderPaginacion('clientes', pag, 'paginaClientes');
}

function abrirModalCliente() {
  document.getElementById('cId').value=''; document.getElementById('cNombre').value='';
  document.getElementById('cRtn').value=''; document.getElementById('cTel').value='';
  document.getElementById('cTel2').value=''; document.getElementById('cCorreo').value='';
  document.getElementById('cContacto').value=''; document.getElementById('cDir').value='';
  document.getElementById('cDiasCredito').value='0';
  document.getElementById('cTipo').value='empresa';
  document.getElementById('tituloCliente').textContent='Nuevo Cliente';
  document.getElementById('errCliente').style.display='none';
  abrirModal('modalCliente');
}

async function editarCliente(id) {
  const r = await api('controllers/ClientesController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error al obtener cliente.','error'); return; }
  const c = r.data.data;
  document.getElementById('cId').value = c.id_cliente;
  document.getElementById('cNombre').value = c.nombre;
  document.getElementById('cTipo').value   = c.tipo_cliente;
  document.getElementById('cRtn').value    = c.rtn||'';
  document.getElementById('cTel').value    = c.telefono||'';
  document.getElementById('cTel2').value   = c.telefono2||'';
  document.getElementById('cCorreo').value = c.correo||'';
  document.getElementById('cContacto').value = c.contacto||'';
  document.getElementById('cDir').value    = c.direccion||'';
  document.getElementById('cDiasCredito').value = c.dias_credito||0;
  document.getElementById('tituloCliente').textContent='Editar Cliente';
  document.getElementById('errCliente').style.display='none';
  abrirModal('modalCliente');
}

async function guardarCliente() {
  const id = document.getElementById('cId').value;
  const body = { id: id ? +id : undefined, nombre: document.getElementById('cNombre').value.trim(),
    tipo_cliente: document.getElementById('cTipo').value, rtn: document.getElementById('cRtn').value.trim(),
    telefono: document.getElementById('cTel').value.trim(), telefono2: document.getElementById('cTel2').value.trim(),
    correo: document.getElementById('cCorreo').value.trim(), contacto: document.getElementById('cContacto').value.trim(),
    dias_credito: parseInt(document.getElementById('cDiasCredito').value)||0,
    direccion: document.getElementById('cDir').value.trim() };
  const errEl = document.getElementById('errCliente');
  if (!body.nombre) { errEl.textContent='El nombre es requerido.'; errEl.style.display='block'; return; }
  const r = await api('controllers/ClientesController.php?action='+(id?'editar':'crear'), { method:'POST', body:JSON.stringify(body) });
  if (r.ok) { cerrarModal('modalCliente'); toast(id?'Cliente actualizado.':'Cliente creado.','success'); cargarClientes(); }
  else { errEl.textContent = r.data.error||'Error al guardar.'; errEl.style.display='block'; }
}

async function cambiarEstadoCliente(id, estado) {
  const label = estado === 'activo' ? 'reactivar' : 'desactivar';
  if (!await confirmDialog(`¿Deseas ${label} este cliente?`)) return;
  const r = await api('controllers/ClientesController.php?action=estado', { method:'POST', body:JSON.stringify({id, estado}) });
  if (r.ok) { toast(`Cliente ${estado === 'activo' ? 'reactivado' : 'desactivado'}.`, 'success'); cargarClientes(); }
  else toast(r.data.error||'Error.','error');
}

// ── INVENTARIO ───────────────────────────────────────────────
let categoriasCache = [];
async function cargarCategoriasCache() {
  if (categoriasCache.length) return;
  const r = await api('controllers/InventarioController.php?action=categorias');
  if (r.ok) categoriasCache = r.data.data;
}

let inventarioData = [];

async function cargarInventario() {
  document.getElementById('tablaInventario').innerHTML = '<p class="loading">Cargando...</p>';
  const r = await api('controllers/InventarioController.php?action=listar');
  if (!r.ok) { document.getElementById('tablaInventario').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  inventarioData = r.data.data;
  document.getElementById('buscarInventario').value = '';
  paginaActual['inventario'] = 1;
  renderTablaInventario(inventarioData);
}

function filtrarInventario() {
  const q = document.getElementById('buscarInventario').value.toLowerCase().trim();
  paginaActual['inventario'] = 1;
  if (!q) { renderTablaInventario(inventarioData); return; }
  renderTablaInventario(inventarioData.filter(m =>
    m.nombre.toLowerCase().includes(q) ||
    (m.codigo && m.codigo.toLowerCase().includes(q)) ||
    (m.categoria && m.categoria.toLowerCase().includes(q))
  ));
}

function renderTablaInventario(rows) {
  const pag = paginar('inventario', rows);
  let h = '<table><thead><tr><th>Código</th><th>Nombre</th><th>Categoría</th><th>Unidad</th><th>P. Compra</th><th>P. Venta</th><th>Stock</th><th>Mín.</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="9" class="empty-state">Sin materiales</td></tr>';
  pag.slice.forEach(m => {
    const stockCls = parseFloat(m.stock) <= parseFloat(m.stock_minimo) ? 'stock-bajo' : '';
    h += `<tr>
      <td><code style="color:var(--muted)">${m.codigo||'—'}</code></td>
      <td><strong>${m.nombre}</strong></td>
      <td>${m.categoria||'—'}</td><td>${m.unidad_medida}</td>
      <td>${fmtMoneda(m.precio_compra)}</td><td>${fmtMoneda(m.precio_venta)}</td>
      <td class="${stockCls}">${m.stock} ${m.unidad_medida}</td>
      <td>${m.stock_minimo}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="editarMaterial(${m.id_material})">Editar</button>
        <button class="btn btn-sm btn-success" onclick="abrirAjuste(${m.id_material},'${m.nombre.replace(/'/g,"\\'")}')">Ajuste</button>
        <button class="btn btn-sm btn-secondary" onclick="verKardex(${m.id_material},'${m.nombre.replace(/'/g,"\\'")}')">Kardex</button>
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaInventario').innerHTML = h;
  renderPaginacion('inventario', pag, 'paginaInventario');
}

async function abrirModalMaterial() {
  await cargarCategoriasCache();
  document.getElementById('mId').value='';
  document.getElementById('mNombre').value=''; document.getElementById('mDesc').value='';
  document.getElementById('mPrecioC').value=''; document.getElementById('mPrecioV').value='';
  document.getElementById('mStock').value='0'; document.getElementById('mStockMin').value='0';
  document.getElementById('mUnidad').value='unidad';
  document.getElementById('tituloMaterial').textContent='Nuevo Material';
  document.getElementById('errMaterial').style.display='none';
  const sel = document.getElementById('mCategoria');
  sel.innerHTML = '<option value="">Sin categoría</option>' + categoriasCache.map(c=>`<option value="${c.id_categoria}">${c.nombre}</option>`).join('');
  abrirModal('modalMaterial');
}

async function editarMaterial(id) {
  await cargarCategoriasCache();
  const r = await api('controllers/InventarioController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error.','error'); return; }
  const m = r.data.data;
  document.getElementById('mId').value = m.id_material;
  // codigo es solo lectura — mostrado en tabla
  document.getElementById('mNombre').value  = m.nombre;
  document.getElementById('mDesc').value    = m.descripcion||'';
  document.getElementById('mPrecioC').value = m.precio_compra;
  document.getElementById('mPrecioV').value = m.precio_venta;
  document.getElementById('mStock').value   = m.stock;
  document.getElementById('mStockMin').value= m.stock_minimo;
  document.getElementById('mUnidad').value  = m.unidad_medida;
  document.getElementById('tituloMaterial').textContent='Editar Material';
  document.getElementById('errMaterial').style.display='none';
  const sel = document.getElementById('mCategoria');
  sel.innerHTML = '<option value="">Sin categoría</option>' + categoriasCache.map(c=>`<option value="${c.id_categoria}" ${c.id_categoria==m.categoria_id?'selected':''}>${c.nombre}</option>`).join('');
  abrirModal('modalMaterial');
}

async function guardarMaterial() {
  const id = document.getElementById('mId').value;
  const body = { id: id?+id:undefined, nombre: document.getElementById('mNombre').value.trim(), descripcion: document.getElementById('mDesc').value.trim(),
    categoria_id: document.getElementById('mCategoria').value||null, unidad_medida: document.getElementById('mUnidad').value,
    precio_compra: document.getElementById('mPrecioC').value, precio_venta: document.getElementById('mPrecioV').value,
    stock: document.getElementById('mStock').value, stock_minimo: document.getElementById('mStockMin').value };
  const errEl = document.getElementById('errMaterial');
  if (!body.nombre) { errEl.textContent='El nombre es requerido.'; errEl.style.display='block'; return; }
  const r = await api('controllers/InventarioController.php?action='+(id?'editar':'crear'), { method:'POST', body:JSON.stringify(body) });
  if (r.ok) {
    document.getElementById('modalMaterial').classList.remove('sobre-modal');
    cerrarModal('modalMaterial');
    toast(id?'Material actualizado.':'Material creado.','success');
    cargarInventario();
    // Si vino desde nueva compra, buscar y seleccionar el material creado automáticamente
    if (!id && materialRapidoCallback) {
      materialRapidoCallback = false;
      setTimeout(async () => {
        const rb = await api('controllers/InventarioController.php?action=buscar&q='+encodeURIComponent(materialRapidoNombre));
        if (rb.ok && rb.data.data.length) {
          const m = rb.data.data[0];
          selMatCompra(m.id_material, m.nombre, m.precio_compra);
          toast('Material creado y seleccionado en la compra.','success');
        }
      }, 300);
    }
  }
  else { errEl.textContent=r.data.error||'Error.'; errEl.style.display='block'; }
}

function abrirAjuste(id, nombre) {
  document.getElementById('ajusteId').value=id; document.getElementById('ajusteNombre').textContent=nombre;
  document.getElementById('ajusteCant').value=''; document.getElementById('ajusteObs').value='';
  document.getElementById('ajusteTipo').value='entrada'; document.getElementById('errAjuste').style.display='none';
  abrirModal('modalAjuste');
}

async function guardarAjuste() {
  const body = { id: +document.getElementById('ajusteId').value, tipo: document.getElementById('ajusteTipo').value,
    cantidad: +document.getElementById('ajusteCant').value, observaciones: document.getElementById('ajusteObs').value.trim()||'Ajuste manual' };
  const errEl = document.getElementById('errAjuste');
  if (!body.cantidad || body.cantidad <= 0) { errEl.textContent='Ingresa una cantidad válida.'; errEl.style.display='block'; return; }
  const r = await api('controllers/InventarioController.php?action=ajuste', { method:'POST', body:JSON.stringify(body) });
  if (r.ok) { cerrarModal('modalAjuste'); toast('Ajuste aplicado.','success'); cargarInventario(); }
  else { errEl.textContent=r.data.error||'Error.'; errEl.style.display='block'; }
}

async function verKardex(id, nombre) {
  document.getElementById('kardexNombre').textContent=nombre;
  document.getElementById('tablaKardex').innerHTML='<p class="loading">Cargando...</p>';
  abrirModal('modalKardex');
  const r = await api('controllers/InventarioController.php?action=kardex&id='+id);
  if (!r.ok) { document.getElementById('tablaKardex').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  const rows = r.data.data;
  let h = '<table><thead><tr><th>Fecha</th><th>Tipo</th><th>Cantidad</th><th>Costo unit.</th><th>Referencia</th><th>Usuario</th></tr></thead><tbody>';
  if (!rows.length) h += '<tr><td colspan="6" class="empty-state">Sin movimientos</td></tr>';
  rows.forEach(m => {
    const tipoBadge = m.tipo==='entrada' ? '<span class="badge badge-green">↑ Entrada</span>' : m.tipo==='salida' ? '<span class="badge badge-red">↓ Salida</span>' : '<span class="badge badge-gray">Ajuste</span>';
    h += `<tr><td>${m.fecha.slice(0,16)}</td><td>${tipoBadge}</td><td>${m.cantidad}</td><td>${fmtMoneda(m.costo_unitario)}</td><td>${m.observaciones||m.tipo_referencia}</td><td>${m.usuario}</td></tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaKardex').innerHTML = h;
}

// ── PROVEEDORES ──────────────────────────────────────────────
let proveedoresData = [];

async function cargarProveedores() {
  document.getElementById('tablaProveedores').innerHTML='<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoProv').value;
  const r = await api('controllers/ComprasController.php?action=proveedores&estado=' + estado);
  if (!r.ok) { document.getElementById('tablaProveedores').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  proveedoresData = r.data.data;
  document.getElementById('buscarProveedor').value = '';
  renderTablaProveedores(proveedoresData);
}

function filtrarProveedores() {
  const q = document.getElementById('buscarProveedor').value.toLowerCase().trim();
  paginaActual['proveedores'] = 1;
  if (!q) { renderTablaProveedores(proveedoresData); return; }
  renderTablaProveedores(proveedoresData.filter(p =>
    p.nombre.toLowerCase().includes(q) ||
    (p.rtn && p.rtn.includes(q)) ||
    (p.telefono && p.telefono.includes(q))
  ));
}

function renderTablaProveedores(rows) {
  const esInactivo = document.getElementById('filtroEstadoProv').value === 'inactivo';
  const pag = paginar('proveedores', rows);
  let h = '<table><thead><tr><th>#</th><th>Nombre</th><th>RTN</th><th>Teléfono</th><th>Contacto</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="7" class="empty-state">Sin proveedores</td></tr>';
  pag.slice.forEach(p => {
    const accionEstado = esInactivo
      ? `<button class="btn btn-sm btn-success" onclick="cambiarEstadoProv(${p.id_proveedor},'activo')">Reactivar</button>`
      : `<button class="btn btn-sm btn-danger"  onclick="cambiarEstadoProv(${p.id_proveedor},'inactivo')">Desactivar</button>`;
    h += `<tr><td>${p.id_proveedor}</td><td><strong>${p.nombre}</strong></td><td>${p.rtn||'—'}</td><td>${p.telefono||'—'}</td><td>${p.contacto||'—'}</td><td>${badgeEstado(p.estado)}</td>
    <td><div class="td-actions">
      <button class="btn btn-sm btn-secondary" onclick="editarProveedor(${p.id_proveedor})">Editar</button>
      ${accionEstado}
    </div></td></tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaProveedores').innerHTML = h;
  renderPaginacion('proveedores', pag, 'paginaProveedores');
}

function abrirModalProveedor() {
  document.getElementById('pId').value=''; document.getElementById('pNombre').value='';
  document.getElementById('pRtn').value=''; document.getElementById('pTel').value='';
  document.getElementById('pCorreo').value=''; document.getElementById('pContacto').value=''; document.getElementById('pDir').value='';
  document.getElementById('tituloProveedor').textContent='Nuevo Proveedor';
  document.getElementById('errProveedor').style.display='none';
  abrirModal('modalProveedor');
}

async function editarProveedor(id) {
  const r = await api('controllers/ComprasController.php?action=prov_obtener&id='+id);
  if (!r.ok) { toast('Error.','error'); return; }
  const p = r.data.data;
  document.getElementById('pId').value=p.id_proveedor; document.getElementById('pNombre').value=p.nombre;
  document.getElementById('pRtn').value=p.rtn||''; document.getElementById('pTel').value=p.telefono||'';
  document.getElementById('pCorreo').value=p.correo||''; document.getElementById('pContacto').value=p.contacto||'';
  document.getElementById('pDir').value=p.direccion||'';
  document.getElementById('tituloProveedor').textContent='Editar Proveedor';
  document.getElementById('errProveedor').style.display='none';
  abrirModal('modalProveedor');
}

async function guardarProveedor() {
  const id = document.getElementById('pId').value;
  const body = { id:id?+id:undefined, nombre:document.getElementById('pNombre').value.trim(),
    rtn:document.getElementById('pRtn').value.trim(), telefono:document.getElementById('pTel').value.trim(),
    correo:document.getElementById('pCorreo').value.trim(), contacto:document.getElementById('pContacto').value.trim(),
    direccion:document.getElementById('pDir').value.trim() };
  const errEl = document.getElementById('errProveedor');
  if (!body.nombre) { errEl.textContent='El nombre es requerido.'; errEl.style.display='block'; return; }
  const r = await api('controllers/ComprasController.php?action='+(id?'prov_editar':'prov_crear'), { method:'POST', body:JSON.stringify(body) });
  if (r.ok) { cerrarModal('modalProveedor'); toast(id?'Proveedor actualizado.':'Proveedor creado.','success'); cargarProveedores(); }
  else { errEl.textContent=r.data.error||'Error.'; errEl.style.display='block'; }
}

async function cambiarEstadoProv(id, estado) {
  const label = estado === 'activo' ? 'reactivar' : 'desactivar';
  if (!await confirmDialog(`¿Deseas ${label} este proveedor?`)) return;
  const r = await api('controllers/ComprasController.php?action=prov_estado', { method:'POST', body:JSON.stringify({id, estado}) });
  if (r.ok) { toast(`Proveedor ${estado === 'activo' ? 'reactivado' : 'desactivado'}.`, 'success'); cargarProveedores(); }
  else toast(r.data.error||'Error.','error');
}

// ── COMPRAS ──────────────────────────────────────────────────
let itemsCompra = [];
let matSelCompra = null;
let compraEditandoId = null;

let comprasData = [];

async function cargarCompras() {
  document.getElementById('tablaCompras').innerHTML='<p class="loading">Cargando...</p>';
  const r = await api('controllers/ComprasController.php?action=listar');
  if (!r.ok) { document.getElementById('tablaCompras').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  comprasData = r.data.data;
  document.getElementById('buscarCompra').value = '';
  paginaActual['compras'] = 1;
  renderTablaCompras(comprasData);
}

function filtrarCompras() {
  const q = document.getElementById('buscarCompra').value.toLowerCase().trim();
  paginaActual['compras'] = 1;
  if (!q) { renderTablaCompras(comprasData); return; }
  renderTablaCompras(comprasData.filter(c =>
    c.proveedor.toLowerCase().includes(q) ||
    (c.numero_documento && c.numero_documento.toLowerCase().includes(q)) ||
    c.fecha.includes(q) ||
    c.estado.includes(q)
  ));
}

function renderTablaCompras(rows) {
  const pag = paginar('compras', rows);
  let h = '<table><thead><tr><th>#</th><th>Proveedor</th><th>Fecha</th><th>Doc.</th><th>Total</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="7" class="empty-state">Sin compras</td></tr>';
  pag.slice.forEach(c => {
    h += `<tr><td>${c.id_compra}</td><td>${c.proveedor}</td><td>${c.fecha}</td><td>${c.numero_documento||'—'}</td>
    <td><strong>${fmtMoneda(c.total)}</strong></td><td>${badgeEstado(c.estado)}</td>
    <td><div class="td-actions">
      <button class="btn btn-sm btn-secondary" onclick="verDetalleCompra(${c.id_compra})">Ver</button>
      ${c.estado==='pendiente' ? `<button class="btn btn-sm btn-warning" onclick="editarCompra(${c.id_compra})">Editar</button>` : ''}
      ${c.estado==='pendiente' ? `<button class="btn btn-sm btn-success" onclick="pagarCompra(${c.id_compra})">Pagar</button>` : ''}
    </div></td></tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaCompras').innerHTML = h;
  renderPaginacion('compras', pag, 'paginaCompras');
}

async function abrirModalCompra(compraId=null){
  compraEditandoId=compraId;itemsCompra=[];matSelCompra=null;
  document.getElementById('errCompra').style.display='none';
  document.getElementById('compraFecha').value=new Date().toISOString().slice(0,10);
  document.getElementById('compraNroDoc').value='';document.getElementById('compraImpuesto').value='0';
  document.getElementById('compraObs').value='';document.getElementById('compraMatBuscar').value='';
  document.getElementById('compraMatCant').value='';document.getElementById('compraMatPrecio').value='';
  document.getElementById('compraMatId').value='';renderItemsCompra();
  const r=await api('controllers/ComprasController.php?action=proveedores');
  const sel=document.getElementById('compraProveedor');
  sel.innerHTML='<option value="">Seleccionar...</option>'+(r.ok?r.data.data.map(p=>`<option value="${p.id_proveedor}">${p.nombre}</option>`).join(''):'');
  const titulo=document.querySelector('#modalCompra h4');if(titulo)titulo.textContent=compraId?'✏️ Editar Compra':'Nueva Compra';
  if(compraId){const rc=await api('controllers/ComprasController.php?action=obtener&id='+compraId);if(rc.ok){const c=rc.data.data;sel.value=c.proveedor_id;document.getElementById('compraFecha').value=c.fecha;document.getElementById('compraNroDoc').value=c.numero_documento||'';document.getElementById('compraObs').value=c.observaciones||'';itemsCompra=c.detalle.map(d=>({material_id:d.material_id,nombre:d.material,cantidad:+d.cantidad,precio_unitario:+d.precio_unitario,isv:0,subtotal:+d.subtotal}));renderItemsCompra();}}
  abrirModal('modalCompra');}
async function editarCompra(id){await abrirModalCompra(id);}

let buscarMatTimer = null;
async function buscarMatCompra() {
  clearTimeout(buscarMatTimer);
  const q = document.getElementById('compraMatBuscar').value.trim();
  if (q.length < 2) { document.getElementById('sugerenciasMatCompra').style.display='none'; return; }
  buscarMatTimer = setTimeout(async () => {
    const r = await api('controllers/InventarioController.php?action=buscar&q='+encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasMatCompra');
    let html = '';
    if (r.data.data.length) {
      html += r.data.data.map(m =>
        `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="selMatCompra(${m.id_material},'${m.nombre.replace(/'/g,"\\'")}',${m.precio_compra})">${m.nombre} <span style="color:var(--muted);font-size:11px">${m.unidad_medida}</span></div>`
      ).join('');
    } else {
      html += `<div style="padding:8px 12px;font-size:13px;color:var(--muted);border-bottom:1px solid var(--border)">Sin resultados para "<strong>${q}</strong>"</div>`;
    }
    // Siempre mostrar opción de crear nuevo
    html += `<div style="padding:8px 12px;cursor:pointer;font-size:13px;color:var(--accent);font-weight:600;display:flex;align-items:center;gap:6px"
      onmousedown="crearMaterialRapido('${q.replace(/'/g,"\\'")}')">
      <span style="font-size:16px">＋</span> Crear nuevo material: "<strong>${q}</strong>"
    </div>`;
    div.innerHTML = html;
    div.style.display='block';
  }, 300);
}

async function crearMaterialRapido(nombre) {
  document.getElementById('sugerenciasMatCompra').style.display='none';
  await cargarCategoriasCache();
  materialRapidoCallback = true;
  materialRapidoNombre   = nombre;
  // Pequeño delay para que el DOM se estabilice antes de abrir el modal
  setTimeout(() => {
    document.getElementById('mId').value='';
    document.getElementById('mNombre').value = nombre;
    document.getElementById('mDesc').value='';
    document.getElementById('mPrecioC').value='';
    document.getElementById('mPrecioV').value='';
    document.getElementById('mStock').value='0';
    document.getElementById('mStockMin').value='0';
    document.getElementById('mUnidad').value='unidad';
    document.getElementById('tituloMaterial').textContent='Nuevo Material';
    document.getElementById('errMaterial').style.display='none';
    const sel = document.getElementById('mCategoria');
    sel.innerHTML = '<option value="">Sin categoría</option>' + categoriasCache.map(c=>`<option value="${c.id_categoria}">${c.nombre}</option>`).join('');
    const mm = document.getElementById('modalMaterial');
    mm.classList.add('sobre-modal');
    abrirModal('modalMaterial');
  }, 150);
}

function selMatCompra(id, nombre, precio) {
  matSelCompra = {id, nombre};
  document.getElementById('compraMatBuscar').value = nombre;
  document.getElementById('compraMatId').value = id;
  document.getElementById('compraMatPrecio').value = precio;
  document.getElementById('sugerenciasMatCompra').style.display='none';
  document.getElementById('compraMatCant').focus();
}

function calcIsvItem() {
  const cant   = parseFloat(document.getElementById('compraMatCant')?.value || 0);
  const precio = parseFloat(document.getElementById('compraMatPrecio')?.value || 0);
  const base   = cant * precio;
  const isv    = parseFloat((base * 0.15).toFixed(2));
  const isvEl  = document.getElementById('compraImpuesto');
  if (isvEl) isvEl.value = isv.toFixed(2);
}

function agregarItemCompra() {
  const matId  = +document.getElementById('compraMatId').value;
  const nombre = document.getElementById('compraMatBuscar').value.trim();
  const cant   = parseFloat(document.getElementById('compraMatCant').value);
  const precio = parseFloat(document.getElementById('compraMatPrecio').value);
  const isvItem = parseFloat(document.getElementById('compraImpuesto').value || 0);
  if (!matId || !nombre || isNaN(cant) || cant<=0 || isNaN(precio) || precio<0) { toast('Completa los datos del material.','warn'); return; }
  const subtotalBase = cant * precio;
  const subtotal     = subtotalBase + isvItem;
  const exist = itemsCompra.findIndex(i => i.material_id === matId);
  if (exist >= 0) {
    itemsCompra[exist].cantidad += cant;
    const newBase = itemsCompra[exist].cantidad * itemsCompra[exist].precio_unitario;
    itemsCompra[exist].isv      = parseFloat((newBase * 0.15).toFixed(2));
    itemsCompra[exist].subtotal = newBase + itemsCompra[exist].isv;
  } else {
    itemsCompra.push({ material_id:matId, nombre, cantidad:cant, precio_unitario:precio, isv:isvItem, subtotal });
  }
  document.getElementById('compraMatBuscar').value=''; document.getElementById('compraMatId').value='';
  document.getElementById('compraMatCant').value=''; document.getElementById('compraMatPrecio').value='';
  document.getElementById('compraImpuesto').value='0';
  matSelCompra=null;
  renderItemsCompra();
}

function renderItemsCompra() {
  const tbody = document.getElementById('itemsCompraBody');
  if (!itemsCompra.length) { tbody.innerHTML='<tr><td colspan="5" class="empty-state">Sin items</td></tr>'; updateTotalesCompra(); return; }
  tbody.innerHTML = itemsCompra.map((it,i) =>
    `<tr><td>${it.nombre}</td><td>${it.cantidad}</td><td>${fmtMoneda(it.precio_unitario)}</td><td>${fmtMoneda(it.isv||0)}</td><td>${fmtMoneda(it.subtotal)}</td>
    <td><button class="btn btn-sm btn-danger" onclick="quitarItemCompra(${i})">✕</button></td></tr>`
  ).join('');
  updateTotalesCompra();
}

function quitarItemCompra(i) { itemsCompra.splice(i,1); renderItemsCompra(); }

function updateTotalesCompra() {
  const sub  = itemsCompra.reduce((a,it) => a + (it.cantidad * it.precio_unitario), 0);
  const isv  = itemsCompra.reduce((a,it) => a + (it.isv||0), 0);
  const total = itemsCompra.reduce((a,it) => a + it.subtotal, 0);
  document.getElementById('compraSubtotalMostrar').textContent = fmtMoneda(sub);
  document.getElementById('compraTotalMostrar').textContent    = fmtMoneda(total);
}

async function guardarCompra() {
  const provId = +document.getElementById('compraProveedor').value;
  const errEl  = document.getElementById('errCompra');
  errEl.style.display='none';
  if (!provId) { errEl.textContent='Selecciona un proveedor.'; errEl.style.display='block'; return; }
  if (!itemsCompra.length) { errEl.textContent='Agrega al menos un material.'; errEl.style.display='block'; return; }
  const isvTotal = itemsCompra.reduce((a,it) => a + (it.isv||0), 0);
  const body = { proveedor_id:provId, fecha:document.getElementById('compraFecha').value,
    numero_documento:document.getElementById('compraNroDoc').value.trim(),
    impuesto: isvTotal,
    observaciones:document.getElementById('compraObs').value.trim(), items:itemsCompra };
  if(compraEditandoId)body.id=compraEditandoId;
  const action=compraEditandoId?'editar':'crear';
  const r=await api('controllers/ComprasController.php?action='+action,{method:'POST',body:JSON.stringify(body)});
  if(r.ok){cerrarModal('modalCompra');toast(compraEditandoId?'Compra actualizada.':'Compra registrada.','success');compraEditandoId=null;cargarCompras();}
  else{errEl.textContent=r.data.error||'Error.';errEl.style.display='block';}
}

let metodoPagoSeleccionado = '';

function selMetodoPago(metodo) {
  metodoPagoSeleccionado = metodo;
  // Resaltar opción seleccionada
  document.querySelectorAll('.metodo-pago-btn').forEach(el => {
    const sel = el.dataset.metodo === metodo;
    el.style.borderColor  = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background   = sel ? 'rgba(232,160,32,.12)' : '';
  });
  // Mostrar campo referencia si es tarjeta o crédito
  const refGrupo = document.getElementById('pagoRefGrupo');
  if (refGrupo) refGrupo.style.display = (metodo === 'tarjeta' || metodo === 'credito') ? 'block' : 'none';
}

async function pagarCompra(id) {
  // Buscar info de la compra para mostrar en el modal
  const r = await api('controllers/ComprasController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error al obtener compra.','error'); return; }
  const c = r.data.data;
  document.getElementById('pagoCompraId').value = id;
  document.getElementById('pagoCompraInfo').textContent =
    `Proveedor: ${c.proveedor} | Total: ${fmtMoneda(c.total)}`;
  document.getElementById('pagoCompraRef').value = '';
  document.getElementById('pagoRefGrupo').style.display = 'none';
  document.getElementById('errPagoCompra').style.display = 'none';
  // Resetear selección
  metodoPagoSeleccionado = '';
  document.querySelectorAll('.metodo-pago-btn').forEach(el => {
    el.style.borderColor = 'var(--border)';
    el.style.background  = '';
  });
  abrirModal('modalPagoCompra');
}

async function confirmarPagoCompra() {
  const id      = +document.getElementById('pagoCompraId').value;
  const ref     = document.getElementById('pagoCompraRef').value.trim();
  const errEl   = document.getElementById('errPagoCompra');
  errEl.style.display = 'none';
  if (!metodoPagoSeleccionado) {
    errEl.textContent = 'Selecciona un método de pago.';
    errEl.style.display = 'block';
    return;
  }
  const r = await api('controllers/ComprasController.php?action=cambiar_estado', {
    method: 'POST',
    body: JSON.stringify({ id, estado:'pagada', metodo_pago: metodoPagoSeleccionado, referencia: ref })
  });
  if (r.ok) {
    cerrarModal('modalPagoCompra');
    toast(`Compra pagada con ${metodoPagoSeleccionado}.`, 'success');
    cargarCompras();
  } else {
    errEl.textContent = r.data.error || 'Error al registrar pago.';
    errEl.style.display = 'block';
  }
}

async function verDetalleCompra(id) {
  // Reusa modal de detalle OT para mostrar detalle compra
  const r = await api('controllers/ComprasController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error.','error'); return; }
  const c = r.data.data;
  let h = `<h4>🛒 Compra #${c.id_compra}</h4>
  <p style="color:var(--muted);font-size:13px;margin-bottom:14px">Proveedor: <strong>${c.proveedor}</strong> | Fecha: ${c.fecha} | Doc: ${c.numero_documento||'—'} | Estado: ${badgeEstado(c.estado)}</p>
  <div style="overflow-x:auto;margin-top:8px"><table style="width:100%"><thead><tr><th>Material</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal</th></tr></thead><tbody>`;
  c.detalle.forEach(d => { h += `<tr><td>${d.material} <small style="color:var(--muted)">${d.unidad_medida}</small></td><td>${d.cantidad}</td><td>${fmtMoneda(d.precio_unitario)}</td><td>${fmtMoneda(d.subtotal)}</td></tr>`; });
  h += `</tbody></table></div>
  <div style="text-align:right;margin-top:12px;font-size:13px">Subtotal: ${fmtMoneda(c.subtotal)} | ISV: ${fmtMoneda(c.impuesto)} | <strong style="color:var(--accent)">Total: ${fmtMoneda(c.total)}</strong></div>`;
  document.getElementById('contenidoDetalleOT').innerHTML = h;
  abrirModal('modalDetalleOT');
}

// ── ÓRDENES DE TRABAJO ───────────────────────────────────────
let tecnicosCache = [];
async function cargarTecnicosCache(forzar = false) {
  if (tecnicosCache.length && !forzar) return;
  try {
    const r = await api('controllers/OrdenesController.php?action=tecnicos');
    if (r.ok && r.data.data && r.data.data.length) {
      tecnicosCache = r.data.data;
    }
  } catch(e) {
    tecnicosCache = [];
  }
}

let ordenesData = [];

async function cargarOrdenes() {
  document.getElementById('tablaOrdenes').innerHTML='<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoOT').value;
  const url = 'controllers/OrdenesController.php?action=listar' + (estado ? '&estado='+estado : '');
  const r = await api(url);
  if (!r.ok) { document.getElementById('tablaOrdenes').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  ordenesData = r.data.data;
  document.getElementById('buscarOrden').value = '';
  paginaActual['ordenes'] = 1;
  renderTablaOrdenes(ordenesData);
}

function filtrarOrdenes() {
  const q = document.getElementById('buscarOrden').value.toLowerCase().trim();
  paginaActual['ordenes'] = 1;
  if (!q) { renderTablaOrdenes(ordenesData); return; }
  renderTablaOrdenes(ordenesData.filter(o =>
    o.numero_orden.toLowerCase().includes(q) ||
    o.cliente.toLowerCase().includes(q) ||
    (o.placa  && o.placa.toLowerCase().includes(q))  ||
    (o.marca  && o.marca.toLowerCase().includes(q))  ||
    (o.modelo && o.modelo.toLowerCase().includes(q)) ||
    (o.tecnicos && o.tecnicos.toLowerCase().includes(q))
  ));
}

function renderTablaOrdenes(rows) {
  const pag = paginar('ordenes', rows);
  let h = '<table><thead><tr><th>OT</th><th>Cliente</th><th>Vehículo</th><th>Técnicos</th><th>Apertura</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="7" class="empty-state">Sin órdenes</td></tr>';
  pag.slice.forEach(o => {
    const veh = [o.marca, o.modelo, o.placa ? '('+o.placa+')' : ''].filter(Boolean).join(' ') || '—';
    h += `<tr>
      <td><strong>${o.numero_orden}</strong></td>
      <td>${o.cliente}</td><td>${veh}</td>
      <td>${o.tecnicos||'—'}</td><td>${o.fecha_apertura}</td>
      <td>${badgeEstado(o.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleOT(${o.id_orden})">Ver</button>
        ${o.estado==='borrador'||o.estado==='en_proceso' ? `<button class="btn btn-sm btn-secondary" onclick="editarOT(${o.id_orden})">Editar</button>` : ''}
        ${o.estado==='borrador' ? `<button class="btn btn-sm btn-success" onclick="cambiarEstadoOT(${o.id_orden},'en_proceso')">▶ Iniciar</button>` : ''}
        ${o.estado==='en_proceso' ? `<button class="btn btn-sm btn-success" onclick="cambiarEstadoOT(${o.id_orden},'finalizada')">✓ Finalizar</button>` : ''}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaOrdenes').innerHTML = h;
  renderPaginacion('ordenes', pag, 'paginaOrdenes');
}

// ── MODAL NUEVA / EDITAR OT ──────────────────────────────────
// ── LÍNEAS DE TRABAJO EN MODAL OT ────────────────────────────
let lineasTrabajo = [];

function agregarLineaTrabajo() {
  const num = lineasTrabajo.length + 1;
  lineasTrabajo.push('Trabajo ' + num);
  renderLineasTrabajo();
}

function editarLineaTrabajo(i, valor) {
  lineasTrabajo[i] = valor;
  sincronizarOtDesc();
}

function eliminarLineaTrabajo(i) {
  lineasTrabajo.splice(i, 1);
  lineasTrabajo = lineasTrabajo.map((l, idx) =>
    /^Trabajo \d+$/.test(l) ? 'Trabajo ' + (idx + 1) : l
  );
  renderLineasTrabajo();
}

function renderLineasTrabajo() {
  const wrap = document.getElementById('otDescWrap');
  if (!wrap) return;
  if (!lineasTrabajo.length) {
    wrap.innerHTML = '<p style="color:var(--muted);font-size:12px;padding:4px 0">Sin líneas. Presiona "+ Trabajo" para agregar.</p>';
    sincronizarOtDesc();
    return;
  }
  wrap.innerHTML = lineasTrabajo.map((l, i) =>
    `<div style="display:flex;align-items:center;gap:6px;margin-bottom:6px">
      <input type="text" value="${l.replace(/"/g,'&quot;')}"
        oninput="editarLineaTrabajo(${i}, this.value)"
        style="flex:1;padding:6px 10px;background:var(--sidebar);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
      <button onclick="eliminarLineaTrabajo(${i})"
        style="background:none;border:none;color:var(--danger);cursor:pointer;font-size:18px;padding:0 4px;line-height:1">✕</button>
    </div>`
  ).join('');
  sincronizarOtDesc();
}

function sincronizarOtDesc() {
  const hidden = document.getElementById('otDesc');
  if (hidden) hidden.value = lineasTrabajo.join('\n');
}

async function abrirModalOT() {
  try { await cargarTecnicosCache(true); } catch(e) { tecnicosCache = []; }
  document.getElementById('otId').value='';
  lineasTrabajo = [];
  renderLineasTrabajo();
  ['otPlaca','otMarca','otModelo','otColor','otMotor','otChasis','otObs','otClienteBuscar'].forEach(id => document.getElementById(id).value='');
  ['otAnio','otKm'].forEach(id => document.getElementById(id).value='');
  document.getElementById('otClienteId').value='';
  document.getElementById('otFecha').value = new Date().toISOString().slice(0,10);
  document.getElementById('tituloOT').textContent='Nueva Orden de Trabajo';
  document.getElementById('errOT').style.display='none';
  document.getElementById('sugerenciasClienteOT').style.display='none';
  const selVeh = document.getElementById('otVehiculoSelect');
  if (selVeh) selVeh.innerHTML = '<option value="">— Seleccionar vehículo del cliente —</option>';
  renderCheckboxesTecnicos(document.getElementById('otTecnicosWrap'), []);
  abrirModal('modalOT');
}

async function editarOT(id) {
  await cargarTecnicosCache(true);
  const r = await api('controllers/OrdenesController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error.','error'); return; }
  const o = r.data.data;
  document.getElementById('otId').value=o.id_orden;
  document.getElementById('otClienteId').value=o.cliente_id;
  document.getElementById('otClienteBuscar').value=o.cliente;
  document.getElementById('otFecha').value=o.fecha_apertura;
  document.getElementById('otPlaca').value=o.placa||'';
  document.getElementById('otMarca').value=o.marca||'';
  document.getElementById('otModelo').value=o.modelo||'';
  document.getElementById('otAnio').value=o.anio||'';
  document.getElementById('otColor').value=o.color||'';
  document.getElementById('otKm').value=o.kilometraje||'';
  document.getElementById('otMotor').value=o.numero_motor||'';
  document.getElementById('otChasis').value=o.numero_chasis||'';
  // Cargar líneas de trabajo existentes
  lineasTrabajo = o.descripcion_trabajo ? o.descripcion_trabajo.split('\n').filter(l => l.trim()) : [];
  renderLineasTrabajo();
  document.getElementById('otObs').value=o.observaciones||'';
  document.getElementById('tituloOT').textContent='Editar OT - '+o.numero_orden;
  document.getElementById('errOT').style.display='none';
  const tecnosAsig = (o.tecnicos||[]).map(t => t.id_empleado);
  renderCheckboxesTecnicos(document.getElementById('otTecnicosWrap'), tecnosAsig);
  abrirModal('modalOT');
}

let buscarClienteTimer = null;
async function buscarClienteOT() {
  clearTimeout(buscarClienteTimer);
  const q = document.getElementById('otClienteBuscar').value.trim();
  if (q.length < 2) { document.getElementById('sugerenciasClienteOT').style.display='none'; return; }
  buscarClienteTimer = setTimeout(async () => {
    const r = await api('controllers/ClientesController.php?action=buscar&q='+encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasClienteOT');
    if (!r.data.data.length) { div.style.display='none'; return; }
    div.innerHTML = r.data.data.map(c =>
      `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="selClienteOT(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
        ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.tipo_cliente==='empresa'?'🏢':'👤'} ${c.rtn||''}</span>
      </div>`
    ).join('');
    div.style.display='block';
  }, 300);
}

function selClienteOT(id, nombre) {
  document.getElementById('otClienteId').value=id;
  document.getElementById('otClienteBuscar').value=nombre;
  document.getElementById('sugerenciasClienteOT').style.display='none';
  cargarVehiculosOT(id);
}

async function cargarVehiculosOT(clienteId) {
  const sel = document.getElementById('otVehiculoSelect');
  if (!sel) return;
  sel.innerHTML = '<option value="">Cargando...</option>';
  try {
    const r = await api('controllers/VehiculosController.php?action=por_cliente&cliente_id=' + clienteId);
    sel.innerHTML = '<option value="">— Seleccionar vehículo del cliente —</option>';
    if (r.ok && r.data.data.length) {
      r.data.data.forEach(v => {
        const label = `${v.placa}${v.marca ? ' — ' + v.marca : ''}${v.modelo ? ' ' + v.modelo : ''}${v.anio ? ' ' + v.anio : ''}`;
        sel.innerHTML += `<option value="${v.id_vehiculo}" data-placa="${v.placa}" data-marca="${v.marca||''}" data-modelo="${v.modelo||''}" data-anio="${v.anio||''}" data-color="${v.color||''}" data-motor="${v.numero_motor||''}" data-chasis="${v.numero_chasis||''}">${label}</option>`;
      });
    } else {
      sel.innerHTML += '<option value="" disabled>— Sin vehículos registrados —</option>';
    }
  } catch(e) {
    sel.innerHTML = '<option value="">— Error al cargar —</option>';
  }
}

function autoLlenarVehiculoOT() {
  const sel = document.getElementById('otVehiculoSelect');
  const opt = sel.options[sel.selectedIndex];
  if (!opt || !opt.value) return;
  document.getElementById('otPlaca').value   = opt.dataset.placa  || '';
  document.getElementById('otMarca').value   = opt.dataset.marca  || '';
  document.getElementById('otModelo').value  = opt.dataset.modelo || '';
  document.getElementById('otAnio').value    = opt.dataset.anio   || '';
  document.getElementById('otColor').value   = opt.dataset.color  || '';
  document.getElementById('otMotor').value   = opt.dataset.motor  || '';
  document.getElementById('otChasis').value  = opt.dataset.chasis || '';
}

async function guardarOT() {
  const id        = document.getElementById('otId').value;
  const clienteId = +document.getElementById('otClienteId').value;
  sincronizarOtDesc();
  const desc      = document.getElementById('otDesc').value.trim();
  const errEl     = document.getElementById('errOT');
  errEl.style.display='none';
  if (!clienteId) { errEl.textContent='Selecciona un cliente.'; errEl.style.display='block'; return; }
  if (!desc) { errEl.textContent='La descripción del trabajo es requerida.'; errEl.style.display='block'; return; }
  const tecnicos = Array.from(document.querySelectorAll('.chkTecnico:checked')).map(cb => +cb.value);
  const body = { id:id?+id:undefined, cliente_id:clienteId,
    tecnicos,
    fecha_apertura: document.getElementById('otFecha').value,
    placa:    document.getElementById('otPlaca').value.trim(),
    marca:    document.getElementById('otMarca').value.trim(),
    modelo:   document.getElementById('otModelo').value.trim(),
    anio:     document.getElementById('otAnio').value||null,
    color:    document.getElementById('otColor').value.trim(),
    kilometraje: document.getElementById('otKm').value||null,
    numero_motor:  document.getElementById('otMotor').value.trim(),
    numero_chasis: document.getElementById('otChasis').value.trim(),
    descripcion_trabajo: desc,
    observaciones: document.getElementById('otObs').value.trim() };
  const r = await api('controllers/OrdenesController.php?action='+(id?'editar':'crear'), { method:'POST', body:JSON.stringify(body) });
  if (r.ok) { cerrarModal('modalOT'); toast(id?'OT actualizada.':'OT creada correctamente.','success'); cargarOrdenes(); }
  else { errEl.textContent=r.data.error||'Error.'; errEl.style.display='block'; }
}

async function verDetalleOT(id) {
  document.getElementById('contenidoDetalleOT').innerHTML='<p class="loading">Cargando...</p>';
  abrirModal('modalDetalleOT');
  const r = await api('controllers/OrdenesController.php?action=obtener&id='+id);
  if (!r.ok) { document.getElementById('contenidoDetalleOT').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  const o = r.data.data;
  const veh = [o.anio, o.marca, o.modelo, o.color].filter(Boolean).join(' ');

  let h = `<h4>🔧 ${o.numero_orden} ${badgeEstado(o.estado)}</h4>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${o.cliente}</strong>${o.cliente_tel ? ' — '+o.cliente_tel : ''}</div>
    <div><span style="color:var(--muted)">Técnicos:</span> ${o.tecnicos&&o.tecnicos.length ? o.tecnicos.map(t=>t.nombre+(t.puesto?` <small style="color:var(--muted)">(${t.puesto})</small>`:'')).join(', ') : 'Sin asignar'}</div>
    <div><span style="color:var(--muted)">Apertura:</span> ${o.fecha_apertura}</div>
    <div><span style="color:var(--muted)">Cierre:</span> ${o.fecha_cierre||'—'}</div>
  </div>`;

  if (veh) {
    h += `<div class="section-title">🚗 Vehículo</div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;margin-bottom:14px;font-size:13px">
      ${o.placa ? `<div><span style="color:var(--muted)">Placa:</span> <strong>${o.placa}</strong></div>` : ''}
      ${veh ? `<div><span style="color:var(--muted)">Vehículo:</span> ${veh}</div>` : ''}
      ${o.kilometraje ? `<div><span style="color:var(--muted)">Km:</span> ${o.kilometraje.toLocaleString()}</div>` : ''}
      ${o.numero_motor ? `<div><span style="color:var(--muted)">Motor:</span> ${o.numero_motor}</div>` : ''}
      ${o.numero_chasis ? `<div><span style="color:var(--muted)">Chasis:</span> ${o.numero_chasis}</div>` : ''}
    </div>`;
  }

  h += `<div class="section-title">📋 Trabajo</div>
  <ul style="margin:0 0 10px 0;padding-left:18px">
    ${(o.descripcion_trabajo||'').split('\n').filter(l=>l.trim()).map(l=>`<li style="font-size:13px;line-height:1.8">${l}</li>`).join('')}
  </ul>`;
  if (o.observaciones) h += `<p style="font-size:12px;color:var(--muted);margin-bottom:14px">${o.observaciones}</p>`;

  // Materiales
  h += `<div class="section-title">📦 Materiales utilizados</div>`;
  if (o.estado === 'borrador' || o.estado === 'en_proceso') {
    h += `<div style="display:grid;grid-template-columns:1fr 80px 90px auto;gap:6px;align-items:end;margin-bottom:8px">
      <input type="text" id="otDetMatBuscar" placeholder="Buscar material..." oninput="buscarMatOT()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
      <input type="number" id="otDetCant" placeholder="Cant." min="0.01" step="0.01" style="padding:7px 8px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
      <input type="number" id="otDetPrecio" placeholder="Precio" min="0" step="0.01" style="padding:7px 8px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
      <button class="btn btn-sm btn-success" onclick="agregarMatOT(${o.id_orden})">+ Agregar</button>
    </div>
    <input type="hidden" id="otDetMatId">
    <div id="sugerenciasMatOT" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:6px;margin-bottom:8px;max-height:120px;overflow-y:auto"></div>`;
  }
  const tablaMats = o.materiales.length
    ? `<table><thead><tr><th>Material</th><th>Cantidad</th><th>Precio unit.</th><th>Subtotal</th>${o.estado==='borrador'||o.estado==='en_proceso'?'<th></th>':''}</tr></thead><tbody>`
      + o.materiales.map(m => `<tr><td>${m.material} <small style="color:var(--muted)">${m.unidad_medida}</small></td><td>${m.cantidad}</td><td>${fmtMoneda(m.precio_unitario)}</td><td>${fmtMoneda(m.subtotal)}</td>${o.estado==='borrador'||o.estado==='en_proceso'?`<td><button class="btn btn-sm btn-danger" onclick="quitarMatOT(${m.id_detalle_om},${o.id_orden})">✕</button></td>`:''}</tr>`).join('')
      + `</tbody></table>`
    : '<p class="empty-state">Sin materiales</p>';
  h += `<div class="table-wrap">${tablaMats}</div>`;

  // Mano de obra
  h += `<div class="section-title">👷 Mano de obra</div>`;
  if (o.estado === 'borrador' || o.estado === 'en_proceso') {
    h += `<p style="font-size:12px;color:var(--muted);margin-bottom:8px">Presiona <strong style="color:var(--accent)">+</strong> para agregar un trabajo. Al quitar con <strong style="color:var(--danger)">✕</strong> regresa aquí.</p>`;
    // Tarifa = suma de salarios diarios de todos los técnicos (salario / 30)
    const tarifaDiaria = o.tecnicos && o.tecnicos.length
      ? o.tecnicos.reduce((sum, t) => sum + (parseFloat(t.salario_mensual) || 0), 0) / 30
      : 0;
    const tarifaStr = tarifaDiaria.toFixed(2);

    // Líneas pendientes = las definidas en descripcion_trabajo que NO están aún en mano_obra
    const todasLineas   = (o.descripcion_trabajo || '').split('\n').filter(l => l.trim());
    const yaAgregadas   = o.mano_obra.map(m => m.descripcion.trim().toLowerCase());
    const lineasDesc    = todasLineas.filter(l => !yaAgregadas.includes(l.trim().toLowerCase()));

    if (lineasDesc.length) {
      h += `<p style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;margin-bottom:6px">Pendientes de agregar</p>`;
      h += `<div class="table-wrap" style="margin-bottom:16px">
        <table style="min-width:500px">
          <thead><tr>
            <th>Descripción</th>
            <th style="width:80px">Días</th>
            <th style="width:130px">Tarifa/día (L.)</th>
            <th style="width:130px">Subtotal (+35%)</th>
            <th style="width:40px"></th>
          </tr></thead>
          <tbody id="moLineasBody">
            ${lineasDesc.map((l, i) => `
            <tr>
              <td style="font-size:13px">${l}</td>
              <td><input type="number" id="moDias_${i}" value="1" min="0.5" step="0.5"
                oninput="calcSubtotalLinea(${i},${tarifaDiaria})"
                style="width:100%;padding:5px 7px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:13px;outline:none"></td>
              <td><input type="number" id="moTarifa_${i}" value="${tarifaStr}" min="0" step="0.01"
                oninput="calcSubtotalLinea(${i},${tarifaDiaria})"
                style="width:100%;padding:5px 7px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:13px;outline:none"></td>
              <td id="moSub_${i}" style="font-weight:600;color:var(--accent);font-size:13px">${fmtMoneda(tarifaDiaria * 1.35)}</td>
              <td><button class="btn btn-sm btn-success" onclick="agregarMoLinea(${o.id_orden},'${l.replace(/'/g,"\\'")}',${i})">+</button></td>
            </tr>`).join('')}
          </tbody>
        </table>
      </div>`;
    } else {
      h += `<div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-bottom:6px">
        <div style="grid-column:1/-1">
          <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:3px">Descripción del servicio</label>
          <input type="text" id="otMoDesc" value="" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
      </div>
      <div style="display:grid;grid-template-columns:80px 140px 140px auto;gap:6px;align-items:end;margin-bottom:8px">
        <div>
          <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:3px">Días</label>
          <input type="number" id="otMoHoras" placeholder="1" min="0.5" step="0.5" value="1" oninput="calcSubtotalMO()" style="width:100%;padding:7px 8px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
        <div>
          <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:3px">Tarifa/día (L.)</label>
          <input type="number" id="otMoTarifa" value="${tarifaStr}" min="0" step="0.01" oninput="calcSubtotalMO()" style="width:100%;padding:7px 8px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
        <div>
          <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:3px">Subtotal <span style="color:var(--muted);font-size:10px">(+35%)</span></label>
          <div id="otMoSubtotal" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;font-size:13px;color:var(--accent);font-weight:600">${fmtMoneda(tarifaDiaria * 1.35)}</div>
        </div>
        <div style="padding-bottom:1px">
          <button class="btn btn-sm btn-success" onclick="agregarMoOT(${o.id_orden})">+ Agregar</button>
        </div>
      </div>`;
    }
  }
  const tituloMO = o.mano_obra.length
    ? `<p style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;margin-bottom:6px">Registrados</p>` : '';
  h += tituloMO;
  const tablaMO = o.mano_obra.length
    ? `<table><thead><tr><th>Descripción</th><th>Días</th><th>Tarifa/día</th><th>Subtotal</th>${o.estado==='borrador'||o.estado==='en_proceso'?'<th></th>':''}</tr></thead><tbody>`
      + o.mano_obra.map(m => `<tr><td>${m.descripcion}</td><td>${m.dias}</td><td>${fmtMoneda(m.tarifa_dia)}</td><td>${fmtMoneda(m.subtotal)}</td>${o.estado==='borrador'||o.estado==='en_proceso'?`<td><button class="btn btn-sm btn-danger" onclick="quitarMoOT(${m.id_mano_obra},${o.id_orden})">✕</button></td>`:''}</tr>`).join('')
      + `</tbody></table>`
    : '<p class="empty-state">Sin mano de obra</p>';
  h += `<div class="table-wrap">${tablaMO}</div>`;

  // Totales
  h += `<div style="text-align:right;margin-top:14px;font-size:13px;line-height:2">
    Materiales: ${fmtMoneda(o.total_materiales)}<br>
    Mano de obra: ${fmtMoneda(o.total_mano_obra)}<br>
    <strong style="font-size:15px;color:var(--accent)">Total: ${fmtMoneda(o.total_general)}</strong>
  </div>`;

  document.getElementById('contenidoDetalleOT').innerHTML = h;
  currentOTId = o.id_orden;

  // Mostrar/ocultar botón "Generar Cotización" según estado de la OT
  let btnCot = document.getElementById('btnCotizarOT');
  if (!btnCot) {
    btnCot = document.createElement('button');
    btnCot.id = 'btnCotizarOT';
    btnCot.className = 'btn btn-primary';
    btnCot.textContent = '📑 Generar Cotización';
    btnCot.onclick = () => generarCotizacionDesdeOT(currentOTId);
    document.getElementById('modalDetalleOT').querySelector('.modal-footer').prepend(btnCot);
  }
  btnCot.style.display = (o.estado === 'finalizada') ? 'inline-flex' : 'none';
}

let currentOTId = null;
let buscarMatOTTimer = null;

async function buscarMatOT() {
  clearTimeout(buscarMatOTTimer);
  const q = document.getElementById('otDetMatBuscar')?.value.trim();
  if (!q || q.length < 2) { document.getElementById('sugerenciasMatOT').style.display='none'; return; }
  buscarMatOTTimer = setTimeout(async () => {
    const r = await api('controllers/InventarioController.php?action=buscar&q='+encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasMatOT');
    if (!r.data.data.length) { div.style.display='none'; return; }
    div.innerHTML = r.data.data.map(m =>
      `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="selMatOT(${m.id_material},'${m.nombre.replace(/'/g,"\\'")}',${m.precio_venta})">
        ${m.nombre} <span style="color:var(--muted);font-size:11px">${m.unidad_medida} | Stock: ${m.stock}</span>
      </div>`
    ).join('');
    div.style.display='block';
  }, 300);
}

function selMatOT(id, nombre, precio) {
  document.getElementById('otDetMatId').value=id;
  document.getElementById('otDetMatBuscar').value=nombre;
  document.getElementById('otDetPrecio').value=precio;
  document.getElementById('sugerenciasMatOT').style.display='none';
  document.getElementById('otDetCant').focus();
}

async function agregarMatOT(ordenId) {
  const matId  = +document.getElementById('otDetMatId').value;
  const cant   = parseFloat(document.getElementById('otDetCant').value);
  const precio = parseFloat(document.getElementById('otDetPrecio').value);
  if (!matId || isNaN(cant)||cant<=0) { toast('Selecciona material y cantidad.','warn'); return; }
  const r = await api('controllers/OrdenesController.php?action=agregar_material', { method:'POST', body:JSON.stringify({orden_id:ordenId, material_id:matId, cantidad:cant, precio_unitario:precio}) });
  if (r.ok) { toast('Material agregado.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}

async function quitarMatOT(detalleId, ordenId) {
  if (!await confirmDialog('¿Quitar este material de la OT? El stock será devuelto.')) return;
  const r = await api('controllers/OrdenesController.php?action=quitar_material', { method:'POST', body:JSON.stringify({id:detalleId}) });
  if (r.ok) { toast('Material removido.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}


function calcSubtotalLinea(i, tarifaBase) {
  const dias   = parseFloat(document.getElementById('moDias_'+i)?.value || 1);
  const tarifa = parseFloat(document.getElementById('moTarifa_'+i)?.value || tarifaBase);
  const sub    = document.getElementById('moSub_'+i);
  if (sub) sub.textContent = fmtMoneda(dias * tarifa * 1.35);
}

async function agregarMoLinea(ordenId, desc, i) {
  const dias   = parseFloat(document.getElementById('moDias_'+i)?.value || 1);
  const tarifa = parseFloat(document.getElementById('moTarifa_'+i)?.value || 0);
  const subtotal = dias * tarifa * 1.35;
  if (!desc) { toast('Descripción vacía.','warn'); return; }
  const r = await api('controllers/OrdenesController.php?action=agregar_mo', {
    method:'POST',
    body: JSON.stringify({orden_id:ordenId, descripcion:desc, dias, tarifa_dia:tarifa, subtotal_override:subtotal})
  });
  if (r.ok) { toast('Mano de obra agregada.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}

function calcSubtotalMO() {
  const dias   = parseFloat(document.getElementById('otMoHoras')?.value || 0);
  const tarifa = parseFloat(document.getElementById('otMoTarifa')?.value || 0);
  const sub    = document.getElementById('otMoSubtotal');
  if (sub) sub.textContent = fmtMoneda(dias * tarifa * 1.35);
}

async function agregarMoOT(ordenId) {
  const desc   = document.getElementById('otMoDesc').value.trim();
  const dias   = parseFloat(document.getElementById('otMoHoras').value);
  const tarifa = parseFloat(document.getElementById('otMoTarifa').value||0);
  if (!desc) { toast('Ingresa la descripción del servicio.','warn'); return; }
  const r = await api('controllers/OrdenesController.php?action=agregar_mo', { method:'POST', body:JSON.stringify({orden_id:ordenId, descripcion:desc, dias, tarifa_dia:tarifa, subtotal_override: dias * tarifa * 1.35}) });
  if (r.ok) { toast('Mano de obra agregada.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}

async function quitarMoOT(moId, ordenId) {
  if (!await confirmDialog('¿Quitar este servicio de la OT?')) return;
  const r = await api('controllers/OrdenesController.php?action=quitar_mo', { method:'POST', body:JSON.stringify({id:moId}) });
  if (r.ok) { toast('Servicio removido.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}

async function cambiarEstadoOT(id, estado) {
  const labels = { en_proceso:'iniciar esta OT', finalizada:'marcar esta OT como finalizada', anulada:'anular esta OT' };
  if (!await confirmDialog(`¿Deseas ${labels[estado]||'cambiar el estado'}?`)) return;
  const r = await api('controllers/OrdenesController.php?action=cambiar_estado', { method:'POST', body:JSON.stringify({id, estado}) });
  if (r.ok) { toast('Estado actualizado.','success'); cargarOrdenes(); }
  else toast(r.data.error||'Error.','error');
}

// ── USUARIOS (Fase 1 - mantenidos) ───────────────────────────
let rolesCache = [];
async function cargarRolesCache() {
  if (rolesCache.length) return;
  const r = await api('controllers/RolesController.php?action=listar');
  if (r.ok) rolesCache = r.data.data;
}
async function cargarUsuarios() {
  document.getElementById('tablaUsuariosWrap').innerHTML='<p class="loading">Cargando...</p>';
  const r = await api('controllers/UsuariosController.php?action=listar');
  if (!r.ok) { document.getElementById('tablaUsuariosWrap').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  let h = '<table><thead><tr><th>#</th><th>Nombre</th><th>Usuario</th><th>Rol</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  r.data.data.forEach(u => {
    h += `<tr><td>${u.id_usuario}</td><td>${u.nombre}</td><td><code style="color:var(--muted)">${u.usuario}</code></td><td>${u.rol}</td><td>${badgeEstado(u.estado)}</td>
    <td><div class="td-actions">
      <button class="btn btn-sm btn-secondary" onclick="editarUsuario(${u.id_usuario})">Editar</button>
      <button class="btn btn-sm ${u.estado==='activo'?'btn-danger':'btn-secondary'}" onclick="toggleUsuario(${u.id_usuario},'${u.estado==='activo'?'inactivo':'activo'}','${u.estado==='activo'?'Desactivar':'Activar'}')">${u.estado==='activo'?'Desactivar':'Activar'}</button>
    </div></td></tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaUsuariosWrap').innerHTML = h;
}
document.getElementById('btnNuevoUsuario').addEventListener('click', async () => {
  await cargarRolesCache();
  ['uId','uNombre','uUsuario','uPassword'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('uUsuario').disabled=false; document.getElementById('uPassNote').textContent='';
  document.getElementById('modalUsuarioTitulo').textContent='Nuevo Usuario'; document.getElementById('modalUsuarioError').style.display='none';
  llenarSelectRoles();
  await cargarEmpleadosSelectUsuario();
  abrirModal('modalUsuario');
});
async function editarUsuario(id) {
  await cargarRolesCache();
  const r = await api('controllers/UsuariosController.php?action=obtener&id='+id);
  if (!r.ok) { toast('Error.','error'); return; }
  const u = r.data.data;
  document.getElementById('uId').value=u.id_usuario; document.getElementById('uNombre').value=u.nombre;
  document.getElementById('uUsuario').value=u.usuario; document.getElementById('uUsuario').disabled=true;
  document.getElementById('uPassword').value=''; document.getElementById('uPassNote').textContent='(dejar vacío para no cambiar)';
  document.getElementById('modalUsuarioTitulo').textContent='Editar Usuario'; document.getElementById('modalUsuarioError').style.display='none';
  llenarSelectRoles(u.rol_id);
  await cargarEmpleadosSelectUsuario(u.empleado_id);
  abrirModal('modalUsuario');
}
function llenarSelectRoles(sel=null) { document.getElementById('uRol').innerHTML=rolesCache.map(r=>`<option value="${r.id_rol}" ${r.id_rol==sel?'selected':''}>${r.nombre}</option>`).join(''); }
async function cargarEmpleadosSelectUsuario(selId=null) {
  const sel = document.getElementById('uEmpleadoId');
  if (!sel) return;
  try {
    const r = await api('controllers/UsuariosController.php?action=empleados');
    sel.innerHTML = '<option value="">— Sin empleado vinculado —</option>';
    if (r.ok) r.data.data.forEach(e => {
      sel.innerHTML += `<option value="${e.id_empleado}" ${e.id_empleado==selId?'selected':''}>${e.nombre}</option>`;
    });
  } catch(e) { sel.innerHTML = '<option value="">— Error al cargar —</option>'; }
}
document.getElementById('btnGuardarUsuario').addEventListener('click', async () => {
  const id=document.getElementById('uId').value, nombre=document.getElementById('uNombre').value.trim();
  const usuario=document.getElementById('uUsuario').value.trim(), password=document.getElementById('uPassword').value;
  const rol_id=document.getElementById('uRol').value;
  const empleado_id=document.getElementById('uEmpleadoId').value||null;
  const errEl=document.getElementById('modalUsuarioError');
  errEl.style.display='none';
  if (!nombre||!rol_id||(!id&&(!usuario||!password))) { errEl.textContent='Completa todos los campos.'; errEl.style.display='block'; return; }
  const body=id?{id:+id,nombre,rol_id:+rol_id,password,empleado_id:empleado_id?+empleado_id:null}:{nombre,usuario,password,rol_id:+rol_id,empleado_id:empleado_id?+empleado_id:null};
  const r=await api('controllers/UsuariosController.php?action='+(id?'editar':'crear'),{method:'POST',body:JSON.stringify(body)});
  if (r.ok) { cerrarModal('modalUsuario'); toast(id?'Usuario actualizado.':'Usuario creado.','success'); cargarUsuarios(); }
  else { errEl.textContent=r.data.error||'Error.'; errEl.style.display='block'; }
});
async function toggleUsuario(id,estado,label) {
  if (!await confirmDialog(`¿${label} este usuario?`)) return;
  const r=await api('controllers/UsuariosController.php?action=estado',{method:'POST',body:JSON.stringify({id,estado})});
  if (r.ok) { toast(`Usuario ${estado==='activo'?'activado':'desactivado'}.`,'success'); cargarUsuarios(); }
  else toast(r.data.error||'Error.','error');
}

// ROLES
const MODULOS = ['usuarios','roles','clientes','ordenes_trabajo','cotizaciones','facturacion','inventario','compras','pagos','planillas','reportes'];
async function cargarRoles() {
  await cargarRolesCache();
  let html='';
  for (const rol of rolesCache) {
    const pr=await api('controllers/RolesController.php?action=permisos&rol_id='+rol.id_rol);
    const pm={}; (pr.ok?pr.data.data:[]).forEach(p=>{pm[p.modulo]=p;});
    html+=`<div style="margin-bottom:22px"><h5 style="color:var(--accent);margin-bottom:10px;font-size:13px">🔑 ${rol.nombre}</h5>
    <div class="permisos-wrap" style="overflow-x:auto"><table style="min-width:380px"><thead><tr><th>Módulo</th><th style="text-align:center">Ver</th><th style="text-align:center">Crear</th><th style="text-align:center">Editar</th><th style="text-align:center">Eliminar</th></tr></thead><tbody>`;
    MODULOS.forEach(mod=>{
      const p=pm[mod]||{}; ['puede_ver','puede_crear','puede_editar','puede_eliminar'].forEach(a=>{if(!p[a])p[a]=0;});
      html+=`<tr><td style="text-transform:capitalize;white-space:nowrap;font-size:13px">${mod.replace(/_/g,' ')}</td>${['puede_ver','puede_crear','puede_editar','puede_eliminar'].map(acc=>`<td style="text-align:center"><input type="checkbox" data-rol="${rol.id_rol}" data-mod="${mod}" data-acc="${acc}" ${p[acc]?'checked':''}></td>`).join('')}</tr>`;
    });
    html+=`</tbody></table></div><button class="btn btn-sm btn-primary" style="margin-top:8px" onclick="guardarPermisos(${rol.id_rol})">💾 Guardar permisos de ${rol.nombre}</button><hr style="border-color:var(--border);margin-top:18px"></div>`;
  }
  document.getElementById('rolesWrap').innerHTML=html;
}
async function guardarPermisos(rol_id) {
  const pm={};
  document.querySelectorAll(`input[data-rol="${rol_id}"]`).forEach(cb=>{
    const mod=cb.dataset.mod,acc=cb.dataset.acc;
    if(!pm[mod])pm[mod]={modulo:mod,puede_ver:0,puede_crear:0,puede_editar:0,puede_eliminar:0};
    pm[mod][acc]=cb.checked?1:0;
  });
  const r=await api('controllers/RolesController.php?action=guardar_permisos',{method:'POST',body:JSON.stringify({rol_id,permisos:Object.values(pm)})});
  if(r.ok)toast('Permisos guardados.','success'); else toast(r.data.error||'Error.','error');
}

// Cargar inicio al arrancar
cargarInicio();

// ══════════════════════════════════════════════════════════
// COTIZACIONES
// ══════════════════════════════════════════════════════════
let cotizacionesData = [];
let itemsCotDir      = [];

async function cargarCotizaciones() {
  document.getElementById('tablaCotizaciones').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoCot').value;
  const r = await api('controllers/CotizacionesController.php?action=listar' + (estado ? '&estado=' + estado : ''));
  if (!r.ok) { document.getElementById('tablaCotizaciones').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  cotizacionesData = r.data.data;
  document.getElementById('buscarCotizacion').value = '';
  paginaActual['cotizaciones'] = 1;
  renderTablaCotizaciones(cotizacionesData);
}

function filtrarCotizaciones() {
  const q = document.getElementById('buscarCotizacion').value.toLowerCase().trim();
  paginaActual['cotizaciones'] = 1;
  if (!q) { renderTablaCotizaciones(cotizacionesData); return; }
  renderTablaCotizaciones(cotizacionesData.filter(c =>
    c.numero_cotizacion.toLowerCase().includes(q) ||
    c.cliente.toLowerCase().includes(q) ||
    (c.numero_orden  && c.numero_orden.toLowerCase().includes(q))  ||
    (c.ot_cliente    && c.ot_cliente.toLowerCase().includes(q))    ||
    (c.orden_compra  && c.orden_compra.toLowerCase().includes(q))
  ));
}

function renderTablaCotizaciones(rows) {
  const pag = paginar('cotizaciones', rows);
  let h = '<table><thead><tr><th>Número</th><th>Cliente</th><th>OT Origen</th><th>OT Cliente</th><th>OC</th><th>Modo</th><th>Fecha</th><th>Total</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="8" class="empty-state">Sin cotizaciones</td></tr>';
  pag.slice.forEach(c => {
    const estadosBtns=[];
    const esAdmin=(rol||'').toLowerCase()==='administrador';
    if(c.estado==='pendiente') estadosBtns.push(`<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoCot(${c.id_cotizacion},'pendiente_aprobacion')">📤 Solicitar Aprobación</button>`);
    if(c.estado==='pendiente_aprobacion'&&esAdmin) estadosBtns.push(`<button class="btn btn-sm btn-success" onclick="cambiarEstadoCot(${c.id_cotizacion},'aprobada')">✓ Aprobar</button>`,`<button class="btn btn-sm btn-danger" onclick="cambiarEstadoCot(${c.id_cotizacion},'rechazada')">✗ Rechazar</button>`);
    if(c.estado==='pendiente_aprobacion'&&!esAdmin) estadosBtns.push(`<span style="font-size:11px;color:var(--muted);padding:4px 8px">⏳ Esperando aprobación</span>`);
    if(c.estado==='aprobada') estadosBtns.push(`<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoCot(${c.id_cotizacion},'enviada')">📨 Marcar Enviada</button>`);
    if(c.estado==='enviada') estadosBtns.push(`<button class="btn btn-sm btn-success" onclick="cambiarEstadoCot(${c.id_cotizacion},'aprobada_cliente')">✅ Aprobada por Cliente</button>`,`<button class="btn btn-sm btn-danger" onclick="cambiarEstadoCot(${c.id_cotizacion},'rechazada')">✗ Rechazada por Cliente</button>`);
    if(c.estado==='aprobada_cliente') estadosBtns.push(`<span class="badge badge-green" style="padding:5px 10px">✅ Listo para facturar</span>`);
    h += `<tr>
      <td><strong>${c.numero_cotizacion}</strong></td>
      <td>${c.cliente}</td>
      <td>${c.numero_orden || '<span style="color:var(--muted)">Directa</span>'}</td>
      <td><span style="font-family:monospace;font-size:12px">${c.ot_cliente || '<span style="color:var(--muted)">—</span>'}</span></td>
      <td><span style="font-family:monospace;font-size:12px">${c.orden_compra || '<span style="color:var(--muted)">—</span>'}</span></td>
      <td><span class="badge ${c.modo === 'POST_TRABAJO' ? 'badge-blue' : 'badge-gray'}">${c.modo === 'POST_TRABAJO' ? 'Post OT' : 'Directa'}</span></td>
      <td>${c.fecha}</td>
      <td><strong>${fmtMoneda(c.total)}</strong></td>
      <td>${badgeEstado(c.estado)}${c.estado==='rechazada'&&c.motivo_rechazo?`<div style="font-size:10px;color:var(--danger);margin-top:2px" title="${c.motivo_rechazo}">↳ ${c.motivo_rechazo.length>32?c.motivo_rechazo.slice(0,32)+'…':c.motivo_rechazo}</div>`:''}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleCot(${c.id_cotizacion})">Ver</button>
        <a href="controllers/CotizacionPDFController.php?action=pdf&id=${c.id_cotizacion}" target="_blank" class="btn btn-sm btn-secondary">📄 PDF</a>
        <button class="btn btn-sm btn-secondary" onclick="exportarCotizacionExcel(${c.id_cotizacion})">⬇️ Excel</button>
        ${estadosBtns.join('')}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaCotizaciones').innerHTML = h;
  renderPaginacion('cotizaciones', pag, 'paginaCotizaciones');
}

async function verDetalleCot(id) {
  document.getElementById('contenidoDetalleCot').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalDetalleCot');
  const r = await api('controllers/CotizacionesController.php?action=obtener&id=' + id);
  if (!r.ok) { document.getElementById('contenidoDetalleCot').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const c = r.data.data;

  const refStyle = 'font-family:monospace;font-size:13px;font-weight:600;color:var(--text)';

  let h = `<h4>📑 ${c.numero_cotizacion} ${badgeEstado(c.estado)}</h4>
  ${c.estado === 'rechazada' ? `
  <div style="background:#2a0a0a;border:1px solid #c00;border-radius:8px;padding:10px 14px;margin-bottom:12px">
    <div style="color:#ff4444;font-weight:700;font-size:13px;letter-spacing:1px">✗ COTIZACIÓN RECHAZADA</div>
    ${c.motivo_rechazo ? `<div style="color:#ff8888;font-size:12px;margin-top:4px">MOTIVO: ${c.motivo_rechazo}</div>` : ''}
  </div>` : ''}
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${c.cliente}</strong></div>
    <div><span style="color:var(--muted)">Modo:</span> ${c.modo === 'POST_TRABAJO' ? '📋 Post OT' : '✏️ Directa'}</div>
    <div><span style="color:var(--muted)">Fecha:</span> ${c.fecha}</div>
    <div><span style="color:var(--muted)">Vigencia:</span> ${c.vigencia_dias} días</div>
    ${c.numero_orden ? `<div><span style="color:var(--muted)">OT origen:</span> <strong>${c.numero_orden}</strong></div>` : ''}
  </div>

  <!-- Referencias del cliente -->
  <div style="background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:12px 16px;margin-bottom:14px">
    <div style="font-size:11px;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);margin-bottom:10px;font-weight:600">📌 Referencias del Cliente</div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;align-items:end">
      <div>
        <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:4px">OT Cliente</label>
        ${c.estado === 'facturada'
          ? `<div style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;font-family:monospace;font-size:13px">${c.ot_cliente || '<span style="color:var(--muted)">—</span>'}</div>`
          : `<input type="text" id="editOtCliente" value="${c.ot_cliente || ''}" placeholder="Ej: 4007731855"
          style="width:100%;padding:7px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;font-family:monospace;outline:none">`
        }
      </div>
      <div>
        <label style="font-size:11px;color:var(--muted);display:block;margin-bottom:4px">Orden de Compra (OC)</label>
        ${c.estado === 'facturada'
          ? `<div style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;font-family:monospace;font-size:13px">${c.orden_compra || '<span style="color:var(--muted)">—</span>'}</div>`
          : `<input type="text" id="editOrdenCompra" value="${c.orden_compra || ''}" placeholder="Ej: 5503905114"
          style="width:100%;padding:7px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;font-family:monospace;outline:none">`
        }
      </div>
    </div>
    ${c.estado !== 'facturada' ? `
    <div style="margin-top:10px;display:flex;align-items:center;gap:10px">
      <button class="btn btn-sm btn-secondary" onclick="guardarReferencias(${c.id_cotizacion})">💾 Guardar referencias</button>
      <span id="refGuardadoMsg" style="font-size:12px;color:var(--success);display:none">✔ Guardado</span>
    </div>` : `<div style="margin-top:8px;font-size:11px;color:var(--muted)">🔒 Facturada — referencias de solo lectura.</div>`}
  </div>

  <div class="section-title">📋 Detalle</div>
  <div class="table-wrap"><table>
    <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal base</th><th>Subtotal final</th></tr></thead>
    <tbody>`;
  c.detalle.forEach(d => {
    const tipo = d.tipo === 'mano_obra' ? '👷 Mano de obra' : '📦 Material';
    h += `<tr><td>${tipo}</td><td>${d.descripcion}</td><td>${d.cantidad}</td>
          <td>${fmtMoneda(d.precio_unitario)}</td>
          <td>${fmtMoneda(d.subtotal_base)}</td>
          <td><strong>${fmtMoneda(d.subtotal_final)}</strong></td></tr>`;
  });
  h += `</tbody></table></div>
  <div style="text-align:right;margin-top:14px;font-size:13px;line-height:2;color:var(--muted)">
    Materiales: ${fmtMoneda(c.subtotal_materiales)}<br>
    Mano de obra: ${fmtMoneda(c.subtotal_mano_obra)}<br>
    Subtotal: ${fmtMoneda(c.subtotal_comercial)}<br>
    ISV 15%: ${fmtMoneda(c.isv)}<br>
    <strong style="font-size:16px;color:var(--accent)">TOTAL: ${fmtMoneda(c.total)}</strong>
  </div>`;
  if (c.observaciones) h += `<p style="font-size:12px;color:var(--muted);margin-top:10px">${c.observaciones}</p>`;
  document.getElementById('contenidoDetalleCot').innerHTML = h;

  // Botón "Facturar" — solo si cotización está aprobada
  let btnFac = document.getElementById('btnFacturarCot');
  if (!btnFac) {
    btnFac = document.createElement('button');
    btnFac.id = 'btnFacturarCot';
    btnFac.className = 'btn btn-primary';
    btnFac.textContent = '🧾 Facturar';
    btnFac.onclick = () => abrirModalFacturar(currentCotId);
    document.getElementById('footerDetalleCot').prepend(btnFac);
  }
  currentCotId = c.id_cotizacion;
  btnFac.style.display = c.estado === 'aprobada_cliente' ? 'inline-flex' : 'none';

  // Botones PDF y Excel en footer (crear si no existen)
  const footerCot = document.getElementById('footerDetalleCot');
  if (!document.getElementById('btnCotPDF')) {
    const lnkPDF = document.createElement('a');
    lnkPDF.id = 'btnCotPDF';
    lnkPDF.className = 'btn btn-secondary';
    lnkPDF.textContent = '📄 PDF';
    lnkPDF.target = '_blank';
    footerCot.prepend(lnkPDF);

    const lnkXLS = document.createElement('a');
    lnkXLS.id = 'btnCotExcel';
    lnkXLS.className = 'btn btn-secondary';
    lnkXLS.textContent = '⬇️ Excel';
    footerCot.prepend(lnkXLS);
  }
  document.getElementById('btnCotPDF').href   = 'controllers/CotizacionPDFController.php?action=pdf&id='   + c.id_cotizacion;
  document.getElementById('btnCotExcel').onclick = () => exportarCotizacionExcel(c.id_cotizacion);
  document.getElementById('btnCotExcel').removeAttribute('href');
}

async function guardarReferencias(cotizacion_id) {
  const ot_cliente   = document.getElementById('editOtCliente').value.trim();
  const orden_compra = document.getElementById('editOrdenCompra').value.trim();
  const r = await api('controllers/CotizacionesController.php?action=actualizar_referencias', {
    method: 'POST',
    body: JSON.stringify({ id: cotizacion_id, ot_cliente, orden_compra })
  });
  if (r.ok) {
    const msg = document.getElementById('refGuardadoMsg');
    msg.style.display = 'inline';
    setTimeout(() => { msg.style.display = 'none'; }, 2500);
    cargarCotizaciones();
  } else {
    toast(r.data.error || 'Error al guardar referencias.', 'error');
  }
}

async function cambiarEstadoCot(id, estado) {
  if (estado === 'rechazada') {
    // Modal de motivo de rechazo
    const motivo = await pedirMotivoRechazo();
    if (motivo === null) return; // canceló
    const r = await api('controllers/CotizacionesController.php?action=cambiar_estado', {
      method: 'POST', body: JSON.stringify({ id, estado, motivo_rechazo: motivo })
    });
    if (r.ok) { toast('Cotización rechazada.', 'success'); cargarCotizaciones(); }
    else toast(r.data.error || 'Error.', 'error');
    return;
  }
  const esAdmin=(rol||'').toLowerCase()==='administrador';
  if(estado==='aprobada'&&!esAdmin){toast('Solo el Administrador puede aprobar cotizaciones.','error');return;}
  const labels={pendiente_aprobacion:'enviar a aprobación del Administrador',aprobada:'aprobar esta cotización',enviada:'marcar como enviada al cliente',aprobada_cliente:'registrar que el cliente aprobó (habilitará Facturar)',rechazada:'registrar el rechazo'};
  if(!await confirmDialog(`¿Deseas ${labels[estado]||'cambiar el estado de esta cotización'}?`))return;
  const r=await api('controllers/CotizacionesController.php?action=cambiar_estado',{method:'POST',body:JSON.stringify({id,estado})});
  if(r.ok){toast('Estado actualizado.','success');cargarCotizaciones();}
  else toast(r.data.error||'Error.','error');
}

function pedirMotivoRechazo() {
  return new Promise(resolve => {
    // Crear mini-modal inline
    const overlay = document.createElement('div');
    overlay.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:9999;display:flex;align-items:center;justify-content:center';
    overlay.innerHTML = `
      <div style="background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:24px;width:380px;max-width:95vw">
        <h4 style="margin:0 0 6px;font-size:15px">✗ Rechazar Cotización</h4>
        <p style="font-size:12px;color:var(--muted);margin:0 0 14px">Ingresa el motivo del rechazo (requerido)</p>
        <textarea id="_motivoRechazoCot" rows="3" placeholder="Ej: PRECIO FUERA DE PRESUPUESTO..."
          style="width:100%;padding:9px 11px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px;outline:none;resize:vertical;font-family:inherit;text-transform:uppercase;box-sizing:border-box"></textarea>
        <div id="_errMotivoRechazo" style="color:var(--danger);font-size:12px;margin-top:6px;display:none">El motivo es requerido.</div>
        <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px">
          <button class="btn btn-secondary" id="_btnCancelRechazo">Cancelar</button>
          <button class="btn btn-danger"    id="_btnConfRechazo">✗ Rechazar</button>
        </div>
      </div>`;
    document.body.appendChild(overlay);
    const ta  = overlay.querySelector('#_motivoRechazoCot');
    const err = overlay.querySelector('#_errMotivoRechazo');
    ta.addEventListener('input', () => { ta.value = ta.value.toUpperCase(); });
    ta.focus();
    overlay.querySelector('#_btnCancelRechazo').onclick = () => { document.body.removeChild(overlay); resolve(null); };
    overlay.querySelector('#_btnConfRechazo').onclick   = () => {
      const v = ta.value.trim();
      if (!v) { err.style.display='block'; return; }
      document.body.removeChild(overlay);
      resolve(v.toUpperCase());
    };
  });
}

// ── COTIZACIÓN DESDE OT (botón en detalle OT) ────────────────
async function generarCotizacionDesdeOT(orden_id) {
  if (!await confirmDialog('¿Generar cotización desde esta OT? Se usarán los materiales y mano de obra registrados.')) return;
  const r = await api('controllers/CotizacionesController.php?action=desde_ot', {
    method: 'POST', body: JSON.stringify({ orden_id, vigencia_dias: 15 })
  });
  if (r.ok) {
    toast(`Cotización ${r.data.cotizacion.numero_cotizacion} generada correctamente.`, 'success');
    cerrarModal('modalDetalleOT');
    // Navegar al módulo cotizaciones
    document.querySelector('.nav-item[data-module="cotizaciones"]').click();
  } else toast(r.data.error || 'Error.', 'error');
}

// ── COTIZACIÓN DIRECTA ───────────────────────────────────────
function abrirModalCotizacionDirecta() {
  itemsCotDir = [];
  document.getElementById('cotDirClienteBuscar').value = '';
  document.getElementById('cotDirClienteId').value = '';
  document.getElementById('cotDirVigencia').value = '15';
  document.getElementById('cotDirObs').value = '';
  document.getElementById('cotDirOtCliente').value = '';
  document.getElementById('cotDirOrdenCompra').value = '';
  document.getElementById('cotDirDesc').value = '';
  document.getElementById('cotDirCant').value = '1';
  document.getElementById('cotDirPrecio').value = '';
  document.getElementById('cotDirPlaca').value = '';
  document.getElementById('errCotDir').style.display = 'none';
  const selVeh = document.getElementById('cotDirVehiculoSelect');
  if (selVeh) selVeh.innerHTML = '<option value="">— Sin vehículo / No aplica —</option>';
  renderItemsCotDir();
  abrirModal('modalCotizacionDirecta');
}

let buscarClienteCotDirTimer = null;
function buscarClienteCotDir() {
  clearTimeout(buscarClienteCotDirTimer);
  const q = document.getElementById('cotDirClienteBuscar').value.trim();
  if (q.length < 2) { document.getElementById('sugerenciasClienteCotDir').style.display = 'none'; return; }
  buscarClienteCotDirTimer = setTimeout(async () => {
    const r = await api('controllers/ClientesController.php?action=buscar&q=' + encodeURIComponent(q));
    if (!r.ok) return;
    const div = document.getElementById('sugerenciasClienteCotDir');
    if (!r.data.data.length) { div.style.display = 'none'; return; }
    div.innerHTML = r.data.data.map(c =>
      `<div style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)" onmousedown="selClienteCotDir(${c.id_cliente},'${c.nombre.replace(/'/g,"\\'")}')">
        ${c.nombre} <span style="color:var(--muted);font-size:11px">${c.rtn || ''}</span>
      </div>`
    ).join('');
    div.style.display = 'block';
  }, 300);
}

function selClienteCotDir(id, nombre) {
  document.getElementById('cotDirClienteId').value = id;
  document.getElementById('cotDirClienteBuscar').value = nombre;
  document.getElementById('sugerenciasClienteCotDir').style.display = 'none';
  cargarVehiculosCotDir(id);
}

async function cargarVehiculosCotDir(clienteId) {
  const sel = document.getElementById('cotDirVehiculoSelect');
  if (!sel) return;
  sel.innerHTML = '<option value="">Cargando...</option>';
  try {
    const r = await api('controllers/VehiculosController.php?action=por_cliente&cliente_id=' + clienteId);
    sel.innerHTML = '<option value="">— Sin vehículo / No aplica —</option>';
    if (r.ok && r.data.data.length) {
      r.data.data.forEach(v => {
        const label = `${v.placa}${v.marca ? ' — ' + v.marca : ''}${v.modelo ? ' ' + v.modelo : ''}${v.anio ? ' ' + v.anio : ''}`;
        sel.innerHTML += `<option value="${v.id_vehiculo}" data-placa="${v.placa}">${label}</option>`;
      });
    } else {
      sel.innerHTML += '<option value="" disabled>— Sin vehículos registrados —</option>';
    }
  } catch(e) {
    sel.innerHTML = '<option value="">— Error al cargar —</option>';
  }
}

function autoLlenarPlacaCotDir() {
  const sel = document.getElementById('cotDirVehiculoSelect');
  const opt = sel.options[sel.selectedIndex];
  if (!opt || !opt.value) return;
  document.getElementById('cotDirPlaca').value = opt.dataset.placa || '';
}

function agregarItemCotDir() {
  const desc   = document.getElementById('cotDirDesc').value.trim();
  const tipo   = document.getElementById('cotDirTipo').value;
  const cant   = parseFloat(document.getElementById('cotDirCant').value);
  const precio = parseFloat(document.getElementById('cotDirPrecio').value);
  if (!desc || isNaN(cant) || cant <= 0 || isNaN(precio) || precio < 0) {
    toast('Completa descripción, cantidad y precio.', 'warn'); return;
  }
  itemsCotDir.push({ descripcion: desc, tipo, cantidad: cant, precio_unitario: precio });
  document.getElementById('cotDirDesc').value = '';
  document.getElementById('cotDirCant').value = '1';
  document.getElementById('cotDirPrecio').value = '';
  renderItemsCotDir();
}

function renderItemsCotDir() {
  const tbody = document.getElementById('itemsCotDirBody');
  if (!itemsCotDir.length) {
    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Sin ítems</td></tr>';
    document.getElementById('cotDirSubtotalMostrar').textContent = 'L. 0.00';
    document.getElementById('cotDirTotalMostrar').textContent    = 'L. 0.00';
    return;
  }
  tbody.innerHTML = itemsCotDir.map((it, i) => {
    const sub = it.cantidad * it.precio_unitario;
    return `<tr>
      <td><span class="badge ${it.tipo === 'mano_obra' ? 'badge-yellow' : 'badge-blue'}">${it.tipo === 'mano_obra' ? 'MO' : it.tipo === 'otro' ? 'Otro' : 'Mat.'}</span></td>
      <td>${it.descripcion}</td><td>${it.cantidad}</td>
      <td>${fmtMoneda(it.precio_unitario)}</td>
      <td>${fmtMoneda(sub)}</td>
      <td><button class="btn btn-sm btn-danger" onclick="quitarItemCotDir(${i})">✕</button>
          <button class="btn btn-sm btn-secondary" onclick="guardarItemEnCatalogo('${it.descripcion.replace(/'/g,"\\'")}','${it.tipo}',${it.precio_unitario})" title="Guardar al catálogo de precios">💾</button></td>
    </tr>`;
  }).join('');
  const subtotal = itemsCotDir.reduce((a, it) => a + it.cantidad * it.precio_unitario, 0);
  // Los precios ingresados ya llevan margen. Solo se agrega ISV 15%.
  const totalEst = subtotal * 1.15;
  document.getElementById('cotDirSubtotalMostrar').textContent = fmtMoneda(subtotal);
  document.getElementById('cotDirTotalMostrar').textContent    = fmtMoneda(totalEst);
}

function quitarItemCotDir(i) { itemsCotDir.splice(i, 1); renderItemsCotDir(); }

async function guardarCotizacionDirecta() {
  const clienteId = +document.getElementById('cotDirClienteId').value;
  const errEl     = document.getElementById('errCotDir');
  errEl.style.display = 'none';
  if (!clienteId)          { errEl.textContent = 'Selecciona un cliente.';            errEl.style.display = 'block'; return; }
  if (!itemsCotDir.length) { errEl.textContent = 'Agrega al menos un ítem.';          errEl.style.display = 'block'; return; }
  const body = {
    cliente_id:    clienteId,
    vigencia_dias: +document.getElementById('cotDirVigencia').value || 15,
    observaciones: document.getElementById('cotDirObs').value.trim(),
    ot_cliente:    document.getElementById('cotDirOtCliente').value.trim(),
    orden_compra:  document.getElementById('cotDirOrdenCompra').value.trim(),
    unidad:        document.getElementById('cotDirPlaca').value.trim(),
    items: itemsCotDir,
  };
  const r = await api('controllers/CotizacionesController.php?action=directa', {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) {
    cerrarModal('modalCotizacionDirecta');
    toast(`Cotización ${r.data.cotizacion.numero_cotizacion} creada.`, 'success');
    cargarCotizaciones();
  } else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ══════════════════════════════════════════════════════════
// FASE 3 — FACTURACIÓN
// ══════════════════════════════════════════════════════════
let facturasData          = [];
let metodoPagoFacSeleccionado = '';

// ── KPIs + tabla ─────────────────────────────────────────
async function cargarFacturacion() {
  cargarKPIsFacturacion();
  cargarFacturas();
}

async function cargarKPIsFacturacion() {
  const r = await api('controllers/FacturacionController.php?action=kpis');
  if (!r.ok) return;
  const k = r.data.data;
  document.getElementById('kpiFacTotal').textContent    = k.total_mes      || '0';
  document.getElementById('kpiFacMonto').textContent    = fmtMoneda(k.monto_mes || 0);
  document.getElementById('kpiFacPendientes').textContent = k.pendientes_cobro || '0';
  document.getElementById('kpiFacAnuladas').textContent = k.anuladas_mes    || '0';
}

async function cargarFacturas() {
  document.getElementById('tablaFacturas').innerHTML = '<p class="loading">Cargando...</p>';
  const estado = document.getElementById('filtroEstadoFac').value;
  const r = await api('controllers/FacturacionController.php?action=listar' + (estado ? '&estado=' + estado : ''));
  if (!r.ok) { document.getElementById('tablaFacturas').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  facturasData = r.data.data;
  document.getElementById('buscarFactura').value = '';
  paginaActual['facturacion'] = 1;
  renderTablaFacturas(facturasData);
}

function filtrarFacturas() {
  const q = document.getElementById('buscarFactura').value.toLowerCase().trim();
  paginaActual['facturacion'] = 1;
  if (!q) { renderTablaFacturas(facturasData); return; }
  renderTablaFacturas(facturasData.filter(f =>
    f.numero_factura.toLowerCase().includes(q) ||
    f.cliente.toLowerCase().includes(q) ||
    (f.numero_cotizacion && f.numero_cotizacion.toLowerCase().includes(q))
  ));
}

function renderTablaFacturas(rows) {
  const pag = paginar('facturacion', rows);
  let h = '<table><thead><tr><th>Número</th><th>Cliente</th><th>RTN</th><th>Cotización</th><th>Fecha</th><th>Subtotal</th><th>ISV</th><th>Total</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin facturas</td></tr>';
  pag.slice.forEach(f => {
    h += `<tr>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.cliente_rtn || '—'}</td>
      <td>${f.numero_cotizacion || '<span style="color:var(--muted)">—</span>'}</td>
      <td>${f.fecha}</td>
      <td>${fmtMoneda(f.subtotal)}</td>
      <td>${fmtMoneda(f.isv)}</td>
      <td><strong style="color:var(--accent)">${fmtMoneda(f.total)}</strong></td>
      <td>${badgeEstado(f.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetalleFactura(${f.id_factura})">Ver</button>
        ${f.estado !== 'anulada' && f.estado !== 'pagada' ? `<button class="btn btn-sm btn-danger" onclick="abrirAnulacion(${f.id_factura},'${f.numero_factura}')">Anular</button>` : ''}
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaFacturas').innerHTML = h;
  renderPaginacion('facturacion', pag, 'paginaFacturas');
}

// ── DETALLE FACTURA ──────────────────────────────────────
async function verDetalleFactura(id) {
  document.getElementById('contenidoDetalleFactura').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('footerDetalleFactura').innerHTML = '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetalleFactura\')">Cerrar</button>';
  abrirModal('modalDetalleFactura');
  const r = await api('controllers/FacturacionController.php?action=obtener&id=' + id);
  if (!r.ok) { document.getElementById('contenidoDetalleFactura').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const f = r.data.data;

  let h = `
  <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:16px;flex-wrap:wrap;gap:12px">
    <div>
      <h4 style="font-family:monospace;font-size:18px;margin-bottom:4px">${f.numero_factura}</h4>
      <div style="font-size:12px;color:var(--muted)">CAI: <span style="font-family:monospace">${f.cai_codigo || 'N/A'}</span></div>
      ${f.fecha_limite_emision ? `<div style="font-size:12px;color:var(--muted)">Fecha límite emisión: ${f.fecha_limite_emision}</div>` : ''}
    </div>
    <div style="text-align:right">${badgeEstado(f.estado)}<br><span style="font-size:13px;color:var(--muted)">${f.fecha}</span></div>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${f.cliente}</strong></div>
    <div><span style="color:var(--muted)">RTN:</span> ${f.cliente_rtn || '—'}</div>
    <div><span style="color:var(--muted)">Dirección:</span> ${f.cliente_direccion || '—'}</div>
    <div><span style="color:var(--muted)">Teléfono:</span> ${f.cliente_tel || '—'}</div>
    ${f.numero_cotizacion ? `<div><span style="color:var(--muted)">Cotización:</span> ${f.numero_cotizacion}</div>` : ''}
    ${f.numero_orden ? `<div><span style="color:var(--muted)">OT:</span> ${f.numero_orden}</div>` : ''}
    <div><span style="color:var(--muted)">Método de pago:</span> ${f.metodo_pago || '—'}</div>
    <div><span style="color:var(--muted)">Emitida por:</span> ${f.usuario}</div>
  </div>
  <div class="section-title">📋 Detalle de servicios</div>
  <div class="table-wrap"><table>
    <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal</th></tr></thead>
    <tbody>`;
  f.detalle.forEach(d => {
    const tipo = d.tipo === 'mano_obra' ? '👷' : '📦';
    h += `<tr><td>${tipo}</td><td>${d.descripcion}</td><td>${d.cantidad}</td>
          <td>${fmtMoneda(d.precio_unitario)}</td>
          <td>${fmtMoneda(d.subtotal_final)}</td></tr>`;
  });
  h += `</tbody></table></div>
  <div style="text-align:right;margin-top:14px;font-size:13px;line-height:2.2;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px">
    <span style="color:var(--muted)">Subtotal (sin ISV):</span> ${fmtMoneda(f.subtotal)}<br>
    <span style="color:var(--muted)">ISV 15%:</span> ${fmtMoneda(f.isv)}<br>
    <strong style="font-size:18px;color:var(--accent)">TOTAL: ${fmtMoneda(f.total)}</strong>
  </div>`;
  if (f.observaciones) h += `<p style="font-size:12px;color:var(--muted);margin-top:10px">${f.observaciones}</p>`;
  document.getElementById('contenidoDetalleFactura').innerHTML = h;

  // Footer dinámico según estado
  const footer = document.getElementById('footerDetalleFactura');
  footer.innerHTML = '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetalleFactura\')">Cerrar</button>';
}

// ── FACTURA DIRECTA (sin cotización) ────────────────────
let fdMetodoSeleccionado = '';
let fdItemCount = 0;

async function abrirModalFacturaDirecta() {
  // Verificar CAI activo
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    toast('No hay CAI activo. Configure el CAI antes de facturar.', 'error');
    setTimeout(() => abrirModalCAI(), 800);
    return;
  }
  // Reset
  fdMetodoSeleccionado = '';
  fdItemCount = 0;
  document.getElementById('fdItemsWrap').innerHTML = '';
  document.getElementById('fdObservaciones').value = '';
  document.getElementById('fdReferencia').value = '';
  document.getElementById('fdRefGrupo').style.display = 'none';
  document.getElementById('fdNotaMetodo').style.display = 'none';
  document.getElementById('errFacturaDirecta').style.display = 'none';
  document.getElementById('fdFecha').value = new Date().toISOString().slice(0, 10);
  document.querySelectorAll('.fd-metodo-btn').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  fdRecalcular();
  // Cargar clientes en select
  const sel = document.getElementById('fdClienteId');
  sel.innerHTML = '<option value="">— Seleccionar cliente —</option>';
  const rCli = await api('controllers/ClientesController.php?action=listar');
  if (rCli.ok && rCli.data.data) {
    rCli.data.data.forEach(c => {
      const o = document.createElement('option');
      o.value = c.id_cliente;
      o.textContent = c.nombre + (c.rtn ? ' (' + c.rtn + ')' : '');
      sel.appendChild(o);
    });
  }
  fdAgregarItem(); // Un ítem inicial
  abrirModal('modalFacturaDirecta');
}

function fdAgregarItem() {
  fdItemCount++;
  const idx = fdItemCount;
  const wrap = document.getElementById('fdItemsWrap');
  const div = document.createElement('div');
  div.id = 'fdItem_' + idx;
  div.style.cssText = 'display:grid;grid-template-columns:1fr 2fr 90px 110px 30px;gap:6px;align-items:center;background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:8px 10px';
  div.innerHTML = `
    <select id="fdTipo_${idx}" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
      <option value="otro">Servicio / Otro</option>
      <option value="mano_obra">Mano de obra</option>
      <option value="material">Material</option>
    </select>
    <input type="text" id="fdDesc_${idx}" placeholder="Descripción *" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
    <input type="number" id="fdCant_${idx}" value="1" min="0.01" step="0.01" placeholder="Cant." oninput="fdRecalcular()" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right">
    <input type="number" id="fdPrecio_${idx}" value="" min="0" step="0.01" placeholder="Precio unit." oninput="fdRecalcular()" style="padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right">
    <button onclick="fdEliminarItem(${idx})" style="background:none;border:none;color:var(--danger);font-size:18px;cursor:pointer;padding:0" title="Eliminar">×</button>
  `;
  wrap.appendChild(div);
}

function fdEliminarItem(idx) {
  const el = document.getElementById('fdItem_' + idx);
  if (el) el.remove();
  fdRecalcular();
}

function fdRecalcular() {
  let subtotal = 0;
  document.querySelectorAll('[id^="fdCant_"]').forEach(el => {
    const idx = el.id.split('_')[1];
    const cant   = parseFloat(el.value)                                   || 0;
    const precio = parseFloat(document.getElementById('fdPrecio_' + idx)?.value) || 0;
    subtotal += cant * precio;
  });
  const isv   = subtotal * 0.15;
  const total = subtotal + isv;
  document.getElementById('fdSubtotal').textContent = fmtMoneda(subtotal);
  document.getElementById('fdISV').textContent      = fmtMoneda(isv);
  document.getElementById('fdTotal').textContent    = fmtMoneda(total);
}

function fdSelMetodo(metodo) {
  fdMetodoSeleccionado = metodo;
  document.querySelectorAll('.fd-metodo-btn').forEach(el => {
    const sel = el.dataset.mfd === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('fdRefGrupo').style.display = 'none';
  const notaEl = document.getElementById('fdNotaMetodo');
  if (metodo === 'credito') {
    notaEl.textContent = '📋 Crédito: la factura quedará en estado "Pendiente" hasta registrar el pago.';
    notaEl.style.display = 'block';
  } else {
    notaEl.textContent = '✅ Contado: la factura se marcará como "Pagada" automáticamente.';
    notaEl.style.display = 'block';
  }
}

async function confirmarFacturaDirecta() {
  const errEl = document.getElementById('errFacturaDirecta');
  errEl.style.display = 'none';
  const cliente_id = +document.getElementById('fdClienteId').value;
  if (!cliente_id)              { errEl.textContent = 'Selecciona un cliente.';           errEl.style.display = 'block'; return; }
  if (!fdMetodoSeleccionado)    { errEl.textContent = 'Selecciona un método de pago.';    errEl.style.display = 'block'; return; }

  // Recopilar ítems
  const items = [];
  let itemsValidos = true;
  document.querySelectorAll('[id^="fdItem_"]').forEach(row => {
    const idx     = row.id.split('_')[1];
    const desc    = document.getElementById('fdDesc_'   + idx)?.value.trim();
    const cant    = parseFloat(document.getElementById('fdCant_'  + idx)?.value);
    const precio  = parseFloat(document.getElementById('fdPrecio_' + idx)?.value);
    const tipo    = document.getElementById('fdTipo_'   + idx)?.value;
    if (!desc || !cant || !precio || cant <= 0 || precio <= 0) { itemsValidos = false; return; }
    items.push({ tipo, descripcion: desc, cantidad: cant, precio_unitario: precio });
  });
  if (items.length === 0 || !itemsValidos) {
    errEl.textContent = 'Completa todos los ítems (descripción, cantidad y precio son requeridos).';
    errEl.style.display = 'block'; return;
  }

  const payload = {
    cliente_id,
    metodo_pago:   fdMetodoSeleccionado,
    referencia_pago: document.getElementById('fdReferencia').value.trim() || null,
    observaciones:   document.getElementById('fdObservaciones').value.trim() || null,
    fecha:           document.getElementById('fdFecha').value,
    items,
  };

  const r = await api('controllers/FacturacionController.php?action=facturar_directo', {
    method: 'POST',
    body: JSON.stringify(payload)
  });
  if (r.ok) {
    cerrarModal('modalFacturaDirecta');
    const estado = r.data.factura.estado;
    const emoji  = estado === 'pagada' ? '✅' : '📋';
    toast(`${emoji} Factura ${r.data.factura.numero_factura} emitida (${estado}).`, 'success');
    cargarFacturacion();
  } else {
    errEl.textContent = r.data.error || 'Error al emitir la factura.';
    errEl.style.display = 'block';
  }
}

// ── FACTURAR DESDE COTIZACIÓN ────────────────────────────
let facturarCotId = null;

async function abrirModalFacturar(cotizacion_id) {
  facturarCotId = cotizacion_id;
  // Verificar CAI activo antes de abrir
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  if (!rCai.ok || !rCai.data.data) {
    toast('No hay CAI activo. Configure el CAI antes de facturar.', 'error');
    setTimeout(() => abrirModalCAI(), 800);
    return;
  }
  // Reset modal método pago cotización
  facturarMetodoPago = '';
  document.querySelectorAll('.metodo-cot-btn').forEach(el => {
    el.style.borderColor = 'var(--border)'; el.style.background = '';
  });
  document.getElementById('facturarCotRefGrupo').style.display = 'none';
  document.getElementById('facturarCotRef').value = '';
  document.getElementById('errFacturarCot').style.display = 'none';
  document.getElementById('facturarCotNotaMetodo').style.display = 'none';
  abrirModal('modalFacturarCotizacion');
}

let facturarMetodoPago = '';

function facturarCotSelMetodo(metodo) {
  facturarMetodoPago = metodo;
  document.querySelectorAll('.metodo-cot-btn').forEach(el => {
    const sel = el.dataset.mcot === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('facturarCotRefGrupo').style.display = 'none';
  const notaEl = document.getElementById('facturarCotNotaMetodo');
  if (metodo === 'credito') {
    notaEl.textContent = '📋 Crédito: la factura quedará en estado "Pendiente" hasta registrar el pago.';
    notaEl.style.display = 'block';
  } else {
    notaEl.textContent = '✅ Contado: la factura se marcará como "Pagada" automáticamente.';
    notaEl.style.display = 'block';
  }
}

async function confirmarFacturarCotizacion() {
  const errEl = document.getElementById('errFacturarCot');
  errEl.style.display = 'none';
  if (!facturarMetodoPago) {
    errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return;
  }
  const ref = document.getElementById('facturarCotRef').value.trim();
  const r = await api('controllers/FacturacionController.php?action=facturar', {
    method: 'POST',
    body: JSON.stringify({ cotizacion_id: facturarCotId, metodo_pago: facturarMetodoPago, referencia_pago: ref || null })
  });
  if (r.ok) {
    cerrarModal('modalFacturarCotizacion');
    const estado = r.data.factura.estado;
    const emoji  = estado === 'pagada' ? '✅' : '📋';
    toast(`${emoji} Factura ${r.data.factura.numero_factura} emitida (${estado}).`, 'success');
    cargarFacturacion();
    cargarCotizaciones();
  } else {
    errEl.textContent = r.data.error || 'Error al generar factura.';
    errEl.style.display = 'block';
  }
}

// ── PAGO DE FACTURA ──────────────────────────────────────
function abrirPagoFactura(factura_id, numero, total, subtotal) {
  metodoPagoFacSeleccionado = '';
  document.getElementById('pagoFacturaId').value       = factura_id;
  document.getElementById('pagoFacturaSubtotal').value = subtotal || 0;
  document.getElementById('pagoFacturaInfo').textContent = `Factura: ${numero} | Total: ${fmtMoneda(total)}`;
  document.getElementById('pagoSaldoPendiente').textContent = fmtMoneda(total);
  document.getElementById('pagoMonto').value  = '';
  document.getElementById('pagoFecha').value  = new Date().toISOString().slice(0, 10);
  document.getElementById('pagoRefFac').value = '';
  document.getElementById('pagoRefGrupoFac').style.display = 'none';
  document.getElementById('errPago').style.display = 'none';
  // Reset retenciones
  document.getElementById('chkRetencionISR').checked = false;
  document.getElementById('chkRetencionISV').checked = false;
  document.getElementById('retencionISRGrupo').style.display = 'none';
  document.getElementById('retencionISVGrupo').style.display = 'none';
  document.getElementById('pagoRetencionISR').value = '';
  document.getElementById('pagoRetencionISV').value = '';
  document.getElementById('pagoResumenNeto').style.display = 'none';
  // Reset botones método
  document.querySelectorAll('.metodo-pago-btn[data-mfac]').forEach(el => {
    el.style.borderColor = 'var(--border)';
    el.style.background  = '';
  });

  // Cargar saldo pendiente real desde el servidor
  api('controllers/FacturacionController.php?action=obtener&id=' + factura_id).then(r => {
    if (r.ok) {
      const f = r.data.data;
      const subtotalReal = parseFloat(f.subtotal) || 0;
      document.getElementById('pagoFacturaSubtotal').value = subtotalReal;
      // Calcular ya pagado
      api('controllers/FacturacionController.php?action=saldo_pendiente&id=' + factura_id).then(rs => {
        if (rs.ok && rs.data.pendiente !== undefined) {
          document.getElementById('pagoSaldoPendiente').textContent = fmtMoneda(rs.data.pendiente);
          document.getElementById('pagoMonto').value = rs.data.pendiente.toFixed(2);
          pagoRecalcular();
        }
      });
    }
  });

  abrirModal('modalRegistrarPago');
}

function pagoToggleRetencion(tipo) {
  const chk   = document.getElementById(tipo === 'isr' ? 'chkRetencionISR' : 'chkRetencionISV');
  const grupo = document.getElementById(tipo === 'isr' ? 'retencionISRGrupo' : 'retencionISVGrupo');
  grupo.style.display = chk.checked ? 'block' : 'none';
  pagoRecalcular();
}

function pagoRecalcular() {
  const monto     = parseFloat(document.getElementById('pagoMonto').value)    || 0;
  const subtotal  = parseFloat(document.getElementById('pagoFacturaSubtotal').value) || 0;
  const chkISR    = document.getElementById('chkRetencionISR').checked;
  const chkISV    = document.getElementById('chkRetencionISV').checked;

  // Calcular retenciones sobre el subtotal proporcional al monto pagado
  // Si el monto pagado es igual al total, la base es el subtotal completo
  const retISR = chkISR ? parseFloat((subtotal * 0.01).toFixed(2))   : 0;
  const retISV = chkISV ? parseFloat((subtotal * 0.125).toFixed(2))  : 0;
  const neto   = parseFloat((monto - retISR - retISV).toFixed(2));

  if (chkISR) document.getElementById('pagoRetencionISR').value = retISR.toFixed(2);
  if (chkISV) document.getElementById('pagoRetencionISV').value = retISV.toFixed(2);

  const tieneRetencion = chkISR || chkISV;
  const resumen = document.getElementById('pagoResumenNeto');
  resumen.style.display = (tieneRetencion && monto > 0) ? 'block' : 'none';
  if (tieneRetencion) {
    document.getElementById('resNBruto').textContent = fmtMoneda(monto);
    document.getElementById('resNISR').textContent   = chkISR ? `− ${fmtMoneda(retISR)}` : 'L. 0.00';
    document.getElementById('resNISV').textContent   = chkISV ? `− ${fmtMoneda(retISV)}` : 'L. 0.00';
    document.getElementById('resNNeto').textContent  = fmtMoneda(neto);
  }
}

function selMetodoPagoFac(metodo) {
  metodoPagoFacSeleccionado = metodo;
  document.querySelectorAll('.metodo-pago-btn[data-mfac]').forEach(el => {
    const sel = el.dataset.mfac === metodo;
    el.style.borderColor = sel ? 'var(--accent)' : 'var(--border)';
    el.style.background  = sel ? 'rgba(232,160,32,.12)' : '';
  });
  document.getElementById('pagoRefGrupoFac').style.display =
    (metodo === 'tarjeta' || metodo === 'transferencia') ? 'block' : 'none';
}

async function confirmarPago() {
  const id    = +document.getElementById('pagoFacturaId').value;
  const monto = parseFloat(document.getElementById('pagoMonto').value);
  const fecha = document.getElementById('pagoFecha').value;
  const ref   = document.getElementById('pagoRefFac').value.trim();
  const errEl = document.getElementById('errPago');
  errEl.style.display = 'none';
  if (!metodoPagoFacSeleccionado) { errEl.textContent = 'Selecciona un método de pago.'; errEl.style.display = 'block'; return; }
  if (!monto || monto <= 0)       { errEl.textContent = 'Ingresa un monto válido.';       errEl.style.display = 'block'; return; }

  const retencion_isr = document.getElementById('chkRetencionISR').checked
    ? parseFloat(document.getElementById('pagoRetencionISR').value) || 0 : 0;
  const retencion_isv = document.getElementById('chkRetencionISV').checked
    ? parseFloat(document.getElementById('pagoRetencionISV').value) || 0 : 0;

  const r = await api('controllers/FacturacionController.php?action=registrar_pago', {
    method: 'POST',
    body: JSON.stringify({
      factura_id: id, monto, fecha,
      metodo_pago: metodoPagoFacSeleccionado,
      referencia: ref,
      retencion_isr, retencion_isv
    })
  });
  if (r.ok) {
    cerrarModal('modalRegistrarPago');
    const d = r.data;
    let msg = `Pago de ${fmtMoneda(monto)} registrado.`;
    if (retencion_isr > 0 || retencion_isv > 0) {
      msg += ` Neto recibido: ${fmtMoneda(d.monto_neto)}.`;
    }
    if (d.pendiente > 0) {
      msg += ` Saldo pendiente: ${fmtMoneda(d.pendiente)}.`;
    } else {
      msg += ` Factura pagada ✅`;
    }
    toast(msg, 'success');
    cargarFacturas();
  } else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ── ANULACIÓN ────────────────────────────────────────────
function abrirAnulacion(factura_id, numero) {
  document.getElementById('anularFacturaId').value = factura_id;
  document.getElementById('anularFacturaInfo').textContent = `Factura: ${numero}`;
  document.getElementById('anularMotivo').value = '';
  document.getElementById('errAnular').style.display = 'none';
  abrirModal('modalAnularFactura');
}

async function confirmarAnulacion() {
  const id     = +document.getElementById('anularFacturaId').value;
  const motivo = document.getElementById('anularMotivo').value.trim();
  const errEl  = document.getElementById('errAnular');
  errEl.style.display = 'none';
  if (!motivo) { errEl.textContent = 'El motivo es requerido.'; errEl.style.display = 'block'; return; }
  const r = await api('controllers/FacturacionController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id, motivo })
  });
  if (r.ok) { cerrarModal('modalAnularFactura'); toast('Factura anulada.', 'success'); cargarFacturas(); }
  else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ── CAI ──────────────────────────────────────────────────
async function abrirModalCAI() {
  document.getElementById('errCAI').style.display = 'none';
  document.getElementById('caiCodigo').value = '';
  document.getElementById('caiInicio').value = '';
  document.getElementById('caiFin').value    = '';
  document.getElementById('caiFechaLimite').value = '';
  document.getElementById('caiEstablecimiento').value = '001';

  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  const info = document.getElementById('caiActualInfo');
  if (rCai.ok && rCai.data.data) {
    const c = rCai.data.data;
    info.innerHTML = `<strong style="color:var(--success)">✅ CAI activo</strong><br>
      <span style="font-family:monospace;font-size:12px">${c.cai}</span><br>
      Correlativo actual: <strong style="font-family:monospace">${c.correlativo_actual}</strong><br>
      Rango: ${c.rango_inicio} — ${c.rango_fin}<br>
      Límite: ${c.fecha_limite_emision}`;
  } else {
    info.innerHTML = '<span style="color:var(--danger)">⚠️ Sin CAI activo. Configura uno para poder facturar.</span>';
  }
  abrirModal('modalCAI');
}

async function guardarCAI() {
  const errEl = document.getElementById('errCAI');
  errEl.style.display = 'none';
  const body = {
    cai:                  document.getElementById('caiCodigo').value.trim(),
    rango_inicio:         document.getElementById('caiInicio').value.trim(),
    rango_fin:            document.getElementById('caiFin').value.trim(),
    fecha_limite_emision: document.getElementById('caiFechaLimite').value,
    establecimiento:      document.getElementById('caiEstablecimiento').value.trim() || '001',
    punto_emision:        '001',
    tipo_documento:       '01',
  };
  if (!body.cai || !body.rango_inicio || !body.rango_fin || !body.fecha_limite_emision) {
    errEl.textContent = 'Todos los campos marcados son requeridos.'; errEl.style.display = 'block'; return;
  }
  const r = await api('controllers/FacturacionController.php?action=cai_crear', {
    method: 'POST', body: JSON.stringify(body)
  });
  if (r.ok) { cerrarModal('modalCAI'); toast('CAI registrado correctamente.', 'success'); }
  else { errEl.textContent = r.data.error || 'Error.'; errEl.style.display = 'block'; }
}

// ══════════════════════════════════════════════════════════
// FASE 3 — LIBRO DE VENTAS
// ══════════════════════════════════════════════════════════
function initLibroVentas() {
  // Setear mes/año actuales en los selects
  const now = new Date();
  const mesActual  = String(now.getMonth() + 1).padStart(2, '0');
  const anioActual = String(now.getFullYear());
  const selMes  = document.getElementById('libroMes');
  const selAnio = document.getElementById('libroAnio');
  if (selMes)  selMes.value  = mesActual;
  if (selAnio) selAnio.value = anioActual;
}

async function cargarLibroVentas() {
  const mes  = document.getElementById('libroMes').value;
  const anio = document.getElementById('libroAnio').value;
  document.getElementById('tablaLibro').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('libroResumen').style.display = 'none';

  const r = await api(`controllers/FacturacionController.php?action=libro_ventas&mes=${mes}&anio=${anio}`);
  if (!r.ok) { document.getElementById('tablaLibro').innerHTML = '<p style="color:var(--danger)">Error al cargar.</p>'; return; }
  const data = r.data.data;

  // Actualizar resumen
  document.getElementById('libroTotalFacturas').textContent = data.total_facturas;
  document.getElementById('libroTotalSubtotal').textContent = fmtMoneda(data.total_subtotal);
  document.getElementById('libroTotalISV').textContent      = fmtMoneda(data.total_isv);
  document.getElementById('libroTotalGeneral').textContent  = fmtMoneda(data.total_general);
  document.getElementById('libroResumen').style.display     = 'grid';

  if (!data.filas.length) {
    document.getElementById('tablaLibro').innerHTML = '<p class="empty-state">Sin facturas para este período</p>';
    return;
  }

  let h = `<table>
    <thead><tr>
      <th>No.</th><th>Número Factura</th><th>Fecha</th>
      <th>Cliente</th><th>RTN Cliente</th>
      <th>OT / Cotización</th><th>Subtotal</th><th>ISV 15%</th>
      <th>Total</th><th>Método</th><th>Estado</th>
    </tr></thead><tbody>`;

  data.filas.forEach((f, i) => {
    const anulada = f.estado === 'anulada';
    const ref = f.numero_cotizacion || f.numero_orden || '—';
    h += `<tr style="${anulada ? 'opacity:.5;text-decoration:line-through' : ''}">
      <td style="color:var(--muted);font-size:12px">${i + 1}</td>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.fecha}</td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.rtn_cliente || '—'}</td>
      <td style="font-size:11px">${ref}</td>
      <td>${fmtMoneda(f.subtotal)}</td>
      <td>${fmtMoneda(f.isv)}</td>
      <td><strong style="color:${anulada ? 'var(--muted)' : 'var(--accent)'}">${fmtMoneda(f.total)}</strong></td>
      <td><span class="badge badge-gray">${f.metodo_pago || '—'}</span></td>
      <td>${badgeEstado(f.estado)}</td>
    </tr>`;
  });

  // Fila de totales
  h += `<tr style="background:var(--bg);font-weight:600;border-top:2px solid var(--border)">
    <td colspan="6" style="text-align:right;color:var(--muted);font-size:12px">TOTALES DEL PERÍODO</td>
    <td>${fmtMoneda(data.total_subtotal)}</td>
    <td>${fmtMoneda(data.total_isv)}</td>
    <td style="color:var(--accent)">${fmtMoneda(data.total_general)}</td>
    <td colspan="2"></td>
  </tr>`;
  h += '</tbody></table>';
  document.getElementById('tablaLibro').innerHTML = h;
}

// Inicializar libro de ventas cuando se active el módulo
document.querySelectorAll('.nav-item[data-module]').forEach(el => {
  if (el.dataset.module === 'libro_ventas') {
    el.addEventListener('click', function() { initLibroVentas(); });
  }
});

// ══════════════════════════════════════════════════════════
// MÓDULO CAI
// ══════════════════════════════════════════════════════════
async function cargarModuloCAI() {
  // Panel CAI activo
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  const wrap = document.getElementById('caiActivoWrap');
  if (wrap) {
    if (rCai.ok && rCai.data.data) {
      const c = rCai.data.data;
      const vencidaFecha = parseInt(c.fecha_vencida || 0);
      if (vencidaFecha) {
        // CAI con fecha vencida — advertencia, NO se puede facturar
        wrap.innerHTML = `
          <div style="background:rgba(224,80,80,.08);border:1px solid rgba(224,80,80,.35);border-radius:10px;padding:14px 18px;font-size:13px">
            <div style="font-weight:700;color:var(--danger);margin-bottom:6px">❌ CAI vencido — No se puede facturar</div>
            <div style="color:var(--muted);margin-bottom:10px;font-size:12px">
              La fecha límite de emisión <strong style="color:var(--danger)">${c.fecha_limite_emision}</strong> ya expiró.
              El sistema lo marcará como inactivo automáticamente. Registra un nuevo CAI para continuar facturando.
            </div>
            <div style="font-family:monospace;font-size:11px;color:var(--muted);word-break:break-all">${c.cai}</div>
          </div>`;
      } else {
        // CAI activo y vigente
        wrap.innerHTML = `
          <div style="background:rgba(40,167,69,.08);border:1px solid rgba(40,167,69,.3);border-radius:10px;padding:14px 18px;font-size:13px">
            <div style="font-weight:700;color:var(--success);margin-bottom:8px">✅ CAI Activo y Vigente</div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px">
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Código CAI</div>
                <div style="font-family:monospace;font-size:12px;word-break:break-all">${c.cai}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Correlativo actual</div>
                <div style="font-family:monospace;font-weight:600">${c.correlativo_actual}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Rango</div>
                <div style="font-family:monospace;font-size:12px">${c.rango_inicio} — ${c.rango_fin}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Fecha límite SAR</div>
                <div style="font-weight:600">${c.fecha_limite_emision}</div></div>
            </div>
          </div>`;
      }
    } else {
      wrap.innerHTML = `<div style="background:rgba(220,53,69,.08);border:1px solid rgba(220,53,69,.3);border-radius:10px;padding:14px 18px;color:var(--danger)">
        ❌ Sin CAI activo. Registra un CAI para poder emitir facturas.</div>`;
    }
  }

  // Historial (todos los CAI)
  const lista = document.getElementById('tablaCAILista');
  if (lista) {
    const rLista = await api('controllers/FacturacionController.php?action=cai_listar');
    if (rLista.ok && rLista.data.data?.length) {
      let h = `<table><thead><tr><th>CAI</th><th>Correlativo actual</th><th>Rango inicio</th><th>Rango fin</th><th>Fecha límite</th><th>Estado</th><th>Acción</th></tr></thead><tbody>`;
      rLista.data.data.forEach(c => {
        const hoy = new Date().toISOString().slice(0,10);
        const fechaVenc = c.fecha_limite_emision < hoy;
        h += `<tr>
          <td style="font-family:monospace;font-size:11px;word-break:break-all">${c.cai}</td>
          <td style="font-family:monospace">${c.correlativo_actual}</td>
          <td style="font-family:monospace;font-size:11px">${c.rango_inicio}</td>
          <td style="font-family:monospace;font-size:11px">${c.rango_fin}</td>
          <td style="color:${fechaVenc?'var(--danger)':'inherit'}">${c.fecha_limite_emision}${fechaVenc?' ⚠️':''}</td>
          <td>${badgeEstado(c.estado)}</td>
          <td>
            ${c.estado === 'activo'
              ? `<button class="btn btn-sm btn-danger" onclick="inactivarCAI(${c.id_cai})">Inactivar</button>`
              : '—'}
          </td>
        </tr>`;
      });
      h += '</tbody></table>';
      lista.innerHTML = h;
    } else {
      lista.innerHTML = '<p class="empty-state">Sin CAI registrados.</p>';
    }
  }
}

function mostrarFormCAI() {
  document.getElementById('errCAIModulo').style.display = 'none';
  ['caiCodigoM','caiInicioM','caiFinalM'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('caiFechaLimiteM').value = '';
  document.getElementById('caiEstablecimientoM').value = '001';
  document.getElementById('formCAIWrap').style.display = 'block';
}

function ocultarFormCAI() {
  document.getElementById('formCAIWrap').style.display = 'none';
}

async function guardarCAIModulo() {
  const errEl = document.getElementById('errCAIModulo');
  errEl.style.display = 'none';
  const body = {
    cai:                  document.getElementById('caiCodigoM').value.trim(),
    rango_inicio:         document.getElementById('caiInicioM').value.trim(),
    rango_fin:            document.getElementById('caiFinalM').value.trim(),
    fecha_limite_emision: document.getElementById('caiFechaLimiteM').value,
    establecimiento:      document.getElementById('caiEstablecimientoM').value.trim() || '001',
    punto_emision:        '001',
    tipo_documento:       '01',
  };
  if (!body.cai || !body.rango_inicio || !body.rango_fin || !body.fecha_limite_emision) {
    errEl.textContent = 'Todos los campos marcados son requeridos.';
    errEl.style.display = 'block'; return;
  }
  const r = await api('controllers/FacturacionController.php?action=cai_crear', { method:'POST', body: JSON.stringify(body) });
  if (r.ok) {
    ocultarFormCAI();
    toast('CAI registrado correctamente.', 'success');
    cargarModuloCAI();
  } else {
    errEl.textContent = r.data.error || 'Error al guardar.';
    errEl.style.display = 'block';
  }
}
// ══════════════════════════════════════════════════════════
// FASE 4 — MÓDULO PAGOS DE CLIENTES
// ══════════════════════════════════════════════════════════
let pagosData   = [];
let cxcData     = [];
let tabPagosActual = 'pagos';

// ── Loaders ──────────────────────────────────────────────
// loaders defined above
async function cargarModuloPagos() {
  await Promise.all([cargarKPIsPagos(), cargarPagos(), cargarCxC(), llenarSelectClientesCxC()]);
}

async function cargarKPIsPagos() {
  const r = await api('controllers/PagosController.php?action=kpis');
  if (!r.ok) return;
  const k = r.data.data;
  document.getElementById('kpiPagosTotal').textContent       = k.total_pagos        || '0';
  document.getElementById('kpiPagosCobrado').textContent     = fmtMoneda(k.total_cobrado   || 0);
  document.getElementById('kpiPagosNeto').textContent        = fmtMoneda(k.total_neto      || 0);
  document.getElementById('kpiPagosRetenciones').textContent = fmtMoneda((parseFloat(k.total_isr||0) + parseFloat(k.total_isv||0)));
}

async function cargarPagos() {
  document.getElementById('tablaPagos').innerHTML = '<p class="loading">Cargando...</p>';
  const mes    = document.getElementById('pagosFiltroMes').value;
  const anio   = document.getElementById('pagosFiltroAnio').value;
  const metodo = document.getElementById('pagosFiltroMetodo').value;
  let url = 'controllers/PagosController.php?action=listar';
  if (mes)    url += '&mes='    + mes;
  if (anio)   url += '&anio='   + anio;
  if (metodo) url += '&metodo_pago=' + metodo;
  const r = await api(url);
  if (!r.ok) { document.getElementById('tablaPagos').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  pagosData = r.data.data;
  document.getElementById('buscarPago').value = '';
  paginaActual['pagos'] = 1;
  renderTablaPagos(pagosData);
}

function filtrarPagos() {
  const q = document.getElementById('buscarPago').value.toLowerCase().trim();
  paginaActual['pagos'] = 1;
  if (!q) { renderTablaPagos(pagosData); return; }
  renderTablaPagos(pagosData.filter(p =>
    p.cliente.toLowerCase().includes(q) ||
    p.numero_factura.toLowerCase().includes(q) ||
    (p.referencia && p.referencia.toLowerCase().includes(q))
  ));
}

function renderTablaPagos(rows) {
  const pag = paginar('pagos', rows);
  const tieneRetenciones = rows.some(p => parseFloat(p.retencion_isr||0) > 0 || parseFloat(p.retencion_isv||0) > 0);
  let h = `<table><thead><tr>
    <th>Fecha</th><th>Factura</th><th>Cliente</th>
    <th>Monto</th>${tieneRetenciones ? '<th>Ret. ISR</th><th>Ret. ISV</th><th>Neto</th>' : ''}
    <th>Método</th><th>Referencia</th><th>Usuario</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += `<tr><td colspan="${tieneRetenciones?10:7}" class="empty-state">Sin pagos registrados</td></tr>`;
  const metodoIcon = { efectivo:'💵', tarjeta:'💳', transferencia:'🏦' };
  pag.slice.forEach(p => {
    const retISR = parseFloat(p.retencion_isr||0);
    const retISV = parseFloat(p.retencion_isv||0);
    h += `<tr>
      <td style="white-space:nowrap">${p.fecha}</td>
      <td><strong style="font-family:monospace;font-size:12px">${p.numero_factura}</strong></td>
      <td>${p.cliente}</td>
      <td><strong>${fmtMoneda(p.monto)}</strong></td>
      ${tieneRetenciones ? `
        <td style="color:var(--danger)">${retISR > 0 ? fmtMoneda(retISR) : '—'}</td>
        <td style="color:var(--danger)">${retISV > 0 ? fmtMoneda(retISV) : '—'}</td>
        <td style="color:var(--success)">${fmtMoneda(p.monto_neto)}</td>
      ` : ''}
      <td>${metodoIcon[p.metodo_pago]||''} ${p.metodo_pago}</td>
      <td style="font-size:12px;color:var(--muted)">${p.referencia||'—'}</td>
      <td style="font-size:12px">${p.usuario}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verDetallePago(${p.id_pago})">Ver</button>
        <button class="btn btn-sm btn-danger" onclick="anularPago(${p.id_pago},'${p.numero_factura}')">Anular</button>
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaPagos').innerHTML = h;
  renderPaginacion('pagos', pag, 'paginaPagos');
}

// ── Cuentas por Cobrar ───────────────────────────────────
async function cargarCxC() {
  document.getElementById('tablaCxC').innerHTML = '<p class="loading">Cargando...</p>';
  const cliente_id = document.getElementById('cxcFiltroCliente').value;
  let url = 'controllers/PagosController.php?action=cuentas_cobrar';
  if (cliente_id) url += '&cliente_id=' + cliente_id;
  const r = await api(url);
  if (!r.ok) { document.getElementById('tablaCxC').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  cxcData = r.data.data;
  document.getElementById('buscarCxC').value = '';
  paginaActual['cxc'] = 1;
  renderTablaCxC(cxcData);
}

function filtrarCxC() {
  const q = document.getElementById('buscarCxC').value.toLowerCase().trim();
  paginaActual['cxc'] = 1;
  if (!q) { renderTablaCxC(cxcData); return; }
  renderTablaCxC(cxcData.filter(f =>
    f.cliente.toLowerCase().includes(q) ||
    f.numero_factura.toLowerCase().includes(q)
  ));
}

function renderTablaCxC(rows) {
  const pag = paginar('cxc', rows);
  const totalPendiente = rows.reduce((s, r) => s + parseFloat(r.saldo_pendiente||0), 0);
  document.getElementById('cxcTotalPendiente').textContent = fmtMoneda(totalPendiente);
  let h = `<table><thead><tr>
    <th>Factura</th><th>Cliente</th><th>RTN</th><th>Fecha</th>
    <th>Total</th><th>Pagado</th><th>Saldo</th><th>Crédito</th><th>Estado crédito</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="10" class="empty-state">Sin cuentas pendientes ✅</td></tr>';
  pag.slice.forEach(f => {
    const diasCredito    = parseInt(f.dias_credito || 0);
    const diasTransc     = parseInt(f.dias_transcurridos || f.dias_vencido || 0);
    const diasVencido    = parseInt(f.dias_vencido || 0);
    const diasRestantes  = parseInt(f.dias_restantes || 0);

    // Columna "Crédito"
    const colCredito = diasCredito > 0
      ? `<span style="font-size:12px">${diasCredito}d</span>`
      : `<span style="font-size:11px;color:var(--muted)">Contado</span>`;

    // Columna "Estado crédito"
    let badgeCredito = '';
    if (diasCredito === 0) {
      // Sin crédito - vence al emitir
      if (diasTransc === 0)
        badgeCredito = `<span class="badge badge-al-dia">Al día</span>`;
      else
        badgeCredito = `<span class="badge badge-vencido">Vencido ${diasTransc}d</span>`;
    } else if (diasRestantes > 5) {
      badgeCredito = `<span class="badge badge-al-dia">Vigente · ${diasRestantes}d rest.</span>`;
    } else if (diasRestantes >= 0) {
      badgeCredito = `<span class="badge badge-por-vencer">Por vencer · ${diasRestantes}d</span>`;
    } else {
      badgeCredito = `<span class="badge badge-vencido">Vencido ${Math.abs(diasRestantes)}d</span>`;
    }

    h += `<tr>
      <td><strong style="font-family:monospace;font-size:12px">${f.numero_factura}</strong></td>
      <td>${f.cliente}</td>
      <td style="font-size:11px;color:var(--muted)">${f.cliente_rtn||'—'}</td>
      <td style="white-space:nowrap">${f.fecha}</td>
      <td>${fmtMoneda(f.total)}</td>
      <td style="color:var(--success)">${fmtMoneda(f.total_pagado)}</td>
      <td><strong style="color:var(--danger)">${fmtMoneda(f.saldo_pendiente)}</strong></td>
      <td style="text-align:center">${colCredito}</td>
      <td>${badgeCredito}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-success" onclick="abrirPagoFactura(${f.id_factura},'${f.numero_factura}',${f.total},${f.total - f.total_pagado})">💳 Pagar</button>
        <button class="btn btn-sm btn-secondary" onclick="verHistorialCliente(${f.id_factura},'${f.cliente}')">Historial</button>
      </div></td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaCxC').innerHTML = h;
  renderPaginacion('cxc', pag, 'paginaCxC');
}

async function llenarSelectClientesCxC() {
  const sel = document.getElementById('cxcFiltroCliente');
  if (sel.options.length > 1) return; // ya cargado
  const r = await api('controllers/ClientesController.php?action=listar&estado=activo');
  if (!r.ok) return;
  r.data.data.forEach(c => {
    const o = document.createElement('option');
    o.value = c.id_cliente;
    o.textContent = c.nombre;
    sel.appendChild(o);
  });
}

// ── Detalle y anulación de pago ──────────────────────────
async function verDetallePago(id) {
  document.getElementById('contenidoDetallePago').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('footerDetallePago').innerHTML =
    '<button class="btn btn-secondary" onclick="cerrarModal(\'modalDetallePago\')">Cerrar</button>';
  abrirModal('modalDetallePago');
  // Buscar en los datos ya cargados
  const pago = pagosData.find(p => p.id_pago === id);
  if (!pago) { document.getElementById('contenidoDetallePago').innerHTML = '<p style="color:var(--danger)">No encontrado.</p>'; return; }
  const retISR = parseFloat(pago.retencion_isr||0);
  const retISV = parseFloat(pago.retencion_isv||0);
  const tieneRet = retISR > 0 || retISV > 0;
  const metodoIcon = { efectivo:'💵 Efectivo', tarjeta:'💳 Tarjeta', transferencia:'🏦 Transferencia' };
  let h = `
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;font-size:13px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:12px">
    <div><span style="color:var(--muted)">Factura:</span> <strong style="font-family:monospace">${pago.numero_factura}</strong></div>
    <div><span style="color:var(--muted)">Fecha:</span> ${pago.fecha}</div>
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${pago.cliente}</strong></div>
    <div><span style="color:var(--muted)">Método:</span> ${metodoIcon[pago.metodo_pago]||pago.metodo_pago}</div>
    ${pago.referencia ? `<div style="grid-column:1/-1"><span style="color:var(--muted)">Referencia:</span> ${pago.referencia}</div>` : ''}
    <div><span style="color:var(--muted)">Registrado por:</span> ${pago.usuario}</div>
    <div><span style="color:var(--muted)">Concepto:</span> ${pago.concepto||'—'}</div>
  </div>
  <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;font-size:13px;line-height:2.2">
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">Monto bruto:</span> <strong>${fmtMoneda(pago.monto)}</strong></div>
    ${tieneRet ? `
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Retención ISR 1%:</span> <span style="color:var(--danger)">${fmtMoneda(retISR)}</span></div>
    <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Retención ISV 12.5%:</span> <span style="color:var(--danger)">${fmtMoneda(retISV)}</span></div>
    <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:6px;margin-top:4px">
      <span style="font-weight:600">Neto recibido:</span>
      <strong style="color:var(--success);font-size:16px">${fmtMoneda(pago.monto_neto)}</strong>
    </div>` : `
    <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:6px;margin-top:4px">
      <span style="font-weight:600">Neto recibido:</span>
      <strong style="color:var(--success);font-size:16px">${fmtMoneda(pago.monto)}</strong>
    </div>`}
  </div>`;
  document.getElementById('contenidoDetallePago').innerHTML = h;
  // Botón anular en footer
  const footer = document.getElementById('footerDetallePago');
  const btnAnular = document.createElement('button');
  btnAnular.className = 'btn btn-danger';
  btnAnular.textContent = 'Anular Pago';
  btnAnular.onclick = () => { cerrarModal('modalDetallePago'); anularPago(id, pago.numero_factura); };
  footer.prepend(btnAnular);
}

async function verHistorialCliente(factura_id, clienteNombre) {
  const cxcRow = cxcData.find(f => f.id_factura === factura_id);
  if (!cxcRow) { toast('No se encontró la factura en la lista.', 'error'); return; }
  await abrirHistorialCliente(cxcRow.cliente_id || cxcRow.id_factura, clienteNombre, cxcRow);
}

async function abrirHistorialCliente(cliente_id, clienteNombre, cxcRow) {
  document.getElementById('historialClienteNombre').textContent = clienteNombre;
  document.getElementById('tablaHistorialPagos').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalHistorialPagos');
  // Cargar historial por cliente_id
  const r = await api('controllers/PagosController.php?action=historial_cliente&cliente_id=' + cliente_id);
  if (!r.ok) { document.getElementById('tablaHistorialPagos').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const pagos = r.data.data;
  // Calcular resumen
  const totCobrado     = pagos.reduce((s,p) => s + parseFloat(p.monto||0), 0);
  const totRetenciones = pagos.reduce((s,p) => s + parseFloat(p.retencion_isr||0) + parseFloat(p.retencion_isv||0), 0);
  const totNeto        = pagos.reduce((s,p) => s + parseFloat(p.monto_neto||0), 0);
  document.getElementById('histResTotal').textContent       = pagos.length;
  document.getElementById('histResCobrado').textContent     = fmtMoneda(totCobrado);
  document.getElementById('histResRetenciones').textContent = fmtMoneda(totRetenciones);
  document.getElementById('histResNeto').textContent        = fmtMoneda(totNeto);
  if (!pagos.length) {
    document.getElementById('tablaHistorialPagos').innerHTML = '<p class="empty-state">Sin pagos registrados para este cliente.</p>';
    return;
  }
  const metodoIcon = { efectivo:'💵', tarjeta:'💳', transferencia:'🏦' };
  let h = `<table><thead><tr><th>Fecha</th><th>Factura</th><th>Monto</th><th>Ret. ISR</th><th>Ret. ISV</th><th>Neto</th><th>Método</th><th>Referencia</th></tr></thead><tbody>`;
  pagos.forEach(p => {
    h += `<tr>
      <td>${p.fecha}</td>
      <td style="font-family:monospace;font-size:12px">${p.numero_factura}</td>
      <td><strong>${fmtMoneda(p.monto)}</strong></td>
      <td style="color:var(--danger)">${parseFloat(p.retencion_isr||0)>0 ? fmtMoneda(p.retencion_isr) : '—'}</td>
      <td style="color:var(--danger)">${parseFloat(p.retencion_isv||0)>0 ? fmtMoneda(p.retencion_isv) : '—'}</td>
      <td style="color:var(--success)">${fmtMoneda(p.monto_neto)}</td>
      <td>${metodoIcon[p.metodo_pago]||''} ${p.metodo_pago}</td>
      <td style="font-size:12px;color:var(--muted)">${p.referencia||'—'}</td>
    </tr>`;
  });
  h += '</tbody></table>';
  document.getElementById('tablaHistorialPagos').innerHTML = h;
}

async function anularPago(id, numeroFactura) {
  if (!await confirmDialog(`¿Anular el pago de la factura ${numeroFactura}? Se revertirá el estado de la factura.`)) return;
  const r = await api('controllers/PagosController.php?action=anular', {
    method: 'POST', body: JSON.stringify({ id })
  });
  if (r.ok) {
    toast('Pago anulado correctamente.', 'success');
    cargarModuloPagos();
  } else {
    toast(r.data.error || 'Error al anular.', 'error');
  }
}

// ── Tabs ─────────────────────────────────────────────────
function switchTabPagos(tab) {
  tabPagosActual = tab;
  document.getElementById('tabPagos').classList.toggle('active', tab === 'pagos');
  document.getElementById('tabCxC').classList.toggle('active', tab === 'cxc');
  document.getElementById('panelHistorialPagos').style.display = tab === 'pagos' ? '' : 'none';
  document.getElementById('panelCxC').style.display            = tab === 'cxc'   ? '' : 'none';
}


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
    <th>Nombre</th><th>Ubicación</th><th>Departamento</th><th>Puesto</th><th>Contrato</th>
    <th>Salario Mensual</th><th>Sal. Quincenal</th><th>Seguro</th><th>Estado</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="9" class="empty-state">Sin empleados</td></tr>';
  pag.slice.forEach(e => {
    const ubicBadge = e.ubicacion === 'VESTA'
      ? `<span class="badge badge-blue">VESTA</span>`
      : `<span class="badge badge-gray">SOLDYMEG</span>`;
    const quince = fmtMoneda(parseFloat(e.salario_mensual||0)/2);
    const seguro = e.seguro_privado != null ? parseFloat(e.seguro_privado) : 0;
    h += `<tr>
      <td><strong>${e.nombre}</strong>${e.identidad?`<br><small style="color:var(--muted)">${e.identidad}</small>`:''}</td>
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
  const r = await api('controllers/PlanillaController.php?action=listar');
  if (!r.ok) { document.getElementById('tablaPlanillas').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  planillasData = r.data.data;
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
    <th>Período</th><th>Quincena</th><th>Fecha Pago</th>
    <th>Total Salarios</th><th>Deducciones</th><th>Neto a Pagar</th>
    <th>Estado</th><th>Acciones</th>
  </tr></thead><tbody>`;
  if (!pag.slice.length) h += '<tr><td colspan="8" class="empty-state">Sin planillas generadas</td></tr>';
  pag.slice.forEach(p => {
    const periodo = (meses[+p.periodo_mes]||'') + ' ' + p.periodo_anio;
    h += `<tr>
      <td><strong>${periodo}</strong></td>
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
    viatico_s1:     0,
    viatico_s2:     0,
    viatico_s3:     0,
    viatico_s4:     0,
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
  const viaticos = (e.viatico_s1||0) + (e.viatico_s2||0) + (e.viatico_s3||0) + (e.viatico_s4||0);
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
          onchange="extrasChange(${i}, es2da ? 'viatico_s3' : 'viatico_s1', this.value)"></td>
      <td><input type="number" min="0" step="0.01"
          value="${es2da ? (e.viatico_s4||0) : (e.viatico_s2||0)}"
          style="${style};border-color:rgba(232,160,32,.5)"
          onchange="extrasChange(${i}, es2da ? 'viatico_s4' : 'viatico_s2', this.value)"></td>
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
      <th>Total Ded.</th><th>NETO A PAGAR</th>
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
    </tr>`;
  });
  h += `</tbody></table></div>`;
  document.getElementById('contenidoDetallePlanilla').innerHTML = h;
  document.getElementById('footerDetallePlanilla').innerHTML = `
    <button class="btn btn-secondary" onclick="cerrarModal('modalDetallePlanilla')">Cerrar</button>
    <a href="controllers/ReportesController.php?action=planilla_pdf&id=${id}" target="_blank" class="btn btn-secondary">📄 PDF</a>
    <a href="controllers/ReportesController.php?action=planilla_excel&id=${id}" class="btn btn-secondary">⬇️ Excel</a>
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

  // Reconstruir extras desde detalle guardado — PRESERVANDO todos los valores
  planEmpleadosExtras = (p.detalle || []).map(d => ({
    empleado_id:    d.empleado_id,
    nombre:         d.empleado,
    ubicacion:      d.ubicacion || 'SOLDYMEG',
    salario_mensual:(parseFloat(d.salario_base) * 2),
    seguro_privado: parseFloat(d.seguro_privado || 0),
    horas_extra:    parseFloat(d.horas_extra    || 0),
    dias_faltados:  parseFloat(d.dias_faltados  || 0),
    abono_prestamo: parseFloat(d.abono_prestamo || 0),
    abono_vale:     parseFloat(d.abono_vale     || 0),
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
  document.getElementById('tabEmpleados').classList.toggle('active', tab==='empleados');
  document.getElementById('tabPlanillas').classList.toggle('active', tab==='planillas');
  document.getElementById('panelEmpleados').style.display = tab==='empleados' ? '' : 'none';
  document.getElementById('panelPlanillas').style.display = tab==='planillas' ? '' : 'none';
  if (tab==='planillas' && !planillasData.length) cargarPlanillas();
  if (tab==='empleados' && !empleadosData.length) cargarEmpleados();
}

// ── REPORTES ──────────────────────────────────────────────
let reporteActual = 'ventas';
let reporteData   = [];

function switchReporte(tipo) {
  reporteActual = tipo;
  ['ventas','cxc','retenciones','rentabilidad','inventario'].forEach(t => {
    document.getElementById('rptab' + t.charAt(0).toUpperCase()+t.slice(1))?.classList.toggle('active', t===tipo);
  });
  document.getElementById('tablaReporte').innerHTML = '<p style="color:var(--muted);text-align:center;padding:40px">Haz clic en Consultar.</p>';
  document.getElementById('reporteKpis').style.display = 'none';
  document.getElementById('rpMes').style.display = tipo === 'cxc' ? 'none' : '';
}

async function ejecutarReporte() {
  document.getElementById('tablaReporte').innerHTML = '<p class="loading">Cargando...</p>';
  document.getElementById('reporteKpis').style.display = 'none';
  const mes  = document.getElementById('rpMes').value;
  const anio = document.getElementById('rpAnio').value;
  let url = `controllers/ReportesController.php?action=${reporteActual}&anio=${anio}`;
  if (mes) url += '&mes=' + mes;
  const r = await api(url);
  if (!r.ok) {
    document.getElementById('tablaReporte').innerHTML = '<p style="color:var(--danger)">' + (r.data?.error || 'Error al cargar reporte.') + '</p>';
    return;
  }
  reporteData = r.data.data || [];
  paginaActual['reporte'] = 1;
  renderReporte(r.data);
}

function renderReporte(data) {
  const rows = data.data || [];
  if (!rows.length) { document.getElementById('tablaReporte').innerHTML='<p class="empty-state">Sin datos para el período.</p>'; return; }
  const kpisEl = document.getElementById('reporteKpis');
  if (data.totales) {
    const t = data.totales;
    let kh = '<div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:4px">';
    Object.entries(t).forEach(([k,v]) => {
      const label = k.replace(/_/g,' ');
      const val   = typeof v === 'number' && v > 100 ? fmtMoneda(v) : v;
      kh += `<div class="kpi-card" style="min-width:130px"><div class="kpi-label">${label}</div><div class="kpi-val" style="font-size:16px">${val}</div></div>`;
    });
    kh += '</div>';
    kpisEl.innerHTML = kh;
    kpisEl.style.display = 'block';
  } else { kpisEl.style.display = 'none'; }
  const pag  = paginar('reporte', rows);
  const cols = Object.keys(rows[0]);
  let h = '<table><thead><tr>' + cols.map(c => `<th>${c.replace(/_/g,' ')}</th>`).join('') + '</tr></thead><tbody>';
  pag.slice.forEach(row => {
    h += '<tr>' + cols.map(c => {
      const v = row[c];
      if (v === null || v === undefined) return '<td>—</td>';
      if (!isNaN(parseFloat(v)) && String(v).match(/^\d+\.?\d*$/) && parseFloat(v) > 100 && String(v).includes('.'))
        return `<td>${fmtMoneda(parseFloat(v))}</td>`;
      return `<td>${v}</td>`;
    }).join('') + '</tr>';
  });
  h += '</tbody></table>';
  document.getElementById('tablaReporte').innerHTML = h;
  renderPaginacion('reporte', pag, 'paginaReporte');
}

function exportarReporteExcel() {
  const mes  = document.getElementById('rpMes').value;
  const anio = document.getElementById('rpAnio').value;
  let url = `controllers/ReportesController.php?action=${reporteActual}&format=excel&anio=${anio}`;
  if (mes) url += '&mes=' + mes;
  window.location.href = url;
}

// ── Loader + paginación ───────────────────────────────────
async function cargarModuloPlanillas() {
  await cargarEmpleados();
}


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

// ══════════════════════════════════════════════════════════════
//  MÓDULO GASTOS DMC / SAR HONDURAS
// ══════════════════════════════════════════════════════════════
let gastosData=[];
const MESES_GASTOS=['','Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
const CATS_GASTOS={materiales:'Materiales',servicios:'Servicios',alquiler:'Alquiler',combustible:'Combustible',publicidad:'Publicidad',mantenimiento:'Mantenimiento',sueldos:'Sueldos',honorarios:'Honorarios',utilities:'Utilities',otros:'Otros'};
function initFiltrosGastos(){const y=new Date().getFullYear();['filtroGastoAnio','gastoAnio'].forEach(id=>{const el=document.getElementById(id);if(!el)return;el.innerHTML='';for(let i=y+1;i>=y-3;i--)el.innerHTML+=`<option value="${i}"${i===y?' selected':''}>${i}</option>`;});const m=new Date().getMonth()+1;const mesEl=document.getElementById('filtroGastoMes');if(mesEl)mesEl.value=m;}
async function cargarGastos(){const anio=document.getElementById('filtroGastoAnio')?.value||'';const mes=document.getElementById('filtroGastoMes')?.value||'';const estado=document.getElementById('filtroGastoEstado')?.value||'';const cat=document.getElementById('filtroGastoCategoria')?.value||'';const r=await api(`controllers/GastosController.php?action=listar&anio=${anio}&mes=${mes}&estado=${estado}&categoria=${cat}`);if(!r.ok){toast('Error al cargar gastos.','error');return;}gastosData=r.data.data||[];filtrarGastosLocal();if(mes&&anio)cargarResumenGastos(mes,anio);}
function filtrarGastosLocal(){const q=(document.getElementById('buscarGasto')?.value||'').toLowerCase();const rows=q?gastosData.filter(g=>(g.nombre_proveedor||'').toLowerCase().includes(q)||(g.descripcion||'').toLowerCase().includes(q)):gastosData;renderTablaGastos(rows);}
async function cargarResumenGastos(mes,anio){const el=document.getElementById('gastosResumen');const btnEl=document.getElementById('gastosBtnDeclarar');if(!mes||!anio){if(el)el.innerHTML='';if(btnEl)btnEl.style.display='none';return;}const r=await api(`controllers/GastosController.php?action=resumen&mes=${mes}&anio=${anio}`);if(!r.ok)return;const d=r.data.data;const fL=n=>'L. '+Number(n||0).toLocaleString('es-HN',{minimumFractionDigits:2});if(el)el.innerHTML=`<div class="stat-card"><div class="stat-label">Registros</div><div class="stat-value">${d.total_registros||0}</div></div><div class="stat-card"><div class="stat-label">Subtotal s/ISV</div><div class="stat-value" style="color:var(--accent)">${fL(d.total_subtotal)}</div></div><div class="stat-card"><div class="stat-label">ISV Total</div><div class="stat-value">${fL(d.total_isv)}</div></div><div class="stat-card"><div class="stat-label">Total General</div><div class="stat-value" style="color:#4caf50;font-size:18px">${fL(d.total_general)}</div></div><div class="stat-card"><div class="stat-label">Deducible ISR</div><div class="stat-value" style="color:#2196f3">${fL(d.total_deducible)}</div></div><div class="stat-card"><div class="stat-label">No Deducible</div><div class="stat-value" style="color:var(--danger)">${fL(d.total_no_deducible)}</div></div><div class="stat-card"><div class="stat-label">Pendiente SAR</div><div class="stat-value" style="color:var(--warning,#f59e0b)">${fL(d.total_pendiente)}</div></div><div class="stat-card"><div class="stat-label">Declarado</div><div class="stat-value" style="color:#4caf50">${fL(d.total_declarado)}</div></div>`;if(btnEl)btnEl.style.display=parseFloat(d.total_pendiente)>0?'':'none';}
function renderTablaGastos(rows){const wrap=document.getElementById('tablaGastosWrap');if(!wrap)return;if(!rows.length){wrap.innerHTML='<p class="empty-state">Sin registros.</p>';return;}const pag=paginar('gastos',rows);const fL=n=>'L. '+Number(n||0).toLocaleString('es-HN',{minimumFractionDigits:2});let h='<table><thead><tr><th>Fecha</th><th>Proveedor</th><th>RTN</th><th>N° Doc</th><th>Categoría</th><th>Descripción</th><th>Subtotal</th><th>ISV</th><th>Total</th><th>Ded.</th><th>Estado</th><th>Acciones</th></tr></thead><tbody>';pag.slice.forEach(g=>{const eb=g.estado==='declarado'?'<span class="badge badge-green">Declarado</span>':'<span class="badge badge-yellow">Pendiente</span>';const acc=g.estado==='declarado'?'<span style="font-size:11px;color:var(--muted)">🔒</span>':`<div class="td-actions"><button class="btn btn-sm btn-secondary" onclick="editarGasto(${g.id_gasto})">Editar</button><button class="btn btn-sm btn-danger" onclick="eliminarGasto(${g.id_gasto})">Eliminar</button></div>`;h+=`<tr><td style="white-space:nowrap">${g.fecha}</td><td><strong>${g.nombre_proveedor}</strong></td><td><code style="font-size:11px">${g.rtn_proveedor||'—'}</code></td><td style="font-size:11px">${g.numero_factura||'—'}</td><td><span class="badge badge-gray">${CATS_GASTOS[g.categoria]||g.categoria}</span></td><td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${g.descripcion}</td><td style="text-align:right">${fL(g.subtotal)}</td><td style="text-align:right">${g.tasa_isv}%/${fL(g.isv)}</td><td style="text-align:right;font-weight:700;color:#4caf50">${fL(g.total)}</td><td style="text-align:center">${g.deducible?'✅':'❌'}</td><td>${eb}</td><td>${acc}</td></tr>`;});h+='</tbody></table>';wrap.innerHTML=h;renderPaginacion('gastos',pag,'paginaGastos');}
function abrirModalGasto(){document.getElementById('modalGastoTitulo').textContent='🧾 Nuevo Gasto';['gastoId','gastoNumDoc','gastoRTN','gastoProveedor','gastoDescripcion','gastoSubtotal','gastoISV','gastoTotal','gastoObs'].forEach(id=>{const e=document.getElementById(id);if(e)e.value='';});document.getElementById('gastoFecha').value=new Date().toISOString().split('T')[0];document.getElementById('gastoTipoDoc').value='factura';document.getElementById('gastoCategoria').value='servicios';document.getElementById('gastoTasaISV').value='15';document.getElementById('gastoDeducible').checked=true;document.getElementById('gastoEstado').value='pendiente';document.getElementById('errGasto').style.display='none';document.getElementById('rtnMsg').textContent='';const mes=document.getElementById('filtroGastoMes')?.value||(new Date().getMonth()+1);const anio=document.getElementById('filtroGastoAnio')?.value||new Date().getFullYear();document.getElementById('gastoMes').value=mes;document.getElementById('gastoAnio').value=anio;abrirModal('modalGasto');}
async function editarGasto(id){const r=await api(`controllers/GastosController.php?action=obtener&id=${id}`);if(!r.ok){toast('Error.','error');return;}const g=r.data.data;if(g.estado==='declarado'){toast('Gasto declarado: no puede editarse.','error');return;}document.getElementById('modalGastoTitulo').textContent='✏️ Editar Gasto';document.getElementById('gastoId').value=g.id_gasto;document.getElementById('gastoFecha').value=g.fecha;document.getElementById('gastoTipoDoc').value=g.tipo_documento;document.getElementById('gastoNumDoc').value=g.numero_factura||'';document.getElementById('gastoCategoria').value=g.categoria;document.getElementById('gastoRTN').value=g.rtn_proveedor||'';document.getElementById('gastoProveedor').value=g.nombre_proveedor;document.getElementById('gastoDescripcion').value=g.descripcion;document.getElementById('gastoSubtotal').value=g.subtotal;document.getElementById('gastoTasaISV').value=String(g.tasa_isv);document.getElementById('gastoDeducible').checked=!!+g.deducible;document.getElementById('gastoEstado').value=g.estado;document.getElementById('gastoObs').value=g.observaciones||'';document.getElementById('gastoMes').value=g.mes_declaracion;document.getElementById('gastoAnio').value=g.anio_declaracion;document.getElementById('errGasto').style.display='none';document.getElementById('rtnMsg').textContent='';calcularGastoISV();validarRTN();abrirModal('modalGasto');}
function calcularGastoISV(){const sub=parseFloat(document.getElementById('gastoSubtotal').value)||0;const tasa=parseInt(document.getElementById('gastoTasaISV').value)||0;const isv=Math.round(sub*tasa*100)/10000;const tot=sub+isv;const fL=n=>'L. '+n.toLocaleString('es-HN',{minimumFractionDigits:2});const iEl=document.getElementById('gastoISV');if(iEl)iEl.value=fL(isv);const tEl=document.getElementById('gastoTotal');if(tEl)tEl.value=fL(tot);}
function validarRTN(){const rtn=(document.getElementById('gastoRTN').value||'').replace(/\D/g,'');const msg=document.getElementById('rtnMsg');if(!msg)return;if(!rtn){msg.textContent='';return;}if(rtn.length===13){msg.textContent='✅ Persona natural';msg.style.color='#4caf50';}else if(rtn.length===14){msg.textContent='✅ Persona jurídica';msg.style.color='#4caf50';}else{msg.textContent=`⚠️ RTN inválido (${rtn.length} dígitos)`;msg.style.color='var(--danger)';}}
async function guardarGasto(){const errEl=document.getElementById('errGasto');errEl.style.display='none';const id=document.getElementById('gastoId').value;const rtn=(document.getElementById('gastoRTN').value||'').replace(/\D/g,'');if(!document.getElementById('gastoFecha').value){errEl.textContent='Fecha requerida.';errEl.style.display='block';return;}if(!document.getElementById('gastoProveedor').value.trim()){errEl.textContent='Proveedor requerido.';errEl.style.display='block';return;}if(!document.getElementById('gastoDescripcion').value.trim()){errEl.textContent='Descripción requerida.';errEl.style.display='block';return;}const sub=parseFloat(document.getElementById('gastoSubtotal').value);if(!sub){errEl.textContent='Monto requerido.';errEl.style.display='block';return;}if(rtn&&![13,14].includes(rtn.length)){errEl.textContent='RTN inválido.';errEl.style.display='block';return;}const body={id:id?+id:undefined,fecha:document.getElementById('gastoFecha').value,tipo_documento:document.getElementById('gastoTipoDoc').value,numero_factura:document.getElementById('gastoNumDoc').value.trim()||null,categoria:document.getElementById('gastoCategoria').value,rtn_proveedor:rtn||null,nombre_proveedor:document.getElementById('gastoProveedor').value.trim(),descripcion:document.getElementById('gastoDescripcion').value.trim(),subtotal:sub,tasa_isv:parseInt(document.getElementById('gastoTasaISV').value)||0,deducible:document.getElementById('gastoDeducible').checked,mes_declaracion:parseInt(document.getElementById('gastoMes').value),anio_declaracion:parseInt(document.getElementById('gastoAnio').value),estado:document.getElementById('gastoEstado').value,observaciones:document.getElementById('gastoObs').value.trim()||null};const btn=document.getElementById('btnGuardarGasto');if(btn)btn.disabled=true;const r=await api(`controllers/GastosController.php?action=${id?'actualizar':'crear'}`,{method:'POST',body:JSON.stringify(body)});if(btn)btn.disabled=false;if(r.ok){cerrarModal('modalGasto');toast(id?'Gasto actualizado.':'Gasto registrado.','success');cargarGastos();}else{errEl.textContent=r.data?.error||'Error al guardar.';errEl.style.display='block';}}
async function eliminarGasto(id){if(!await confirmDialog('¿Eliminar este registro?'))return;const r=await api('controllers/GastosController.php?action=eliminar',{method:'POST',body:JSON.stringify({id})});if(r.ok){toast('Gasto eliminado.','success');cargarGastos();}else toast(r.data?.error||'Error.','error');}
async function marcarPeriodoDeclarado(){const mes=parseInt(document.getElementById('filtroGastoMes')?.value||0);const anio=parseInt(document.getElementById('filtroGastoAnio')?.value||0);if(!mes||!anio){toast('Selecciona mes y año.','error');return;}if(!await confirmDialog(`¿Marcar todos los gastos pendientes de ${MESES_GASTOS[mes]} ${anio} como declarados?

No podrán editarse ni eliminarse después.`))return;const r=await api('controllers/GastosController.php?action=marcar_declarado',{method:'POST',body:JSON.stringify({mes,anio})});if(r.ok){toast(`${r.data.actualizados} gasto(s) declarados.`,'success');cargarGastos();}else toast(r.data?.error||'Error.','error');}
// ══════════════════════════════════════════════════════════
// MÓDULO: CATÁLOGO DE PRECIOS
// ══════════════════════════════════════════════════════════
let catalogoData = [];
let catalogoDataFull = [];

async function cargarCatalogo() {
  document.getElementById('tablaCatalogoBody').innerHTML = '<tr><td colspan="7" class="empty-state">Cargando...</td></tr>';
  const estado = document.getElementById('filtroCatEstado').value;
  const r = await api(`controllers/CatalogoPreciosController.php?action=listar&estado=${estado}`);
  if (!r.ok) { toast('Error al cargar catálogo.', 'error'); return; }
  catalogoDataFull = r.data.data || [];
  filtrarCatalogo();
}

function filtrarCatalogo() {
  const q    = (document.getElementById('filtroCatQ').value || '').toLowerCase();
  const tipo = document.getElementById('filtroCatTipo').value;
  catalogoData = catalogoDataFull.filter(it => {
    const matchQ = !q ||
      (it.descripcion||'').toLowerCase().includes(q) ||
      (it.codigo||'').toLowerCase().includes(q) ||
      (it.categoria||'').toLowerCase().includes(q);
    const matchTipo = !tipo || it.tipo === tipo;
    return matchQ && matchTipo;
  });
  renderCatalogo();
}

function renderCatalogo() {
  const tbody = document.getElementById('tablaCatalogoBody');
  if (!catalogoData.length) {
    tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Sin ítems registrados.</td></tr>';
    return;
  }
  const tipoBadge = t => t === 'mano_obra' ? '<span class="badge badge-yellow">MO</span>'
                       : t === 'material'  ? '<span class="badge badge-blue">Mat.</span>'
                       : '<span class="badge">Otro</span>';
  tbody.innerHTML = catalogoData.map(it => `
    <tr>
      <td style="font-family:monospace;font-size:12px">${it.codigo || '—'}</td>
      <td><strong>${it.descripcion}</strong></td>
      <td>${tipoBadge(it.tipo)}</td>
      <td>${it.categoria || '—'}</td>
      <td style="text-align:right;font-weight:600">${fmtMoneda(it.precio)}</td>
      <td>${badgeEstado(it.estado)}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="editarCatalogo(${it.id_catalogo})">Editar</button>
        ${it.estado === 'activo'
          ? `<button class="btn btn-sm btn-danger" onclick="cambiarEstadoCatalogo(${it.id_catalogo},'inactivo','${it.descripcion.replace(/'/g,"\\'")}')">Desactivar</button>`
          : `<button class="btn btn-sm btn-secondary" onclick="cambiarEstadoCatalogo(${it.id_catalogo},'activo','${it.descripcion.replace(/'/g,"\\'")}')">Activar</button>`
        }
      </div></td>
    </tr>`).join('');
}

async function abrirModalCatalogo() {
  document.getElementById('tituloCatalogo').textContent = 'Nuevo Ítem';
  document.getElementById('catId').value = '';
  document.getElementById('catCodigo').value = '...';
  ['catDescripcion','catPrecio'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('catTipo').value     = 'material';
  document.getElementById('catCategoria').value = '';
  document.getElementById('errCatalogo').style.display = 'none';
  abrirModal('modalCatalogo');
  // Obtener siguiente código automático
  const r = await api('controllers/CatalogoPreciosController.php?action=siguiente_codigo');
  if (r.ok) document.getElementById('catCodigo').value = r.data.codigo;
}

async function editarCatalogo(id) {
  const r = await api('controllers/CatalogoPreciosController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error al cargar ítem.', 'error'); return; }
  const it = r.data.data;
  document.getElementById('tituloCatalogo').textContent = 'Editar Ítem';
  document.getElementById('catId').value          = it.id_catalogo;
  document.getElementById('catCodigo').value      = it.codigo      || '';
  document.getElementById('catDescripcion').value = it.descripcion || '';
  document.getElementById('catTipo').value        = it.tipo        || 'material';
  document.getElementById('catCategoria').value   = it.categoria   || '';
  document.getElementById('catPrecio').value      = it.precio      || '';
  document.getElementById('errCatalogo').style.display = 'none';
  abrirModal('modalCatalogo');
}

async function guardarCatalogo() {
  const id       = document.getElementById('catId').value;
  const desc     = document.getElementById('catDescripcion').value.trim();
  const categoria= document.getElementById('catCategoria').value;
  const precio   = document.getElementById('catPrecio').value;
  const codigo   = document.getElementById('catCodigo').value.trim();
  const errEl    = document.getElementById('errCatalogo');
  errEl.style.display = 'none';

  if (!desc)      { errEl.textContent = 'La descripción es requerida.'; errEl.style.display = 'block'; return; }
  if (!categoria) { errEl.textContent = 'Selecciona una categoría.';    errEl.style.display = 'block'; return; }
  if (precio === '') { errEl.textContent = 'El precio es requerido.';   errEl.style.display = 'block'; return; }

  // Solo verificar duplicado en NUEVO ítem
  if (!id) {
    try {
      const chk = await api('controllers/CatalogoPreciosController.php?action=existe&descripcion=' + encodeURIComponent(desc));
      if (chk.ok && chk.data.existe) {
        errEl.textContent = 'Ya existe un ítem activo con esa descripción (Cód. ' + (chk.data.id || '?') + ').';
        errEl.style.display = 'block';
        return;
      }
    } catch(e) { /* si falla la verificación, continuar */ }
  }

  const body = {
    codigo,
    descripcion: desc,
    tipo:        document.getElementById('catTipo').value,
    categoria,
    precio:      parseFloat(precio),
  };
  if (id) body.id = +id;

  try {
    const action = id ? 'editar' : 'crear';
    const r = await api('controllers/CatalogoPreciosController.php?action=' + action, {
      method: 'POST', body: JSON.stringify(body),
    });
    if (r.ok) {
      cerrarModal('modalCatalogo');
      toast(id ? 'Ítem actualizado.' : 'Ítem creado.', 'success');
      cargarCatalogo();
    } else {
      errEl.textContent = r.data?.error || 'Error al guardar.';
      errEl.style.display = 'block';
    }
  } catch(e) {
    errEl.textContent = 'Error de conexión al guardar.';
    errEl.style.display = 'block';
  }
}

async function cambiarEstadoCatalogo(id, estado, nombre) {
  if (!confirm(`¿${estado === 'inactivo' ? 'Desactivar' : 'Activar'} "${nombre}"?`)) return;
  const r = await api('controllers/CatalogoPreciosController.php?action=estado', {
    method: 'POST', body: JSON.stringify({ id, estado }),
  });
  if (r.ok) { toast(`Ítem ${estado === 'inactivo' ? 'desactivado' : 'activado'}.`, 'success'); cargarCatalogo(); }
}

// ── Exportar Excel ──────────────────────────────────────────
function exportarCatalogoExcel() {
  if (!catalogoDataFull.length) { toast('Sin datos.', 'error'); return; }
  const tipoBadge = t => t === 'mano_obra' ? 'Mano de Obra' : t === 'material' ? 'Material' : 'Otro';
  const rows = [
    ['CATÁLOGO DE PRECIOS — VAMER / SOLDYMEG'],
    [],
    ['Código', 'Descripción', 'Tipo', 'Categoría', 'Precio (L.)', 'Estado'],
    ...catalogoData.map(it => [
      it.codigo || '',
      it.descripcion,
      tipoBadge(it.tipo),
      it.categoria || '',
      parseFloat(it.precio),
      it.estado === 'activo' ? 'Activo' : 'Inactivo',
    ]),
  ];
  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [12, 40, 14, 18, 14, 10].map(w => ({ wch: w }));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Catalogo');
  XLSX.writeFile(wb, 'Catalogo_Precios.xlsx');
  toast('Excel generado.', 'success');
}

// ── Exportar PDF ────────────────────────────────────────────
function exportarCatalogoPDF() {
  if (!catalogoData.length) { toast('Sin datos.', 'error'); return; }
  const tipoBadge = t => t === 'mano_obra' ? 'MO' : t === 'material' ? 'Mat.' : 'Otro';
  const fmtP = n => 'L. ' + Number(n||0).toLocaleString('es-HN', { minimumFractionDigits: 2 });
  const rows = catalogoData.map((it, i) => `
    <tr>
      <td style="text-align:center">${i+1}</td>
      <td style="font-family:monospace;font-size:11px">${it.codigo||'—'}</td>
      <td>${it.descripcion}</td>
      <td style="text-align:center">${tipoBadge(it.tipo)}</td>
      <td>${it.categoria||'—'}</td>
      <td style="text-align:right;font-weight:600">${fmtP(it.precio)}</td>
    </tr>`).join('');
  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8">
  <title>Catálogo de Precios</title>
  <style>
    body{font-family:Arial,sans-serif;font-size:11px;padding:20px;color:#111}
    h2{text-align:center;margin-bottom:4px}
    p{text-align:center;color:#555;margin-bottom:12px}
    table{width:100%;border-collapse:collapse}
    th{background:#ddd;border:1px solid #333;padding:5px;font-size:10px;text-align:center;text-transform:uppercase}
    td{border:1px solid #ccc;padding:4px 6px}
    @media print{@page{margin:10mm}}
  </style></head><body>
  <h2>CATÁLOGO DE PRECIOS</h2>
  <p>VENTAS AMERICA S. DE R.L / SOLDYMEG — ${new Date().toLocaleDateString('es-HN')}</p>
  <table>
    <thead><tr><th>#</th><th>Código</th><th>Descripción</th><th>Tipo</th><th>Categoría</th><th>Precio</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>
  <script>window.onload=()=>window.print()<\/script>
  </body></html>`;
  const w = window.open('', '_blank');
  w.document.write(html);
  w.document.close();
}

// ══════════════════════════════════════════════════════════
// BUSCAR EN CATÁLOGO (para cotización directa)
// ══════════════════════════════════════════════════════════
let catalogoModalData = [];

async function abrirBuscarCatalogo() {
  document.getElementById('buscarCatQ').value = '';
  document.getElementById('buscarCatTipo').value = '';
  document.getElementById('catalogoModalBody').innerHTML = '<tr><td colspan="6" class="empty-state">Cargando...</td></tr>';
  abrirModal('modalBuscarCatalogo');
  const r = await api('controllers/CatalogoPreciosController.php?action=listar&estado=activo');
  catalogoModalData = r.ok ? (r.data.data || []) : [];
  filtrarCatalogoModal();
}

function filtrarCatalogoModal() {
  const q    = (document.getElementById('buscarCatQ').value || '').toLowerCase();
  const tipo = document.getElementById('buscarCatTipo').value;
  const lista = catalogoModalData.filter(it => {
    const matchQ = !q || (it.descripcion||'').toLowerCase().includes(q) || (it.codigo||'').toLowerCase().includes(q) || (it.categoria||'').toLowerCase().includes(q);
    return matchQ && (!tipo || it.tipo === tipo);
  });
  const tbody = document.getElementById('catalogoModalBody');
  if (!lista.length) { tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Sin resultados.</td></tr>'; return; }
  const tipoBadge = t => t === 'mano_obra' ? '<span class="badge badge-yellow">MO</span>' : t === 'material' ? '<span class="badge badge-blue">Mat.</span>' : '<span class="badge">Otro</span>';
  tbody.innerHTML = lista.map(it => `
    <tr>
      <td style="font-family:monospace;font-size:11px">${it.codigo||'—'}</td>
      <td>${it.descripcion}</td>
      <td>${tipoBadge(it.tipo)}</td>
      <td>${it.categoria||'—'}</td>
      <td style="text-align:right;font-weight:600">${fmtMoneda(it.precio)}</td>
      <td><button class="btn btn-sm btn-primary" onclick="seleccionarDelCatalogo(${it.id_catalogo})">+ Usar</button></td>
    </tr>`).join('');
}

function seleccionarDelCatalogo(id) {
  const it = catalogoModalData.find(i => i.id_catalogo === id);
  if (!it) return;
  document.getElementById('cotDirDesc').value   = it.descripcion;
  document.getElementById('cotDirTipo').value   = it.tipo;
  document.getElementById('cotDirPrecio').value = it.precio;
  document.getElementById('cotDirCant').value   = '1';
  cerrarModal('modalBuscarCatalogo');
}

// ── Guardar ítem al catálogo desde cotización directa ──────
async function guardarItemEnCatalogo(desc, tipo, precio) {
  // Verificar si ya existe en el catálogo
  const chk = await api('controllers/CatalogoPreciosController.php?action=existe&descripcion=' + encodeURIComponent(desc));
  if (chk.ok && chk.data.existe) {
    toast('⚠️ Ya existe en catálogo (Cód. ' + (chk.data.id||'?') + ').', 'warn');
    return;
  }
  // Obtener código automático
  const codR = await api('controllers/CatalogoPreciosController.php?action=siguiente_codigo');
  const codigo = codR.ok ? codR.data.codigo : '0001';
  const body = { codigo, descripcion: desc, tipo, precio: parseFloat(precio), categoria: 'Otros' };
  const r = await api('controllers/CatalogoPreciosController.php?action=crear', {
    method: 'POST', body: JSON.stringify(body),
  });
  if (r.ok) toast('✅ Agregado al catálogo (Cód. ' + codigo + ').', 'success');
  else toast('Error al guardar en catálogo.', 'error');
}

// ══════════════════════════════════════════════════════════
// MÓDULO: REQUISICIONES DE MATERIALES
// ══════════════════════════════════════════════════════════
let requisicionesData     = [];
let requisicionesDataFull = [];
let reqFilaCount          = 0;
let inventarioParaReq     = []; // cache de materiales para autocomplete

async function cargarRequisiciones() {
  document.getElementById('tablaReqBody').innerHTML = '<tr><td colspan="8" class="empty-state">Cargando...</td></tr>';
  const est = document.getElementById('filtroReqEstado').value;
  const r   = await api(`controllers/RequisicionController.php?action=listar&estado=${est}`);
  if (!r.ok) { toast('Error al cargar requisiciones.', 'error'); return; }
  requisicionesDataFull = r.data.data || [];
  filtrarRequisiciones();
}

function filtrarRequisiciones() {
  const q = (document.getElementById('filtroReqQ').value || '').toLowerCase();
  requisicionesData = !q ? [...requisicionesDataFull] : requisicionesDataFull.filter(r =>
    (r.numero||'').toLowerCase().includes(q) ||
    (r.empleado_nombre||'').toLowerCase().includes(q) ||
    (r.departamento||'').toLowerCase().includes(q) ||
    (r.numero_ot||'').toLowerCase().includes(q) ||
    (r.unidad||'').toLowerCase().includes(q)
  );
  renderRequisiciones();
}

const ESTADO_REQ_BADGES = {
  pendiente:  '<span class="badge badge-yellow">Pendiente</span>',
  aprobada:   '<span class="badge badge-green">Aprobada</span>',
  despachada: '<span class="badge badge-blue">Despachada</span>',
  anulada:    '<span class="badge badge-red">Anulada</span>',
};

function renderRequisiciones() {
  const tbody = document.getElementById('tablaReqBody');
  if (!requisicionesData.length) {
    tbody.innerHTML = '<tr><td colspan="8" class="empty-state">Sin requisiciones registradas.</td></tr>';
    return;
  }
  tbody.innerHTML = requisicionesData.map(r => `
    <tr>
      <td style="font-family:monospace;font-weight:700;color:var(--accent)">${r.numero}</td>
      <td>${r.fecha_solicitud}</td>
      <td>${r.empleado_nombre}</td>
      <td>${r.departamento}</td>
      <td>${r.numero_ot || '—'}</td>
      <td>${r.unidad || '—'}</td>
      <td>${ESTADO_REQ_BADGES[r.estado] || r.estado}</td>
      <td><div class="td-actions">
        <button class="btn btn-sm btn-secondary" onclick="verRequisicion(${r.id_requisicion})">Ver</button>
        ${r.estado === 'pendiente' ? `
          <button class="btn btn-sm btn-secondary" onclick="editarRequisicion(${r.id_requisicion})">Editar</button>
          <button class="btn btn-sm btn-primary"   onclick="cambiarEstadoReq(${r.id_requisicion},'aprobada')">Aprobar</button>
          <button class="btn btn-sm btn-danger"    onclick="cambiarEstadoReq(${r.id_requisicion},'anulada')">Anular</button>
        ` : ''}
        ${r.estado === 'aprobada' ? `
          <button class="btn btn-sm btn-primary" onclick="cambiarEstadoReq(${r.id_requisicion},'despachada')">Despachar</button>
        ` : ''}
      </div></td>
    </tr>`).join('');
}

// ── Abrir modal nueva requisición ───────────────────────────
async function abrirModalRequisicion() {
  document.getElementById('tituloRequisicion').textContent = 'Nueva Requisición de Materiales';
  document.getElementById('reqId').value      = '';
  document.getElementById('reqNumero').value  = '...';
  document.getElementById('reqFecha').value   = new Date().toISOString().slice(0,10);
  document.getElementById('reqEmpleado').value = '';
  document.getElementById('reqDepartamento').value = '';
  document.getElementById('reqOT').value      = '';
  document.getElementById('reqUnidad').value  = '';
  document.getElementById('reqObs').value     = '';
  document.getElementById('errRequisicion').style.display = 'none';
  reqFilaCount = 0;
  document.getElementById('reqDetalleBody').innerHTML =
    '<tr id="reqFilaVacia"><td colspan="6" style="text-align:center;color:var(--muted);padding:12px">Sin materiales. Haga clic en "+ Agregar Material".</td></tr>';

  await cargarEmpleadosReq();
  const rn = await api('controllers/RequisicionController.php?action=siguiente_numero');
  if (rn.ok) document.getElementById('reqNumero').value = rn.data.numero;

  abrirModal('modalRequisicion');
  agregarFilaReq(); // abrir con una fila lista
}

async function editarRequisicion(id) {
  const r = await api('controllers/RequisicionController.php?action=obtener&id=' + id);
  if (!r.ok) { toast('Error al cargar.', 'error'); return; }
  const req = r.data.data;
  document.getElementById('tituloRequisicion').textContent = 'Editar Requisición ' + req.numero;
  document.getElementById('reqId').value           = req.id_requisicion;
  document.getElementById('reqNumero').value       = req.numero;
  document.getElementById('reqFecha').value        = req.fecha_solicitud;
  document.getElementById('reqOT').value           = req.numero_ot   || '';
  document.getElementById('reqUnidad').value       = req.unidad      || '';
  document.getElementById('reqObs').value          = req.observaciones || '';
  document.getElementById('errRequisicion').style.display = 'none';

  await cargarEmpleadosReq();
  document.getElementById('reqEmpleado').value    = req.empleado_id;
  document.getElementById('reqDepartamento').value = req.departamento;

  reqFilaCount = 0;
  document.getElementById('reqDetalleBody').innerHTML = '';
  (req.detalle || []).forEach(it => agregarFilaReq(it));
  if (!(req.detalle||[]).length) {
    document.getElementById('reqDetalleBody').innerHTML =
      '<tr id="reqFilaVacia"><td colspan="6" style="text-align:center;color:var(--muted);padding:12px">Sin materiales.</td></tr>';
  }
  abrirModal('modalRequisicion');
}

async function cargarEmpleadosReq() {
  const sel = document.getElementById('reqEmpleado');
  const cur = sel.value;
  sel.innerHTML = '<option value="">— Seleccionar —</option>';
  // Solo empleados SOLDYMEG activos
  const r = await api('controllers/EmpleadoController.php?action=listar&estado=activo&ubicacion=SOLDYMEG');
  if (r.ok) {
    (r.data.data || []).forEach(e => {
      const opt = document.createElement('option');
      opt.value       = e.id_empleado;
      opt.textContent = e.nombre;
      opt.dataset.departamento    = e.departamento_nombre || '';
      opt.dataset.departamento_id = e.departamento_id    || '';
      sel.appendChild(opt);
    });
  }
  if (cur) sel.value = cur;
  // Auto-rellenar departamento al cambiar empleado
  sel.onchange = () => {
    const opt = sel.selectedOptions[0];
    if (opt && opt.dataset.departamento) {
      document.getElementById('reqDepartamento').value = opt.dataset.departamento;
    }
  };
}

// ── Filas de detalle ────────────────────────────────────────
function agregarFilaReq(it = null) {
  const vacia = document.getElementById('reqFilaVacia');
  if (vacia) vacia.remove();
  const idx = reqFilaCount++;
  const tr  = document.createElement('tr');
  tr.id     = `reqFila_${idx}`;
  const desc = it ? it.descripcion       : '';
  const um   = it ? (it.unidad_medida||'unidad') : 'unidad';
  const cant = it ? it.cantidad          : '';
  const obs  = it ? (it.observacion||'') : '';
  const mid  = it ? (it.material_id||'') : '';
  tr.innerHTML = `
    <td style="text-align:center;color:var(--muted);font-size:12px">${idx+1}</td>
    <td>
      <input type="hidden" class="req-mat-id" value="${mid}">
      <input type="text" class="req-desc"
             value="${desc}"
             placeholder="Descripción del material"
             style="width:100%;padding:5px 7px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px"
             oninput="buscarMaterialReq(this,${idx})">
      <div class="req-sugerencias" id="reqSug_${idx}" style="display:none;position:absolute;z-index:200;background:var(--surface);border:1px solid var(--border);border-radius:6px;max-height:160px;overflow-y:auto;min-width:240px"></div>
    </td>
    <td>
      <select class="req-um" style="width:100%;padding:5px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
        ${['unidad','piezas','kg','lb','litros','metros','galones','rollos','cajas','bolsas'].map(u=>`<option value="${u}"${u===um?' selected':''}>${u}</option>`).join('')}
      </select>
    </td>
    <td>
      <input type="number" class="req-cant" value="${cant}" min="0.01" step="0.01"
             placeholder="0"
             style="width:100%;padding:5px 7px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right">
    </td>
    <td>
      <input type="text" class="req-obs" value="${obs}" placeholder="Nota..."
             style="width:100%;padding:5px 7px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
    </td>
    <td style="text-align:center">
      <button class="btn btn-sm btn-danger" onclick="quitarFilaReq(${idx})">✕</button>
    </td>`;
  document.getElementById('reqDetalleBody').appendChild(tr);
}

function quitarFilaReq(idx) {
  const tr = document.getElementById(`reqFila_${idx}`);
  if (tr) tr.remove();
  if (!document.getElementById('reqDetalleBody').querySelector('tr')) {
    document.getElementById('reqDetalleBody').innerHTML =
      '<tr id="reqFilaVacia"><td colspan="6" style="text-align:center;color:var(--muted);padding:12px">Sin materiales.</td></tr>';
  }
}

async function buscarMaterialReq(input, idx) {
  const q = input.value.trim();
  const sug = document.getElementById(`reqSug_${idx}`);
  if (q.length < 2) { sug.style.display='none'; return; }
  if (!inventarioParaReq.length) {
    const r = await api('controllers/InventarioController.php?action=listar');
    if (r.ok) inventarioParaReq = r.data.data || [];
  }
  const lista = inventarioParaReq.filter(m =>
    (m.nombre||'').toLowerCase().includes(q.toLowerCase()) ||
    (m.codigo||'').toLowerCase().includes(q.toLowerCase())
  ).slice(0, 8);
  if (!lista.length) { sug.style.display='none'; return; }
  sug.innerHTML = lista.map(m => `
    <div style="padding:6px 10px;cursor:pointer;font-size:12px;border-bottom:1px solid var(--border)"
         onmousedown="seleccionarMaterialReq(${idx},'${m.nombre.replace(/'/g,"\\'")}',${m.id_material})">
      <strong>${m.nombre}</strong> <span style="color:var(--muted)">${m.codigo||''}</span>
      <span style="float:right;color:var(--accent)">Stock: ${m.stock}</span>
    </div>`).join('');
  sug.style.display = '';
}

function seleccionarMaterialReq(idx, nombre, materialId) {
  const tr  = document.getElementById(`reqFila_${idx}`);
  tr.querySelector('.req-desc').value   = nombre;
  tr.querySelector('.req-mat-id').value = materialId;
  document.getElementById(`reqSug_${idx}`).style.display = 'none';
}

// ── Guardar ────────────────────────────────────────────────
async function guardarRequisicion() {
  const id         = document.getElementById('reqId').value;
  const empleadoId = document.getElementById('reqEmpleado').value;
  const fecha      = document.getElementById('reqFecha').value;
  const depto      = document.getElementById('reqDepartamento').value;
  const errEl      = document.getElementById('errRequisicion');
  errEl.style.display = 'none';

  if (!empleadoId) { errEl.textContent='Selecciona el empleado que solicita.'; errEl.style.display='block'; return; }
  if (!fecha)      { errEl.textContent='La fecha de solicitud es requerida.';  errEl.style.display='block'; return; }
  if (!depto)      { errEl.textContent='Selecciona el departamento.';          errEl.style.display='block'; return; }

  const filas   = [...document.getElementById('reqDetalleBody').querySelectorAll('tr[id^="reqFila_"]')];
  const detalle = filas.map(tr => ({
    material_id:   tr.querySelector('.req-mat-id').value || null,
    descripcion:   tr.querySelector('.req-desc').value.trim(),
    unidad_medida: tr.querySelector('.req-um').value,
    cantidad:      parseFloat(tr.querySelector('.req-cant').value) || 0,
    observacion:   tr.querySelector('.req-obs').value.trim(),
  })).filter(it => it.descripcion && it.cantidad > 0);

  if (!detalle.length) { errEl.textContent='Agrega al menos un material con descripción y cantidad.'; errEl.style.display='block'; return; }

  const body = {
    id:               id ? +id : undefined,
    fecha_solicitud:  fecha,
    empleado_id:      +empleadoId,
    departamento:     depto,
    numero_ot:        document.getElementById('reqOT').value.trim(),
    unidad:           document.getElementById('reqUnidad').value.trim(),
    observaciones:    document.getElementById('reqObs').value.trim(),
    detalle,
  };

  try {
    const action = id ? 'editar' : 'crear';
    const r = await api('controllers/RequisicionController.php?action=' + action, {
      method: 'POST', body: JSON.stringify(body),
    });
    if (r.ok) {
      cerrarModal('modalRequisicion');
      toast(id ? 'Requisición actualizada.' : `Requisición ${r.data.numero||''} creada.`, 'success');
      cargarRequisiciones();
    } else {
      errEl.textContent = r.data?.error || 'Error al guardar.';
      errEl.style.display = 'block';
    }
  } catch(e) {
    errEl.textContent = 'Error de conexión.';
    errEl.style.display = 'block';
  }
}

// ── Ver detalle ─────────────────────────────────────────────
async function verRequisicion(id) {
  document.getElementById('contenidoVerReq').innerHTML = '<p class="loading">Cargando...</p>';
  abrirModal('modalVerRequisicion');
  const r = await api('controllers/RequisicionController.php?action=obtener&id=' + id);
  if (!r.ok) { document.getElementById('contenidoVerReq').innerHTML = '<p style="color:var(--danger)">Error.</p>'; return; }
  const req = r.data.data;
  const fila = (it, i) => `
    <tr>
      <td style="text-align:center">${i+1}</td>
      <td>${it.descripcion}</td>
      <td style="text-align:center">${it.unidad_medida}</td>
      <td style="text-align:center;font-weight:600">${it.cantidad}</td>
      <td>${it.observacion||'—'}</td>
    </tr>`;
  document.getElementById('contenidoVerReq').innerHTML = `
    <h4 style="margin-bottom:12px">📋 ${req.numero} — ${ESTADO_REQ_BADGES[req.estado]||req.estado}</h4>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px 16px;font-size:13px;margin-bottom:14px">
      <div><span style="color:var(--muted)">Fecha:</span> <strong>${req.fecha_solicitud}</strong></div>
      <div><span style="color:var(--muted)">Empleado:</span> <strong>${req.empleado_nombre}</strong></div>
      <div><span style="color:var(--muted)">Departamento:</span> <strong>${req.departamento}</strong></div>
      <div><span style="color:var(--muted)">N° OT:</span> <strong>${req.numero_ot||'—'}</strong></div>
      <div><span style="color:var(--muted)">Unidad/Placa:</span> <strong>${req.unidad||'—'}</strong></div>
    </div>
    <table style="width:100%;border-collapse:collapse;font-size:12px">
      <thead><tr style="background:var(--bg-alt,#1e1e2e)">
        <th style="padding:5px;border:1px solid var(--border)">#</th>
        <th style="padding:5px;border:1px solid var(--border)">Descripción</th>
        <th style="padding:5px;border:1px solid var(--border)">Unidad</th>
        <th style="padding:5px;border:1px solid var(--border)">Cantidad</th>
        <th style="padding:5px;border:1px solid var(--border)">Observación</th>
      </tr></thead>
      <tbody>${(req.detalle||[]).map(fila).join('')}</tbody>
    </table>
    ${req.observaciones ? `<div style="margin-top:10px;font-size:12px"><strong>Observaciones:</strong> ${req.observaciones}</div>` : ''}`;
  window._reqImprimirData = req;
}

function imprimirRequisicion() {
  const req = window._reqImprimirData;
  if (!req) return;
  const filas = (req.detalle||[]).map((it,i) => `
    <tr>
      <td style="text-align:center;border:1px solid #ccc;padding:4px">${i+1}</td>
      <td style="border:1px solid #ccc;padding:4px">${it.descripcion}</td>
      <td style="text-align:center;border:1px solid #ccc;padding:4px">${it.unidad_medida}</td>
      <td style="text-align:center;border:1px solid #ccc;padding:4px;font-weight:700">${it.cantidad}</td>
      <td style="border:1px solid #ccc;padding:4px">${it.observacion||''}</td>
    </tr>`).join('');
  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8">
  <title>${req.numero}</title>
  <style>
    body{font-family:Arial,sans-serif;font-size:11px;padding:20px;color:#111}
    h2{text-align:center;margin-bottom:2px}
    .info{display:grid;grid-template-columns:1fr 1fr;gap:4px 20px;margin:10px 0;font-size:11px}
    .lbl{font-weight:700}
    table{width:100%;border-collapse:collapse;margin-top:10px}
    th{background:#ddd;border:1px solid #333;padding:5px;text-transform:uppercase;font-size:10px}
    .firma{margin-top:40px;display:flex;justify-content:space-around}
    .firma div{text-align:center;width:200px;border-top:1px solid #333;padding-top:4px;font-size:10px}
    @media print{@page{margin:10mm}}
  </style></head><body>
  <h2>REQUISICIÓN DE MATERIALES</h2>
  <p style="text-align:center;color:#555;margin:2px">VENTAS AMERICA S. DE R.L / SOLDYMEG</p>
  <div class="info">
    <div><span class="lbl">N° Requisición:</span> ${req.numero}</div>
    <div><span class="lbl">Fecha:</span> ${req.fecha_solicitud}</div>
    <div><span class="lbl">Empleado:</span> ${req.empleado_nombre}</div>
    <div><span class="lbl">Departamento:</span> ${req.departamento}</div>
    <div><span class="lbl">N° OT:</span> ${req.numero_ot||'—'}</div>
    <div><span class="lbl">Unidad/Placa:</span> ${req.unidad||'—'}</div>
  </div>
  <table>
    <thead><tr><th>#</th><th>Descripción</th><th>Unidad Med.</th><th>Cantidad</th><th>Observación</th></tr></thead>
    <tbody>${filas}</tbody>
  </table>
  ${req.observaciones ? `<p style="margin-top:8px"><strong>Observaciones:</strong> ${req.observaciones}</p>` : ''}
  <div class="firma">
    <div>Solicitado por<br><br>${req.empleado_nombre}</div>
    <div>Aprobado por<br><br>&nbsp;</div>
    <div>Despachado por<br><br>&nbsp;</div>
  </div>
  <script>window.onload=()=>window.print()<\/script>
  </body></html>`;
  const w = window.open('','_blank'); w.document.write(html); w.document.close();
}

// ── Cambiar estado ──────────────────────────────────────────
async function cambiarEstadoReq(id, estado) {
  const msgs = { aprobada:'¿Aprobar esta requisición?', anulada:'¿Anular esta requisición?', despachada:'¿Despachar y rebajar inventario?' };
  if (!confirm(msgs[estado] || '¿Cambiar estado?')) return;
  const r = await api('controllers/RequisicionController.php?action=estado', {
    method:'POST', body: JSON.stringify({id, estado}),
  });
  if (r.ok) { toast('Estado actualizado.','success'); cargarRequisiciones(); }
  else alert('⚠️ ' + (r.data?.error || 'Error al cambiar estado.'));
}

// ── Exportar Excel ──────────────────────────────────────────
function exportarRequisicionesExcel() {
  if (!requisicionesDataFull.length) { toast('Sin datos.','error'); return; }
  const rows = [
    ['N° Requisición','Fecha','Empleado','Departamento','N° OT','Unidad','Estado','Fecha Creación'],
    ...requisicionesDataFull.map(r => [
      r.numero, r.fecha_solicitud, r.empleado_nombre, r.departamento,
      r.numero_ot||'', r.unidad||'', r.estado,
      r.fecha_creacion ? r.fecha_creacion.slice(0,10) : '',
    ]),
  ];
  const ws = XLSX.utils.aoa_to_sheet(rows);
  ws['!cols'] = [14,12,22,18,12,12,12,12].map(w=>({wch:w}));
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, 'Requisiciones');
  XLSX.writeFile(wb, 'Requisiciones_Materiales.xlsx');
  toast('Excel generado.','success');
}

function exportarGastosExcel(){if(!gastosData.length){toast('Sin datos.','error');return;}const mes=document.getElementById('filtroGastoMes')?.value||'';const anio=document.getElementById('filtroGastoAnio')?.value||'';const fN=n=>Number(n||0).toFixed(2);const rows=[['Fecha','Proveedor','RTN','N° Documento','Categoría','Descripción','Subtotal','ISV %','ISV','Total','Deducible','Estado','Mes','Año'],...gastosData.map(g=>[g.fecha,g.nombre_proveedor,g.rtn_proveedor||'',g.numero_factura||'',CATS_GASTOS[g.categoria]||g.categoria,g.descripcion,fN(g.subtotal),g.tasa_isv,fN(g.isv),fN(g.total),g.deducible?'Sí':'No',g.estado,MESES_GASTOS[g.mes_declaracion]||g.mes_declaracion,g.anio_declaracion])];const ws=XLSX.utils.aoa_to_sheet(rows);ws['!cols']=[10,25,16,20,14,30,12,8,12,12,10,10,12,6].map(w=>({wch:w}));const wb=XLSX.utils.book_new();XLSX.utils.book_append_sheet(wb,ws,'Gastos DMC');XLSX.writeFile(wb,`Gastos_DMC${mes?'_'+MESES_GASTOS[mes]:''}${anio?'_'+anio:''}.xlsx`);toast('Excel generado.','success');}

async function exportarCotizacionExcel(id) {
  try {
    const r = await api('controllers/CotizacionesController.php?action=obtener&id=' + id);
    if (!r.ok || !r.data?.data) { toast('Error al obtener cotización.', 'error'); return; }
    const c   = r.data.data;
    const det = c.detalle || [];
    const fN  = n => parseFloat(Number(n || 0).toFixed(2));
    const fU  = n => { const v = parseFloat(n||0); return v === Math.floor(v) ? Math.floor(v) : v; };
    const num    = (c.numero_cotizacion || '').toUpperCase();
    const fecha  = c.fecha ? c.fecha.split('-').reverse().join('/') : '';

    const elaborado = (c.elaborado_por      || '').toUpperCase();
    const telElab   = (c.telefono_elaborado || '');
    const cliente   = (c.cliente            || '').toUpperCase();
    const rtn       = (c.cliente_rtn        || '');
    const dir       = (c.cliente_direccion  || '').toUpperCase();
    const tel       = (c.cliente_tel        || '');
    const unidad    = (c.unidad             || '').toUpperCase();
    const obs       = [c.ot_cliente, c.orden_compra, c.observaciones].filter(Boolean).join(' ').trim();
    const subtotal  = fN(c.subtotal_comercial);
    const isv       = fN(c.isv);
    const total     = fN(c.total);

    const rows = [];

    rows.push(['VENTAS AMERICA S. DE R.L']);
    rows.push(['Col. San Sebastian, Frente a Cemcol — San Pedro Sula, Cortés']);
    rows.push(['TEL. 9941-8647 | 9596-9903 | vamerhn@gmail.com']);
    rows.push([]);
    rows.push(['', '', 'COTIZACIÓN']);
    rows.push([]);

    rows.push(['CLIENTE:',     cliente,  '', 'ELABORADO POR:',  elaborado]);
    rows.push(['RTN:',         rtn,      '', 'TELÉFONO:',       telElab]);
    rows.push(['DIRECCIÓN:',   dir,      '', 'COTIZACIÓN NO.:', num]);
    rows.push(['TELÉFONO:',    tel,      '', 'FECHA:',          fecha]);
    rows.push(['UNIDAD/PLACA:', unidad]);
    rows.push([]);

    rows.push(['ITEM', 'CÓDIGO', 'DESCRIPCIÓN', 'CANT.', 'P. UNITARIO', 'TOTAL']);

    det.forEach((it, i) => {
      const sub = fN(it.subtotal_final ?? (parseFloat(it.cantidad) * parseFloat(it.precio_unitario)));
      rows.push([i+1, i+1, (it.descripcion||'').toUpperCase(), fU(it.cantidad), fN(it.precio_unitario), sub]);
    });

    for (let e = 0; e < Math.max(0, 20 - det.length); e++) {
      rows.push(['', '', '-', '', '-', '-']);
    }
    rows.push([]);

    if (obs) { rows.push(['OBSERVACIONES:']); rows.push([obs]); rows.push([]); }

    rows.push(['', '', '', '', 'SUB-TOTAL', subtotal]);
    rows.push(['', '', '', '', 'ISV',       isv]);
    rows.push(['', '', '', '', 'TOTAL',     total]);
    rows.push([]);
    rows.push(['AUTORIZADO POR: HENRY JOSUE GUDIEL DIAZ']);

    const ws = XLSX.utils.aoa_to_sheet(rows);
    ws['!cols'] = [14, 12, 42, 8, 14, 14].map(w => ({ wch: w }));

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Cotizacion');
    XLSX.writeFile(wb, num + '.xlsx');
    toast('Excel generado.', 'success');
  } catch(e) {
    console.error(e);
    toast('Error al generar Excel.', 'error');
  }
}
function exportarGastosPDF(){if(!gastosData.length){toast('Sin datos.','error');return;}const mes=document.getElementById('filtroGastoMes')?.value||'';const anio=document.getElementById('filtroGastoAnio')?.value||'';const fL=n=>'L. '+Number(n||0).toLocaleString('es-HN',{minimumFractionDigits:2});const totGen=gastosData.reduce((a,g)=>a+ +g.total,0);const totSub=gastosData.reduce((a,g)=>a+ +g.subtotal,0);const totISV=gastosData.reduce((a,g)=>a+ +g.isv,0);const rows=gastosData.map(g=>`<tr><td>${g.fecha}</td><td>${g.nombre_proveedor}</td><td>${g.rtn_proveedor||'—'}</td><td>${g.numero_factura||'—'}</td><td>${CATS_GASTOS[g.categoria]||g.categoria}</td><td>${g.descripcion}</td><td style="text-align:right">${fL(g.subtotal)}</td><td style="text-align:center">${g.tasa_isv}%</td><td style="text-align:right">${fL(g.isv)}</td><td style="text-align:right;font-weight:700">${fL(g.total)}</td><td>${g.deducible?'Sí':'No'}</td><td style="color:${g.estado==='declarado'?'green':'orange'}">${g.estado==='declarado'?'Declarado':'Pendiente'}</td></tr>`).join('');const html=`<!DOCTYPE html><html><head><meta charset="utf-8"><title>Gastos DMC</title><style>body{font-family:Arial,sans-serif;font-size:10px;margin:15px}h2{color:#00c853}table{width:100%;border-collapse:collapse}th{background:#00c853;color:#fff;padding:5px 3px;text-align:left}td{padding:3px;border-bottom:1px solid #eee}tr:nth-child(even){background:#f9f9f9}.tot{margin-top:10px;text-align:right}@media print{@page{size:landscape;margin:10mm}}</style></head><body><h2>VAMER — Gastos DMC</h2><p>${mes?MESES_GASTOS[mes]:''} ${anio} | ${new Date().toLocaleDateString('es-HN')}</p><table><thead><tr><th>Fecha</th><th>Proveedor</th><th>RTN</th><th>N° Doc</th><th>Categoría</th><th>Descripción</th><th>Subtotal</th><th>ISV%</th><th>ISV</th><th>Total</th><th>Ded.</th><th>Estado</th></tr></thead><tbody>${rows}</tbody></table><div class="tot">Sub:${fL(totSub)} ISV:${fL(totISV)} <strong>Total:${fL(totGen)}</strong></div></body></html>`;const w=window.open('','_blank');w.document.write(html);w.document.close();w.focus();setTimeout(()=>w.print(),400);}
