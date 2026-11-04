<?php
// ============================================================
//  VAMER — MarcacionModel
//  Asistencia diaria: hora de entrada / salida por empleado.
//  El estado de cada día (puntual, tardanza, ausente...) se
//  CALCULA aquí a partir del horario configurado.
// ============================================================
require_once __DIR__ . '/../config/db.php';

class MarcacionModel {

    const ORIGENES = ['manual', 'app_movil', 'biometrico', 'importado'];

    // ── Configuración ─────────────────────────────────────
    public static function config(): array {
        $c = getDB()->query("SELECT * FROM marcaciones_config WHERE id = 1")->fetch();
        if (!$c) {
            $c = ['id' => 1, 'hora_entrada' => '08:00:00', 'hora_salida' => '17:00:00', 'almuerzo_min' => 60,
                  'trabaja_sabado' => 1, 'sabado_entrada' => '08:00:00', 'sabado_salida' => '12:00:00', 'tolerancia_min' => 5];
        }
        foreach (['hora_entrada', 'hora_salida', 'sabado_entrada', 'sabado_salida'] as $k) $c[$k] = substr($c[$k], 0, 5);
        $c['almuerzo_min'] = (int)$c['almuerzo_min'];
        $c['tolerancia_min'] = (int)$c['tolerancia_min'];
        $c['trabaja_sabado'] = (int)$c['trabaja_sabado'];
        return $c;
    }

