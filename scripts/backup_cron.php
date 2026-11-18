<?php
// ============================================================
//  Respaldo automático — ejecutar desde cron (solo línea de comandos).
//  Ejemplo (todos los días 2:00 a.m.):
//    0 2 * * * /usr/bin/php /ruta/al/sistema/scripts/backup_cron.php >> /ruta/al/sistema/backups/cron.log 2>&1
//  Sube a Google Drive si está conectado y activada la opción "Subir a Drive".
// ============================================================
if (PHP_SAPI !== 'cli') { http_response_code(403); exit('Solo línea de comandos.'); }
require_once __DIR__ . '/../models/BackupModel.php';
try {
    $subir = BackupModel::driveConectado() && !empty(BackupModel::config()['subir_auto']);
    $r = BackupModel::crear(null, 'automatico', $subir);
    echo date('Y-m-d H:i:s') . " OK {$r['archivo']} ({$r['tablas']} tablas, {$r['filas']} filas)"
       . ($subir ? ($r['drive'] ? ' + Drive' : ' | Drive falló: ' . ($r['drive_error'] ?? '')) : '') . "\n";
} catch (Throwable $e) { fwrite(STDERR, date('Y-m-d H:i:s') . ' ERROR ' . $e->getMessage() . "\n"); exit(1); }
