-- Crear la base de datos y seleccionarla
CREATE DATABASE IF NOT EXISTS tienda_ropa;
USE tienda_ropa;

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(150),
    correo_electronico VARCHAR(100),
    telefono VARCHAR(20)
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50),
    stock INT
);

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    fecha DATE,
    estado VARCHAR(20),
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_venta DECIMAL(10,2),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Insertar clientes
INSERT INTO clientes (nombre, apellido, direccion, correo_electronico, telefono) VALUES
('Juan', 'Pérez', 'Av. Principal 123', 'juan.perez@ejemplo.com', '0414-1111111'),
('María', 'Gómez', 'Calle 5, Edif. Sol', 'maria.gomez@ejemplo.com', '0424-2222222'),
('Ana', 'Martínez', 'Urb. Los Pinos 45', 'ana.martinez@ejemplo.com', '0416-4444444'),
('Luis', 'Fernández', 'Calle Bolívar 78', 'luis.fernandez@ejemplo.com', '0426-5555555');

-- Insertar productos
INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Camiseta básica', 'Algodón, varios colores', 20.00, 'Camisetas', 100),
('Camiseta estampada', 'Diseño gráfico', 25.00, 'Camisetas', 80),
('Jeans clásico', 'Corte recto', 45.00, 'Pantalones', 50),
('Chaqueta de cuero', 'Sintético', 80.00, 'Chaquetas', 20),
('Gorra deportiva', 'Ajustable', 15.00, 'Accesorios', 60);

-- Insertar pedidos (fechas relativas a hoy)
INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES
(1, CURDATE() - INTERVAL 5 DAY,   'Entregado', 70.00),
(1, CURDATE() - INTERVAL 15 DAY,  'Enviado',   80.00),
(2, CURDATE() - INTERVAL 10 DAY,  'Entregado', 45.00),
(3, CURDATE() - INTERVAL 20 DAY,  'Pendiente', 40.00),
(1, CURDATE() - INTERVAL 90 DAY,  'Entregado', 25.00),
(2, CURDATE() - INTERVAL 200 DAY, 'Entregado', 15.00),
(4, CURDATE() - INTERVAL 3 DAY,   'Pendiente', 0.00);

-- Insertar ventas (el pedido 7 queda sin ventas a propósito)
INSERT INTO ventas (id_pedido, id_producto, cantidad, precio_venta) VALUES
(1, 1, 2, 20.00),
(1, 5, 2, 15.00),
(2, 4, 1, 80.00),
(3, 3, 1, 45.00),
(4, 1, 2, 20.00),
(5, 2, 1, 25.00),
(6, 5, 1, 15.00);

-- Consulta 1: clientes con pedidos en los últimos 30 días
SELECT DISTINCT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
       c.direccion, c.correo_electronico
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha >= CURDATE() - INTERVAL 30 DAY;

-- Consulta 2: productos más vendidos en el último mes
SELECT pr.nombre,
       SUM(v.cantidad) AS cantidad_vendida,
       SUM(v.cantidad * v.precio_venta) AS total_vendido
FROM productos pr
INNER JOIN ventas v ON pr.id_producto = v.id_producto
INNER JOIN pedidos p ON v.id_pedido = p.id_pedido
WHERE p.fecha >= CURDATE() - INTERVAL 1 MONTH
GROUP BY pr.id_producto, pr.nombre
ORDER BY cantidad_vendida DESC;

-- Consulta 3: clientes con más pedidos en el último año
SELECT c.nombre, c.apellido, COUNT(p.id_pedido) AS total_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha >= CURDATE() - INTERVAL 1 YEAR
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY total_pedidos DESC;

-- Actualización: aumentar 10% el precio de las camisetas
UPDATE productos
SET precio = ROUND(precio * 1.10, 2)
WHERE categoria = 'Camisetas';

SELECT * FROM productos;

-- Eliminación: pedidos sin ventas asociadas
DELETE FROM pedidos
WHERE id_pedido NOT IN (SELECT id_pedido FROM ventas);

SELECT * FROM pedidos;

-- Vista: nombre completo, fecha y total del pedido
-- DROP VIEW IF EXISTS vista_clientes_pedidos;
CREATE VIEW vista_clientes_pedidos AS
SELECT CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
       p.fecha AS fecha_pedido,
       p.total AS total_pedido
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente;

-- Consultar la vista
SELECT * FROM vista_clientes_pedidos;