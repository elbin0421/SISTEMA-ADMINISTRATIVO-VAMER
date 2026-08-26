// ══════════════════════════════════════════════════════════
// core.js — Núcleo: globales, sidebar, auth, API, paginación, toast, modal, helpers
// Extraído de dashboard.js líneas 1-272
// ══════════════════════════════════════════════════════════

// ── GLOBALES ─────────────────────────────────────────────────

// ── MAPA MÓDULO → GRUPO ──────────────────────────────────────
const MODULE_GROUP = {
  usuarios: 'admin', roles: 'admin',
  clientes: 'operaciones', inventario: 'operaciones', compras: 'operaciones',
  proveedores: 'operaciones', ordenes: 'operaciones',
  vehiculos: 'operaciones', requisiciones: 'operaciones',
  cotizaciones: 'comercial', facturacion: 'comercial', cai: 'comercial',
  libro_ventas: 'comercial', pagos: 'comercial', gastos: 'comercial', catalogo: 'comercial',
  movimientos: 'comercial',
  planillas: 'rrhh', vacaciones: 'rrhh',
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
  if (!document.body.classList.contains('sb-mini')) {
    document.querySelectorAll('.nav-group-body').forEach(b => b.classList.remove('open'));
    document.querySelectorAll('.nav-group-header').forEach(h => h.classList.remove('open'));
  }
  if (grpId) {
    const grp = document.getElementById('grp-' + grpId);
    if (grp) {
      grp.classList.add('has-active');
      if (!document.body.classList.contains('sb-mini')) toggleGrupo(grpId, true);
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
const modTitles = { inicio:'Inicio', clientes:'Clientes', vehiculos:'Vehículos', inventario:'Inventario', requisiciones:'Requisiciones de Materiales', compras:'Compras', proveedores:'Proveedores', ordenes:'Órdenes de Trabajo', usuarios:'Usuarios', roles:'Roles y Permisos', cotizaciones:'Cotizaciones', movimientos:'Movimientos', catalogo:'Catálogo de Precios', facturacion:'Facturación', libro_ventas:'Libro de Ventas', vacaciones:'Vacaciones', gastos:'Gastos DMC / SAR Honduras' };
document.querySelectorAll('.nav-item[data-module]').forEach(el => {
  el.addEventListener('click', function() {
    const mod = this.dataset.module;
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.module').forEach(m => m.classList.remove('active'));
    this.classList.add('active');
    document.getElementById('mod-' + mod).classList.add('active');
    document.getElementById('topbarTitle').textContent = modTitles[mod] || mod;
    document.getElementById('main')?.scrollTo(0, 0);
    window.scrollTo(0, 0);
    marcarGrupoActivo(mod);
    // En mobile colapsar al navegar
    if (isMobile()) document.body.classList.add('sb-mini');
    const loaders = {
      clientes: cargarClientes, vehiculos: cargarVehiculos, inventario: cargarInventario, compras: cargarCompras,
      proveedores: cargarProveedores, ordenes: cargarOrdenes, usuarios: cargarUsuarios,
      roles: cargarRoles, cotizaciones: cargarCotizaciones, facturacion: cargarFacturacion,
      catalogo: cargarCatalogo, requisiciones: cargarRequisiciones,
      movimientos: () => { if (typeof cargarMovimientos === 'function') cargarMovimientos(); },
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
    gastos:         () => renderTablaGastos(datosModulo[modulo]),
    movimientos:    () => renderTablaMovimientos(datosModulo[modulo]),
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

