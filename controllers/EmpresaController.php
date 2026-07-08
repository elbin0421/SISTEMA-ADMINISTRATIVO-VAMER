<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
require_once __DIR__ . '/../models/EmpresaModel.php';
header('Content-Type: application/json');
requireAuth();
echo json_encode(['ok'=>true,'data'=>EmpresaModel::listar()]);
