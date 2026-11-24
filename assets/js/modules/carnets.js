// ══════════════════════════════════════════════════════════
// carnets.js — Carnets de empleados (RRHH)
// El carnet se dibuja en un <canvas> (mismo dibujo para vista previa, PDF y PNG).
// ══════════════════════════════════════════════════════════
const CR_URL = 'controllers/CarnetsController.php';
const CR_PLANT = {
  verde:   { nombre: 'Verde VAMER',      p: '#0a6b36', s: '#2fb36f', t: '#0a6b36' },
  azul:    { nombre: 'Azul SOLDYMEG', p: '#0d3b8c', s: '#2f7de1', t: '#0d3b8c' },
};
const CR_FUENTES = {
  arial_bold:     { n: 'Arial Bold',     w: 'bold',   f: 'Arial, Helvetica, sans-serif' },
  arial:          { n: 'Arial',          w: 'normal', f: 'Arial, Helvetica, sans-serif' },
  georgia_bold:   { n: 'Georgia Bold',   w: 'bold',   f: 'Georgia, serif' },
  verdana_bold:   { n: 'Verdana Bold',   w: 'bold',   f: 'Verdana, Geneva, sans-serif' },
  trebuchet_bold: { n: 'Trebuchet Bold', w: 'bold',   f: "'Trebuchet MS', Helvetica, sans-serif" },
};
const CR_TAM = { std: { w: 54, h: 85.6, n: '54 × 85.6 mm vertical (CR80)' }, grande: { w: 81, h: 128.4, n: '81 × 128.4 mm vertical (grande)' } };
const CR_COLORES = ['#0a6b36', '#111111', '#1d4ed8', '#7c3aed', '#be185d'];
const CR_TEL_RRHH = '9596-9903';
const CR_MESES = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];

let crEmps = [], crEmp = null, crC = null, crEmpresa = null, crUrlFicha = '', crLadoAct = 'frente', crTipoImg = '', crIniciado = false, crSeq = 0;
const crImgCache = {};
const crEsc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

// ── Librerías (QR y PDF) ─────────────────────────────────
let crLibsP = null;
function crCargarLibs() {
  if (crLibsP) return crLibsP;
  const cargar = src => new Promise(res => { const s = document.createElement('script'); s.src = src; s.onload = () => res(true); s.onerror = () => res(false); document.head.appendChild(s); });
  crLibsP = Promise.all([
    typeof qrcode === 'function' ? true : cargar('https://cdnjs.cloudflare.com/ajax/libs/qrcode-generator/1.4.4/qrcode.min.js'),
    window.jspdf ? true : cargar('https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'),
  ]).then(r => { if (!r[0] || !r[1]) crLibsP = null; return r; });
  return crLibsP;
}

function crRecortar(im) {   // quita márgenes vacíos (transparentes/blancos) para que el logo quede centrado
  try {
    const c = document.createElement('canvas'), w = c.width = im.width, h = c.height = im.height, x = c.getContext('2d'); x.drawImage(im, 0, 0);
    const d = x.getImageData(0, 0, w, h).data; let x0 = w, y0 = h, x1 = -1, y1 = -1;
    for (let j = 0; j < h; j++) for (let i = 0; i < w; i++) { const o = (j * w + i) * 4; if (d[o + 3] > 20 && !(d[o] > 245 && d[o + 1] > 245 && d[o + 2] > 245)) { if (i < x0) x0 = i; if (i > x1) x1 = i; if (j < y0) y0 = j; if (j > y1) y1 = j; } }
    if (x1 < 0) return im;
    const o = document.createElement('canvas'); o.width = x1 - x0 + 1; o.height = y1 - y0 + 1; o.getContext('2d').drawImage(c, x0, y0, o.width, o.height, 0, 0, o.width, o.height); return o;
  } catch (e) { return im; }
}
function crImg(src) {
  if (!src) return Promise.resolve(null);
  if (crImgCache[src] !== undefined) return Promise.resolve(crImgCache[src]);
  return new Promise(res => {
    const im = new Image();
    im.onload = () => { crImgCache[src] = im; im.recorte = /\/logo_/.test(src) ? crRecortar(im) : null; res(im); };
    im.onerror = () => { crImgCache[src] = null; res(null); };
    im.src = src;
  });
}

