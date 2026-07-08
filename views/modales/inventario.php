<!-- MODAL MATERIAL -->
<div class="modal-bg" id="modalMaterial">
  <div class="modal">
    <h4 id="tituloMaterial">Nuevo Material</h4>
    <div class="alert alert-error" id="errMaterial"></div>
    <input type="hidden" id="mId">
    <div class="form-row">
      <div class="form-group"><label>Nombre *</label><input type="text" id="mNombre" placeholder="Nombre del material"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Categoría</label><select id="mCategoria"><option value="">Sin categoría</option></select></div>
      <div class="form-group"><label>Unidad de medida</label>
        <select id="mUnidad">
          <option value="unidad">Unidad</option><option value="metro">Metro</option>
          <option value="litro">Litro</option><option value="kg">Kilogramo</option>
          <option value="galón">Galón</option><option value="par">Par</option>
          <option value="caja">Caja</option><option value="rollo">Rollo</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Precio compra (L.)</label><input type="number" id="mPrecioC" placeholder="0.00" min="0" step="0.01" oninput="calcPrecioVenta()"></div>
      <div class="form-group"><label>Precio venta (L.) <span style="color:var(--muted);font-size:11px">+35% auto</span></label><input type="number" id="mPrecioV" placeholder="0.00" min="0" step="0.01"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Stock actual</label><input type="number" id="mStock" placeholder="0" min="0" step="0.01"></div>
      <div class="form-group"><label>Stock mínimo</label><input type="number" id="mStockMin" placeholder="0" min="0" step="0.01"></div>
    </div>
    <div class="form-group"><label>Descripción</label><textarea id="mDesc" placeholder="Descripción opcional"></textarea></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalMaterial')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarMaterial()">Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL AJUSTE STOCK -->
<div class="modal-bg" id="modalAjuste">
  <div class="modal">
    <h4>Ajuste de Stock — <span id="ajusteNombre"></span></h4>
    <div class="alert alert-error" id="errAjuste"></div>
    <input type="hidden" id="ajusteId">
    <div class="form-row">
      <div class="form-group"><label>Tipo</label><select id="ajusteTipo"><option value="entrada">Entrada (+)</option><option value="salida">Salida (-)</option></select></div>
      <div class="form-group"><label>Cantidad *</label><input type="number" id="ajusteCant" placeholder="0" min="0.01" step="0.01"></div>
    </div>
    <div class="form-group"><label>Observaciones</label><input type="text" id="ajusteObs" placeholder="Motivo del ajuste"></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalAjuste')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarAjuste()">Aplicar</button>
    </div>
  </div>
</div>

<!-- MODAL KARDEX -->
<div class="modal-bg" id="modalKardex">
  <div class="modal modal-lg">
    <h4>Kardex — <span id="kardexNombre"></span></h4>
    <div class="table-wrap" id="tablaKardex"><p class="loading">Cargando...</p></div>
    <div class="modal-footer"><button class="btn btn-secondary" onclick="cerrarModal('modalKardex')">Cerrar</button></div>
  </div>
</div>
