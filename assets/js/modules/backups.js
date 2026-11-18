// ══════════════════════════════════════════════════════════
// backups.js — Respaldos de la base de datos + Google Drive
// ══════════════════════════════════════════════════════════
let bkData = null;
const BK_URL = 'controllers/BackupController.php';
const bkEsc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const bkTam = b => b >= 1048576 ? (b / 1048576).toFixed(1) + ' MB' : Math.max(1, Math.round(b / 1024)) + ' KB';

async function cargarBackups() {
  const r = await api(`${BK_URL}?action=listar`);
  if (!r.ok) { document.getElementById('bkTabla').innerHTML = `<p style="color:var(--danger)">${bkEsc(r.data?.error || 'Error al cargar.')}</p>`; return; }
  bkData = r.data;
  const c = r.data.config;

  // Avisos del servidor
  const av = [];
  if (!r.data.carpeta_ok) av.push('La carpeta <b>backups/</b> no existe o no tiene permisos de escritura.');
  if (!r.data.curl_ok) av.push('PHP no tiene habilitada la extensión <b>cURL</b>; no se podrá subir a Google Drive.');
  document.getElementById('bkAvisos').innerHTML = av.map(m => `<div class="bk-aviso" style="display:block">⚠️ ${m}</div>`).join('');

  // Configuración
  document.getElementById('bkClientId').value = c.google_client_id || '';
  document.getElementById('bkClientSecret').value = '';
  document.getElementById('bkClientSecret').placeholder = c.tiene_secret ? '•••••••• (guardado; deja vacío para conservarlo)' : '';
  document.getElementById('bkCarpeta').value = c.drive_folder_nombre || 'Respaldos VAMER';
  document.getElementById('bkRetencion').value = c.retencion_local;
  document.getElementById('bkSubirAuto').checked = !!c.subir_auto;
  document.getElementById('bkSubirDrive').checked = !!c.subir_auto && c.drive_conectado;
  document.getElementById('bkRedirect').textContent = r.data.redirect_uri;
  document.getElementById('bkCron').textContent = '0 2 * * *  ' + r.data.cron;

  const est = document.getElementById('bkDriveEstado');
  est.textContent = c.drive_conectado ? 'Conectado' : 'No conectado';
  est.className = 'bk-estado ' + (c.drive_conectado ? 'bk-on' : 'bk-off');
  document.getElementById('bkDriveInfo').textContent = c.drive_conectado
    ? `Cuenta: ${c.google_email || '(conectada)'} · Carpeta: ${c.drive_folder_nombre}`
    : 'Conecta una cuenta de Google para guardar los respaldos en Drive.';
  document.getElementById('bkBtnConectar').textContent = c.drive_conectado ? '🔄 Reconectar' : '🔗 Conectar con Google';
  document.getElementById('bkBtnDesconectar').style.display = c.drive_conectado ? '' : 'none';

  const ult = r.data.data.find(b => b.estado === 'ok');
  document.getElementById('bkUltimo').textContent = ult ? `Último respaldo: ${ult.fecha} (${bkTam(ult.tamano)})` : 'Aún no hay respaldos.';
  bkRenderTabla();
}

function bkRenderTabla() {
  const rows = bkData.data, drive = bkData.config.drive_conectado;
  if (!rows.length) { document.getElementById('bkTabla').innerHTML = '<p class="empty-state">Sin respaldos todavía.</p>'; return; }
  let h = '<table><thead><tr><th>Fecha</th><th>Archivo</th><th>Tamaño</th><th>Contenido</th><th>Tipo</th><th>Google Drive</th><th>Estado</th><th></th></tr></thead><tbody>';
  rows.forEach(b => {
    const dr = b.drive_subido == 1 ? '<span class="bk-estado bk-on">✓ En Drive</span>'
      : (drive && b.local_existe == 1 && b.estado === 'ok' ? `<button class="btn btn-sm btn-secondary" onclick="bkSubir(${b.id_backup}, this)">☁️ Subir</button>` : '<span style="color:var(--muted)">—</span>');
    const acc = [];
    if (b.local_existe == 1 && b.estado === 'ok') acc.push(`<button class="btn btn-sm btn-secondary" onclick="bkDescargar(${b.id_backup})">⬇️ Descargar</button>`);
    acc.push(`<button class="btn btn-sm btn-danger" onclick="bkEliminar(${b.id_backup})">🗑️</button>`);
    h += `<tr>
      <td>${bkEsc(b.fecha)}${b.usuario_nombre ? `<div class="td-sub">${bkEsc(b.usuario_nombre)}</div>` : ''}</td>
      <td style="font-size:12px">${bkEsc(b.archivo)}${b.local_existe == 0 && b.estado === 'ok' ? '<div class="td-sub">Ya no está en el servidor</div>' : ''}</td>
      <td>${b.estado === 'ok' ? bkTam(b.tamano) : '—'}</td>
      <td style="font-size:12px">${b.estado === 'ok' ? `${b.tablas} tablas · ${Number(b.filas).toLocaleString()} filas` : ''}</td>
      <td>${b.tipo === 'automatico' ? '🤖 Automático' : '👤 Manual'}</td>
      <td>${dr}</td>
      <td>${b.estado === 'ok' ? '<span class="bk-estado bk-on">OK</span>' : `<span class="bk-estado bk-off" title="${bkEsc(b.mensaje)}">Error</span>`}</td>
      <td style="white-space:nowrap">${acc.join(' ')}</td></tr>`;
  });
  document.getElementById('bkTabla').innerHTML = h + '</tbody></table>';
}