// ── Inicio ───────────────────────────────────────────────
async function cargarCarnets() {
  if (!crIniciado) {
    const sel = document.getElementById('crTamano');
    sel.innerHTML = Object.entries(CR_TAM).map(([k, v]) => `<option value="${k}">${v.n}</option>`).join('');
    document.getElementById('crEstilo').innerHTML = Object.entries(CR_FUENTES).map(([k, v]) => `<option value="${k}">${v.n}</option>`).join('');
    crIniciado = true;
    crCargarLibs();
  }
  const r = await api(`${CR_URL}?action=empleados`);
  if (r.ok) crEmps = r.data.data;
  crPintarControles();
  if (crEmp) crRender();
}

function crBuscarEmp() {
  const box = document.getElementById('crSug'), norm = s => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
  const q = norm(document.getElementById('crBuscar').value.trim());
  const res = crEmps.filter(e => !q || norm(e.nombre).includes(q) || norm(e.puesto).includes(q)).slice(0, 12);
  box.innerHTML = res.length ? res.map(e => `<div onmousedown="crElegirEmp(${e.id_empleado})" style="padding:8px 12px;cursor:pointer;font-size:13px;border-bottom:1px solid var(--border)">
      <strong>${crEsc(e.nombre)}</strong>${e.tiene_carnet == 1 ? ' <span title="Ya tiene carnet guardado">🪪</span>' : ''}<div style="font-size:11px;color:var(--muted)">${crEsc(e.puesto || '')}${e.empresa ? ' · ' + crEsc(e.empresa) : ''}</div></div>`).join('')
    : '<div style="padding:8px 12px;font-size:12px;color:var(--muted)">Sin resultados</div>';
  box.style.display = '';
}

async function crElegirEmp(id) {
  document.getElementById('crSug').style.display = 'none';
  const r = await api(`${CR_URL}?action=obtener&empleado_id=${id}`);
  if (!r.ok) { toast(r.data?.error || 'No se pudo cargar el empleado.', 'error'); return; }
  crEmp = r.data.empleado; crEmpresa = r.data.empresa; crUrlFicha = r.data.ficha_url;
  const c = r.data.carnet;
  crC = {
    plantilla: CR_PLANT[c.plantilla] ? c.plantilla : 'verde', tamano: c.tamano, estilo_texto: c.estilo_texto, color_texto: c.color_texto, fondo_color: c.fondo_color || '#ffffff',
    fondo_imagen: c.fondo_imagen, nombre_carnet: c.nombre_carnet || '', telefono_carnet: c.telefono_carnet || '',
    mostrar_identidad: c.mostrar_identidad == 1, mostrar_telefono: c.mostrar_telefono == 1, mostrar_ingreso: c.mostrar_ingreso == 1, vigencia: c.vigencia || '',
  };
  document.getElementById('crBuscar').value = `${crEmp.nombres} ${crEmp.apellidos}`.trim();
  crPintarControles();
  crRender();
}

function crPintarControles() {
  if (crC) {
    document.getElementById('crTamano').value = crC.tamano;
    document.getElementById('crEstilo').value = crC.estilo_texto;
  }
  const actual = crC ? (crC.color_texto || CR_PLANT[crC.plantilla].t) : null;
  document.getElementById('crColores').innerHTML = CR_COLORES.map(c => `<i style="background:${c}" class="${actual && actual.toLowerCase() === c ? 'on' : ''}" onclick="crCambio('color_texto','${c}')"></i>`).join('');
}

function crCambio(campo, valor) {
  if (!crC) { toast('Elige primero un empleado.', 'warn'); return; }
  crC[campo] = valor;
  crPintarControles(); crRender();
}
function crLado(l) {
  crLadoAct = l;
  document.getElementById('crTabFrente').classList.toggle('on', l === 'frente');
  document.getElementById('crTabReverso').classList.toggle('on', l === 'reverso');
  if (crEmp) crRender();
}

