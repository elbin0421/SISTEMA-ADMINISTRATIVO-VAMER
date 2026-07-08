<!-- MODAL VEHÍCULO -->
<div class="modal-bg" id="modalVehiculo">
  <div class="modal modal-lg">
    <h4 id="tituloVehiculo">Nuevo Vehículo</h4>
    <div class="alert alert-error" id="errVehiculo"></div>
    <input type="hidden" id="vId">

    <div class="section-title">👤 Cliente propietario</div>
    <div class="form-row">
      <div class="form-group" style="grid-column:1/-1">
        <label>Cliente *</label>
        <input type="text" id="vClienteBuscar" placeholder="Buscar cliente por nombre o RTN..." oninput="buscarClienteVehiculo()" autocomplete="off">
        <input type="hidden" id="vClienteId">
      </div>
    </div>
    <div id="sugerenciasClienteVehiculo"
      style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:6px;margin-bottom:8px;max-height:150px;overflow-y:auto"></div>

    <div class="section-title">🚗 Datos del Vehículo</div>
    <div class="form-row-3">
      <div class="form-group">
        <label>Placa *</label>
        <input type="text" id="vPlaca" placeholder="AAA-0000" style="text-transform:uppercase">
      </div>
      <div class="form-group">
        <label>Marca</label>
        <input type="text" id="vMarca" placeholder="Toyota, Ford, Kenworth...">
      </div>
      <div class="form-group">
        <label>Modelo</label>
        <input type="text" id="vModelo" placeholder="Hilux, F-150, T800...">
      </div>
    </div>
    <div class="form-row-3">
      <div class="form-group">
        <label>Año</label>
        <input type="number" id="vAnio" placeholder="2020" min="1900" max="2099">
      </div>
      <div class="form-group">
        <label>Color</label>
        <input type="text" id="vColor" placeholder="Blanco, Rojo...">
      </div>
      <div class="form-group">
        <label>No. Motor</label>
        <input type="text" id="vMotor" placeholder="Número de motor">
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>No. Chasis</label>
        <input type="text" id="vChasis" placeholder="VIN / Número de chasis">
      </div>
      <div class="form-group">
        <label>Observaciones</label>
        <input type="text" id="vObservaciones" placeholder="Notas adicionales...">
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalVehiculo')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarVehiculo()">💾 Guardar</button>
    </div>
  </div>
</div>
