<div class="module" id="mod-libro_ventas">
  <div class="card">
    <div class="card-header">
      <h4>📒 Libro de Ventas</h4>
      <div class="btn-group">
        <select id="libroMes" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="01">Enero</option><option value="02">Febrero</option>
          <option value="03">Marzo</option><option value="04">Abril</option>
          <option value="05">Mayo</option><option value="06">Junio</option>
          <option value="07">Julio</option><option value="08">Agosto</option>
          <option value="09">Septiembre</option><option value="10">Octubre</option>
          <option value="11">Noviembre</option><option value="12">Diciembre</option>
        </select>
        <select id="libroAnio" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="2025">2025</option><option value="2026">2026</option><option value="2027">2027</option>
        </select>
        <button class="btn btn-primary" onclick="cargarLibroVentas()">🔍 Consultar</button>
      </div>
    </div>
    <div id="libroResumen" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:14px 18px;margin-bottom:14px;display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:10px">
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px">Facturas emitidas</div><div style="font-size:22px;font-weight:600;color:var(--text)" id="libroTotalFacturas">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px">Subtotal</div><div style="font-size:18px;font-weight:600;color:var(--text)" id="libroTotalSubtotal">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px">ISV 15%</div><div style="font-size:18px;font-weight:600;color:var(--text)" id="libroTotalISV">—</div></div>
      <div><div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.6px">Total general</div><div style="font-size:22px;font-weight:600;color:var(--accent)" id="libroTotalGeneral">—</div></div>
    </div>
    <div class="table-wrap" id="tablaLibro"><p style="color:var(--muted);text-align:center;padding:30px">Selecciona mes y año para consultar</p></div>
  </div>
</div>
