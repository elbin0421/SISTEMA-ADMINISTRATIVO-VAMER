// ══════════════════════════════════════════════════════════
// requisiciones.js — Requisiciones de Materiales
// Extraído de dashboard.js líneas 5494-5961
// ══════════════════════════════════════════════════════════

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
