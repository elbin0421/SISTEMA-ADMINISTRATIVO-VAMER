// ══════════════════════════════════════════════════════════
// compras.js — Órdenes de Compra
// Extraído de dashboard.js líneas 748-1017
// ══════════════════════════════════════════════════════════

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

