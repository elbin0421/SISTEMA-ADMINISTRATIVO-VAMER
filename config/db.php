<?php
// ============================================================
//  SOLDYMEG — Configuración de base de datos
//  Cambiar DB_HOST a 'localhost' al subir al servidor
// ============================================================

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'vamer_admin');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// Tiempo de expiración de sesión en horas
define('SESSION_HOURS', 8);

function getDB(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            http_response_code(500);
            die(json_encode(['error' => 'Error de conexión a la base de datos.']));
        }
    }
    return $pdo;
}
