-- ============================================================
--  SOLDYMEG — Migración Fase 4: Módulo Pagos
--  Solo asegura que existan permisos para el módulo 'pagos'
--  en todos los roles. Seguro de ejecutar múltiples veces.
-- ============================================================

-- Administrador (rol 1): acceso total
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES (1, 'pagos', 1, 1, 1, 1);

-- Ventas (rol 2): puede ver pero no anular
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES (2, 'pagos', 1, 0, 0, 0);

-- Contabilidad (rol 3): puede ver y editar (anular)
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES (3, 'pagos', 1, 1, 1, 0);

-- Técnico (rol 4): sin acceso
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar)
VALUES (4, 'pagos', 0, 0, 0, 0);

-- Verificación
SELECT r.nombre AS rol, p.modulo, p.puede_ver, p.puede_crear, p.puede_editar, p.puede_eliminar
FROM permisos p
JOIN roles r ON r.id_rol = p.rol_id
WHERE p.modulo = 'pagos'
ORDER BY p.rol_id;
-- ============================================================
