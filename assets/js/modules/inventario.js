// ══════════════════════════════════════════════════════════
// inventario.js — Inventario / Materiales
// Extraído de dashboard.js líneas 506-660
// ══════════════════════════════════════════════════════════

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