// ── Datos que se dibujan ─────────────────────────────────
function crFmtIngreso(f) { if (!f) return ''; const [y, m, d] = f.split('-'); return `${+d} ${CR_MESES[+m - 1]} ${y}`; }
function crFmtFecha(f) { const [y, m, d] = f.split('-'); return `${d}/${m}/${y}`; }
function crDatos() {
  const e = crEmp, c = crC, em = crEmpresa || {};
  /*const pn = (e.nombres || '').trim().split(/\s+/)[0] || '', pa = (e.apellidos || '').trim().split(/\s+/)[0] || '';*/
  const pn = (e.nombres || '').trim()|| '', pa = (e.apellidos || '')|| '';
  const empresa = em.nombre_mostrado || e.empresa || '';
  return {
    nombre: c.nombre_carnet || `${pn} ${pa}`.trim(), identidad: c.mostrar_identidad ? (e.identidad || '') : '',
    telefono: c.mostrar_telefono ? (c.telefono_carnet || e.telefono || '') : '', puesto: e.puesto || '',
    ingreso: c.mostrar_ingreso ? crFmtIngreso(e.fecha_ingreso) : '', empresa,
    direccion: e.empresa_direccion || '', empTel: CR_TEL_RRHH,
    reverso: em.texto_reverso || `Propiedad de ${empresa}\nEste documento es propiedad de ${e.empresa_id == 2 ? 'VAMER' : empresa}.\nSu uso es estrictamente personal e intransferible. En caso de extravío, se solicita a quien lo encuentre el favor de reportarlo o devolverlo llamando al número ${CR_TEL_RRHH}.`,
    vigencia: crFmtFecha(c.vigencia || (new Date().getFullYear() + '-12-31')),
    firmaNombre: em.firma_nombre || '', firmaCargo: em.firma_cargo || '',
  };
}

// ── Dibujo ───────────────────────────────────────────────
function crPath(ctx, k, pts) { ctx.beginPath(); pts.forEach(p => { if (p[0] === 'M') ctx.moveTo(p[1] * k, p[2] * k); else if (p[0] === 'L') ctx.lineTo(p[1] * k, p[2] * k); else if (p[0] === 'C') ctx.bezierCurveTo(p[1] * k, p[2] * k, p[3] * k, p[4] * k, p[5] * k, p[6] * k); }); ctx.closePath(); }
function crRR(ctx, k, x, y, w, h, r) { crPath(ctx, k, [['M', x + r, y], ['L', x + w - r, y], ['C', x + w, y, x + w, y, x + w, y + r], ['L', x + w, y + h - r], ['C', x + w, y + h, x + w, y + h, x + w - r, y + h], ['L', x + r, y + h], ['C', x, y + h, x, y + h, x, y + h - r], ['L', x, y + r], ['C', x, y, x, y, x + r, y]]); }
function crFont(k, size, weight, family) { return `${weight} ${size * k}px ${family}`; }

function crTxt(ctx, k, txt, x, y, size, o = {}) {
  const w = o.weight || 'normal', fam = o.family || 'Arial, Helvetica, sans-serif';
  let s = size; ctx.font = crFont(k, s, w, fam);
  if (o.maxW) {
    while (ctx.measureText(txt).width > o.maxW * k && s > 2.1) { s -= 0.1; ctx.font = crFont(k, s, w, fam); }
    while (ctx.measureText(txt).width > o.maxW * k && txt.length > 2) txt = txt.slice(0, -2) + '…';
  }
  ctx.fillStyle = o.color || '#222'; ctx.textAlign = o.align || 'left'; ctx.textBaseline = 'middle';
  ctx.fillText(txt, x * k, y * k);
}
function crWrap(ctx, text, maxPx) {
  const out = []; let cur = '';
  String(text).split(/\s+/).forEach(w => { const t = cur ? cur + ' ' + w : w; if (ctx.measureText(t).width > maxPx && cur) { out.push(cur); cur = w; } else cur = t; });
  if (cur) out.push(cur); return out;
}
function crCover(ctx, k, im, x, y, w, h, fy = 0.5) {
  const r = Math.max(w / im.width, h / im.height), dw = im.width * r, dh = im.height * r;
  ctx.drawImage(im, (x + (w - dw) / 2) * k, (y + (h - dh) * fy) * k, dw * k, dh * k);
}
function crContain(ctx, k, im, x, y, w, h) {
  const r = Math.min(w / im.width, h / im.height), dw = im.width * r, dh = im.height * r;
  ctx.drawImage(im, (x + (w - dw) / 2) * k, (y + (h - dh) / 2) * k, dw * k, dh * k);
}

