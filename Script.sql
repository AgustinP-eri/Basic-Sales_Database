
-- CREACIÓN DE LA BASE DE DATOS Y TABLAS 

CREATE SCHEMA IF NOT EXISTS `proyecto` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `proyecto`;

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS `clientes` (
  `cliente_id` INT NOT NULL PRIMARY KEY,
  `nombre` TEXT NULL,
  `cliente_nuevo` TEXT NULL,
  `fecha_registro` TEXT NULL,
  `genero` TEXT NULL,
  `edad` INT NULL,
  `email` TEXT NULL,
  UNIQUE INDEX `cliente_id_UNIQUE` (`cliente_id` ASC)
) ENGINE = InnoDB;

-- Tabla de proveedores
CREATE TABLE IF NOT EXISTS `proveedores` (
  `proveedor_id` INT NOT NULL PRIMARY KEY,
  `nombre_proveedor` TEXT NULL,
  `pais` TEXT NULL,
  `telefono` TEXT NULL
) ENGINE = InnoDB;

-- Tabla de productos
CREATE TABLE IF NOT EXISTS `productos` (
  `producto_id` INT NOT NULL PRIMARY KEY,
  `nombre_producto` TEXT NULL,
  `categoria` TEXT NULL,
  `precio_unitario` DOUBLE NULL,
  `proveedor_id` INT NULL,
  UNIQUE INDEX `producto_id_UNIQUE` (`producto_id` ASC),
  CONSTRAINT `fk_productos_proveedores`
    FOREIGN KEY (`proveedor_id`)
    REFERENCES `proveedores` (`proveedor_id`)
) ENGINE = InnoDB;

-- Tabla de promociones
CREATE TABLE IF NOT EXISTS `promociones` (
  `promocion_id` INT NOT NULL PRIMARY KEY,
  `producto_id` INT NOT NULL,
  `descuento` DOUBLE NULL,
  `fecha_inicio` DATE NULL,
  `fecha_fin` DATE NULL,
  `descripcion` TEXT NULL,
  CONSTRAINT `fk_promociones_productos`
    FOREIGN KEY (`producto_id`)
    REFERENCES `productos` (`producto_id`)
) ENGINE = InnoDB;

-- Tabla de stock
CREATE TABLE IF NOT EXISTS `stock` (
  `producto_id` INT NOT NULL,
  `sucursal` TEXT NULL,
  `stock_actual` INT NULL,
  `fecha_actualizacion` TEXT NULL,
  PRIMARY KEY (`producto_id`),
  CONSTRAINT `fk_stock_productos`
    FOREIGN KEY (`producto_id`)
    REFERENCES `productos` (`producto_id`)
) ENGINE = InnoDB;

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS `ventas` (
  `venta_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `fecha` DATE NULL,
  `producto_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `sucursal` VARCHAR(50) NULL,
  `cantidad` INT NULL,
  `total_venta` DECIMAL(10,2) NULL,
  INDEX `idx_producto` (`producto_id`),
  INDEX `idx_cliente` (`cliente_id`),
  CONSTRAINT `fk_ventas_productos`
    FOREIGN KEY (`producto_id`)
    REFERENCES `productos` (`producto_id`),
  CONSTRAINT `fk_ventas_clientes`
    FOREIGN KEY (`cliente_id`)
    REFERENCES `clientes` (`cliente_id`)
) ENGINE = InnoDB AUTO_INCREMENT = 151;

-- -------------------------------------------------------
-- CONSULTAS DE ANÁLISIS DE DATOS
-- -------------------------------------------------------

-- 1. Consultas básicas para verificar los datos
-- -------------------------------------------------------

-- Mostrar todos los registros de la tabla ventas
SELECT * FROM ventas;

-- Mostrar todos los registros de la tabla clientes
SELECT * FROM clientes;

-- Mostrar todos los registros de la tabla productos
SELECT * FROM productos;

