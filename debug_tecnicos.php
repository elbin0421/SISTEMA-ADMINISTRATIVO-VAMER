<?php
// ============================================================
//  Debug — verificar que tecnicos() devuelve empleados
//  1. Sube a /admin/debug_tecnicos.php
//  2. Abre http://localhost/admin/debug_tecnicos.php
//  3. Elimina después
// ============================================================
require_once __DIR__ . '/config/db.php';
header('Content-Type: text/html; charset=utf-8');
echo '<pre style="font-family:monospace;padding:20px;font-size:14px">';
echo "=== TEST TABLA EMPLEADOS ===\n\n";

try {
    $pdo = getDB();

    // 1. Ver todos los empleados
    $all = $pdo->query("SELECT id_empleado, nombre, puesto, estado FROM empleados")->fetchAll();
    echo "Total empleados: " . count($all) . "\n";
    foreach ($all as $e) {
        echo "  [{$e['id_empleado']}] {$e['nombre']} — {$e['puesto']} — {$e['estado']}\n";
    }

    // 2. Misma query que usa el controller
    $activos = $pdo->query("
        SELECT id_empleado, nombre, puesto
        FROM empleados
        WHERE estado = 'activo'
        ORDER BY nombre
    ")->fetchAll();
    echo "\nEmpleados activos (query del controller): " . count($activos) . "\n";
    foreach ($activos as $e) {
        echo "  [{$e['id_empleado']}] {$e['nombre']} — {$e['puesto']}\n";
    }

    // 3. Simular respuesta JSON
    echo "\nJSON que devolvería el controller:\n";
    echo json_encode(['ok' => true, 'data' => $activos], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch(Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
echo '</pre>';