function crCabecera(ctx, k, P) {
  // onda clara (abajo), luego verde oscuro y una línea blanca entre ambas
  crPath(ctx, k, [['M', 0, 0], ['L', 54, 0], ['L', 54, 27], ['C', 46, 27.5, 38, 19.5, 28, 18.8], ['C', 16, 18, 7, 22, 0, 20.5]]); ctx.fillStyle = P.s; ctx.fill();
  const edge = [['M', 0, 0], ['L', 54, 0], ['L', 54, 15.2], ['C', 46, 20, 37, 13.2, 26, 14.6], ['C', 14, 16.2, 7, 20, 0, 17.4]];
  crPath(ctx, k, edge); ctx.fillStyle = P.p; ctx.fill();
  ctx.lineWidth = 1 * k; ctx.strokeStyle = '#fff'; ctx.beginPath();
  ctx.moveTo(54 * k, 15.2 * k); ctx.bezierCurveTo(46 * k, 20 * k, 37 * k, 13.2 * k, 26 * k, 14.6 * k); ctx.bezierCurveTo(14 * k, 16.2 * k, 7 * k, 20 * k, 0, 17.4 * k); ctx.stroke();
}
function crPie(ctx, k, P) {
  crPath(ctx, k, [['M', 0, 76.8], ['C', 14, 73.8, 34, 80.8, 54, 75.2], ['L', 54, 85.6], ['L', 0, 85.6]]); ctx.fillStyle = P.s; ctx.fill();
  crPath(ctx, k, [['M', 0, 80.6], ['C', 16, 78.2, 38, 84.6, 54, 79.6], ['L', 54, 85.6], ['L', 0, 85.6]]); ctx.fillStyle = P.p; ctx.fill();
}

function crQR(ctx, k, url, x, y, size) {
  ctx.fillStyle = '#fff'; ctx.fillRect((x - 1) * k, (y - 1) * k, (size + 2) * k, (size + 2) * k);
  if (typeof qrcode !== 'function') { ctx.fillStyle = '#ddd'; ctx.fillRect(x * k, y * k, size * k, size * k); crTxt(ctx, k, 'QR', x + size / 2, y + size / 2, 4, { align: 'center', color: '#777' }); return; }
  const qr = qrcode(0, 'M'); qr.addData(url); qr.make();
  const n = qr.getModuleCount(), cell = size / n;
  ctx.fillStyle = '#000';
  for (let r = 0; r < n; r++) for (let c = 0; c < n; c++) if (qr.isDark(r, c)) ctx.fillRect((x + c * cell) * k, (y + r * cell) * k, cell * k + 0.7, cell * k + 0.7);
}

function crLogoCirculo(ctx, k, cx, cy, r, P, d, im) {
  ctx.beginPath(); ctx.arc(cx * k, cy * k, r * k, 0, Math.PI * 2); ctx.fillStyle = '#fff'; ctx.fill();
  ctx.lineWidth = 0.5 * k; ctx.strokeStyle = P.s; ctx.stroke();
  if (im) { ctx.save(); ctx.beginPath(); ctx.arc(cx * k, cy * k, (r - 1) * k, 0, Math.PI * 2); ctx.clip(); crContain(ctx, k, im.recorte || im, cx - r + 1.5, cy - r + 1.5, (r - 1.5) * 2, (r - 1.5) * 2); ctx.restore(); }
  else crTxt(ctx, k, (d.empresa || '?').split(/\s+/).map(w => w[0]).join('').slice(0, 3).toUpperCase(), cx, cy, r * .8, { align: 'center', weight: 'bold', color: P.p });
}