async function bkCrear() {
  const btn = document.getElementById('bkBtnCrear'), subir = document.getElementById('bkSubirDrive').checked;
  if (subir && !bkData?.config.drive_conectado) { toast('Conecta primero Google Drive o desmarca la opción de subir.', 'warn'); return; }
  btn.disabled = true; const txt = btn.textContent; btn.textContent = '⏳ Generando respaldo...';
  try {
    const r = await api(`${BK_URL}?action=crear`, { method: 'POST', body: JSON.stringify({ subir_drive: subir }) });
    if (!r.ok) { toast(r.data?.error || 'Error al crear el respaldo.', 'error'); return; }
    let m = `Respaldo creado: ${r.data.tablas} tablas, ${Number(r.data.filas).toLocaleString()} filas (${bkTam(r.data.tamano)}).`;
    if (subir) m += r.data.drive ? ' Subido a Google Drive.' : ` No se pudo subir a Drive: ${r.data.drive_error || ''}`;
    toast(m, subir && !r.data.drive ? 'warn' : 'success');
    cargarBackups();
  } finally { btn.disabled = false; btn.textContent = txt; }
}

function bkDescargar(id) { window.location.href = `${BK_URL}?action=descargar&id=${id}`; }

async function bkSubir(id, btn) {
  btn.disabled = true; btn.textContent = '⏳...';
  const r = await api(`${BK_URL}?action=subir_drive`, { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo subir a Drive.', 'error'); btn.disabled = false; btn.textContent = '☁️ Subir'; return; }
  toast('Respaldo subido a Google Drive.', 'success'); cargarBackups();
}

async function bkEliminar(id) {
  if (!await confirmDialog('¿Eliminar este respaldo del servidor y del historial? (La copia en Google Drive no se borra.)')) return;
  const r = await api(`${BK_URL}?action=eliminar`, { method: 'POST', body: JSON.stringify({ id }) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo eliminar.', 'error'); return; }
  toast('Respaldo eliminado.', 'success'); cargarBackups();
}

async function bkGuardarConfig(silencioso) {
  const body = {
    google_client_id: document.getElementById('bkClientId').value.trim(),
    google_client_secret: document.getElementById('bkClientSecret').value.trim(),
    drive_folder_nombre: document.getElementById('bkCarpeta').value.trim(),
    retencion_local: +document.getElementById('bkRetencion').value || 10,
    subir_auto: document.getElementById('bkSubirAuto').checked,
  };
  const r = await api(`${BK_URL}?action=config_guardar`, { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo guardar.', 'error'); return false; }
  if (!silencioso) { toast('Configuración guardada.', 'success'); cargarBackups(); }
  return true;
}

async function bkConectar() {
  if (!(await bkGuardarConfig(true))) return;
  if (!document.getElementById('bkClientId').value.trim() || (!document.getElementById('bkClientSecret').value.trim() && !bkData?.config.tiene_secret)) {
    toast('Escribe el Client ID y el Client Secret de Google.', 'warn'); return;
  }
  window.location.href = `${BK_URL}?action=drive_conectar`;
}

async function bkDesconectar() {
  if (!await confirmDialog('¿Desconectar Google Drive? Los respaldos ya subidos se quedan en Drive.')) return;
  const r = await api(`${BK_URL}?action=drive_desconectar`, { method: 'POST', body: '{}' });
  if (!r.ok) { toast(r.data?.error || 'Error.', 'error'); return; }
  toast('Google Drive desconectado.', 'success'); cargarBackups();
}

function bkCopiarUri() {
  const t = document.getElementById('bkRedirect').textContent;
  (navigator.clipboard ? navigator.clipboard.writeText(t) : Promise.reject()).then(() => toast('URI copiada.', 'success'), () => toast('Cópiala manualmente.', 'warn'));
}

// Resultado de la autorización de Google (el controlador redirige a dashboard.php?bk=ok:... / error:...)
(function () {
  const p = new URLSearchParams(location.search).get('bk');
  if (!p) return;
  history.replaceState(null, '', location.pathname);
  window.addEventListener('load', () => setTimeout(() => {
    const i = p.indexOf(':'), tipo = p.slice(0, i), msg = p.slice(i + 1);
    if (typeof navegarModulo === 'function') navegarModulo('backups');
    toast(msg, tipo === 'ok' ? 'success' : 'error');
  }, 400));
})();