    public static function guardarConfig(array $d): void {
        $he = self::horaValida($d['hora_entrada'] ?? '');   $hs = self::horaValida($d['hora_salida'] ?? '');
        $se = self::horaValida($d['sabado_entrada'] ?? ''); $ss = self::horaValida($d['sabado_salida'] ?? '');
        if (!$he || !$hs || !$se || !$ss) throw new Exception('Horas inválidas (formato HH:MM).');
        if (self::min($hs) <= self::min($he)) throw new Exception('La hora de salida debe ser mayor a la de entrada.');
        if (self::min($ss) <= self::min($se)) throw new Exception('La salida del sábado debe ser mayor a la entrada.');
        $alm = max(0, min(240, (int)($d['almuerzo_min'] ?? 60)));
        $tol = max(0, min(60,  (int)($d['tolerancia_min'] ?? 5)));
        $sab = !empty($d['trabaja_sabado']) ? 1 : 0;
        $pdo = getDB();
        $pdo->prepare("INSERT INTO marcaciones_config (id, hora_entrada, hora_salida, almuerzo_min, trabaja_sabado, sabado_entrada, sabado_salida, tolerancia_min)
                       VALUES (1,?,?,?,?,?,?,?)
                       ON DUPLICATE KEY UPDATE hora_entrada=VALUES(hora_entrada), hora_salida=VALUES(hora_salida), almuerzo_min=VALUES(almuerzo_min),
                         trabaja_sabado=VALUES(trabaja_sabado), sabado_entrada=VALUES(sabado_entrada), sabado_salida=VALUES(sabado_salida), tolerancia_min=VALUES(tolerancia_min)")
            ->execute([$he, $hs, $alm, $sab, $se, $ss, $tol]);
    }

    // ── Utilidades de hora ────────────────────────────────
    /** Devuelve 'HH:MM' si es válida, o null. */
    public static function horaValida($h): ?string {
        $h = trim((string)$h);
        if (!preg_match('/^([01]?\d|2[0-3]):([0-5]\d)(:[0-5]\d)?$/', $h, $m)) return null;
        return str_pad($m[1], 2, '0', STR_PAD_LEFT) . ':' . $m[2];
    }
    public static function min(?string $h): ?int {
        if ($h === null || $h === '') return null;
        $p = explode(':', $h);
        return ((int)$p[0]) * 60 + (int)($p[1] ?? 0);
    }

    // ── Cálculo del estado de un día ──────────────────────
    /**
     * @param array|null $row  fila de marcaciones (o null si no hay)
     * @return array  est, e, s, min_tarde, min_ant, min_trab, min_extra, ...
     * est: puntual | tardanza | salida_anticipada | falta_salida | ausente | justificado
     *      | inhabil | pendiente | futuro | na
     */
    public static function estadoDia(array $cfg, string $fecha, string $hoy, ?array $row, ?string $fechaIngreso): array {
        $dow = (int)(new DateTime($fecha))->format('w'); // 0 = domingo
        $base = ['est' => 'inhabil', 'e' => null, 's' => null, 'min_tarde' => 0, 'min_ant' => 0, 'min_trab' => 0, 'min_extra' => 0,
                 'origen' => null, 'obs' => null, 'justificado' => false, 'just' => null, 'id' => null, 'editor' => null, 'fecha_edicion' => null];

        if ($fechaIngreso && $fecha < $fechaIngreso) { $base['est'] = 'na'; return $base; }

        $laborable = $dow !== 0 && !($dow === 6 && !$cfg['trabaja_sabado']);
        $progE = $dow === 6 ? $cfg['sabado_entrada'] : $cfg['hora_entrada'];
        $progS = $dow === 6 ? $cfg['sabado_salida']  : $cfg['hora_salida'];
        $tol   = $cfg['tolerancia_min'];

        if (!$row) {
            if (!$laborable)     $base['est'] = 'inhabil';
            elseif ($fecha > $hoy)  $base['est'] = 'futuro';
            elseif ($fecha === $hoy) $base['est'] = 'pendiente';
            else                  $base['est'] = 'ausente';
            return $base;
        }

        $e = $row['hora_entrada'] ? substr($row['hora_entrada'], 0, 5) : null;
        $s = $row['hora_salida']  ? substr($row['hora_salida'], 0, 5)  : null;
        $just = (int)$row['justificado'] === 1;
        $base['e'] = $e; $base['s'] = $s;
        $base['origen'] = $row['origen']; $base['obs'] = $row['observacion'];
        $base['justificado'] = $just; $base['just'] = $row['justificacion'];
        $base['id'] = (int)$row['id_marcacion'];
        $base['editor'] = $row['editor'] ?? null; $base['fecha_edicion'] = $row['fecha_edicion'] ?: ($row['fecha_creacion'] ?? null);

        $mE = self::min($e); $mS = self::min($s);

        if ($mE === null && $mS === null) {            // fila solo de justificación
            if ($just)               $base['est'] = 'justificado';
            elseif (!$laborable)     $base['est'] = 'inhabil';
            elseif ($fecha < $hoy)   $base['est'] = 'ausente';
            else                     $base['est'] = 'pendiente';
            return $base;
        }

        // Horas trabajadas (lunes a viernes se descuenta el almuerzo)
        if ($mE !== null && $mS !== null && $mS > $mE) {
            $span = $mS - $mE;
            if ($dow >= 1 && $dow <= 5 && $span >= 300) $span -= $cfg['almuerzo_min'];
            $base['min_trab'] = max(0, $span);
        }
        if ($laborable) {
            $pE = self::min($progE); $pS = self::min($progS);
            if ($mE !== null) $base['min_tarde'] = max(0, $mE - $pE);
            if ($mS !== null) {
                $base['min_extra'] = max(0, $mS - $pS);
                $base['min_ant']   = max(0, $pS - $mS);
            }
            $tardanza = $base['min_tarde'] > $tol;
            $salAnt   = $mS !== null && $base['min_ant'] > $tol;
            $faltaSal = $mS === null && $fecha < $hoy;
            if ($just)          $base['est'] = 'justificado';
            elseif ($tardanza)  $base['est'] = 'tardanza';
            elseif ($salAnt)    $base['est'] = 'salida_anticipada';
            elseif ($faltaSal)  $base['est'] = 'falta_salida';
            else                $base['est'] = 'puntual';
        } else {
            // Trabajó en día inhábil: todo lo trabajado cuenta como extra
            $base['min_extra'] = $base['min_trab'];
            $base['est'] = $just ? 'justificado' : 'puntual';
        }
        return $base;
    }

    // ── Empleados y departamentos ─────────────────────────
    public static function departamentos(): array {
        return getDB()->query("SELECT id_departamento, nombre FROM departamentos ORDER BY nombre")->fetchAll();
    }

    public static function empleadosActivos(): array {
        return getDB()->query("
            SELECT e.id_empleado, CONCAT(e.nombres,' ',e.apellidos) AS nombre, e.puesto, e.empresa_id, e.departamento_id
            FROM empleados e WHERE e.estado='activo' ORDER BY e.nombres, e.apellidos
        ")->fetchAll();
    }

    // ── Período (quincena / mes / día) ────────────────────
    public static function periodo(string $desde, string $hasta, string $hoy, int $empresa_id = 0, int $departamento_id = 0): array {
        $cfg = self::config();
        $pdo = getDB();

        $dias = [];
        $d = new DateTime($desde); $fin = new DateTime($hasta);
        while ($d <= $fin) {
            $dias[] = ['fecha' => $d->format('Y-m-d'), 'dow' => (int)$d->format('w')];
            $d->modify('+1 day');
        }

        $sql = "SELECT e.id_empleado, CONCAT(e.nombres,' ',e.apellidos) AS nombre, e.puesto, e.fecha_ingreso,
                       e.empresa_id, e.departamento_id, dep.nombre AS departamento
                FROM empleados e
                LEFT JOIN departamentos dep ON dep.id_departamento = e.departamento_id
                WHERE e.estado = 'activo'";
        $p = [];
        if ($empresa_id)      { $sql .= ' AND e.empresa_id = ?';      $p[] = $empresa_id; }
        if ($departamento_id) { $sql .= ' AND e.departamento_id = ?'; $p[] = $departamento_id; }
        $sql .= ' ORDER BY e.nombres, e.apellidos';
        $st = $pdo->prepare($sql); $st->execute($p);
        $emps = $st->fetchAll();

        $marcas = [];
        if ($emps) {
            $ids = array_column($emps, 'id_empleado');
            $in  = implode(',', array_fill(0, count($ids), '?'));
            $q = $pdo->prepare("SELECT m.*, u.nombre AS editor FROM marcaciones m
                                LEFT JOIN usuarios u ON u.id_usuario = COALESCE(m.editado_por, m.usuario_id)
                                WHERE m.fecha BETWEEN ? AND ? AND m.empleado_id IN ($in)");
            $q->execute(array_merge([$desde, $hasta], $ids));
            foreach ($q->fetchAll() as $r) $marcas[(int)$r['empleado_id']][$r['fecha']] = $r;
        }

        $kTard = 0; $kAus = 0; $kDen = 0;
        $salida = [];
        foreach ($emps as $e) {
            $id = (int)$e['id_empleado'];
            $celdas = []; $tard = 0; $aus = 0; $den = 0; $minTrab = 0;
            foreach ($dias as $dia) {
                $c = self::estadoDia($cfg, $dia['fecha'], $hoy, $marcas[$id][$dia['fecha']] ?? null, $e['fecha_ingreso']);
                $celdas[$dia['fecha']] = $c;
                $minTrab += $c['min_trab'];
                if ($c['est'] === 'tardanza') $tard++;
                if ($c['est'] === 'ausente')  $aus++;
                if (!in_array($c['est'], ['inhabil', 'pendiente', 'futuro', 'na'], true)) $den++;
            }
            $salida[] = [
                'id' => $id, 'nombre' => $e['nombre'], 'puesto' => $e['puesto'], 'departamento' => $e['departamento'],
                'celdas' => $celdas,
                'tot' => ['min_trab' => $minTrab, 'tardanzas' => $tard, 'ausencias' => $aus, 'dias' => $den,
                          'asistencia' => $den > 0 ? (int)round((($den - $aus) / $den) * 100) : null],
            ];
            $kTard += $tard; $kAus += $aus; $kDen += $den;
        }
        return [
            'config' => $cfg, 'dias' => $dias, 'empleados' => $salida,
            'kpis' => ['tardanzas' => $kTard, 'ausencias' => $kAus,
                       'asistencia' => $kDen > 0 ? (int)round((($kDen - $kAus) / $kDen) * 100) : null],
        ];
    }

    // ── Escritura ─────────────────────────────────────────
    private static function empleadoExiste(int $id): void {
        $st = getDB()->prepare("SELECT 1 FROM empleados WHERE id_empleado = ? AND estado = 'activo'");
        $st->execute([$id]);
        if (!$st->fetch()) throw new Exception('Empleado no encontrado o inactivo.');
    }
    private static function fechaValida(string $f): void {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $f) || !strtotime($f)) throw new Exception('Fecha inválida.');
    }
    private static function fila(int $empleado_id, string $fecha): ?array {
        $st = getDB()->prepare("SELECT * FROM marcaciones WHERE empleado_id = ? AND fecha = ?");
        $st->execute([$empleado_id, $fecha]);
        return $st->fetch() ?: null;
    }

    /** Crea o corrige la marca de un empleado en un día. */
    public static function guardar(array $d, int $uid): void {
        $emp = (int)($d['empleado_id'] ?? 0); $fecha = trim($d['fecha'] ?? '');
        self::empleadoExiste($emp); self::fechaValida($fecha);
        $e = trim((string)($d['hora_entrada'] ?? '')) === '' ? null : self::horaValida($d['hora_entrada']);
        $s = trim((string)($d['hora_salida']  ?? '')) === '' ? null : self::horaValida($d['hora_salida']);
        if (trim((string)($d['hora_entrada'] ?? '')) !== '' && !$e) throw new Exception('Hora de entrada inválida.');
        if (trim((string)($d['hora_salida']  ?? '')) !== '' && !$s) throw new Exception('Hora de salida inválida.');
        if ($e === null && $s === null) throw new Exception('Indica al menos la hora de entrada.');
        if ($e === null && $s !== null) throw new Exception('No puede haber salida sin hora de entrada.');
        if ($s !== null && self::min($s) <= self::min($e)) throw new Exception('La hora de salida debe ser mayor a la de entrada.');
        $origen = in_array($d['origen'] ?? 'manual', self::ORIGENES, true) ? $d['origen'] : 'manual';
        $obs = mb_substr(trim((string)($d['observacion'] ?? '')), 0, 255);
        $obs = $obs === '' ? null : $obs;

        $pdo = getDB();
        if (self::fila($emp, $fecha)) {
            $pdo->prepare("UPDATE marcaciones SET hora_entrada=?, hora_salida=?, origen=?, observacion=?, editado_por=?, fecha_edicion=NOW()
                           WHERE empleado_id=? AND fecha=?")->execute([$e, $s, $origen, $obs, $uid, $emp, $fecha]);
        } else {
            $pdo->prepare("INSERT INTO marcaciones (empleado_id, fecha, hora_entrada, hora_salida, origen, observacion, usuario_id)
                           VALUES (?,?,?,?,?,?,?)")->execute([$emp, $fecha, $e, $s, $origen, $obs, $uid]);
        }
    }

    /**
     * Alimenta "Tiempo Extra y Faltas" (asistencia_registros) con las horas extra y
     * ausencias injustificadas del período. $aplicar=false solo devuelve la vista previa.
     */
    const PREFIJO_SYNC = 'Asistencia diaria';
    public static function sincronizarTiempoExtra(array $d, int $uid, bool $aplicar): array {
        $desde = trim($d['desde'] ?? ''); $hasta = trim($d['hasta'] ?? ''); $hoy = trim($d['hoy'] ?? '');
        self::fechaValida($desde); self::fechaValida($hasta); self::fechaValida($hoy);
        if ($hasta < $desde) throw new Exception('Rango inválido.');
        $incExtra = !empty($d['incluir_extra']); $incFalt = !empty($d['incluir_faltas']);
        if (!$incExtra && !$incFalt) throw new Exception('Elige qué enviar: horas extra y/o faltas.');
        $minimo = max(1, (int)($d['min_extra_minimo'] ?? 30));
        $per = self::periodo($desde, $hasta, $hoy, (int)($d['empresa_id'] ?? 0), (int)($d['departamento_id'] ?? 0));

        $items = [];
        foreach ($per['empleados'] as $e) {
            foreach ($e['celdas'] as $fecha => $c) {
                if ($incExtra && $c['min_extra'] >= $minimo && $c['s'])
                    $items[] = ['empleado_id' => $e['id'], 'empleado' => $e['nombre'], 'fecha' => $fecha, 'tipo' => 'horas_extra',
                                'cantidad' => round($c['min_extra'] / 60, 2), 'motivo' => self::PREFIJO_SYNC . ': salida ' . $c['s']];
                if ($incFalt && $c['est'] === 'ausente')
                    $items[] = ['empleado_id' => $e['id'], 'empleado' => $e['nombre'], 'fecha' => $fecha, 'tipo' => 'dia_faltado',
                                'cantidad' => 1, 'motivo' => self::PREFIJO_SYNC . ': ausente'];
            }
        }
        $pdo = getDB();
        $ex = [];
        if ($items) {
            $ids = array_values(array_unique(array_column($items, 'empleado_id')));
            $in = implode(',', array_fill(0, count($ids), '?'));
            $q = $pdo->prepare("SELECT * FROM asistencia_registros WHERE fecha BETWEEN ? AND ? AND empleado_id IN ($in)");
            $q->execute(array_merge([$desde, $hasta], $ids));
            foreach ($q->fetchAll() as $r) $ex[$r['empleado_id'] . '|' . $r['fecha'] . '|' . $r['tipo']] = $r;
        }
        $res = ['nuevo' => 0, 'actualiza' => 0, 'igual' => 0, 'en_planilla' => 0, 'manual' => 0];
        if ($aplicar) $pdo->beginTransaction();
        try {
            foreach ($items as &$it) {
                $r = $ex[$it['empleado_id'] . '|' . $it['fecha'] . '|' . $it['tipo']] ?? null;
                if (!$r) $it['accion'] = 'nuevo';
                elseif ($r['planilla_id']) $it['accion'] = 'en_planilla';
                elseif (strpos((string)$r['motivo'], self::PREFIJO_SYNC) !== 0) $it['accion'] = 'manual';
                elseif (abs((float)$r['cantidad'] - $it['cantidad']) < 0.005) $it['accion'] = 'igual';
                else $it['accion'] = 'actualiza';
                $res[$it['accion']]++;
                if (!$aplicar) continue;
                if ($it['accion'] === 'nuevo')
                    $pdo->prepare("INSERT INTO asistencia_registros (empleado_id, fecha, tipo, cantidad, motivo, usuario_id) VALUES (?,?,?,?,?,?)")
                        ->execute([$it['empleado_id'], $it['fecha'], $it['tipo'], $it['cantidad'], $it['motivo'], $uid]);
                elseif ($it['accion'] === 'actualiza')
                    $pdo->prepare("UPDATE asistencia_registros SET cantidad=?, motivo=? WHERE id_registro=?")
                        ->execute([$it['cantidad'], $it['motivo'], $r['id_registro']]);
            }
            unset($it);
            if ($aplicar) $pdo->commit();
        } catch (Exception $e) { if ($aplicar && $pdo->inTransaction()) $pdo->rollBack(); throw $e; }
        return ['items' => $items, 'resumen' => $res];
    }

    /** Registra marcas para varios empleados a la vez. modo: 'guardar' | 'ahora'. */
    public static function lote(array $d, int $uid): array {
        $ids = array_values(array_unique(array_filter(array_map('intval', (array)($d['empleados'] ?? [])))));
        if (!$ids) throw new Exception('Selecciona al menos un empleado.');
        if (count($ids) > 300) throw new Exception('Máximo 300 empleados por vez.');
        $fecha = trim($d['fecha'] ?? ''); self::fechaValida($fecha);
        $ahora = ($d['modo'] ?? 'guardar') === 'ahora';
        $sobre = !empty($d['sobrescribir']);
        $in = implode(',', array_fill(0, count($ids), '?'));
        $st = getDB()->prepare("SELECT id_empleado, CONCAT(nombres,' ',apellidos) n FROM empleados WHERE estado='activo' AND id_empleado IN ($in)");
        $st->execute($ids);
        $nombres = $st->fetchAll(PDO::FETCH_KEY_PAIR);
        $ok = 0; $omitidos = []; $errores = [];
        foreach ($ids as $id) {
            $n = $nombres[$id] ?? "#$id";
            if (!isset($nombres[$id])) { $errores[] = "$n: empleado no encontrado."; continue; }
            try {
                if ($ahora) {
                    self::marcarAhora(['empleado_id' => $id, 'fecha' => $fecha, 'hora' => $d['hora'] ?? ''], $uid);
                } else {
                    $r = self::fila($id, $fecha);
                    if ($r && ($r['hora_entrada'] || $r['hora_salida']) && !$sobre) { $omitidos[] = $n; continue; }
                    self::guardar(array_merge($d, ['empleado_id' => $id]), $uid);
                }
                $ok++;
            } catch (Exception $e) { $errores[] = $n . ': ' . $e->getMessage(); }
        }
        return ['guardados' => $ok, 'omitidos' => $omitidos, 'errores' => $errores];
    }

    /** Marca con la hora actual: primero la entrada y luego la salida. */
    public static function marcarAhora(array $d, int $uid): string {
        $emp = (int)($d['empleado_id'] ?? 0); $fecha = trim($d['fecha'] ?? ''); $hora = self::horaValida($d['hora'] ?? '');
        self::empleadoExiste($emp); self::fechaValida($fecha);
        if (!$hora) throw new Exception('Hora inválida.');
        $r = self::fila($emp, $fecha);
        $pdo = getDB();
        if (!$r) {
            $pdo->prepare("INSERT INTO marcaciones (empleado_id, fecha, hora_entrada, origen, usuario_id) VALUES (?,?,?,'manual',?)")
                ->execute([$emp, $fecha, $hora, $uid]);
            return "Entrada registrada a las $hora.";
        }
        if (!$r['hora_entrada']) {
            $pdo->prepare("UPDATE marcaciones SET hora_entrada=?, editado_por=?, fecha_edicion=NOW() WHERE id_marcacion=?")->execute([$hora, $uid, $r['id_marcacion']]);
            return "Entrada registrada a las $hora.";
        }
        if (!$r['hora_salida']) {
            if (self::min($hora) <= self::min($r['hora_entrada'])) throw new Exception('La hora de salida debe ser mayor a la de entrada.');
            $pdo->prepare("UPDATE marcaciones SET hora_salida=?, editado_por=?, fecha_edicion=NOW() WHERE id_marcacion=?")->execute([$hora, $uid, $r['id_marcacion']]);
            return "Salida registrada a las $hora.";
        }
        throw new Exception('El empleado ya tiene entrada y salida registradas en ese día.');
    }

    public static function justificar(array $d, int $uid): void {
        $emp = (int)($d['empleado_id'] ?? 0); $fecha = trim($d['fecha'] ?? '');
        self::empleadoExiste($emp); self::fechaValida($fecha);
        $r = self::fila($emp, $fecha);
        $pdo = getDB();
        if (!empty($d['quitar'])) {
            if (!$r) return;
            if (!$r['hora_entrada'] && !$r['hora_salida']) {
                $pdo->prepare("DELETE FROM marcaciones WHERE id_marcacion=?")->execute([$r['id_marcacion']]);
            } else {
                $pdo->prepare("UPDATE marcaciones SET justificado=0, justificacion=NULL, editado_por=?, fecha_edicion=NOW() WHERE id_marcacion=?")->execute([$uid, $r['id_marcacion']]);
            }
            return;
        }
        $motivo = mb_substr(trim((string)($d['justificacion'] ?? '')), 0, 255);
        if (mb_strlen($motivo) < 3) throw new Exception('Escribe el motivo de la justificación.');
        if ($r) {
            $pdo->prepare("UPDATE marcaciones SET justificado=1, justificacion=?, editado_por=?, fecha_edicion=NOW() WHERE id_marcacion=?")->execute([$motivo, $uid, $r['id_marcacion']]);
        } else {
            $pdo->prepare("INSERT INTO marcaciones (empleado_id, fecha, justificado, justificacion, usuario_id) VALUES (?,?,1,?,?)")->execute([$emp, $fecha, $motivo, $uid]);
        }
    }

    public static function eliminar(int $id): void {
        $st = getDB()->prepare("DELETE FROM marcaciones WHERE id_marcacion = ?");
        $st->execute([$id]);
        if (!$st->rowCount()) throw new Exception('Marca no encontrada.');
    }
}