function crJust(ctx, k, linea, x, y, w, size, color, justificar) {
  ctx.font = crFont(k, size, 'normal', 'Arial, Helvetica, sans-serif'); ctx.fillStyle = color; ctx.textAlign = 'left'; ctx.textBaseline = 'middle';
  const ps = linea.split(' ');
  if (!justificar || ps.length < 2) { ctx.fillText(linea, x * k, y * k); return; }
  const tot = ps.reduce((a, t) => a + ctx.measureText(t).width, 0), gap = (w * k - tot) / (ps.length - 1);
  let cx = x * k; ps.forEach(t => { ctx.fillText(t, cx, y * k); cx += ctx.measureText(t).width + gap; });
}

function crDibujar(canvas, lado, k, plantillaForzada) {
  const T = CR_TAM[crC.tamano] || CR_TAM.std, W = 54, H = 85.6, kk = k * (T.w / 54);   // el dibujo siempre es 54 × 85.6; "grande" solo escala
  canvas.width = Math.round(W * kk); canvas.height = Math.round(H * kk);
  const ctx = canvas.getContext('2d'), d = crDatos(), P = CR_PLANT[plantillaForzada || crC.plantilla];
  const col = crC.color_texto || P.t, F = CR_FUENTES[crC.estilo_texto] || CR_FUENTES.arial_bold;
  const fondo = crImgCache[crC.fondo_imagen] || null, logo = crImgCache[crEmpresa?.logo] || null, foto = crImgCache[crEmp.foto] || null, firma = crImgCache[crEmpresa?.firma] || null;
  const k2 = kk;

  // Marco blanco exterior con esquinas redondeadas
  ctx.save(); crRR(ctx, k2, 0, 0, W, H, 5.6); ctx.clip();
  ctx.fillStyle = '#fff'; ctx.fillRect(0, 0, canvas.width, canvas.height);
  // Contenido interior
  crRR(ctx, k2, 1.5, 1.5, W - 3, H - 3, 4.2); ctx.clip();
  ctx.fillStyle = lado === 'reverso' ? P.p : (crC.fondo_color || '#fff'); ctx.fillRect(0, 0, canvas.width, canvas.height);
  if (fondo) crCover(ctx, k2, fondo, 0, 0, W, H);

  if (lado === 'frente') {
    crCabecera(ctx, k2, P);
    crLogoCirculo(ctx, k2, 11.6, 10.2, 7.3, P, d, logo);
    ctx.font = crFont(k2, 2.3, 'bold', 'Arial, sans-serif');
    const lines = crWrap(ctx, d.empresa, 32.5 * k2).slice(0, 3), y0 = 11.2 - (lines.length - 1) * 1.7;
    lines.forEach((ln, i) => crTxt(ctx, k2, ln, 20, y0 + i * 3.4, 2.3, { weight: 'bold', color: '#fff', maxW: 32.5 }));

    // Foto
    ctx.save(); ctx.shadowColor = 'rgba(0,0,0,.3)'; ctx.shadowBlur = 1.4 * k2; ctx.shadowOffsetY = 0.4 * k2;
    crRR(ctx, k2, 17.1, 19.2, 19.8, 24.5, 3); ctx.fillStyle = '#fff'; ctx.fill(); ctx.restore();
    ctx.save(); crRR(ctx, k2, 17.7, 19.8, 18.6, 23.3, 2.5); ctx.clip();
    if (foto) crCover(ctx, k2, foto, 17.7, 19.8, 18.6, 23.3, 0.2);
    else {
      ctx.fillStyle = '#bcd0f5'; ctx.fillRect(17.7 * k2, 19.8 * k2, 18.6 * k2, 23.3 * k2);
      ctx.fillStyle = '#4b2a88'; ctx.beginPath(); ctx.arc(27 * k2, 30.2 * k2, 3.6 * k2, 0, Math.PI * 2); ctx.fill();
      ctx.beginPath(); ctx.ellipse(27 * k2, 41.8 * k2, 7 * k2, 6 * k2, 0, Math.PI, 0); ctx.fill();
    }
    ctx.restore();

    crTxt(ctx, k2, d.nombre, 27, 48.2, 3.9, { align: 'center', weight: F.w, family: F.f, color: '#111', maxW: 46 });
    if (d.identidad) crTxt(ctx, k2, d.identidad, 27, 52.9, 3, { align: 'center', weight: F.w, family: F.f, color: col, maxW: 46 });
    ctx.strokeStyle = P.p; ctx.lineWidth = 0.2 * k2; ctx.beginPath(); ctx.moveTo(5.5 * k2, 55.4 * k2); ctx.lineTo(48.5 * k2, 55.4 * k2); ctx.stroke();

    const filas = [];
    if (d.telefono) filas.push(['📞', d.telefono]);
    if (d.puesto) filas.push(['💼', d.puesto]);
    if (d.ingreso) filas.push(['📅', 'Ingreso: ' + d.ingreso]);
    filas.forEach((f, i) => {
      const y = 60.2 + i * 4.2;
      crTxt(ctx, k2, f[0], 5.3, y, 2.6, { family: 'Apple Color Emoji, Segoe UI Emoji, Noto Color Emoji, sans-serif' });
      crTxt(ctx, k2, f[1], 9, y, 2.5, { color: '#222', maxW: 23.5 });
    });
    crQR(ctx, k2, crUrlFicha || 'https://', 33.6, 56.8, 14.8);
    crPie(ctx, k2, P);
  } else {
    // Reverso: fondo de color sólido, texto blanco justificado
    const X = 5.7, Wt = 42.6, SZ = 2.25, LH = 3.5;
    ctx.font = crFont(k2, SZ, 'normal', 'Arial, Helvetica, sans-serif');
    let y = 8.7;
    String(d.reverso).split(/\n+/).forEach(par => {
      const ls = crWrap(ctx, par, Wt * k2);
      ls.forEach((ln, i) => { crJust(ctx, k2, ln, X, y, Wt, SZ, '#fff', i < ls.length - 1); y += LH; });
    });
    crTxt(ctx, k2, 'Fecha de vigencia hasta el ' + d.vigencia, 27, Math.max(y + 8, 44.3), 2.4, { align: 'center', color: '#fff', maxW: 46 });
    if (firma) crContain(ctx, k2, firma, 15, 60.5, 24, 10);
    ctx.strokeStyle = '#fff'; ctx.lineWidth = 0.25 * k2; ctx.beginPath(); ctx.moveTo(10.7 * k2, 71.6 * k2); ctx.lineTo(43.3 * k2, 71.6 * k2); ctx.stroke();
    if (d.firmaNombre) crTxt(ctx, k2, d.firmaNombre, 27, 73.8, 2.2, { align: 'center', weight: 'bold', color: '#fff', maxW: 40 });
    crTxt(ctx, k2, d.firmaCargo || 'Recursos Humanos', 27, d.firmaNombre ? 76.6 : 74.4, 2.3, { align: 'center', color: '#fff', maxW: 40 });
    crTxt(ctx, k2, d.empresa + (d.empTel ? ' Tel: ' + d.empTel : ''), 27, 80.2, 2.3, { align: 'center', color: '#fff', maxW: 47 });
  }
  ctx.restore();
}

