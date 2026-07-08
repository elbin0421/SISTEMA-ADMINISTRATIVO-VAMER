<!-- MODAL CLIENTE -->
<div class="modal-bg" id="modalCliente">
  <div class="modal">
    <h4 id="tituloCliente">Nuevo Cliente</h4>
    <div class="alert alert-error" id="errCliente"></div>
    <input type="hidden" id="cId">
    <div class="form-row">
      <div class="form-group" style="grid-column:1/-1"><label>Nombre *</label><input type="text" id="cNombre" placeholder="Nombre completo o razón social"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Tipo</label><select id="cTipo"><option value="empresa">Empresa</option><option value="natural">Persona Natural</option></select></div>
      <div class="form-group"><label>RTN</label><input type="text" id="cRtn" placeholder="0000-0000-000000"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Teléfono</label><input type="text" id="cTel" placeholder="0000-0000"></div>
      <div class="form-group"><label>Teléfono 2</label><input type="text" id="cTel2" placeholder="0000-0000"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Correo</label><input type="email" id="cCorreo" placeholder="correo@ejemplo.com"></div>
      <div class="form-group"><label>Contacto</label><input type="text" id="cContacto" placeholder="Nombre de contacto"></div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Días de crédito <span style="color:var(--muted);font-size:11px">— 0 = contado</span></label>
        <input type="number" id="cDiasCredito" min="0" max="365" step="1" value="0" placeholder="0">
      </div>
      <div class="form-group" style="padding-top:28px">
        <div style="font-size:12px;color:var(--muted);line-height:1.5">
          💡 Ejemplos: 0=contado, 15=quincenal, 30=mensual, 60=bimensual
        </div>
      </div>
    </div>
    <div class="form-group"><label>Dirección</label><input type="text" id="cDir" placeholder="Dirección completa"></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCliente')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarCliente()">Guardar</button>
    </div>
  </div>
</div>
