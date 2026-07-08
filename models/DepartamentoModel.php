<?php
require_once __DIR__ . '/../config/db.php';

class DepartamentoModel {

    public static function listar(string $estado = 'activo'): array {
        $where = $estado !== 'todos' ? "WHERE estado = '$estado'" : '';
        return getDB()->query("SELECT * FROM departamentos $where ORDER BY nombre")->fetchAll();
    }

    public static function crear(string $nombre, string $descripcion = ''): int {
        $pdo = getDB();
        $pdo->prepare("INSERT INTO departamentos (nombre, descripcion) VALUES (?,?)")
            ->execute([trim($nombre), trim($descripcion)]);
        return (int)$pdo->lastInsertId();
    }

    public static function actualizar(int $id, string $nombre, string $descripcion = ''): void {
        getDB()->prepare("UPDATE departamentos SET nombre=?, descripcion=? WHERE id_departamento=?")
               ->execute([trim($nombre), trim($descripcion), $id]);
    }

    public static function cambiarEstado(int $id, string $estado): void {
        getDB()->prepare("UPDATE departamentos SET estado=? WHERE id_departamento=?")
               ->execute([$estado, $id]);
    }
}