async function crPrecargar() {
  await Promise.all([crImg(crEmp.foto), crImg(crEmpresa?.logo), crImg(crEmpresa?.firma), crImg(crC.fondo_imagen)]);
}

async function crRender() {
  if (!crEmp || !crC) return;
  const seq = ++crSeq;
  await Promise.all([crPrecargar(), crCargarLibs()]);
  if (seq !== crSeq) return;
  const cv = document.getElementById('crCanvas');
  crDibujar(cv, crLadoAct, 8);
  const T = CR_TAM[crC.tamano] || CR_TAM.std;
  cv.style.width = '270px'; cv.style.display = '';
  document.getElementById('crVacio').style.display = 'none';
  // Plantillas (mini-vistas con el empleado elegido)
  const box = document.getElementById('crPlantList');
  if (!box.dataset.listo) {
    box.innerHTML = Object.entries(CR_PLANT).map(([k, v]) => `<div class="cr-pl" id="crPl_${k}" onclick="crCambio('plantilla','${k}')"><canvas id="crPlc_${k}" style="width:112px"></canvas>${v.nombre}</div>`).join('');
    box.dataset.listo = '1';
  }
  Object.keys(CR_PLANT).forEach(k => {
    crDibujar(document.getElementById('crPlc_' + k), 'frente', 3, k);
    document.getElementById('crPlc_' + k).style.width = '112px';
    document.getElementById('crPl_' + k).classList.toggle('on', crC.plantilla === k);
  });
}

