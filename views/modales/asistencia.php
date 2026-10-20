<!-- MODAL TIEMPO EXTRA / DÍAS FALTADOS -->
<div class="modal-bg" id="modalAsistencia">
  <div class="modal">
    <h4 id="tituloAsistencia">Nuevo Registro</h4>
    <div class="alert alert-error" id="errAsistencia"></div>
    <input type="hidden" id="asisId">
    <div class="form-group">
      <label>Empleado *</label>
      <select id="asisEmpleado"><option value="">— Seleccionar empleado —</option></select>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Fecha *</label><input type="date" id="asisFecha"></div>
      <div class="form-group">
        <label>Tipo *</label>
        <select id="asisTipo" onchange="alCambiarTipoAsistencia()">
          <option value="horas_extra">Horas extra</option>
          <option value="dia_faltado">Día faltado</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label id="asisCantidadLabel">Cantidad de horas *</label><input type="number" id="asisCantidad" min="0" step="0.25" placeholder="0"></div>
      <div class="form-group"><label>Motivo / observación</label><input type="text" id="asisMotivo" maxlength="255"></div>
    </div>
    <div style="font-size:11px;color:var(--muted)">Solo se registra la cantidad. La planilla calcula el valor (horas extra por ubicación y días faltados según el salario).</div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalAsistencia')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarAsistencia()">Guardar</button>
    </div>
  </div>
</div>
