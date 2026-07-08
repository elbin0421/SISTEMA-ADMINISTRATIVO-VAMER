<?php
require_once __DIR__ . '/../config/db.php';
class EmpresaModel {
    public static function listar(): array {
        return getDB()->query("SELECT * FROM empresas WHERE activo=1 ORDER BY nombre")->fetchAll();
    }
}
