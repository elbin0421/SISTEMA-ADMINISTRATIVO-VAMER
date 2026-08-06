// ══════════════════════════════════════════════════════════
// cai.js — CAI (SAR Honduras)
// Extraído de dashboard.js líneas 2692-2805
// ══════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════
// MÓDULO CAI
// ══════════════════════════════════════════════════════════
async function cargarModuloCAI() {
  // Panel CAI activo
  const rCai = await api('controllers/FacturacionController.php?action=cai_activo');
  const wrap = document.getElementById('caiActivoWrap');
  if (wrap) {
    if (rCai.ok && rCai.data.data) {
      const c = rCai.data.data;
      const vencidaFecha = parseInt(c.fecha_vencida || 0);
      if (vencidaFecha) {
        // CAI con fecha vencida — advertencia, NO se puede facturar
        wrap.innerHTML = `
          <div style="background:rgba(224,80,80,.08);border:1px solid rgba(224,80,80,.35);border-radius:10px;padding:14px 18px;font-size:13px">
            <div style="font-weight:700;color:var(--danger);margin-bottom:6px">❌ CAI vencido — No se puede facturar</div>
            <div style="color:var(--muted);margin-bottom:10px;font-size:12px">
              La fecha límite de emisión <strong style="color:var(--danger)">${c.fecha_limite_emision}</strong> ya expiró.
              El sistema lo marcará como inactivo automáticamente. Registra un nuevo CAI para continuar facturando.
            </div>
            <div style="font-family:monospace;font-size:11px;color:var(--muted);word-break:break-all">${c.cai}</div>
          </div>`;
      } else {
        // CAI activo y vigente
        wrap.innerHTML = `
          <div style="background:rgba(40,167,69,.08);border:1px solid rgba(40,167,69,.3);border-radius:10px;padding:14px 18px;font-size:13px">
            <div style="font-weight:700;color:var(--success);margin-bottom:8px">✅ CAI Activo y Vigente</div>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px">
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Código CAI</div>
                <div style="font-family:monospace;font-size:12px;word-break:break-all">${c.cai}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Correlativo actual</div>
                <div style="font-family:monospace;font-weight:600">${c.correlativo_actual}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Rango</div>
                <div style="font-family:monospace;font-size:12px">${c.rango_inicio} — ${c.rango_fin}</div></div>
              <div><div style="color:var(--muted);font-size:11px;text-transform:uppercase">Fecha límite SAR</div>
                <div style="font-weight:600">${c.fecha_limite_emision}</div></div>
            </div>
          </div>`;
      }
    } else {
      wrap.innerHTML = `<div style="background:rgba(220,53,69,.08);border:1px solid rgba(220,53,69,.3);border-radius:10px;padding:14px 18px;color:var(--danger)">
        ❌ Sin CAI activo. Registra un CAI para poder emitir facturas.</div>`;
    }
  }

  // Historial (todos los CAI)
  const lista = document.getElementById('tablaCAILista');
  if (lista) {
    const rLista = await api('controllers/FacturacionController.php?action=cai_listar');
    if (rLista.ok && rLista.data.data?.length) {
      let h = `<table><thead><tr><th>CAI</th><th>Correlativo actual</th><th>Rango inicio</th><th>Rango fin</th><th>Fecha límite</th><th>Estado</th><th>Acción</th></tr></thead><tbody>`;
      rLista.data.data.forEach(c => {
        const hoy = new Date().toISOString().slice(0,10);
        const fechaVenc = c.fecha_limite_emision < hoy;
        h += `<tr>
          <td style="font-family:monospace;font-size:11px;word-break:break-all">${c.cai}</td>
          <td style="font-family:monospace">${c.correlativo_actual}</td>
          <td style="font-family:monospace;font-size:11px">${c.rango_inicio}</td>
          <td style="font-family:monospace;font-size:11px">${c.rango_fin}</td>
          <td style="color:${fechaVenc?'var(--danger)':'inherit'}">${c.fecha_limite_emision}${fechaVenc?' ⚠️':''}</td>
          <td>${badgeEstado(c.estado)}</td>
          <td>
            ${c.estado === 'activo'
              ? `<button class="btn btn-sm btn-danger" onclick="inactivarCAI(${c.id_cai})">Inactivar</button>`
              : '—'}
          </td>
        </tr>`;
      });
      h += '</tbody></table>';
      lista.innerHTML = h;
    } else {
      lista.innerHTML = '<p class="empty-state">Sin CAI registrados.</p>';
    }
  }
}

function mostrarFormCAI() {
  document.getElementById('errCAIModulo').style.display = 'none';
  ['caiCodigoM','caiInicioM','caiFinalM'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('caiFechaLimiteM').value = '';
  document.getElementById('caiEstablecimientoM').value = '001';
  document.getElementById('formCAIWrap').style.display = 'block';
}

function ocultarFormCAI() {
  document.getElementById('formCAIWrap').style.display = 'none';
}

async function guardarCAIModulo() {
  const errEl = document.getElementById('errCAIModulo');
  errEl.style.display = 'none';
  const body = {
    cai:                  document.getElementById('caiCodigoM').value.trim(),
    rango_inicio:         document.getElementById('caiInicioM').value.trim(),
    rango_fin:            document.getElementById('caiFinalM').value.trim(),
    fecha_limite_emision: document.getElementById('caiFechaLimiteM').value,
    establecimiento:      document.getElementById('caiEstablecimientoM').value.trim() || '001',
    punto_emision:        '001',
    tipo_documento:       '01',
  };
  if (!body.cai || !body.rango_inicio || !body.rango_fin || !body.fecha_limite_emision) {
    errEl.textContent = 'Todos los campos marcados son requeridos.';
    errEl.style.display = 'block'; return;
  }
  const r = await api('controllers/FacturacionController.php?action=cai_crear', { method:'POST', body: JSON.stringify(body) });
  if (r.ok) {
    ocultarFormCAI();
    toast('CAI registrado correctamente.', 'success');
    cargarModuloCAI();
  } else {
    errEl.textContent = r.data.error || 'Error al guardar.';
    errEl.style.display = 'block';
  }
}
