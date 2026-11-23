<!-- MODAL CARNET: EDITAR DATOS -->
<div class="modal-bg" id="modalCarnetDatos">
  <div class="modal" style="max-width:520px">
    <h4>✏️ Datos del carnet</h4>
    <p style="font-size:12px;color:var(--muted);margin:0 0 10px">El nombre, puesto, identidad y fecha de ingreso vienen del empleado. Para cambiarlos edita el empleado en <b>Empleados</b>.</p>
    <div class="form-group"><label>Nombre en el carnet</label><input type="text" id="crdNombre" maxlength="80"><small style="color:var(--muted)">Vacío = primer nombre + primer apellido</small></div>
    <div class="form-group"><label>Teléfono en el carnet</label><input type="text" id="crdTelefono" maxlength="30"><small style="color:var(--muted)">Vacío = teléfono del empleado</small></div>
    <div class="form-group"><label>Vigencia hasta (reverso)</label><input type="date" id="crdVigencia"><small style="color:var(--muted)">Vacío = 31/12 del año actual</small></div>
    <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:12px">
      <label style="display:flex;gap:6px;align-items:center;font-size:13px"><input type="checkbox" id="crdMIdentidad"> Mostrar identidad</label>
      <label style="display:flex;gap:6px;align-items:center;font-size:13px"><input type="checkbox" id="crdMTelefono"> Mostrar teléfono</label>
      <label style="display:flex;gap:6px;align-items:center;font-size:13px"><input type="checkbox" id="crdMIngreso"> Mostrar fecha de ingreso</label>
    </div>
    <div class="section-title">🏢 Empresa (aplica a todos los carnets de esta empresa)</div>
    <div class="form-group"><label>Nombre que aparece en el carnet</label><input type="text" id="crdEmpNombre" maxlength="100"></div>
    <div class="form-row">
      <div class="form-group"><label>Firmante</label><input type="text" id="crdFirmaNombre" maxlength="100"></div>
      <div class="form-group"><label>Cargo del firmante</label><input type="text" id="crdFirmaCargo" maxlength="100"></div>
    </div>
    <div class="form-group"><label>Texto del reverso</label><textarea id="crdReverso" rows="6" maxlength="400"></textarea></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCarnetDatos')">Cancelar</button>
      <button class="btn btn-primary" onclick="crAplicarDatos()">Aplicar</button>
    </div>
  </div>
</div>

<!-- MODAL CARNET: FONDO -->
<div class="modal-bg" id="modalCarnetFondo">
  <div class="modal" style="max-width:380px">
    <h4>🎨 Fondo del carnet</h4>
    <div class="form-group"><label>Color de fondo</label><input type="color" id="crfColor" style="width:80px;height:36px;padding:2px"></div>
    <div class="form-group"><label>Imagen de fondo (opcional)</label>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <button type="button" class="btn btn-sm btn-secondary" onclick="crPedirImagen('fondo')">Subir imagen</button>
        <button type="button" class="btn btn-sm btn-danger" onclick="crQuitarFondo()">Quitar imagen</button>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCarnetFondo')">Cerrar</button>
      <button class="btn btn-primary" onclick="crAplicarFondo()">Aplicar color</button>
    </div>
  </div>
</div>
