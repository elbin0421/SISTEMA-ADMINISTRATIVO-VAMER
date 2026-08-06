// ══════════════════════════════════════════════════════════
// usuarios.js — Usuarios y Roles
// Extraído de dashboard.js líneas 1517-1624
// ══════════════════════════════════════════════════════════

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

