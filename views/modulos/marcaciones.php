<div class="module" id="mod-marcaciones">
<style>
  .mc-top{display:flex;justify-content:space-between;align-items:flex-start;gap:12px;flex-wrap:wrap;margin-bottom:14px}
  .mc-top h4{margin:0;font-size:18px}
  .mc-sub{font-size:12px;color:var(--muted);margin-top:2px}
  .mc-kpis{display:grid;grid-template-columns:repeat(4,1fr) 1.15fr;gap:12px;margin-bottom:14px}
  .mc-kpi{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:14px 16px}
  .mc-kpi b{display:block;font-size:26px;line-height:1.1}
  .mc-kpi span{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.3px}
  .mc-nav{display:flex;align-items:center;justify-content:space-between;gap:8px;text-align:center}
  .mc-nav b{font-size:14px}.mc-nav small{display:block;font-size:11px;color:var(--muted);text-transform:none}
  .mc-body{display:grid;grid-template-columns:1fr 290px;gap:14px;align-items:start}
  .mc-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:14px}
  .mc-bar{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-bottom:12px}
  .mc-bar .sp{flex:1}
  .mc-seg{padding:7px 14px;border:1px solid var(--border);background:var(--bg);color:var(--text);border-radius:7px;cursor:pointer;font-size:13px}
  .mc-seg.on{background:var(--accent);border-color:var(--accent);color:#fff;font-weight:600}
  .mc-sel{padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px}
  .mc-wrap{overflow-x:auto}
  table.mc-grid{border-collapse:separate;border-spacing:3px;font-size:11px}
  .mc-grid th{font-weight:600;color:var(--muted);padding:3px 2px;min-width:46px;text-align:center}
  .mc-grid th.sat{background:rgba(32,178,170,.16);border-radius:6px;color:var(--text)}
  .mc-grid th.sun{background:rgba(128,128,128,.14);border-radius:6px}
  .mc-grid th.fix,.mc-grid td.fix{position:sticky;left:0;background:var(--surface);z-index:2;text-align:left;min-width:96px;font-size:12px;font-weight:600}
  .mc-grid th small{display:block;font-size:13px;color:var(--text)}
  .mc-c{border-radius:6px;padding:4px 2px;text-align:center;line-height:1.25;cursor:pointer;min-width:46px;border:1px solid transparent}
  .mc-c i{display:block;font-style:normal}
  .mc-c.sel{outline:2px solid var(--text);outline-offset:1px}
  .mc-puntual{background:rgba(46,160,110,.18);color:#3fb97f}
  .mc-sabado{background:rgba(32,178,170,.22);color:#2bb7ab}
  .mc-tardanza{background:rgba(224,165,38,.22);color:#e0a526}
  .mc-salida_anticipada{background:rgba(232,123,58,.22);color:#e87b3a}
  .mc-falta_salida{background:rgba(139,108,240,.2);color:#9b82f2}
  .mc-ausente{background:rgba(224,82,82,.2);color:#e25555;font-weight:700}
  .mc-justificado{background:rgba(59,155,224,.2);color:#3b9be0}
  .mc-inhabil,.mc-na,.mc-futuro,.mc-pendiente{background:rgba(128,128,128,.13);color:var(--muted);cursor:default}
  .mc-tot{text-align:center;font-size:12px;min-width:44px}
  .mc-legend{display:flex;gap:14px;flex-wrap:wrap;margin-top:12px;font-size:11px;color:var(--muted)}
  .mc-legend i{display:inline-block;width:12px;height:12px;border-radius:3px;margin-right:5px;vertical-align:-2px}
  .mc-det h5{margin:0;font-size:11px;color:var(--muted);letter-spacing:.5px;text-transform:uppercase}
  .mc-det .nm{font-size:20px;font-weight:700;margin:6px 0 0}.mc-det .dt{font-size:12px;color:var(--muted);margin-bottom:10px}
  .mc-badge{border-radius:7px;padding:8px 12px;font-weight:600;font-size:13px;margin-bottom:10px}
  .mc-row{display:flex;justify-content:space-between;padding:7px 0;border-bottom:1px solid var(--border);font-size:13px}
  .mc-row span{color:var(--muted)}
  @media(max-width:1000px){.mc-body{grid-template-columns:1fr}.mc-kpis{grid-template-columns:repeat(2,1fr)}}
</style>

  <div class="mc-top">
    <div>
      <h4>🕘 Asistencia diaria</h4>
      <div class="mc-sub" id="mcSubtitulo">—</div>
    </div>
    <div class="btn-group">
      <button class="btn btn-secondary" onclick="mcExportarExcel()">Excel</button>
      <button class="btn btn-secondary" onclick="mcAbrirSync()" title="Enviar horas extra y ausencias a Tiempo Extra y Faltas">⏩ A Tiempo Extra</button>
      <button class="btn btn-secondary" onclick="mcImprimir()">Imprimir</button>
      <button class="btn btn-secondary" onclick="mcAbrirConfig()">⚙️ Horario</button>
      <button class="btn btn-primary" onclick="mcAbrirMarca()">Registrar marca</button>
    </div>
  </div>

  <div class="mc-kpis">
    <div class="mc-kpi"><b id="mcKpiPresentes">—</b><span id="mcKpiPresentesLbl">Presentes</span></div>
    <div class="mc-kpi"><b id="mcKpiTard">—</b><span>Tardanzas en el período</span></div>
    <div class="mc-kpi"><b id="mcKpiAus">—</b><span>Ausencias en el período</span></div>
    <div class="mc-kpi"><b id="mcKpiAsis">—</b><span>Asistencia del período</span></div>
    <div class="mc-kpi mc-nav">
      <button class="btn btn-secondary btn-sm" onclick="mcMover(-1)">‹</button>
      <div><b id="mcNavTitulo">—</b><small id="mcNavSub"></small></div>
      <button class="btn btn-secondary btn-sm" onclick="mcMover(1)">›</button>
    </div>
  </div>

  <div class="mc-body">
    <div class="mc-card">
      <div class="mc-bar">
        <button class="mc-seg on" id="mcVQuincena" onclick="mcSetVista('quincena')">Quincena</button>
        <button class="mc-seg" id="mcVMes" onclick="mcSetVista('mes')">Mes</button>
        <button class="mc-seg" id="mcVDia" onclick="mcSetVista('dia')">Día</button>
        <span class="sp"></span>
        <span id="mcQuincenaBtns">
          <button class="mc-seg" id="mcQ1" onclick="mcSetQuincena(1)">1.ª (1–15)</button>
          <button class="mc-seg on" id="mcQ2" onclick="mcSetQuincena(2)">2.ª (16–fin)</button>
        </span>
        <select class="mc-sel" id="mcEmpresa" onchange="mcCargar()">
          <option value="">Empresa: Todas</option><option value="1">SOLDYMEG</option><option value="2">VAMER</option>
        </select>
        <select class="mc-sel" id="mcDepto" onchange="mcCargar()"><option value="">Departamento: Todos</option></select>
      </div>
      <div class="mc-wrap" id="mcGrid"><p class="loading">Cargando...</p></div>
      <div class="mc-legend" id="mcLegend"></div>
    </div>

    <div class="mc-card mc-det" id="mcDetalle"><h5>Detalle del día</h5><p class="empty-state" style="padding:20px 0">Selecciona una casilla.</p></div>
  </div>
</div>
