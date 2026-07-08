<!-- ══════════════════════════════════════════════
     MODAL VACACIONES — Registrar período vacacional
     ══════════════════════════════════════════════ -->
<div class="modal-bg" id="modalVacacion">
  <div class="modal" style="max-width:560px">
    <h4>🏖️ Registrar Vacaciones</h4>
    <div class="alert alert-error" id="errVacacion"></div>
    <input type="hidden" id="vacId">

    <!-- Empleado -->
    <div class="form-group">
      <label>Empleado *</label>
      <select id="vacEmpleadoId" onchange="onCambioEmpleadoVac()">
        <option value="">— Seleccionar empleado —</option>
      </select>
    </div>

    <!-- Info empleado -->
    <div id="vacInfoEmpleado" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:10px 14px;margin-bottom:12px;font-size:12px">
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px">
        <div><span style="color:var(--muted)">Salario mensual</span><br><strong id="vacSalarioMensual">—</strong></div>
        <div><span style="color:var(--muted)">Salario diario</span><br><strong id="vacSalarioDiario">—</strong></div>
        <div><span style="color:var(--muted)">Fecha de ingreso</span><br><strong id="vacFechaIngreso">—</strong></div>
      </div>
    </div>

    <!-- Fechas del período laboral -->
    <div class="section-title">📅 Período Laboral</div>
    <div class="form-row">
      <div class="form-group">
        <label>Fecha inicio del período *</label>
        <input type="date" id="vacFechaInicio" onchange="calcularPreviewVac()">
      </div>
      <div class="form-group">
        <label>Fecha fin del período *</label>
        <input type="date" id="vacFechaFin" onchange="calcularPreviewVac()">
      </div>
    </div>

    <!-- Preview cálculo -->
    <div id="vacPreviewCalculo" style="display:none;background:var(--bg);border:1px solid var(--accent);border-radius:8px;padding:12px 16px;margin-bottom:12px">
      <div style="font-size:11px;color:var(--accent);font-weight:700;letter-spacing:.5px;margin-bottom:8px">📐 CÁLCULO AUTOMÁTICO</div>
      <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;font-size:12px">
        <div><span style="color:var(--muted)">Años laborados</span><br><strong id="vacAnios">—</strong></div>
        <div><span style="color:var(--muted)">Días que corresponden</span><br><strong id="vacDias" style="font-size:18px;color:var(--accent)">—</strong></div>
        <div><span style="color:var(--muted)">Salario diario</span><br><strong id="vacSDiario">—</strong></div>
        <div><span style="color:var(--muted)">Monto a pagar</span><br><strong id="vacMonto" style="color:#4caf50">—</strong></div>
      </div>
    </div>


    <div id="vacPanelDiasAUsar" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:12px">
      <div style="font-size:11px;color:var(--muted);font-weight:600;letter-spacing:.5px;margin-bottom:10px">📅 DÍAS DE VACACIONES</div>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;align-items:end">
        <div><div style="font-size:11px;color:var(--muted);margin-bottom:4px">Días disponibles</div><strong id="vacDiasDisponibles" style="font-size:16px;color:var(--accent)">—</strong></div>
        <div><label style="display:block;font-size:12px;color:var(--muted);margin-bottom:4px">Días a usar *</label><input type="number" id="vacDiasAUsar" min="1" step="1" value="" style="width:100%;padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:14px" oninput="recalcularParcial()"></div>
        <div><div style="font-size:11px;color:var(--muted);margin-bottom:4px">Monto estimado</div><strong id="vacMontoParcial" style="font-size:15px;color:#4caf50">—</strong></div>
      </div>
    </div>
    <!-- Tipo y fecha de registro -->
    <div class="section-title">✍️ Forma de Goce</div>
    <div class="form-row">
      <div class="form-group">
        <label>Tipo de vacación *</label>
        <select id="vacTipo" onchange="onTipoVacChange()">
          <option value="descanso">🏖️ Días de Descanso (no se paga)</option>
          <option value="pago">💰 Pago en Efectivo</option>
        </select>
      </div>
      <div class="form-group">
        <label>Fecha de registro</label>
        <input type="date" id="vacFechaRegistro">
      </div>
    </div>

    <!-- Nota pago -->
    <div id="vacNotaPago" style="display:none;background:#1a2e1a;border:1px solid #4caf50;border-radius:7px;padding:9px 13px;margin-bottom:10px;font-size:12px;color:#81c784">
      💰 Se registrará el pago de <strong id="vacNotaMonto">L. 0.00</strong> en efectivo al empleado.
    </div>

    <div class="form-group">
      <label>Observaciones</label>
      <textarea id="vacObs" rows="2" placeholder="Ej: VACACIONES PERÍODO 2024-2025..."></textarea>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalVacacion')">Cancelar</button>
      <button class="btn btn-primary" id="btnGuardarVacacion" disabled onclick="guardarVacacion()">
        Registrar Vacaciones
      </button>
    </div>
  </div>
</div>
