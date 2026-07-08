<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../models/EmpleadoModel.php';

class PlanillaEspecialModel {

    public static function calcularEmpleado(array $emp, string $tipo, int $anio_pago): array {
        $salario_mensual = (float)$emp['salario_mensual'];
        $fecha_ingreso   = $emp['fecha_ingreso'] ?? null;
        if ($tipo === 'catorceavo') {
            $periodo_ini = new DateTime(($anio_pago - 1) . '-07-01');
            $periodo_fin = new DateTime($anio_pago . '-06-30');
        } else {
            $periodo_ini = new DateTime(($anio_pago - 1) . '-11-01');
            $periodo_fin = new DateTime($anio_pago . '-10-31');
        }
        $ingreso         = $fecha_ingreso ? new DateTime($fecha_ingreso) : clone $periodo_ini;
        $inicio_efectivo = $ingreso > $periodo_ini ? $ingreso : clone $periodo_ini;
        $diff_dias       = (int)$inicio_efectivo->diff($periodo_fin)->days + 1;
        $total_dias      = (int)$periodo_ini->diff($periodo_fin)->days + 1;
        $dias_trabajados = max(0, min($diff_dias, $total_dias));
        $proporcional    = round($salario_mensual * ($dias_trabajados / $total_dias), 2);
        $meses_trabajados= round($dias_trabajados / ($total_dias / 12), 2);
        return [
            'empleado_id'      => (int)$emp['id_empleado'],
            'nombre'           => $emp['nombre'],
            'puesto'           => $emp['puesto'] ?? '',
            'ubicacion'        => $emp['ubicacion'] ?? 'SOLDYMEG',
            'empresa_nombre'   => $emp['empresa_nombre'] ?? '',
            'tipo_contrato'    => $emp['tipo_contrato'] ?? '',
            'fecha_ingreso'    => $emp['fecha_ingreso'] ?? null,
            'salario_mensual'  => $salario_mensual,
            'dias_trabajados'  => $dias_trabajados,
            'total_dias'       => $total_dias,
            'meses_trabajados' => $meses_trabajados,
            'monto'            => $proporcional,
            'excluido'         => false,
        ];
    }

    public static function previsualizar(string $tipo, int $anio_pago, array $excluidos = []): array {
        $empleados = EmpleadoModel::listar('activo');
        $detalle   = [];
        foreach ($empleados as $emp) {
            $fila = self::calcularEmpleado($emp, $tipo, $anio_pago);
            if (in_array($fila['empleado_id'], $excluidos)) {
                $fila['excluido'] = true;
                $fila['monto']    = 0;
            }
            $detalle[] = $fila;
        }
        return ['tipo'=>$tipo,'anio'=>$anio_pago,'detalle'=>$detalle,'totales'=>self::sumarTotales($detalle)];
    }

