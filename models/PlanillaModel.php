<?php
// ============================================================
//  SOLDYMEG — PlanillaModel  (Fase 5 — Rev.2)
//  Planilla QUINCENAL. Sin IHSS/RAP/ISR/Vacaciones/13vo.
//  Seguro privado fijo por ubicación:
//    SOLDYMEG → L.359.74  |  VESTA → L.215.84
//  Hora extra:
//    SOLDYMEG → L.70/hr   |  VESTA → L.85/hr
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/EmpleadoModel.php';

class PlanillaModel {

    const SEGURO = ['SOLDYMEG' => 359.74, 'VESTA' => 215.84];
    const HE_RATE= ['SOLDYMEG' => 70.00,  'VESTA' => 85.00];

    /**
     * Calcula las líneas de un empleado para una quincena.
     * $extras = ['horas_extra'=>0, 'dias_faltados'=>0, 'abono_prestamo'=>0, 'abono_vale'=>0]
     * $quincena = '1ra' | '2da'  — el seguro solo se descuenta en la 2da quincena
     */
    public static function calcularEmpleado(array $emp, array $extras = [], string $quincena = '1ra'): array {
        $ubicacion       = $emp['ubicacion'] ?? 'SOLDYMEG';
        $salario_mensual = (float)$emp['salario_mensual'];
        $salario_quince  = round($salario_mensual / 2, 2);

        // Horas extra
        $horas_extra = (float)($extras['horas_extra'] ?? 0);
        $tarifa_he   = self::HE_RATE[$ubicacion] ?? 70;
        $monto_he    = round($horas_extra * $tarifa_he, 2);

        // Días faltados — descuento proporcional del salario quincenal (÷ 15 días)
        $dias_faltados  = (float)($extras['dias_faltados'] ?? 0);
        $monto_faltados = round(($salario_quince / 15) * $dias_faltados, 2);

        // Seguro privado — SOLO en 2da quincena, y solo si aplicar_seguro es true
        // Prioridad 1: valor enviado por JS en $extras['seguro_privado']
        // Prioridad 2: campo seguro_privado del empleado en BD ($emp)
        // Fallback:    constante por ubicación
        $aplicar_seguro  = $extras['aplicar_seguro'] ?? true;
        if (isset($extras['seguro_privado'])) {
            $monto_seguro = (float)$extras['seguro_privado'];
        } elseif (isset($emp['seguro_privado'])) {
            $monto_seguro = (float)$emp['seguro_privado'];
        } else {
            $monto_seguro = (float)(self::SEGURO[$ubicacion] ?? 0);
        }
        $seguro = ($quincena === '2da' && $aplicar_seguro) ? $monto_seguro : 0.00;

        // Abonos
        $abono_prestamo = (float)($extras['abono_prestamo'] ?? 0);
        $abono_vale     = (float)($extras['abono_vale']     ?? 0);

        $viatico_s1 = (float)($extras['viatico_s1'] ?? 0);
        $viatico_s2 = (float)($extras['viatico_s2'] ?? 0);
        $viatico_s3 = (float)($extras['viatico_s3'] ?? 0);
        $viatico_s4 = (float)($extras['viatico_s4'] ?? 0);
        $total_viaticos = $viatico_s1 + $viatico_s2 + $viatico_s3 + $viatico_s4;
        $total_deducciones = round($monto_faltados + $seguro + $abono_prestamo + $abono_vale, 2);
        $salario_neto      = round($salario_quince + $monto_he + $total_viaticos - $total_deducciones, 2);

        return [
            'empleado_id'         => (int)$emp['id_empleado'],
            'nombre'              => $emp['nombre'],
            'puesto'              => $emp['puesto'] ?? '',
            'ubicacion'           => $ubicacion,
            'tipo_contrato'       => $emp['tipo_contrato'],
            'salario_base'        => $salario_quince,
            'horas_extra'         => $horas_extra,
            'monto_horas_extra'   => $monto_he,
            'dias_faltados'       => $dias_faltados,
            'monto_dias_faltados' => $monto_faltados,
            'seguro_privado'      => $seguro,
            'aplicar_seguro'      => $aplicar_seguro ? 1 : 0,
            'abono_prestamo'      => $abono_prestamo,
            'abono_vale'          => $abono_vale,
            'viatico_s1'          => $viatico_s1,
            'viatico_s2'          => $viatico_s2,
            'viatico_s3'          => $viatico_s3,
            'viatico_s4'          => $viatico_s4,
            'otras_deducciones'   => 0,
            'total_deducciones'   => $total_deducciones,
            'salario_neto'        => $salario_neto,
            // Legacy siempre 0
            'ihss_empleado'       => 0,
            'ihss_patronal'       => 0,
            'rap_empleado'        => 0,
            'isr_mensual'         => 0,
            'vacaciones_acum'     => 0,
            'decimo_acum'         => 0,
        ];
    }

