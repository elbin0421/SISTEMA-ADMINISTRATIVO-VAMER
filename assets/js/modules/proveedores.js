// ══════════════════════════════════════════════════════════
// proveedores.js — Proveedores
// Extraído de dashboard.js líneas 661-747
// ══════════════════════════════════════════════════════════

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

