<!-- MODAL HISTORIAL PAGOS CLIENTE -->
<div class="modal-bg" id="modalHistorialPagos">
  <div class="modal modal-lg">
    <h4>📋 Historial de Pagos — <span id="historialClienteNombre"></span></h4>
    <div id="historialResumen" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:14px;font-size:13px">
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px">Pagos</div><div style="font-size:20px;font-weight:600" id="histResTotal">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px">Total cobrado</div><div style="font-size:20px;font-weight:600;color:var(--accent)" id="histResCobrado">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px">Retenciones</div><div style="font-size:20px;font-weight:600;color:var(--danger)" id="histResRetenciones">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px">Neto recibido</div><div style="font-size:20px;font-weight:600;color:var(--success)" id="histResNeto">—</div></div>
    </div>
    <div class="table-wrap" id="tablaHistorialPagos"><p class="loading">Cargando...</p></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalHistorialPagos')">Cerrar</button>
    </div>
  </div>
</div>

<!-- MODAL DETALLE PAGO -->
<div class="modal-bg" id="modalDetallePago">
  <div class="modal" style="max-width:460px">
    <h4>🧾 Detalle de Pago</h4>
    <div id="contenidoDetallePago"><p class="loading">Cargando...</p></div>
    <div class="modal-footer" id="footerDetallePago">
      <button class="btn btn-secondary" onclick="cerrarModal('modalDetallePago')">Cerrar</button>
    </div>
  </div>
</div>
