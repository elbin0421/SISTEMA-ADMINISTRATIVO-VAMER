<!-- MODAL RECIBO -->
<div class="modal-bg" id="modalRecibo">
  <div class="modal modal-lg">
    <h4 id="tituloRecibo">Nuevo Recibo</h4>
    <div class="alert alert-error" id="errRecibo"></div>
    <input type="hidden" id="recId">
    <div class="form-row">
      <div class="form-group" style="flex:2">
        <label>Empleado *</label>
        <select id="recEmpleado" onchange="alSeleccionarEmpleadoRecibo()">
          <option value="">— Seleccionar empleado —</option>
        </select>
      </div>
      <div class="form-group"><label>Fecha</label><input type="date" id="recFecha"></div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Semana de planilla <span style="color:var(--muted);font-size:11px">(obligatoria si hay viáticos)</span></label>
        <select id="recSemana">
          <option value="">— Sin viáticos —</option>
          <option value="1">Semana 1 — 1ra quincena (viático S.1)</option>
          <option value="2">Semana 2 — 1ra quincena (viático S.2)</option>
          <option value="3">Semana 3 — 2da quincena (viático S.3)</option>
          <option value="4">Semana 4 — 2da quincena (viático S.4)</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>RTN / Identidad</label><input type="text" id="recRtn" placeholder="0801199900000"></div>
      <div class="form-group"><label>Dirección</label><input type="text" id="recDireccion"></div>
    </div>

    <div class="section-title">📋 Conceptos <span style="color:var(--muted);font-size:11px;font-weight:400">(máximo 5 líneas)</span></div>
    <div style="font-size:11px;color:var(--muted);margin-bottom:6px">
      Viáticos <b>suman</b> en la planilla · Adelanto de salario y Abono préstamo <b>restan</b> como deducción · Otro no afecta la planilla.
    </div>
    <div id="recLineasWrap"></div>
    <button type="button" class="btn btn-sm btn-secondary" id="btnAddLineaRecibo" onclick="agregarLineaRecibo()" style="margin-top:8px">+ Línea</button>

    <div class="form-row" style="margin-top:14px">
      <div class="form-group"><label>Observaciones (no se imprime)</label><input type="text" id="recObs" maxlength="255"></div>
      <div class="form-group"><label>Retenciones (L.)</label><input type="number" id="recRetenciones" min="0" step="0.01" value="0" oninput="calcTotalesRecibo()"></div>
    </div>
    <div style="text-align:right;font-size:14px">
      Subtotal: <b id="recSubtotalTxt">L. 0.00</b> &nbsp;|&nbsp; Total: <b id="recTotalTxt" style="color:var(--accent)">L. 0.00</b>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalRecibo')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarRecibo()">Guardar Recibo</button>
    </div>
  </div>
</div>

<!-- MODAL SERIE DE RECIBOS -->
<div class="modal-bg" id="modalSerieRecibos">
  <div class="modal">
    <h4>⚙️ Serie autorizada de recibos</h4>
    <div class="alert alert-error" id="errSerieRecibos"></div>
    <div class="form-row">
      <div class="form-group"><label>Prefijo</label><input type="text" id="serPrefijo" placeholder="000-001-01"></div>
      <div class="form-group"><label>Fecha Límite de Emisión</label><input type="date" id="serFechaLimite"></div>
    </div>
    <div class="form-row-3">
      <div class="form-group"><label>Rango inicial</label><input type="number" id="serInicio" min="1"></div>
      <div class="form-group"><label>Rango final</label><input type="number" id="serFin" min="1"></div>
      <div class="form-group"><label>Último emitido</label><input type="number" id="serActual" min="0"></div>
    </div>
    <div style="font-size:12px;color:var(--muted)" id="serSiguienteTxt"></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalSerieRecibos')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarSerieRecibos()">Guardar</button>
    </div>
  </div>
</div>
