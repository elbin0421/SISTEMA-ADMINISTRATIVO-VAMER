// ══════════════════════════════════════════════════════════
// catalogo.js — Catálogo de Precios
// Extraído de dashboard.js líneas 5220-5493
// ══════════════════════════════════════════════════════════

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

