<!-- MODAL: GENERAR PLANILLA ESPECIAL -->
<div class="modal-bg" id="modalGenerarEspecial" style="align-items:flex-start;padding:10px">
  <div class="modal modal-lg" style="max-width:98vw;width:100%;max-height:calc(100vh - 20px);overflow-y:auto;margin:0 auto">
    <h4 id="tituloEspecial">📋 Generar Planilla Especial</h4>
    <div class="alert alert-error" id="errEspecial" style="display:none"></div>

    <!-- Tipo + Empresa + Año + Fecha + Obs -->
    <div style="display:grid;grid-template-columns:auto auto auto 1fr 1fr;gap:12px;align-items:end;margin-bottom:14px">
      <div>
        <label style="display:block;font-size:12px;color:var(--muted);margin-bottom:5px">Tipo *</label>
        <div style="display:flex;gap:8px">
          <div class="especial-tipo-btn" onclick="selTipoEspecial('catorceavo')" data-tipo="catorceavo"
            style="border:2px solid var(--accent);background:rgba(232,160,32,.12);border-radius:8px;padding:8px 14px;text-align:center;cursor:pointer;min-width:110px">
            <div style="font-size:15px">1️⃣4️⃣</div><div style="font-size:11px;font-weight:600">Catorceavo</div>
            <div style="font-size:10px;color:var(--muted)">Jul 1 – Jun 30</div>
          </div>
          <div class="especial-tipo-btn" onclick="selTipoEspecial('aguinaldo')" data-tipo="aguinaldo"
            style="border:2px solid var(--border);border-radius:8px;padding:8px 14px;text-align:center;cursor:pointer;min-width:110px">
            <div style="font-size:15px">🎄</div><div style="font-size:11px;font-weight:600">Aguinaldo</div>
            <div style="font-size:10px;color:var(--muted)">Nov 1 – Oct 31</div>
          </div>
        </div>
      </div>
      <div class="form-group" style="margin:0">
        <label>Empresa *</label>
        <select id="espFiltroEmpresa" style="min-width:110px">
          <option value="0">Todas</option>
          <option value="1">SOLDYMEG</option>
          <option value="2">VAMER</option>
        </select>
      </div>
      <div class="form-group" style="margin:0">
        <label>Año de pago *</label>
        <select id="espAnio" style="min-width:90px" onchange="actualizarInfoPeriodo()">
          <option value="2024">2024</option><option value="2025">2025</option>
          <option value="2026" selected>2026</option><option value="2027">2027</option>
        </select>
      </div>
      <div class="form-group" style="margin:0">
        <label>Fecha de pago</label>
        <input type="date" id="espFechaPago">
      </div>
      <div class="form-group" style="margin:0">
        <label>Observaciones</label>
        <input type="text" id="espObs" placeholder="Opcional...">
      </div>
    </div>

    <div id="espInfoPeriodo" style="background:rgba(232,160,32,.08);border:1px solid rgba(232,160,32,.3);border-radius:8px;padding:10px 14px;font-size:12px;color:var(--muted);margin-bottom:12px">
      Período: <strong id="espPeriodoLabel">—</strong> &nbsp;|&nbsp; El monto es proporcional a los meses trabajados.
    </div>

    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
      <div class="section-title" style="margin:0">👷 Empleados — Marcar ✗ para excluir</div>
      <button class="btn btn-secondary btn-sm" onclick="cargarEmpEspeciales()">🔄 Cargar empleados</button>
    </div>
    <div id="espExtrasWrap" style="overflow-x:auto;border:1px solid var(--border);border-radius:8px;padding:8px;background:var(--bg);min-height:60px">
      <p style="color:var(--muted);font-size:13px;padding:8px">Selecciona la empresa y haz clic en "Cargar empleados".</p>
    </div>

    <div id="espPreview" style="display:none;background:var(--sidebar);border:1px solid var(--border);border-radius:8px;padding:10px 14px;font-size:13px;margin-top:10px">
      <div style="font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:8px;font-weight:600">📊 Vista previa</div>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px">
        <div><div style="color:var(--muted);font-size:11px">Incluidos</div><strong id="pvEspEmpleados">—</strong></div>
        <div><div style="color:var(--muted);font-size:11px">Excluidos</div><strong style="color:var(--danger)" id="pvEspExcluidos">—</strong></div>
        <div><div style="color:var(--muted);font-size:11px">Total a pagar</div><strong style="color:var(--accent)" id="pvEspNeto">—</strong></div>
      </div>
    </div>

    <div class="modal-footer" style="margin-top:14px">
      <button class="btn btn-secondary" onclick="cerrarModal('modalGenerarEspecial')">Cancelar</button>
      <button class="btn btn-secondary" onclick="previsualizarEspecial()">👁️ Previsualizar</button>
      <button class="btn btn-primary" onclick="confirmarGenerarEspecial()">✓ Generar Planilla</button>
    </div>
  </div>
</div>

<!-- MODAL: DETALLE PLANILLA ESPECIAL -->
<div class="modal-bg" id="modalDetalleEspecial">
  <div class="modal modal-lg" style="max-width:960px">
    <div id="contenidoDetalleEspecial"><p class="loading">Cargando...</p></div>
    <div class="modal-footer" id="footerDetalleEspecial">
      <button class="btn btn-secondary" onclick="cerrarModal('modalDetalleEspecial')">Cerrar</button>
    </div>
  </div>
</div>
