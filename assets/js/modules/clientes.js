// ══════════════════════════════════════════════════════════
// clientes.js — Clientes
// Extraído de dashboard.js líneas 400-505
// ══════════════════════════════════════════════════════════

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