// ── Imágenes (foto / logo / firma / fondo) ───────────────
function crPedirImagen(tipo) {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  crTipoImg = tipo; document.getElementById('crFile').click();
}

function crReducir(file, max, png) {
  return new Promise((res, rej) => {
    const url = URL.createObjectURL(file), im = new Image();
    im.onload = () => {
      const k = Math.min(1, max / Math.max(im.width, im.height)), c = document.createElement('canvas');
      c.width = Math.round(im.width * k); c.height = Math.round(im.height * k);
      const x = c.getContext('2d'); if (!png) { x.fillStyle = '#fff'; x.fillRect(0, 0, c.width, c.height); }
      x.drawImage(im, 0, 0, c.width, c.height); URL.revokeObjectURL(url);
      res(png ? c.toDataURL('image/png') : c.toDataURL('image/jpeg', 0.86));
    };
    im.onerror = () => { URL.revokeObjectURL(url); rej(new Error('No se pudo leer la imagen.')); };
    im.src = url;
  });
}

async function crArchivoElegido(input) {
  const file = input.files && input.files[0]; input.value = '';
  if (!file || !crEmp) return;
  if (!/^image\//.test(file.type)) { toast('Selecciona una imagen.', 'warn'); return; }
  const tipo = crTipoImg;
  try {
    if (tipo === 'foto') {
      const img = await crReducir(file, 480, false);
      const r = await api('controllers/EmpleadoController.php?action=foto', { method: 'POST', body: JSON.stringify({ id: crEmp.id_empleado, imagen: img }) });
      if (!r.ok) { toast(r.data?.error || 'No se pudo guardar la foto.', 'error'); return; }
      crEmp.foto = r.data.foto; toast('Foto actualizada en el empleado.', 'success');
    } else {
      const img = await crReducir(file, tipo === 'fondo' ? 900 : 700, tipo !== 'fondo');
      const r = await api(`${CR_URL}?action=imagen`, { method: 'POST', body: JSON.stringify({ tipo, empleado_id: crEmp.id_empleado, imagen: img }) });
      if (!r.ok) { toast(r.data?.error || 'No se pudo guardar la imagen.', 'error'); return; }
      if (tipo === 'fondo') crC.fondo_imagen = r.data.ruta; else crEmpresa[tipo] = r.data.ruta;
      toast(tipo === 'fondo' ? 'Fondo actualizado.' : `${tipo === 'logo' ? 'Logo' : 'Firma'} guardado para todos los carnets de la empresa.`, 'success');
    }
    crRender();
  } catch (e) { toast(e.message || 'Error al procesar la imagen.', 'error'); }
}

// ── Modales ──────────────────────────────────────────────
function crAbrirDatos() {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  const e = crEmpresa || {};
  document.getElementById('crdNombre').value = crC.nombre_carnet; document.getElementById('crdNombre').placeholder = crDatos().nombre;
  document.getElementById('crdTelefono').value = crC.telefono_carnet; document.getElementById('crdTelefono').placeholder = crEmp.telefono || '';
  document.getElementById('crdMIdentidad').checked = crC.mostrar_identidad; document.getElementById('crdMTelefono').checked = crC.mostrar_telefono; document.getElementById('crdMIngreso').checked = crC.mostrar_ingreso;
  document.getElementById('crdVigencia').value = crC.vigencia || '';
  document.getElementById('crdEmpNombre').value = e.nombre_mostrado || crEmp.empresa || '';
  document.getElementById('crdFirmaNombre').value = e.firma_nombre || ''; document.getElementById('crdFirmaCargo').value = e.firma_cargo || '';
  document.getElementById('crdReverso').value = e.texto_reverso || ''; document.getElementById('crdReverso').placeholder = crDatos().reverso;
  abrirModal('modalCarnetDatos');
}
function crAplicarDatos() {
  crC.nombre_carnet = document.getElementById('crdNombre').value.trim(); crC.telefono_carnet = document.getElementById('crdTelefono').value.trim();
  crC.mostrar_identidad = document.getElementById('crdMIdentidad').checked; crC.mostrar_telefono = document.getElementById('crdMTelefono').checked; crC.mostrar_ingreso = document.getElementById('crdMIngreso').checked;
  crC.vigencia = document.getElementById('crdVigencia').value;
  crEmpresa.nombre_mostrado = document.getElementById('crdEmpNombre').value.trim(); crEmpresa.firma_nombre = document.getElementById('crdFirmaNombre').value.trim();
  crEmpresa.firma_cargo = document.getElementById('crdFirmaCargo').value.trim(); crEmpresa.texto_reverso = document.getElementById('crdReverso').value.trim();
  cerrarModal('modalCarnetDatos'); crRender();
  toast('Datos aplicados. Pulsa "Guardar carnet" para conservarlos.', 'info');
}
function crAbrirFondo() {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  document.getElementById('crfColor').value = crC.fondo_color || '#ffffff'; abrirModal('modalCarnetFondo');
}
function crAplicarFondo() { crC.fondo_color = document.getElementById('crfColor').value; cerrarModal('modalCarnetFondo'); crRender(); }
async function crQuitarFondo() {
  const r = await api(`${CR_URL}?action=imagen`, { method: 'POST', body: JSON.stringify({ tipo: 'fondo', empleado_id: crEmp.id_empleado, quitar: true }) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo quitar.', 'error'); return; }
  crC.fondo_imagen = null; toast('Imagen de fondo quitada.', 'success'); crRender();
}

// ── Guardar / exportar ───────────────────────────────────
async function crGuardar() {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  const body = { empleado_id: crEmp.id_empleado, ...crC, empresa: { nombre_mostrado: crEmpresa.nombre_mostrado, firma_nombre: crEmpresa.firma_nombre, firma_cargo: crEmpresa.firma_cargo, texto_reverso: crEmpresa.texto_reverso } };
  const r = await api(`${CR_URL}?action=guardar`, { method: 'POST', body: JSON.stringify(body) });
  if (!r.ok) { toast(r.data?.error || 'No se pudo guardar el carnet.', 'error'); return; }
  toast('Carnet guardado.', 'success');
  const e = crEmps.find(x => x.id_empleado == crEmp.id_empleado); if (e) e.tiene_carnet = 1;
}

function crNombreArchivo() { return 'Carnet_' + (crEmp.nombres + '_' + crEmp.apellidos).trim().replace(/[^\wÁÉÍÓÚáéíóúñÑ]+/g, '_'); }

async function crExportarPDF() {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  const libs = await crCargarLibs();
  if (!libs[1] || !window.jspdf) { toast('No se pudo cargar la librería de PDF (revisa la conexión a internet).', 'error'); return; }
  await crPrecargar();
  const T = CR_TAM[crC.tamano] || CR_TAM.std, cv = document.createElement('canvas');
  const pdf = new window.jspdf.jsPDF({ orientation: 'portrait', unit: 'mm', format: [T.w, T.h] });
  crDibujar(cv, 'frente', 12); pdf.addImage(cv.toDataURL('image/png'), 'PNG', 0, 0, T.w, T.h);
  pdf.addPage([T.w, T.h], 'portrait');
  crDibujar(cv, 'reverso', 12); pdf.addImage(cv.toDataURL('image/png'), 'PNG', 0, 0, T.w, T.h);
  pdf.save(crNombreArchivo() + '.pdf');
  toast('PDF generado (frente y reverso).', 'success');
}

async function crExportarPNG() {
  if (!crEmp) { toast('Elige primero un empleado.', 'warn'); return; }
  await crPrecargar();
  const cv = document.createElement('canvas'); crDibujar(cv, crLadoAct, 12);
  cv.toBlob(b => { const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = `${crNombreArchivo()}_${crLadoAct}.png`; a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 2000); }, 'image/png');
}
