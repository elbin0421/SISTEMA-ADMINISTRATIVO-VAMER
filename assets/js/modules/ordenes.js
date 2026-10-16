// ══════════════════════════════════════════════════════════
// ordenes.js — Órdenes de Trabajo
// Extraído de dashboard.js líneas 1018-1516
// ══════════════════════════════════════════════════════════

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
    const veh = [o.placa ? 'Unidad '+o.placa : '', o.modelo, o.marca ? '('+o.marca+')' : ''].filter(Boolean).join(' ') || '—';
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
  ['otPlaca','otMarca','otColor','otMotor','otChasis','otObs','otClienteBuscar'].forEach(id => document.getElementById(id).value='');
  ['otAnio','otKm'].forEach(id => document.getElementById(id).value='');
  document.getElementById('otClienteId').value='';
  document.getElementById('otFecha').value = new Date().toISOString().slice(0,10);
  document.getElementById('tituloOT').textContent='Nueva Orden de Trabajo';
  document.getElementById('errOT').style.display='none';
  document.getElementById('sugerenciasClienteOT').style.display='none';
  document.getElementById('otFotosInput').value='';
  fotosOTExistentes = [];
  fotosOTPendientes = [];
  renderFotosOT();
  const selVeh = document.getElementById('otVehiculoSelect');
  if (selVeh) selVeh.innerHTML = '<option value="">— Seleccionar vehículo del cliente —</option>';
  await cargarTiposVehiculoCache();
  llenarSelectTipoVehiculo(document.getElementById('otModelo'), '');
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
  await cargarTiposVehiculoCache();
  llenarSelectTipoVehiculo(document.getElementById('otModelo'), o.modelo||'');
  document.getElementById('otAnio').value=o.anio||'';
  document.getElementById('otColor').value=o.color||'';
  document.getElementById('otKm').value=o.kilometraje||'';
  document.getElementById('otMotor').value=o.numero_motor||'';
  document.getElementById('otChasis').value=o.numero_chasis||'';
  document.getElementById('otFotosInput').value='';
  fotosOTExistentes = o.fotos || [];
  fotosOTPendientes = [];
  renderFotosOT();
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
        const label = `Unidad ${v.placa}${v.marca ? ' — Placa ' + v.marca : ''}${v.modelo ? ' — ' + v.modelo : ''}${v.anio ? ' ' + v.anio : ''}`;
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
  llenarSelectTipoVehiculo(document.getElementById('otModelo'), opt.dataset.modelo || '');
  document.getElementById('otAnio').value    = opt.dataset.anio   || '';
  document.getElementById('otColor').value   = opt.dataset.color  || '';
  document.getElementById('otMotor').value   = opt.dataset.motor  || '';
  document.getElementById('otChasis').value  = opt.dataset.chasis || '';
}

async function abrirNuevoVehiculoDesdeOT() {
  const clienteId     = +document.getElementById('otClienteId').value;
  const clienteNombre = document.getElementById('otClienteBuscar').value.trim();
  if (!clienteId) { toast('Selecciona primero el cliente de la OT.', 'warn'); return; }
  vehiculoRapidoCallback  = true;
  vehiculoRapidoClienteId = clienteId;
  await abrirModalVehiculo();
  document.getElementById('vClienteId').value     = clienteId;
  document.getElementById('vClienteBuscar').value = clienteNombre;
  document.getElementById('modalVehiculo').classList.add('sobre-modal');
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
  if (r.ok) {
    const nuevoId = id || r.data.id;
    if (!id && fotosOTPendientes.length) {
      for (const f of fotosOTPendientes) { await subirFotoOT(nuevoId, f.dataUrl, f.nombre); }
      fotosOTPendientes = [];
    }
    cerrarModal('modalOT'); toast(id?'OT actualizada.':'OT creada correctamente.','success'); cargarOrdenes();
  }
  else { errEl.textContent=r.data?.error||'Error al guardar la OT.'; errEl.style.display='block'; }
}

// ── Fotos de recepción del equipo ───────────────────────────
let fotosOTExistentes = []; // {id_foto, ruta, nombre_original} — OT ya guardada
let fotosOTPendientes = []; // {dataUrl, nombre} — OT nueva, se suben al crear