    public static function generar(string $tipo, int $anio_pago, string $fecha_pago, string $observaciones, array $excluidos, int $usuario_id, int $excluirId = 0): int {
        $pdo = getDB();
        $sql = "SELECT id_planilla FROM planillas WHERE quincena = ? AND periodo_anio = ? AND periodo_mes = ?";
        $params = [$tipo, $anio_pago, $tipo === 'catorceavo' ? 6 : 12];
        if ($excluirId > 0) { $sql .= " AND id_planilla != ?"; $params[] = $excluirId; }
        $chk = $pdo->prepare($sql); $chk->execute($params);
        if ($chk->fetch()) throw new Exception("Ya existe la planilla de " . ($tipo==='catorceavo'?'Catorceavo':'Aguinaldo') . " $anio_pago.");
        $empleados = EmpleadoModel::listar('activo');
        if (!$empleados) throw new Exception('No hay empleados activos.');
        $detalle = [];
        foreach ($empleados as $emp) {
            $fila = self::calcularEmpleado($emp, $tipo, $anio_pago);
            if (in_array($fila['empleado_id'], $excluidos)) { $fila['excluido']=true; $fila['monto']=0; }
            $detalle[] = $fila;
        }
        $totales  = self::sumarTotales($detalle);
        $mes_pago = $tipo === 'catorceavo' ? 6 : 12;
        $pdo->beginTransaction();
        try {
            $pdo->prepare("INSERT INTO planillas (periodo_mes,periodo_anio,quincena,fecha_pago,total_salarios,total_ihss_emp,total_ihss_pat,total_rap,total_isr,total_seguro,total_deducciones,total_neto,observaciones,estado,usuario_id) VALUES (?,?,?,?,?,0,0,0,0,0,?,?,?,'borrador',?)")
                ->execute([$mes_pago,$anio_pago,$tipo,$fecha_pago,$totales['total_salarios'],0,$totales['total_neto'],$observaciones,$usuario_id]);
            $planilla_id = (int)$pdo->lastInsertId();
            $ins = $pdo->prepare("INSERT INTO detalle_planilla (planilla_id,empleado_id,salario_base,horas_extra,monto_horas_extra,dias_faltados,monto_dias_faltados,ihss_empleado,ihss_patronal,rap_empleado,isr_mensual,seguro_privado,aplicar_seguro,abono_prestamo,abono_vale,otras_deducciones,total_deducciones,salario_neto,vacaciones_acum,decimo_acum,observaciones) VALUES (?,?,?,0,0,0,0,0,0,0,0,0,0,0,0,0,0,?,0,0,?)");
            foreach ($detalle as $d) {
                $ins->execute([$planilla_id,$d['empleado_id'],$d['salario_mensual'],$d['monto'],$d['excluido']?'EXCLUIDO':null]);
            }
            $pdo->commit();
            return $planilla_id;
        } catch (Exception $e) { $pdo->rollBack(); throw $e; }
    }

    public static function listar(string $tipo = ''): array {
        $pdo   = getDB();
        $where = $tipo ? "AND p.quincena = ?" : '';
        $stmt  = $pdo->prepare("SELECT p.*, u.nombre AS usuario,(SELECT COUNT(*) FROM detalle_planilla dp WHERE dp.planilla_id=p.id_planilla) AS total_empleados FROM planillas p JOIN usuarios u ON u.id_usuario=p.usuario_id WHERE p.quincena IN ('catorceavo','aguinaldo') $where ORDER BY p.periodo_anio DESC, p.quincena ASC");
        $tipo ? $stmt->execute([$tipo]) : $stmt->execute();
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("SELECT p.*, u.nombre AS usuario FROM planillas p JOIN usuarios u ON u.id_usuario=p.usuario_id WHERE p.id_planilla=?");
        $stmt->execute([$id]);
        $planilla = $stmt->fetch();
        if (!$planilla) return null;
        $det = $pdo->prepare("SELECT dp.*, CONCAT(e.nombres,' ',e.apellidos) AS empleado, e.puesto, e.tipo_contrato, e.ubicacion, emp.nombre AS empresa_nombre, e.banco, e.cuenta_banco, e.salario_mensual, e.fecha_ingreso FROM detalle_planilla dp JOIN empleados e ON e.id_empleado=dp.empleado_id LEFT JOIN empresas emp ON emp.id_empresa=e.empresa_id WHERE dp.planilla_id=? ORDER BY e.apellidos,e.nombres");
        $det->execute([$id]);
        $planilla['detalle'] = $det->fetchAll();
        return $planilla;
    }

    private static function sumarTotales(array $detalle): array {
        $t = ['total_salarios'=>0,'total_neto'=>0,'total_empleados'=>0,'excluidos'=>0];
        foreach ($detalle as $d) {
            if (!$d['excluido']) { $t['total_salarios']+=$d['salario_mensual']; $t['total_neto']+=$d['monto']; $t['total_empleados']++; }
            else $t['excluidos']++;
        }
        $t['total_salarios'] = round($t['total_salarios'],2);
        $t['total_neto']     = round($t['total_neto'],2);
        return $t;
    }
}
