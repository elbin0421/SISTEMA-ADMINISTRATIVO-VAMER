<!-- MODAL USUARIO -->
<div class="modal-bg" id="modalUsuario">
  <div class="modal">
    <h4 id="modalUsuarioTitulo">Nuevo Usuario</h4>
    <div class="alert alert-error" id="modalUsuarioError"></div>
    <input type="hidden" id="uId">
    <div class="form-group"><label>Nombre completo</label><input type="text" id="uNombre" placeholder="Ej: Juan Pérez" autocomplete="off"></div>
    <div class="form-group"><label>Usuario (login)</label><input type="text" id="uUsuario" placeholder="Ej: jperez" autocomplete="off"></div>
    <div class="form-group"><label>Contraseña <span id="uPassNote" style="color:var(--muted);font-size:11px"></span></label><input type="password" id="uPassword" placeholder="Mínimo 6 caracteres"></div>
    <div class="form-group"><label>Rol</label><select id="uRol"></select></div>
    <div class="form-group">
      <label>Empleado vinculado <span style="color:var(--muted);font-size:11px">(para datos en cotizaciones)</span></label>
      <select id="uEmpleadoId">
        <option value="">— Sin empleado vinculado —</option>
      </select>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalUsuario')">Cancelar</button>
      <button class="btn btn-primary" id="btnGuardarUsuario">Guardar</button>
    </div>
  </div>
</div>
