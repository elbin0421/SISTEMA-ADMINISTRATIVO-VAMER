<div class="module" id="mod-backups">
<style>
  .bk-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:16px}
  @media(max-width:900px){.bk-grid{grid-template-columns:1fr}}
  .bk-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:16px 18px}
  .bk-card h5{margin:0 0 4px;font-size:14px}
  .bk-card p{font-size:12px;color:var(--muted);margin:0 0 12px}
  .bk-card label{display:block;font-size:12px;color:var(--muted);margin:10px 0 3px}
  .bk-card input[type=text],.bk-card input[type=password],.bk-card input[type=number]{width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;box-sizing:border-box}
  .bk-estado{display:inline-block;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:700}
  .bk-on{background:rgba(62,207,142,.15);color:#3ecf8e}.bk-off{background:rgba(240,90,90,.15);color:#f05a5a}
  .bk-uri{display:flex;gap:6px;align-items:center;background:var(--bg);border:1px solid var(--border);border-radius:6px;padding:6px 8px;font-size:11px;word-break:break-all}
  .bk-aviso{font-size:12px;border-radius:7px;padding:8px 10px;margin-bottom:10px;background:rgba(240,180,60,.12);color:#e0a63a;display:none}
  .bk-pasos{font-size:12px;color:var(--muted);line-height:1.7}
  .bk-pasos code{background:var(--bg);padding:1px 5px;border-radius:4px}
</style>

  <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;flex-wrap:wrap;margin-bottom:14px">
    <div>
      <h4 style="margin:0;font-size:18px">💾 Respaldos de la base de datos</h4>
      <div style="font-size:12px;color:var(--muted);margin-top:2px">Respaldo completo (estructura y datos) en un archivo .sql comprimido. Se puede guardar en Google Drive.</div>
    </div>
  </div>

  <div id="bkAvisos"></div>

  <div class="bk-grid">
    <!-- Crear respaldo -->
    <div class="bk-card">
      <h5>Crear respaldo ahora</h5>
      <p>Genera un respaldo completo de todas las tablas, vistas y procedimientos. Puede tardar unos segundos.</p>
      <label style="display:flex;gap:6px;align-items:center;font-size:13px;color:var(--text);margin:0 0 12px"><input type="checkbox" id="bkSubirDrive"> Subir también a Google Drive</label>
      <button class="btn btn-primary" id="bkBtnCrear" onclick="bkCrear()">💾 Crear respaldo</button>
      <div id="bkUltimo" style="font-size:12px;color:var(--muted);margin-top:10px"></div>
      <div style="font-size:11px;color:var(--muted);margin-top:12px;border-top:1px solid var(--border);padding-top:10px">
        <b>Respaldo automático (cron):</b> programa en el servidor<br>
        <code id="bkCron" style="font-size:11px;word-break:break-all"></code>
      </div>
    </div>

    <!-- Google Drive -->
    <div class="bk-card">
      <h5>☁️ Google Drive <span id="bkDriveEstado" class="bk-estado bk-off" style="margin-left:6px">No conectado</span></h5>
      <p id="bkDriveInfo">Conecta una cuenta de Google para guardar los respaldos en Drive.</p>

      <label>Client ID (Google Cloud)</label>
      <input type="text" id="bkClientId" autocomplete="off" placeholder="xxxxxxxx.apps.googleusercontent.com">
      <label>Client Secret</label>
      <input type="password" id="bkClientSecret" autocomplete="new-password" placeholder="">
      <label>URI de redirección autorizada (cópiala en Google Cloud)</label>
      <div class="bk-uri"><span id="bkRedirect" style="flex:1"></span><button type="button" class="btn btn-sm btn-secondary" onclick="bkCopiarUri()">Copiar</button></div>
      <div style="display:flex;gap:10px">
        <div style="flex:2"><label>Carpeta en Drive</label><input type="text" id="bkCarpeta" placeholder="Respaldos VAMER"></div>
        <div style="flex:1"><label>Guardar en servidor</label><input type="number" id="bkRetencion" min="1" max="200" title="Cantidad de respaldos que se conservan en el servidor"></div>
      </div>
      <label style="display:flex;gap:6px;align-items:center;font-size:13px;color:var(--text)"><input type="checkbox" id="bkSubirAuto"> Subir a Drive automáticamente (respaldos programados y el checkbox de "Crear respaldo")</label>

      <div style="display:flex;gap:8px;flex-wrap:wrap;margin-top:14px">
        <button class="btn btn-secondary" onclick="bkGuardarConfig()">Guardar configuración</button>
        <button class="btn btn-primary" id="bkBtnConectar" onclick="bkConectar()">🔗 Conectar con Google</button>
        <button class="btn btn-danger" id="bkBtnDesconectar" onclick="bkDesconectar()" style="display:none">Desconectar</button>
      </div>

      <details style="margin-top:14px">
        <summary style="cursor:pointer;font-size:12px;color:var(--muted)">¿Cómo obtener el Client ID y Client Secret?</summary>
        <ol class="bk-pasos" style="padding-left:18px;margin:8px 0 0">
          <li>Entra a <code>console.cloud.google.com</code> y crea (o elige) un proyecto.</li>
          <li><b>APIs y servicios → Biblioteca</b>: habilita <b>Google Drive API</b>.</li>
          <li><b>Pantalla de consentimiento OAuth</b>: tipo "Externo", agrega tu correo como <i>usuario de prueba</i>. Para que la conexión no caduque, publica la app ("En producción").</li>
          <li><b>Credenciales → Crear credenciales → ID de cliente OAuth</b>, tipo <b>Aplicación web</b>.</li>
          <li>En <b>URI de redirección autorizados</b> pega la URI de arriba (debe ser idéntica).</li>
          <li>Copia el Client ID y el Client Secret aquí, pulsa <b>Guardar configuración</b> y luego <b>Conectar con Google</b>.</li>
        </ol>
      </details>
    </div>
  </div>

  <div class="bk-card">
    <h5>Historial de respaldos</h5>
    <p>Los archivos en el servidor se descargan desde aquí (no son accesibles por URL).</p>
    <div id="bkTabla"><p class="loading">Cargando...</p></div>
  </div>
</div>
