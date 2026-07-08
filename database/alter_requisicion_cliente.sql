-- SOLDYMEG — Agregar columna cliente_id a requisiciones_materiales
-- Ejecutar UNA sola vez

ALTER TABLE requisiciones_materiales
  ADD COLUMN cliente_id INT NULL DEFAULT NULL AFTER unidad,
  ADD CONSTRAINT fk_req_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente) ON DELETE SET NULL;
