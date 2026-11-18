<?php
// ============================================================
//  BackupModel — respaldo completo de la base de datos (PHP puro,
//  no depende de mysqldump) + subida a Google Drive (OAuth2).
// ============================================================
require_once __DIR__ . '/../config/db.php';

class BackupModel {

    const SCOPE = 'https://www.googleapis.com/auth/drive.file';

    public static function dir(): string {
        $d = __DIR__ . '/../backups/';
        if (!is_dir($d)) @mkdir($d, 0750, true);
        if (!file_exists($d . '.htaccess')) @file_put_contents($d . '.htaccess', "Require all denied\n<IfModule !mod_authz_core.c>\n  Order allow,deny\n  Deny from all\n</IfModule>\n");
        return $d;
    }

    // ── Configuración ────────────────────────────────────────
    public static function config(): array {
        $r = getDB()->query("SELECT * FROM backup_config WHERE id = 1")->fetch();
        return $r ?: ['id' => 1, 'drive_folder_nombre' => 'Respaldos VAMER', 'subir_auto' => 0, 'retencion_local' => 10];
    }

    public static function guardarConfig(array $d): void {
        $cur = self::config();
        $secret = trim((string)($d['google_client_secret'] ?? ''));
        if ($secret === '') $secret = $cur['google_client_secret'] ?? null;      // vacío = conservar
        $clientId = trim((string)($d['google_client_id'] ?? ''));
        $carpeta  = trim((string)($d['drive_folder_nombre'] ?? '')) ?: 'Respaldos VAMER';
        $ret = max(1, min(200, (int)($d['retencion_local'] ?? 10)));
        // Si cambia el cliente OAuth o la carpeta, se invalida el id de carpeta guardado
        $folderId = ($carpeta === ($cur['drive_folder_nombre'] ?? '')) ? ($cur['drive_folder_id'] ?? null) : null;
        getDB()->prepare("UPDATE backup_config SET google_client_id=?, google_client_secret=?, drive_folder_nombre=?, drive_folder_id=?, subir_auto=?, retencion_local=? WHERE id=1")
            ->execute([$clientId ?: null, $secret, $carpeta, $folderId, !empty($d['subir_auto']) ? 1 : 0, $ret]);
    }

