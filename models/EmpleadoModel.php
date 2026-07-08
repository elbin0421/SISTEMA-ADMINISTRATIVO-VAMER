<?php
require_once __DIR__ . '/../config/db.php';

class EmpleadoModel {

    public static function listar(string $estado = 'activo', string $ubicacion = '', int $empresa_id = 0): array {
        $pdo   = getDB();
        // Detectar estructura DB
        $nueva = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        $conds = []; $params = [];
        if ($estado)     { $conds[] = "e.estado = ?";      $params[] = $estado; }
        if ($ubicacion)  { $conds[] = "e.ubicacion = ?";   $params[] = $ubicacion; }
        if ($empresa_id) { $conds[] = "e.empresa_id = ?";  $params[] = $empresa_id; }
        $where = $conds ? 'WHERE '.implode(' AND ', $conds) : '';
        if ($nueva) {
            $stmt = $pdo->prepare("
                SELECT e.*, CONCAT(e.nombres,' ',e.apellidos) AS nombre,
                       d.nombre AS departamento_nombre,
                       emp.nombre AS empresa_nombre
                FROM empleados e
                LEFT JOIN departamentos d ON d.id_departamento = e.departamento_id
                LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id
                $where ORDER BY e.apellidos, e.nombres");
        } else {
            $stmt = $pdo->prepare("
                SELECT e.*, e.nombre, NULL AS departamento_nombre
                FROM empleados e $where ORDER BY e.nombre");
        }
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $nova = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        if ($nova) {
            $stmt = $pdo->prepare("
                SELECT e.*, CONCAT(e.nombres,' ',e.apellidos) AS nombre,
                       d.nombre AS departamento_nombre,
                       emp.nombre AS empresa_nombre
                FROM empleados e
                LEFT JOIN departamentos d ON d.id_departamento = e.departamento_id
                LEFT JOIN empresas emp ON emp.id_empresa = e.empresa_id
                WHERE e.id_empleado = ?");
        } else {
            $stmt = $pdo->prepare("SELECT e.*, NULL AS departamento_nombre FROM empleados e WHERE e.id_empleado = ?");
        }
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public static function crear(array $d): int {
        $pdo  = getDB();
        $nova = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        if ($nova) {
            $pdo->prepare("
                INSERT INTO empleados
                  (nombres, apellidos, ubicacion, empresa_id, departamento_id, identidad, puesto, tipo_contrato, salario_mensual,
                   fecha_ingreso, ihss_numero, rap_numero, correo, telefono, direccion, cuenta_banco, banco,
                   aplica_ihss, aplica_rap, aplica_isr, seguro_privado, estado)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,0,0,?,'activo')
            ")->execute([
                trim($d['nombres']), trim($d['apellidos']),
                $d['ubicacion'] ?? 'SOLDYMEG',
                !empty($d['empresa_id']) ? (int)$d['empresa_id'] : null,
                ($d['departamento_id'] ?? null) ?: null,
                trim($d['identidad']??''), trim($d['puesto']??''),
                $d['tipo_contrato']??'tiempo_completo', (float)($d['salario_mensual']??0),
                $d['fecha_ingreso']??date('Y-m-d'), trim($d['ihss_numero']??''), trim($d['rap_numero']??''),
                trim($d['correo']??''), trim($d['telefono']??''), trim($d['direccion']??''),
                trim($d['cuenta_banco']??''), trim($d['banco']??''), (float)($d['seguro_privado']??0),
            ]);
        } else {
            $pdo->prepare("
                INSERT INTO empleados
                  (nombre, ubicacion, identidad, puesto, tipo_contrato, salario_mensual,
                   fecha_ingreso, ihss_numero, rap_numero, correo, telefono, direccion, cuenta_banco, banco,
                   aplica_ihss, aplica_rap, aplica_isr, seguro_privado, estado)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,0,0,?,'activo')
            ")->execute([
                trim($d['nombres']??$d['nombre']??''),
                $d['ubicacion']??'SOLDYMEG', trim($d['identidad']??''), trim($d['puesto']??''),
                $d['tipo_contrato']??'tiempo_completo', (float)($d['salario_mensual']??0),
                $d['fecha_ingreso']??date('Y-m-d'), trim($d['ihss_numero']??''), trim($d['rap_numero']??''),
                trim($d['correo']??''), trim($d['telefono']??''), trim($d['direccion']??''),
                trim($d['cuenta_banco']??''), trim($d['banco']??''), (float)($d['seguro_privado']??0),
            ]);
        }
        return (int)$pdo->lastInsertId();
    }

    public static function actualizar(int $id, array $d): bool {
        $pdo  = getDB();
        $nova = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        if ($nova) {
            return (bool) $pdo->prepare("
                UPDATE empleados SET
                  nombres=?, apellidos=?, ubicacion=?, empresa_id=?, departamento_id=?,
                  identidad=?, puesto=?, tipo_contrato=?, salario_mensual=?,
                  fecha_ingreso=?, ihss_numero=?, rap_numero=?,
                  correo=?, telefono=?, direccion=?, cuenta_banco=?, banco=?,
                  aplica_ihss=?, aplica_rap=?, aplica_isr=?, seguro_privado=?
                WHERE id_empleado=?
            ")->execute([
                trim($d['nombres']), trim($d['apellidos']),
                $d['ubicacion']??'SOLDYMEG',
                !empty($d['empresa_id']) ? (int)$d['empresa_id'] : null,
                ($d['departamento_id']??null)?:null,
                trim($d['identidad']??''), trim($d['puesto']??''),
                $d['tipo_contrato']??'tiempo_completo', (float)($d['salario_mensual']??0),
                $d['fecha_ingreso']??date('Y-m-d'), trim($d['ihss_numero']??''), trim($d['rap_numero']??''),
                trim($d['correo']??''), trim($d['telefono']??''), trim($d['direccion']??''),
                trim($d['cuenta_banco']??''), trim($d['banco']??''),
                (int)($d['aplica_ihss']??0), (int)($d['aplica_rap']??0), (int)($d['aplica_isr']??0),
                (float)($d['seguro_privado']??0), $id,
            ]);
        } else {
            return (bool) $pdo->prepare("
                UPDATE empleados SET
                  nombre=?, ubicacion=?, identidad=?, puesto=?, tipo_contrato=?, salario_mensual=?,
                  fecha_ingreso=?, ihss_numero=?, rap_numero=?,
                  correo=?, telefono=?, direccion=?, cuenta_banco=?, banco=?,
                  aplica_ihss=?, aplica_rap=?, aplica_isr=?, seguro_privado=?
                WHERE id_empleado=?
            ")->execute([
                trim($d['nombres']??$d['nombre']??''),
                $d['ubicacion']??'SOLDYMEG', trim($d['identidad']??''), trim($d['puesto']??''),
                $d['tipo_contrato']??'tiempo_completo', (float)($d['salario_mensual']??0),
                $d['fecha_ingreso']??date('Y-m-d'), trim($d['ihss_numero']??''), trim($d['rap_numero']??''),
                trim($d['correo']??''), trim($d['telefono']??''), trim($d['direccion']??''),
                trim($d['cuenta_banco']??''), trim($d['banco']??''),
                (int)($d['aplica_ihss']??0), (int)($d['aplica_rap']??0), (int)($d['aplica_isr']??0),
                (float)($d['seguro_privado']??0), $id,
            ]);
        }
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        return (bool) getDB()->prepare("UPDATE empleados SET estado=? WHERE id_empleado=?")
            ->execute([$estado, $id]);
    }
}
