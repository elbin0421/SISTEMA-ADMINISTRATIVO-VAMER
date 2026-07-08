<div class="module active" id="mod-inicio">

  <!-- ── Fila 1: KPIs ──────────────────────────────────────── -->
  <div class="kpi-grid" style="grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px;margin-bottom:20px">

    <div class="kpi-card" style="border-left:4px solid var(--accent)">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <div>
          <div class="kpi-label">💰 Ventas del día</div>
          <div class="kpi-val" id="kpiVentasDia">—</div>
          <div class="kpi-sub" id="kpiVentasDiaCant">— facturas</div>
        </div>
        <div style="font-size:30px;opacity:.15">💰</div>
      </div>
    </div>

    <div class="kpi-card" style="border-left:4px solid #e07b39">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <div>
          <div class="kpi-label">🕐 Cuentas por cobrar</div>
          <div class="kpi-val" id="kpiCxC" style="color:#e07b39">—</div>
          <div class="kpi-sub" id="kpiCxCCant">— facturas pendientes</div>
        </div>
        <div style="font-size:30px;opacity:.15">🕐</div>
      </div>
    </div>

    <div class="kpi-card" style="border-left:4px solid #e03e3e">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <div>
          <div class="kpi-label">🛒 Cuentas por pagar</div>
          <div class="kpi-val" id="kpiCxP" style="color:#e03e3e">—</div>
          <div class="kpi-sub" id="kpiCxPCant">— compras pendientes</div>
        </div>
        <div style="font-size:30px;opacity:.15">🛒</div>
      </div>
    </div>

    <div class="kpi-card" style="border-left:4px solid #3ea8e0">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <div>
          <div class="kpi-label">🔧 OT en proceso</div>
          <div class="kpi-val" id="kpiOTProceso" style="color:#3ea8e0">—</div>
          <div class="kpi-sub">órdenes activas</div>
        </div>
        <div style="font-size:30px;opacity:.15">🔧</div>
      </div>
    </div>

    <div class="kpi-card" style="border-left:4px solid #c94040">
      <div style="display:flex;justify-content:space-between;align-items:flex-start">
        <div>
          <div class="kpi-label">📦 Stock bajo mínimo</div>
          <div class="kpi-val stock-bajo" id="kpiStockBajo">—</div>
          <div class="kpi-sub">materiales críticos</div>
        </div>
        <div style="font-size:30px;opacity:.15">📦</div>
      </div>
    </div>

  </div>

  <!-- ── Fila 2: Gráfico + Cotizaciones ────────────────────── -->
  <div style="display:grid;grid-template-columns:1fr 370px;gap:16px;margin-bottom:16px">

    <div class="card" style="margin-bottom:0">
      <div class="card-header">
        <h4>📈 Ingresos mensuales</h4>
        <span style="font-size:12px;color:var(--muted)">Últimos 6 meses</span>
      </div>
      <div style="position:relative;height:220px">
        <canvas id="graficoIngresos"></canvas>
        <div id="graficoLoading" style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:13px">Cargando...</div>
      </div>
    </div>

    <div class="card" style="margin-bottom:0">
      <div class="card-header">
        <h4>📑 Últimas cotizaciones</h4>
        <button class="btn btn-sm btn-secondary" onclick="document.querySelector('[data-module=cotizaciones]').click()">Ver todas</button>
      </div>
      <div id="inicioCotizaciones"><p class="loading">Cargando...</p></div>
    </div>

  </div>

  <!-- ── Fila 3: OT Recientes ──────────────────────────────── -->
  <div class="card">
    <div class="card-header">
      <h4>🔧 Órdenes de Trabajo recientes</h4>
      <button class="btn btn-sm btn-secondary" onclick="document.querySelector('[data-module=ordenes]').click()">Ver todas</button>
    </div>
    <div class="table-wrap" id="otRecientes"><p class="loading">Cargando...</p></div>
  </div>

</div>