    // ── Historial ────────────────────────────────────────────
    public static function listar(): array {
        return getDB()->query("
            SELECT b.*, u.nombre AS usuario_nombre
            FROM backup_historial b LEFT JOIN usuarios u ON u.id_usuario = b.usuario_id
            ORDER BY b.fecha DESC, b.id_backup DESC LIMIT 200")->fetchAll();
    }
    public static function obtener(int $id): ?array {
        $st = getDB()->prepare("SELECT * FROM backup_historial WHERE id_backup = ?"); $st->execute([$id]);
        return $st->fetch() ?: null;
    }
    public static function rutaArchivo(array $b): string { return self::dir() . basename($b['archivo']); }

    public static function eliminar(int $id): void {
        $b = self::obtener($id); if (!$b) throw new Exception('Respaldo no encontrado.');
        $f = self::rutaArchivo($b);
        if (is_file($f)) @unlink($f);
        getDB()->prepare("DELETE FROM backup_historial WHERE id_backup = ?")->execute([$id]);
    }

    // ── Respaldo ─────────────────────────────────────────────
    public static function crear(?int $usuario_id, string $tipo = 'manual', bool $subirDrive = false): array {
        @set_time_limit(0); @ignore_user_abort(true); @ini_set('memory_limit', '512M');
        $pdo = getDB();
        $gz  = function_exists('gzopen');
        $nombre = 'vamer_backup_' . date('Ymd_His') . '.sql' . ($gz ? '.gz' : '');
        $ruta = self::dir() . $nombre;
        $h = $gz ? @gzopen($ruta, 'wb6') : @fopen($ruta, 'wb');
        if (!$h) throw new Exception('No se pudo crear el archivo en la carpeta backups/ (revisa permisos de escritura).');
        $w = fn(string $s) => $gz ? gzwrite($h, $s) : fwrite($h, $s);

        $tablas = 0; $filas = 0;
        try {
            $db = DB_NAME;
            $w("-- ============================================================\n-- Respaldo completo de `$db`\n-- Generado: " . date('Y-m-d H:i:s') . "\n-- Sistema Administrativo VAMER\n-- ============================================================\n\n");
            $w("SET NAMES utf8mb4;\nSET FOREIGN_KEY_CHECKS=0;\nSET UNIQUE_CHECKS=0;\nSET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';\nSET time_zone='+00:00';\n\n");

            $objetos = $pdo->query("SHOW FULL TABLES")->fetchAll(PDO::FETCH_NUM);
            $bases = []; $vistas = [];
            foreach ($objetos as $o) { if (strtoupper($o[1]) === 'VIEW') $vistas[] = $o[0]; else $bases[] = $o[0]; }

            foreach ($bases as $t) {
                $q = '`' . str_replace('`', '``', $t) . '`';
                $create = $pdo->query("SHOW CREATE TABLE $q")->fetch(PDO::FETCH_NUM)[1];
                $w("-- ----------------------------\n-- Tabla $q\n-- ----------------------------\nDROP TABLE IF EXISTS $q;\n$create;\n\n");
                $tablas++;
                $filas += self::volcarFilas($pdo, $t, $q, $w);
            }
            foreach ($vistas as $v) {
                $q = '`' . str_replace('`', '``', $v) . '`';
                try {
                    $row = $pdo->query("SHOW CREATE VIEW $q")->fetch(PDO::FETCH_NUM);
                    $sql = preg_replace('/DEFINER=`[^`]*`@`[^`]*`\s*/i', '', $row[1]);
                    $sql = preg_replace('/SQL SECURITY DEFINER/i', 'SQL SECURITY INVOKER', $sql);
                    $w("-- Vista $q\nDROP VIEW IF EXISTS $q;\n$sql;\n\n");
                } catch (Throwable $e) { $w("-- (No se pudo respaldar la vista $q: " . str_replace("\n", ' ', $e->getMessage()) . ")\n\n"); }
            }
            self::volcarTriggersYRutinas($pdo, $w);
            $w("SET FOREIGN_KEY_CHECKS=1;\nSET UNIQUE_CHECKS=1;\n\n-- Respaldo completado: $tablas tablas, $filas filas\n");
        } catch (Throwable $e) {
            $gz ? gzclose($h) : fclose($h);
            @unlink($ruta);
            self::registrar($nombre, 0, 0, 0, $tipo, 'error', mb_substr($e->getMessage(), 0, 480), false, $usuario_id);
            throw new Exception('Error al generar el respaldo: ' . $e->getMessage());
        }
        $gz ? gzclose($h) : fclose($h);
        clearstatcache(true, $ruta);
        $tam = (int)@filesize($ruta);
        if ($tam < 200) { @unlink($ruta); throw new Exception('El archivo de respaldo quedó vacío.'); }

        $id = self::registrar($nombre, $tam, $tablas, $filas, $tipo, 'ok', null, true, $usuario_id);
        $resultado = ['id' => $id, 'archivo' => $nombre, 'tamano' => $tam, 'tablas' => $tablas, 'filas' => $filas, 'drive' => null];

        if ($subirDrive) {
            try { self::subirADrive($id); $resultado['drive'] = true; }
            catch (Throwable $e) { $resultado['drive'] = false; $resultado['drive_error'] = $e->getMessage(); }
        }
        self::limpiarLocales();
        return $resultado;
    }

    private static function registrar(string $archivo, int $tam, int $tablas, int $filas, string $tipo, string $estado, ?string $msg, bool $local, ?int $uid): int {
        $pdo = getDB();
        $pdo->prepare("INSERT INTO backup_historial (archivo, tamano, tablas, filas, tipo, estado, mensaje, local_existe, usuario_id) VALUES (?,?,?,?,?,?,?,?,?)")
            ->execute([$archivo, $tam, $tablas, $filas, $tipo, $estado, $msg, $local ? 1 : 0, $uid]);
        return (int)$pdo->lastInsertId();
    }

    private static function volcarFilas(PDO $pdo, string $t, string $q, callable $w): int {
        // Columnas binarias → hexadecimal
        $bin = [];
        foreach ($pdo->query("SHOW COLUMNS FROM $q")->fetchAll() as $i => $c) $bin[$i] = (bool)preg_match('/blob|binary/i', $c['Type']);
        $total = 0; $buf = []; $bytes = 0;
        $flush = function () use (&$buf, &$bytes, $q, $w) {
            if ($buf) { $w("INSERT INTO $q VALUES\n" . implode(",\n", $buf) . ";\n"); $buf = []; $bytes = 0; }
        };
        $pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);
        try {
            $st = $pdo->query("SELECT * FROM $q");
            while ($r = $st->fetch(PDO::FETCH_NUM)) {
                $vals = [];
                foreach ($r as $i => $v) {
                    if ($v === null) $vals[] = 'NULL';
                    elseif (!empty($bin[$i])) $vals[] = $v === '' ? "''" : '0x' . bin2hex($v);
                    else $vals[] = $pdo->quote((string)$v);
                }
                $row = '(' . implode(',', $vals) . ')';
                $buf[] = $row; $bytes += strlen($row); $total++;
                if (count($buf) >= 250 || $bytes > 900000) $flush();
            }
            $st->closeCursor();
        } finally {
            $pdo->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, true);
        }
        $flush();
        if ($total) $w("\n");
        return $total;
    }

    private static function volcarTriggersYRutinas(PDO $pdo, callable $w): void {
        try {
            $tr = $pdo->query("SHOW TRIGGERS")->fetchAll();
            if ($tr) $w("DELIMITER $$\n");
            foreach ($tr as $t) {
                $n = '`' . str_replace('`', '``', $t['Trigger']) . '`';
                $row = $pdo->query("SHOW CREATE TRIGGER $n")->fetch(PDO::FETCH_NUM);
                $sql = preg_replace('/DEFINER=`[^`]*`@`[^`]*`\s*/i', '', $row[2] ?? '');
                if ($sql) $w("DROP TRIGGER IF EXISTS $n$$\n$sql$$\n\n");
            }
            if ($tr) $w("DELIMITER ;\n\n");
        } catch (Throwable $e) { $w("-- (No se pudieron respaldar los triggers)\n\n"); }
        try {
            $st = $pdo->prepare("SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = ?");
            $st->execute([DB_NAME]); $rs = $st->fetchAll();
            if ($rs) $w("DELIMITER $$\n");
            foreach ($rs as $r) {
                $tipo = strtoupper($r['ROUTINE_TYPE']) === 'PROCEDURE' ? 'PROCEDURE' : 'FUNCTION';
                $n = '`' . str_replace('`', '``', $r['ROUTINE_NAME']) . '`';
                $row = $pdo->query("SHOW CREATE $tipo $n")->fetch(PDO::FETCH_NUM);
                $sql = preg_replace('/DEFINER=`[^`]*`@`[^`]*`\s*/i', '', $row[2] ?? '');
                if ($sql) $w("DROP $tipo IF EXISTS $n$$\n$sql$$\n\n");
            }
            if ($rs) $w("DELIMITER ;\n\n");
        } catch (Throwable $e) { $w("-- (No se pudieron respaldar procedimientos/funciones)\n\n"); }
    }

    /** Conserva solo los N respaldos más recientes en el servidor (los de Drive no se tocan). */
    public static function limpiarLocales(): void {
        $n = max(1, (int)(self::config()['retencion_local'] ?? 10));
        $pdo = getDB();
        $ids = $pdo->query("SELECT id_backup, archivo FROM backup_historial WHERE local_existe = 1 AND estado = 'ok' ORDER BY fecha DESC, id_backup DESC")->fetchAll();
        foreach (array_slice($ids, $n) as $b) {
            $f = self::dir() . basename($b['archivo']);
            if (is_file($f)) @unlink($f);
            $pdo->prepare("UPDATE backup_historial SET local_existe = 0 WHERE id_backup = ?")->execute([$b['id_backup']]);
        }
    }

    // ── Google Drive ─────────────────────────────────────────
    private static function http(string $method, string $url, array $headers = [], $body = null, array $extra = []): array {
        if (!function_exists('curl_init')) throw new Exception('El servidor no tiene la extensión cURL de PHP habilitada.');
        $ch = curl_init($url);
        $hdr = [];
        curl_setopt_array($ch, [
            CURLOPT_CUSTOMREQUEST => $method, CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 3600, CURLOPT_CONNECTTIMEOUT => 20,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_HEADERFUNCTION => function ($c, $l) use (&$hdr) { $p = explode(':', $l, 2); if (count($p) === 2) $hdr[strtolower(trim($p[0]))] = trim($p[1]); return strlen($l); },
        ] + $extra);
        if ($body !== null && !isset($extra[CURLOPT_UPLOAD])) curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        $res = curl_exec($ch);
        if ($res === false) { $e = curl_error($ch); curl_close($ch); throw new Exception('No se pudo conectar con Google: ' . $e); }
        $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE); curl_close($ch);
        return ['code' => $code, 'body' => (string)$res, 'json' => json_decode((string)$res, true), 'headers' => $hdr];
    }

    private static function errorGoogle(array $r): string {
        $j = $r['json'] ?? [];
        $m = $j['error_description'] ?? ($j['error']['message'] ?? ($j['error'] ?? ''));
        if (is_array($m)) $m = json_encode($m);
        return 'Google respondió ' . $r['code'] . ($m ? ': ' . $m : '');
    }

    public static function driveConectado(?array $cfg = null): bool {
        $cfg = $cfg ?? self::config();
        return !empty($cfg['google_refresh_token']) && !empty($cfg['google_client_id']) && !empty($cfg['google_client_secret']);
    }

    public static function urlAutorizacion(string $redirectUri, string $state): string {
        $cfg = self::config();
        if (empty($cfg['google_client_id']) || empty($cfg['google_client_secret'])) throw new Exception('Guarda primero el Client ID y el Client Secret de Google.');
        return 'https://accounts.google.com/o/oauth2/v2/auth?' . http_build_query([
            'client_id' => $cfg['google_client_id'], 'redirect_uri' => $redirectUri, 'response_type' => 'code',
            'scope' => self::SCOPE, 'access_type' => 'offline', 'prompt' => 'consent', 'state' => $state,
        ]);
    }

    public static function intercambiarCodigo(string $code, string $redirectUri): void {
        $cfg = self::config();
        $r = self::http('POST', 'https://oauth2.googleapis.com/token', ['Content-Type: application/x-www-form-urlencoded'], http_build_query([
            'code' => $code, 'client_id' => $cfg['google_client_id'], 'client_secret' => $cfg['google_client_secret'],
            'redirect_uri' => $redirectUri, 'grant_type' => 'authorization_code',
        ]));
        if ($r['code'] !== 200 || empty($r['json']['access_token'])) throw new Exception(self::errorGoogle($r));
        if (empty($r['json']['refresh_token'])) throw new Exception('Google no devolvió el permiso de acceso continuo. Quita el acceso de la app en tu cuenta de Google (myaccount.google.com/permissions) e inténtalo de nuevo.');
        $email = null;
        $a = self::http('GET', 'https://www.googleapis.com/drive/v3/about?fields=user(emailAddress)', ['Authorization: Bearer ' . $r['json']['access_token']]);
        if ($a['code'] === 200) $email = $a['json']['user']['emailAddress'] ?? null;
        getDB()->prepare("UPDATE backup_config SET google_refresh_token = ?, google_email = ?, drive_folder_id = NULL WHERE id = 1")->execute([$r['json']['refresh_token'], $email]);
    }

    public static function desconectar(): void {
        getDB()->prepare("UPDATE backup_config SET google_refresh_token = NULL, google_email = NULL, drive_folder_id = NULL WHERE id = 1")->execute();
    }

    private static function accessToken(array $cfg): string {
        $r = self::http('POST', 'https://oauth2.googleapis.com/token', ['Content-Type: application/x-www-form-urlencoded'], http_build_query([
            'client_id' => $cfg['google_client_id'], 'client_secret' => $cfg['google_client_secret'],
            'refresh_token' => $cfg['google_refresh_token'], 'grant_type' => 'refresh_token',
        ]));
        if ($r['code'] !== 200 || empty($r['json']['access_token'])) throw new Exception('No se pudo renovar el acceso a Google Drive (' . self::errorGoogle($r) . '). Vuelve a conectar la cuenta.');
        return $r['json']['access_token'];
    }

    private static function carpetaDrive(array $cfg, string $token): string {
        $auth = ['Authorization: Bearer ' . $token];
        if (!empty($cfg['drive_folder_id'])) {
            $r = self::http('GET', 'https://www.googleapis.com/drive/v3/files/' . rawurlencode($cfg['drive_folder_id']) . '?fields=id,trashed', $auth);
            if ($r['code'] === 200 && empty($r['json']['trashed'])) return $cfg['drive_folder_id'];
        }
        $nombre = $cfg['drive_folder_nombre'] ?: 'Respaldos VAMER';
        $q = "name = '" . str_replace(["\\", "'"], ["\\\\", "\\'"], $nombre) . "' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
        $r = self::http('GET', 'https://www.googleapis.com/drive/v3/files?' . http_build_query(['q' => $q, 'fields' => 'files(id)', 'pageSize' => 1]), $auth);
        $id = ($r['code'] === 200) ? ($r['json']['files'][0]['id'] ?? null) : null;
        if (!$id) {
            $r = self::http('POST', 'https://www.googleapis.com/drive/v3/files?fields=id', array_merge($auth, ['Content-Type: application/json']),
                json_encode(['name' => $nombre, 'mimeType' => 'application/vnd.google-apps.folder']));
            if ($r['code'] !== 200 || empty($r['json']['id'])) throw new Exception('No se pudo crear la carpeta en Drive (' . self::errorGoogle($r) . ').');
            $id = $r['json']['id'];
        }
        getDB()->prepare("UPDATE backup_config SET drive_folder_id = ? WHERE id = 1")->execute([$id]);
        return $id;
    }

    public static function subirADrive(int $idBackup): void {
        @set_time_limit(0);
        $cfg = self::config();
        if (!self::driveConectado($cfg)) throw new Exception('Google Drive no está conectado.');
        $b = self::obtener($idBackup); if (!$b) throw new Exception('Respaldo no encontrado.');
        $ruta = self::rutaArchivo($b);
        if (!is_file($ruta)) throw new Exception('El archivo ya no existe en el servidor.');
        $token  = self::accessToken($cfg);
        $folder = self::carpetaDrive($cfg, $token);
        $mime = substr($b['archivo'], -3) === '.gz' ? 'application/gzip' : 'application/sql';
        $size = filesize($ruta);

        // 1) Sesión de subida reanudable
        $r = self::http('POST', 'https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable&fields=id', [
            'Authorization: Bearer ' . $token, 'Content-Type: application/json; charset=UTF-8',
            'X-Upload-Content-Type: ' . $mime, 'X-Upload-Content-Length: ' . $size,
        ], json_encode(['name' => $b['archivo'], 'parents' => [$folder], 'description' => 'Respaldo base de datos VAMER']));
        $url = $r['headers']['location'] ?? '';
        if ($r['code'] !== 200 || !$url) throw new Exception('No se pudo iniciar la subida a Drive (' . self::errorGoogle($r) . ').');

        // 2) Contenido (en flujo, sin cargar el archivo en memoria)
        $fh = fopen($ruta, 'rb');
        try {
            $r = self::http('PUT', $url, ['Content-Type: ' . $mime, 'Content-Length: ' . $size], null,
                [CURLOPT_UPLOAD => true, CURLOPT_INFILE => $fh, CURLOPT_INFILESIZE => $size]);
        } finally { fclose($fh); }
        if (!in_array($r['code'], [200, 201], true) || empty($r['json']['id'])) throw new Exception('Falló la subida a Drive (' . self::errorGoogle($r) . ').');

        getDB()->prepare("UPDATE backup_historial SET drive_subido = 1, drive_file_id = ? WHERE id_backup = ?")->execute([$r['json']['id'], $idBackup]);
    }
}