function comprimirImagenOT(file, maxDim = 1600, calidad = 0.75) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        let { width, height } = img;
        if (width > maxDim || height > maxDim) {
          if (width > height) { height = Math.round(height * maxDim / width); width = maxDim; }
          else { width = Math.round(width * maxDim / height); height = maxDim; }
        }
        const canvas = document.createElement('canvas');
        canvas.width = width; canvas.height = height;
        canvas.getContext('2d').drawImage(img, 0, 0, width, height);
        resolve(canvas.toDataURL('image/jpeg', calidad));
      };
      img.onerror = reject;
      img.src = e.target.result;
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function leerArchivoComoDataURL(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload  = e => resolve(e.target.result);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function esArchivoPDF(archivo) {
  if (typeof archivo !== 'string') return false;
  return archivo.startsWith('data:application/pdf') || /\.pdf($|\?)/i.test(archivo);
}

async function onSeleccionarFotosOT(input) {
  const files = Array.from(input.files || []);
  if (!files.length) return;
  const idOT = document.getElementById('otId').value;

  for (const file of files) {
    const esImagen = file.type.startsWith('image/');
    const esPDF    = file.type === 'application/pdf';
    if (!esImagen && !esPDF) continue;
    try {
      const dataUrl = esImagen ? await comprimirImagenOT(file) : await leerArchivoComoDataURL(file);
      if (idOT) await subirFotoOT(idOT, dataUrl, file.name);
      else fotosOTPendientes.push({ dataUrl, nombre: file.name });
    } catch (e) { toast('No se pudo procesar uno de los archivos.', 'error'); }
  }
  input.value = '';
  renderFotosOT();
}

async function subirFotoOT(ordenId, dataUrl, nombre) {
  const r = await api('controllers/OrdenesController.php?action=subir_foto', {
    method: 'POST',
    body: JSON.stringify({ orden_id: ordenId, imagen_base64: dataUrl, nombre_original: nombre }),
  });
  if (r.ok) fotosOTExistentes.push(r.data.foto);
  else toast(r.data?.error || 'Error al subir archivo.', 'error');
}

function previewArchivoOT(src, nombre) {
  if (esArchivoPDF(src)) {
    return `<a href="${src}" target="_blank" style="display:flex;flex-direction:column;align-items:center;justify-content:center;width:100%;height:100%;border-radius:6px;border:1px solid var(--border);background:var(--bg);text-decoration:none;color:var(--text);font-size:9px;padding:4px;box-sizing:border-box;overflow:hidden;text-align:center">
      <span style="font-size:26px">📄</span>
      <span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;width:100%">${nombre || 'PDF'}</span>
    </a>`;
  }
  return `<img src="${src}" style="width:100%;height:100%;object-fit:cover;border-radius:6px;border:1px solid var(--border);cursor:pointer" onclick="window.open('${src}','_blank')">`;
}

function renderFotosOT() {
  const grid = document.getElementById('otFotosGrid');
  if (!grid) return;
  const existentesHtml = fotosOTExistentes.map(f => `
    <div style="position:relative;width:90px;height:90px">
      ${previewArchivoOT(f.ruta, f.nombre_original)}
      <button type="button" onclick="eliminarFotoOT(${f.id_foto})" title="Eliminar"
        style="position:absolute;top:-6px;right:-6px;width:20px;height:20px;border-radius:50%;background:var(--danger);color:#fff;border:none;cursor:pointer;font-size:11px;line-height:1">✕</button>
    </div>`).join('');
  const pendientesHtml = fotosOTPendientes.map((f, i) => `
    <div style="position:relative;width:90px;height:90px">
      <div style="width:100%;height:100%;opacity:.85">${previewArchivoOT(f.dataUrl, f.nombre)}</div>
      <span style="position:absolute;bottom:2px;left:2px;background:rgba(0,0,0,.6);color:#fff;font-size:9px;padding:1px 4px;border-radius:3px">Pendiente</span>
      <button type="button" onclick="quitarFotoPendienteOT(${i})" title="Quitar"
        style="position:absolute;top:-6px;right:-6px;width:20px;height:20px;border-radius:50%;background:var(--danger);color:#fff;border:none;cursor:pointer;font-size:11px;line-height:1">✕</button>
    </div>`).join('');
  grid.innerHTML = (existentesHtml + pendientesHtml) || '<p style="color:var(--muted);font-size:12px;margin:0">Sin archivos aún.</p>';
}

function quitarFotoPendienteOT(i) {
  fotosOTPendientes.splice(i, 1);
  renderFotosOT();
}

async function eliminarFotoOT(idFoto) {
  if (!await confirmDialog('¿Eliminar esta foto?')) return;
  const r = await api('controllers/OrdenesController.php?action=eliminar_foto', {
    method: 'POST', body: JSON.stringify({ id: idFoto }),
  });
  if (r.ok) {
    fotosOTExistentes = fotosOTExistentes.filter(f => f.id_foto !== idFoto);
    renderFotosOT();
    toast('Foto eliminada.', 'success');
  } else toast(r.data?.error || 'Error.', 'error');
}

let otDetalleActual = null;

async function verDetalleOT(id) {
  document.getElementById('contenidoDetalleOT').innerHTML='<p class="loading">Cargando...</p>';
  abrirModal('modalDetalleOT');
  const r = await api('controllers/OrdenesController.php?action=obtener&id='+id);
  if (!r.ok) { document.getElementById('contenidoDetalleOT').innerHTML='<p style="color:var(--danger)">Error.</p>'; return; }
  const o = r.data.data;

  let h = `<h4>🔧 ${o.numero_orden} ${badgeEstado(o.estado)}</h4>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:14px;font-size:13px">
    <div><span style="color:var(--muted)">Cliente:</span> <strong>${o.cliente}</strong>${o.cliente_tel ? ' — '+o.cliente_tel : ''}</div>
    <div><span style="color:var(--muted)">Técnicos:</span> ${o.tecnicos&&o.tecnicos.length ? o.tecnicos.map(t=>t.nombre+(t.puesto?` <small style="color:var(--muted)">(${t.puesto})</small>`:'')).join(', ') : 'Sin asignar'}</div>
    <div><span style="color:var(--muted)">Apertura:</span> ${o.fecha_apertura}</div>
    <div><span style="color:var(--muted)">Cierre:</span> ${o.fecha_cierre||'—'}</div>
  </div>`;

  if (o.placa || o.marca || o.modelo || o.color) {
    h += `<div class="section-title">🚗 Vehículo</div>
    <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;margin-bottom:14px;font-size:13px">
      ${o.placa ? `<div><span style="color:var(--muted)">Unidad:</span> <strong>${o.placa}</strong></div>` : ''}
      ${o.marca ? `<div><span style="color:var(--muted)">Placa:</span> <strong>${o.marca}</strong></div>` : ''}
      ${o.modelo ? `<div><span style="color:var(--muted)">Tipo:</span> ${o.modelo}</div>` : ''}
      ${o.color ? `<div><span style="color:var(--muted)">Color:</span> ${o.color}</div>` : ''}
      ${o.kilometraje ? `<div><span style="color:var(--muted)">Km:</span> ${o.kilometraje.toLocaleString()}</div>` : ''}
      ${o.numero_motor ? `<div><span style="color:var(--muted)">Motor:</span> ${o.numero_motor}</div>` : ''}
      ${o.numero_chasis ? `<div><span style="color:var(--muted)">Chasis:</span> ${o.numero_chasis}</div>` : ''}
    </div>`;
  }

  if (o.fotos && o.fotos.length) {
    h += `<div class="section-title">📸 Fotos de recepción</div>
    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px">
      ${o.fotos.map(f => `<div style="width:90px;height:90px">${previewArchivoOT(f.ruta, f.nombre_original)}</div>`).join('')}
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
    h += `<p style="font-size:11px;color:var(--muted);margin-bottom:6px">Elige un material del inventario o escribe uno nuevo — no se descuenta del stock, es solo una lista de referencia.</p>
    <div style="display:grid;grid-template-columns:1fr 80px 90px auto;gap:6px;align-items:end;margin-bottom:8px">
      <input type="text" id="otDetMatBuscar" placeholder="Material (busca o escribe uno nuevo)..." oninput="buscarMatOT()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
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
  otDetalleActual = o;

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
  const idHid = document.getElementById('otDetMatId'); if (idHid) idHid.value = '';
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
  const matId  = +document.getElementById('otDetMatId').value || 0;
  const desc   = document.getElementById('otDetMatBuscar').value.trim();
  const cant   = parseFloat(document.getElementById('otDetCant').value);
  const precio = parseFloat(document.getElementById('otDetPrecio').value) || 0;
  if (!desc || isNaN(cant) || cant <= 0) { toast('Escribe el material y la cantidad.', 'warn'); return; }
  const r = await api('controllers/OrdenesController.php?action=agregar_material', {
    method: 'POST',
    body: JSON.stringify({ orden_id: ordenId, material_id: matId || null, descripcion: desc, cantidad: cant, precio_unitario: precio })
  });
  if (r.ok) { toast('Material agregado.','success'); verDetalleOT(ordenId); }
  else toast(r.data.error||'Error.','error');
}

async function quitarMatOT(detalleId, ordenId) {
  if (!await confirmDialog('¿Quitar este material de la lista de la OT?')) return;
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



// ── PDFs de la OT (Trabajo / Materiales) ─────────────────────
function escOT(t) {
  return String(t ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function abrirPDFOT(o, tituloSeccion, cuerpoHtml) {
  const tecnicos = (o.tecnicos && o.tecnicos.length)
    ? o.tecnicos.map(t => escOT(t.nombre) + (t.puesto ? ` (${escOT(t.puesto)})` : '')).join(', ')
    : 'Sin asignar';
  const vehiculo = (o.placa || o.marca || o.modelo)
    ? `<h3>🚗 Vehículo</h3>
       <table class="info">
         ${o.placa  ? `<tr><td class="k">Unidad:</td><td>${escOT(o.placa)}</td></tr>`  : ''}
         ${o.marca  ? `<tr><td class="k">Placa:</td><td>${escOT(o.marca)}</td></tr>`   : ''}
         ${o.modelo ? `<tr><td class="k">Tipo:</td><td>${escOT(o.modelo)}</td></tr>`   : ''}
       </table>` : '';

  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8">
  <title>${escOT(o.numero_orden)} — ${tituloSeccion}</title>
  <style>
    body{font-family:Arial,sans-serif;font-size:13px;color:#111;padding:28px 34px}
    h2{margin:0 0 14px;font-size:20px}
    h3{margin:18px 0 6px;font-size:14px;border-bottom:1px solid #ccc;padding-bottom:4px}
    .estado{font-size:12px;font-weight:400;color:#555;margin-left:6px}
    table.info td{padding:2px 8px 2px 0;vertical-align:top}
    table.info td.k{color:#555;white-space:nowrap}
    table.lista{width:100%;border-collapse:collapse;margin-top:6px}
    table.lista th,table.lista td{border:1px solid #bbb;padding:6px 8px;text-align:left}
    table.lista th{background:#f0f0f0}
    table.lista td.num,table.lista th.num{text-align:right;width:90px}
    ul{margin:6px 0 0;padding-left:20px} li{line-height:1.8}
    .vacio{color:#777;font-style:italic}
    @media print{@page{margin:14mm}}
  </style></head><body>
  <h2>🔧 ${escOT(o.numero_orden)} <span class="estado">${escOT(String(o.estado||'').replace('_',' '))}</span></h2>
  <table class="info">
    <tr><td class="k">Cliente:</td><td><strong>${escOT(o.cliente)}</strong>${o.cliente_tel ? ' — ' + escOT(o.cliente_tel) : ''}</td></tr>
    <tr><td class="k">Técnicos:</td><td>${tecnicos}</td></tr>
    <tr><td class="k">Apertura:</td><td>${escOT(o.fecha_apertura)}</td></tr>
    <tr><td class="k">Cierre:</td><td>${escOT(o.fecha_cierre || '—')}</td></tr>
  </table>
  ${vehiculo}
  ${cuerpoHtml}
  <script>window.onload=()=>window.print()<\/script>
  </body></html>`;
  const w = window.open('', '_blank');
  if (!w) { toast('El navegador bloqueó la ventana. Permite pop-ups para este sitio.', 'warn'); return; }
  w.document.write(html);
  w.document.close();
}

function pdfOTTrabajo() {
  const o = otDetalleActual;
  if (!o) { toast('Abre primero el detalle de una OT.', 'warn'); return; }
  const lineas = (o.descripcion_trabajo || '').split('\n').filter(l => l.trim());
  const cuerpo = `<h3>📋 Trabajo</h3>` + (lineas.length
    ? `<ul>${lineas.map(l => `<li>${escOT(l)}</li>`).join('')}</ul>`
    : `<p class="vacio">Sin trabajos registrados.</p>`);
  abrirPDFOT(o, 'Trabajo', cuerpo);
}

function pdfOTMateriales() {
  const o = otDetalleActual;
  if (!o) { toast('Abre primero el detalle de una OT.', 'warn'); return; }
  const mats = o.materiales || [];
  const cuerpo = `<h3>📦 Materiales utilizados</h3>` + (mats.length
    ? `<table class="lista"><thead><tr><th>Material</th><th class="num">Cantidad</th></tr></thead><tbody>
        ${mats.map(m => `<tr><td>${escOT(m.material)} <small style="color:#666">${escOT(m.unidad_medida || '')}</small></td><td class="num">${escOT(m.cantidad)}</td></tr>`).join('')}
       </tbody></table>`
    : `<p class="vacio">Sin materiales registrados.</p>`);
  abrirPDFOT(o, 'Materiales', cuerpo);
}
