<?php
require_once __DIR__ . '/../config/db.php';

class CarnetModel {

    public static function dir(): string {
        $d = __DIR__ . '/../assets/uploads/carnets/';
        if (!is_dir($d)) @mkdir($d, 0755, true);
        return $d;
    }

    /** Empleados activos para el selector (con foto y si ya tienen carnet guardado). */
    public static function empleados(): array {
        return getDB()->query("
            SELECT e.id_empleado, CONCAT(e.nombres,' ',e.apellidos) AS nombre, e.puesto, e.empresa_id, e.foto,
                   emp.nombre AS empresa, d.nombre AS departamento, (c.id_carnet IS NOT NULL) AS tiene_carnet
            FROM empleados e
            LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id
            LEFT JOIN departamentos d ON d.id_departamento = e.departamento_id
            LEFT JOIN carnets c ON c.empleado_id = e.id_empleado
            WHERE e.estado = 'activo'
            ORDER BY e.nombres, e.apellidos")->fetchAll();
    }

    public static function empleado(int $id): ?array {
        $st = getDB()->prepare("
            SELECT e.id_empleado, e.nombres, e.apellidos, e.identidad, e.puesto, e.fecha_ingreso, e.telefono, e.foto, e.estado,
                   e.empresa_id, emp.nombre AS empresa, emp.direccion AS empresa_direccion, emp.telefono AS empresa_telefono,
                   d.nombre AS departamento
            FROM empleados e
            LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id
            LEFT JOIN departamentos d ON d.id_departamento = e.departamento_id
            WHERE e.id_empleado = ?");
        $st->execute([$id]);
        return $st->fetch() ?: null;
    }

    /** Devuelve el carnet del empleado; si no existe lo crea (con su token del QR). */
    public static function obtenerOCrear(int $empleadoId, ?int $uid): array {
        $pdo = getDB();
        $st = $pdo->prepare("SELECT * FROM carnets WHERE empleado_id = ?"); $st->execute([$empleadoId]);
        $c = $st->fetch();
        if (!$c) {
            $pdo->prepare("INSERT INTO carnets (empleado_id, token, usuario_id) VALUES (?,?,?)")
                ->execute([$empleadoId, bin2hex(random_bytes(16)), $uid]);
            $st->execute([$empleadoId]); $c = $st->fetch();
        }
        return $c;
    }

    public static function empresaConfig(?int $empresaId): array {
        $vacio = ['empresa_id' => $empresaId, 'nombre_mostrado' => null, 'logo' => null, 'firma' => null, 'firma_nombre' => null, 'firma_cargo' => 'Recursos Humanos', 'texto_reverso' => null];
        if (!$empresaId) return $vacio;
        $st = getDB()->prepare("SELECT * FROM carnets_empresa WHERE empresa_id = ?"); $st->execute([$empresaId]);
        return $st->fetch() ?: $vacio;
    }

    public static function guardar(int $empleadoId, array $d, ?int $uid): void {
        $c = self::obtenerOCrear($empleadoId, $uid);
        $plantillas = ['verde', 'azul'];
        $estilos = ['arial_bold', 'arial', 'georgia_bold', 'verdana_bold', 'trebuchet_bold'];
        $plantilla = in_array($d['plantilla'] ?? '', $plantillas, true) ? $d['plantilla'] : 'verde';
        $estilo = in_array($d['estilo_texto'] ?? '', $estilos, true) ? $d['estilo_texto'] : 'arial_bold';
        $tamano = in_array($d['tamano'] ?? '', ['std', 'grande'], true) ? $d['tamano'] : 'std';
        $hex = fn($v, $def) => preg_match('/^#[0-9a-fA-F]{6}$/', (string)$v) ? $v : $def;
        $txt = fn($v, $n) => ($t = trim((string)($v ?? ''))) === '' ? null : mb_substr($t, 0, $n);
        getDB()->prepare("UPDATE carnets SET plantilla=?, tamano=?, estilo_texto=?, color_texto=?, fondo_color=?, nombre_carnet=?, telefono_carnet=?,
                mostrar_identidad=?, mostrar_telefono=?, mostrar_ingreso=?, vigencia=?, usuario_id=? WHERE id_carnet=?")
            ->execute([$plantilla, $tamano, $estilo, ($d['color_texto'] ?? '') === '' ? null : $hex($d['color_texto'], null), $hex($d['fondo_color'] ?? '', '#ffffff'),
                $txt($d['nombre_carnet'] ?? null, 80), $txt($d['telefono_carnet'] ?? null, 30),
                !empty($d['mostrar_identidad']) ? 1 : 0, !empty($d['mostrar_telefono']) ? 1 : 0, !empty($d['mostrar_ingreso']) ? 1 : 0,
                preg_match('/^\d{4}-\d{2}-\d{2}$/', (string)($d['vigencia'] ?? '')) ? $d['vigencia'] : null,
                $uid, $c['id_carnet']]);
    }

    public static function guardarEmpresa(int $empresaId, array $d): void {
        $txt = fn($v, $n) => ($t = trim((string)($v ?? ''))) === '' ? null : mb_substr($t, 0, $n);
        getDB()->prepare("INSERT INTO carnets_empresa (empresa_id, nombre_mostrado, firma_nombre, firma_cargo, texto_reverso) VALUES (?,?,?,?,?)
            ON DUPLICATE KEY UPDATE nombre_mostrado=VALUES(nombre_mostrado), firma_nombre=VALUES(firma_nombre), firma_cargo=VALUES(firma_cargo), texto_reverso=VALUES(texto_reverso)")
            ->execute([$empresaId, $txt($d['nombre_mostrado'] ?? null, 100), $txt($d['firma_nombre'] ?? null, 100), $txt($d['firma_cargo'] ?? null, 100), $txt($d['texto_reverso'] ?? null, 400)]);
    }

    /** Guarda una imagen (data URL) como logo/firma de la empresa o fondo del carnet. */
    public static function guardarImagen(string $tipo, int $empleadoId, ?string $dataUrl): ?string {
        if (!in_array($tipo, ['logo', 'firma', 'fondo'], true)) throw new Exception('Tipo de imagen no válido.');
        $emp = self::empleado($empleadoId); if (!$emp) throw new Exception('Empleado no encontrado.');
        $pdo = getDB();
        if ($tipo === 'fondo') { $c = self::obtenerOCrear($empleadoId, null); $tabla = 'carnets'; $pk = 'id_carnet'; $id = (int)$c['id_carnet']; $col = 'fondo_imagen'; $actual = $c['fondo_imagen']; }
        else {
            if (!$emp['empresa_id']) throw new Exception('El empleado no tiene empresa asignada.');
            $cfg = self::empresaConfig((int)$emp['empresa_id']);
            $pdo->prepare("INSERT IGNORE INTO carnets_empresa (empresa_id) VALUES (?)")->execute([$emp['empresa_id']]);
            $tabla = 'carnets_empresa'; $pk = 'empresa_id'; $id = (int)$emp['empresa_id']; $col = $tipo; $actual = $cfg[$tipo] ?? null;
        }
        $nuevo = null;
        if ($dataUrl !== null) {
            if (!preg_match('#^data:image/(jpeg|png|webp);base64,(.+)$#s', $dataUrl, $m)) throw new Exception('Imagen no válida.');
            $bin = base64_decode($m[2], true);
            if ($bin === false || strlen($bin) > 3 * 1024 * 1024) throw new Exception('La imagen es inválida o supera 3 MB.');
            $info = @getimagesizeFromString($bin);
            $ext = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'][$info['mime'] ?? ''] ?? null;
            if (!$ext) throw new Exception('El archivo no es una imagen válida.');
            $nombre = "{$tipo}_{$id}_" . time() . ".$ext";
            if (@file_put_contents(self::dir() . $nombre, $bin) === false) throw new Exception('No se pudo guardar (revisa permisos de assets/uploads/carnets).');
            $nuevo = "assets/uploads/carnets/$nombre";
        }
        if ($actual && preg_match('#^(assets/)?uploads/carnets/[a-z]+_\d+_\d+\.(jpg|png|webp)$#', $actual) && is_file(__DIR__ . '/../' . $actual)) @unlink(__DIR__ . '/../' . $actual);
        $pdo->prepare("UPDATE $tabla SET $col = ? WHERE $pk = ?")->execute([$nuevo, $id]);
        return $nuevo;
    }

    /** Ficha pública por token del QR. */
    public static function fichaPorToken(string $token): ?array {
        if (!preg_match('/^[0-9a-f]{32}$/', $token)) return null;
        $st = getDB()->prepare("
            SELECT c.mostrar_identidad, c.mostrar_telefono, c.mostrar_ingreso, c.nombre_carnet, c.telefono_carnet,
                   e.nombres, e.apellidos, e.identidad, e.puesto, e.fecha_ingreso, e.telefono, e.foto, e.estado,
                   emp.nombre AS empresa, ce.nombre_mostrado, ce.logo, d.nombre AS departamento
            FROM carnets c
            JOIN empleados e ON e.id_empleado = c.empleado_id
            LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id
            LEFT JOIN carnets_empresa ce ON ce.empresa_id = e.empresa_id
            LEFT JOIN departamentos d ON d.id_departamento = e.departamento_id
            WHERE c.token = ?");
        $st->execute([$token]);
        return $st->fetch() ?: null;
    }
}