    /**
     * Vista previa (sin guardar).
     */
    public static function previsualizar(int $mes, int $anio, string $quincena = '1ra', array $extrasMap = [], int $empresa_id = 0): array {
        $empleados = EmpleadoModel::listar('activo', '', $empresa_id);
        $detalle   = [];
        foreach ($empleados as $emp) {
            $extras    = $extrasMap[$emp['id_empleado']] ?? [];
            $detalle[] = self::calcularEmpleado($emp, $extras, $quincena);
        }
        return [
            'mes'      => $mes,
            'anio'     => $anio,
            'quincena' => $quincena,
            'detalle'  => $detalle,
            'totales'  => self::sumarTotales($detalle),
        ];
    }

    /**
     * Genera y guarda la planilla quincenal.
     */
    public static function generar(int $mes, int $anio, string $quincena, string $fecha_pago, string $observaciones, array $extrasMap, int $usuario_id, int $excluirId = 0, int $empresa_id = 0): int {
        $pdo = getDB();

        $sql = "SELECT id_planilla FROM planillas WHERE periodo_mes=? AND periodo_anio=? AND quincena=?";
        $params = [$mes, $anio, $quincena];
        if ($excluirId > 0) {
            $sql .= " AND id_planilla != ?";
            $params[] = $excluirId;
        }
        $chk = $pdo->prepare($sql);
        $chk->execute($params);
        if ($chk->fetch()) {
            throw new Exception("Ya existe la planilla de la {$quincena} quincena de " . self::nombreMes($mes) . " $anio.");
        }

        $empleados = EmpleadoModel::listar('activo', '', $empresa_id);
        if (!$empleados) throw new Exception('No hay empleados activos.');

        $detalle = [];
        foreach ($empleados as $emp) {
            $extras    = $extrasMap[$emp['id_empleado']] ?? [];
            $detalle[] = self::calcularEmpleado($emp, $extras, $quincena);
        }
        $totales = self::sumarTotales($detalle);

        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO planillas
                  (periodo_mes, periodo_anio, quincena, fecha_pago,
                   total_salarios, total_ihss_emp, total_ihss_pat,
                   total_rap, total_isr, total_seguro,
                   total_deducciones, total_neto, observaciones, estado, usuario_id)
                VALUES (?,?,?,?,?,0,0,0,0,?,?,?,?,'borrador',?)
            ")->execute([
                $mes, $anio, $quincena, $fecha_pago,
                $totales['total_salarios'],
                $totales['total_seguro'],
                $totales['total_deducciones'],
                $totales['total_neto'],
                $observaciones,
                $usuario_id,
            ]);
            $planilla_id = (int)$pdo->lastInsertId();

            $ins = $pdo->prepare("
                INSERT INTO detalle_planilla
                  (planilla_id, empleado_id, salario_base,
                   horas_extra, monto_horas_extra,
                   dias_faltados, monto_dias_faltados,
                   ihss_empleado, ihss_patronal, rap_empleado,
                   isr_mensual, seguro_privado, aplicar_seguro,
                   abono_prestamo, abono_vale,
                   viatico_s1, viatico_s2, viatico_s3, viatico_s4,
                   otras_deducciones, total_deducciones,
                   salario_neto, vacaciones_acum, decimo_acum, observaciones)
                VALUES (?,?,?,?,?,?,?,0,0,0,0,?,?,?,?,?,?,?,?,0,?,?,0,0,?)
            ");
            foreach ($detalle as $d) {
                $ins->execute([
                    $planilla_id,
                    $d['empleado_id'],
                    $d['salario_base'],
                    $d['horas_extra'],
                    $d['monto_horas_extra'],
                    $d['dias_faltados'],
                    $d['monto_dias_faltados'],
                    $d['seguro_privado'],
                    $d['aplicar_seguro'] ? 1 : 0,
                    $d['abono_prestamo'],
                    $d['abono_vale'],
                    $d['viatico_s1'] ?? 0,
                    $d['viatico_s2'] ?? 0,
                    $d['viatico_s3'] ?? 0,
                    $d['viatico_s4'] ?? 0,
                    $d['total_deducciones'],
                    $d['salario_neto'],
                    null,
                ]);
            }

            $pdo->commit();
            return $planilla_id;
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    public static function listar(): array {
        $stmt = getDB()->prepare("
            SELECT p.*, u.nombre AS usuario,
                   (SELECT COUNT(*) FROM detalle_planilla dp WHERE dp.planilla_id = p.id_planilla) AS total_empleados
            FROM planillas p
            JOIN usuarios u ON u.id_usuario = p.usuario_id
            ORDER BY p.periodo_anio DESC, p.periodo_mes DESC, p.quincena DESC
        ");
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT p.*, u.nombre AS usuario
            FROM planillas p
            JOIN usuarios u ON u.id_usuario = p.usuario_id
            WHERE p.id_planilla = ?
        ");
        $stmt->execute([$id]);
        $planilla = $stmt->fetch();
        if (!$planilla) return null;

        $det = $pdo->prepare("
            SELECT dp.*, CONCAT(e.nombres, ' ', e.apellidos) AS empleado, e.puesto, e.tipo_contrato,
                   e.ubicacion, e.banco, e.cuenta_banco
            FROM detalle_planilla dp
            JOIN empleados e ON e.id_empleado = dp.empleado_id
            WHERE dp.planilla_id = ?
            ORDER BY e.ubicacion ASC, e.apellidos ASC, e.nombres ASC
        ");
        $det->execute([$id]);
        $planilla['detalle'] = $det->fetchAll();
        return $planilla;
    }

    public static function cerrar(int $id): bool {
        return getDB()->prepare("UPDATE planillas SET estado='cerrada' WHERE id_planilla=?")
            ->execute([$id]);
    }

    public static function eliminar(int $id): bool {
        $pdo  = getDB();
        $stmt = $pdo->prepare("SELECT estado FROM planillas WHERE id_planilla=?");
        $stmt->execute([$id]);
        $p = $stmt->fetch();
        if (!$p) throw new Exception('Planilla no encontrada.');
        if ($p['estado'] === 'cerrada') throw new Exception('No se puede eliminar una planilla cerrada.');
        return $pdo->prepare("DELETE FROM planillas WHERE id_planilla=?")->execute([$id]);
    }

    private static function sumarTotales(array $detalle): array {
        $t = [
            'total_salarios'    => 0, 'total_horas_extra'    => 0,
            'total_faltados'    => 0, 'total_seguro'         => 0,
            'total_prestamos'   => 0, 'total_vales'          => 0,
            'total_deducciones' => 0, 'total_neto'           => 0,
            'total_empleados'   => count($detalle),
            // Legacy (siempre 0)
            'total_ihss_emp'    => 0, 'total_ihss_pat'       => 0,
            'total_rap'         => 0, 'total_isr'            => 0,
        ];
        foreach ($detalle as $d) {
            $t['total_salarios']    += $d['salario_base'];
            $t['total_horas_extra'] += $d['monto_horas_extra'];
            $t['total_faltados']    += $d['monto_dias_faltados'];
            $t['total_seguro']      += $d['seguro_privado'];
            $t['total_prestamos']   += $d['abono_prestamo'];
            $t['total_vales']       += $d['abono_vale'];
            $t['total_deducciones'] += $d['total_deducciones'];
            $t['total_neto']        += $d['salario_neto'];
        }
        foreach ($t as $k => $v) {
            if (is_float($v)) $t[$k] = round($v, 2);
        }
        return $t;
    }

    public static function nombreMes(int $mes): string {
        return ['','Enero','Febrero','Marzo','Abril','Mayo','Junio',
                'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'][$mes] ?? '';
    }
}