-- Mostrar todos los registros de la tabla promociones
SELECT * FROM promociones;

-- Mostrar todos los registros de la tabla proveedores
SELECT * FROM proveedores;

-- 2. Actualización de datos
-- -------------------------------------------------------

-- Actualizar el género de los clientes para mayor claridad
-- Reemplazar "M" por "Masculino" en la columna género
UPDATE clientes
SET genero = "Masculino"
WHERE genero = "M";

-- Reemplazar "F" por "Femenino" en la columna género
UPDATE clientes
SET genero = "Femenino"
WHERE genero = "F";

-- 3. Análisis de ventas
-- -------------------------------------------------------

-- Calcular la recaudación total de todas las ventas
SELECT SUM(total_venta) AS Recaudacion_total
FROM ventas;

-- Calcular la cantidad total de productos vendidos
SELECT SUM(cantidad) AS Ventas_totales
FROM ventas;

-- Calcular el promedio de productos vendidos por venta
SELECT AVG(cantidad) AS Ventas_promedio
FROM ventas;

-- Mostrar los 3 días con más ventas (en cantidad), junto con la recaudación de cada día
SELECT 
    fecha, 
    COUNT(*) AS Cantidad_ventas, 
    SUM(total_venta) AS Recaudacion
FROM ventas
GROUP BY fecha
ORDER BY Cantidad_ventas DESC
LIMIT 3;

-- 4. Análisis de clientes
-- -------------------------------------------------------

-- Contar cuántos clientes hay por género
SELECT 
    genero, 
    COUNT(*) AS Recuento
FROM clientes
GROUP BY genero
ORDER BY Recuento DESC;

-- Mostrar nombres únicos de clientes (para verificar posibles duplicados)
SELECT DISTINCT nombre
FROM clientes;

-- Clasificar a los clientes según su edad
SELECT 
    nombre,
    edad,
    CASE 
        WHEN edad <= 25 THEN 'Adulto joven'
        WHEN edad > 25 AND edad < 60 THEN 'Adulto'
        WHEN edad >= 60 THEN 'Persona Mayor'
    END AS categoria_edad
FROM clientes;

-- Mostrar clientes cuya edad es mayor o igual al promedio de edades
SELECT 
    nombre, 
    edad
FROM clientes
WHERE edad >= (
    SELECT AVG(edad)
    FROM clientes
);

-- 5. Análisis de productos
-- -------------------------------------------------------

-- Contar cuántos productos hay por categoría
SELECT 
    categoria, 
    COUNT(*) AS Cantidad_productos
FROM productos
GROUP BY categoria
ORDER BY Cantidad_productos DESC;

-- Mostrar categoría y nombre del proveedor de productos lácteos
SELECT 
    p.categoria, 
    prov.nombre_proveedor
FROM productos p
INNER JOIN proveedores prov ON p.proveedor_id = prov.proveedor_id
WHERE p.categoria = "Lácteos"
ORDER BY prov.nombre_proveedor ASC;

-- 6. Consultas adicionales
-- -------------------------------------------------------

-- Productos más vendidos
SELECT 
    p.producto_id, 
    p.nombre_producto, 
    SUM(v.cantidad) AS Total_vendido
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
GROUP BY p.producto_id, p.nombre_producto
ORDER BY Total_vendido DESC
LIMIT 10;

-- Ventas por categoría de producto
SELECT 
    p.categoria, 
    SUM(v.cantidad) AS Unidades_vendidas, 
    SUM(v.total_venta) AS Ingresos_totales
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id
GROUP BY p.categoria
ORDER BY Ingresos_totales DESC;

-- Mejores clientes por valor total de compras
SELECT 
    c.cliente_id, 
    c.nombre, 
    SUM(v.total_venta) AS Total_compras
FROM ventas v
JOIN clientes c ON v.cliente_id = c.cliente_id
GROUP BY c.cliente_id, c.nombre
ORDER BY Total_compras DESC
LIMIT 10;