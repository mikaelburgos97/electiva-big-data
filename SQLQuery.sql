-- Nota: Este script crea vistas para indicadores de data warehouse basados en las bases de datos Northwind y Pubs.
-- Las vistas tienen prefijos NW_ para Northwind y PB_ para Pubs.

USE Northwind
GO

-- 1. Ventas Totales por Período (Año y Mes)
-- Northwind
CREATE VIEW NW_VentasTotalesPorPeriodo AS
SELECT 
    YEAR(o.OrderDate) AS Año,
    MONTH(o.OrderDate) AS Mes,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    YEAR(o.OrderDate), MONTH(o.OrderDate);
GO

-- 2. Ventas por Categoría de Producto
-- Northwind
CREATE VIEW NW_VentasPorCategoria AS
SELECT 
    c.CategoryName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Categories c
    JOIN Products p ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY 
    c.CategoryName;
GO

-- 3. Total de Ventas por Categoría (ya cubierto por la vista anterior)

-- 4. Ventas por Región/País
-- Northwind
CREATE VIEW NW_VentasPorRegionPais AS
SELECT 
    o.ShipCountry,
    o.ShipRegion,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    o.ShipCountry, o.ShipRegion;
GO

-- 5. Número de Pedidos Procesados por Empleado
-- Northwind
CREATE VIEW NW_PedidosPorEmpleado AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS NombreEmpleado,
    COUNT(o.OrderID) AS NumeroPedidos
FROM 
    Employees e
    LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName;
GO

-- 6. Productividad de Empleados (Ventas por Empleado)
-- Northwind
CREATE VIEW NW_ProductividadEmpleados AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS NombreEmpleado,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName;
GO

-- 7. Clientes Atendidos por Empleado
-- Northwind
CREATE VIEW NW_ClientesPorEmpleado AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS NombreEmpleado,
    COUNT(DISTINCT o.CustomerID) AS NumeroClientes
FROM 
    Employees e
    LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName;
GO

-- 8. Productos Más Vendidos
-- Northwind
CREATE VIEW NW_ProductosMasVendidos AS
SELECT TOP 10
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS CantidadVendida
FROM 
    Products p
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    CantidadVendida DESC;
GO

-- 9. Productos Más Vendidos por Categoría
-- Northwind
CREATE VIEW NW_ProductosMasVendidosPorCategoria AS
SELECT 
    c.CategoryName,
    p.ProductName,
    SUM(od.Quantity) AS CantidadVendida,
    ROW_NUMBER() OVER (PARTITION BY c.CategoryID ORDER BY SUM(od.Quantity) DESC) AS Ranking
FROM 
    Categories c
    JOIN Products p ON c.CategoryID = p.CategoryID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY 
    c.CategoryID, c.CategoryName, p.ProductName;
GO

-- 10. Total de Ventas por Transportista
-- Northwind
CREATE VIEW NW_VentasPorTransportista AS
SELECT 
    s.ShipperID,
    s.CompanyName AS Transportista,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Shippers s
    JOIN Orders o ON s.ShipperID = o.ShipVia
    JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    s.ShipperID, s.CompanyName;
GO

-- 11. Número de Órdenes Enviadas por Transportista
-- Northwind
CREATE VIEW NW_OrdenesPorTransportista AS
SELECT 
    s.ShipperID,
    s.CompanyName AS Transportista,
    COUNT(o.OrderID) AS NumeroOrdenes
FROM 
    Shippers s
    LEFT JOIN Orders o ON s.ShipperID = o.ShipVia
GROUP BY 
    s.ShipperID, s.CompanyName;
GO

-- 12. Total de Ventas por Cliente
-- Northwind
CREATE VIEW NW_VentasPorCliente AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS VentaTotal
FROM 
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    c.CustomerID, c.CompanyName;
GO

-- 13. Número de Órdenes por Cliente
-- Northwind
CREATE VIEW NW_OrdenesPorCliente AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    COUNT(o.OrderID) AS NumeroOrdenes
FROM 
    Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.CompanyName;
GO

-- Ahora cambiamos a la base de datos Pubs
USE pubs
GO

-- 1. Ventas Totales por Período (Año y Mes)
-- Pubs
CREATE VIEW PB_VentasTotalesPorPeriodo AS
SELECT 
    YEAR(s.ord_date) AS Año,
    MONTH(s.ord_date) AS Mes,
    SUM(s.qty * t.price) AS VentaTotal
FROM 
    sales s
    JOIN titles t ON s.title_id = t.title_id
GROUP BY 
    YEAR(s.ord_date), MONTH(s.ord_date);
GO

-- 2. Ventas por Categoría de Producto
-- Pubs
CREATE VIEW PB_VentasPorCategoria AS
SELECT 
    t.type AS Categoria,
    SUM(s.qty * t.price) AS VentaTotal
FROM 
    titles t
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    t.type;
GO

-- 4. Ventas por Región/País
-- Pubs
CREATE VIEW PB_VentasPorRegionPais AS
SELECT 
    st.state AS Region,
    st.country AS Pais,
    SUM(s.qty * t.price) AS VentaTotal
FROM 
    sales s
    JOIN stores st ON s.stor_id = st.stor_id
    JOIN titles t ON s.title_id = t.title_id
GROUP BY 
    st.state, st.country;
GO

-- 5. Número de Pedidos Procesados por Empleado
-- Pubs (Nota: Esta vista es una aproximación, ya que Pubs no tiene una relación directa entre empleados y ventas)
CREATE VIEW PB_PedidosPorEmpleado AS
SELECT 
    e.emp_id,
    e.fname + ' ' + e.lname AS NombreEmpleado,
    COUNT(DISTINCT s.ord_num) AS NumeroPedidos
FROM 
    employee e
    JOIN publishers p ON e.pub_id = p.pub_id
    JOIN titles t ON p.pub_id = t.pub_id
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    e.emp_id, e.fname, e.lname;
GO

-- 6. Productividad de Empleados (Ventas por Empleado)
-- Pubs (Nota: Esta vista es una aproximación, ya que Pubs no tiene una relación directa entre empleados y ventas)
CREATE VIEW PB_ProductividadEmpleados AS
SELECT 
    e.emp_id,
    e.fname + ' ' + e.lname AS NombreEmpleado,
    SUM(s.qty * t.price) AS VentaTotal
FROM 
    employee e
    JOIN publishers p ON e.pub_id = p.pub_id
    JOIN titles t ON p.pub_id = t.pub_id
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    e.emp_id, e.fname, e.lname;
GO

-- 7. Clientes Atendidos por Empleado
-- Pubs (Nota: Esta vista es una aproximación, ya que Pubs no tiene una relación directa entre empleados y clientes)
CREATE VIEW PB_ClientesPorEmpleado AS
SELECT 
    e.emp_id,
    e.fname + ' ' + e.lname AS NombreEmpleado,
    COUNT(DISTINCT s.stor_id) AS NumeroClientes
FROM 
    employee e
    JOIN publishers p ON e.pub_id = p.pub_id
    JOIN titles t ON p.pub_id = t.pub_id
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    e.emp_id, e.fname, e.lname;
GO

-- 8. Productos Más Vendidos
-- Pubs
CREATE VIEW PB_ProductosMasVendidos AS
SELECT TOP 10
    t.title_id,
    t.title AS Titulo,
    SUM(s.qty) AS CantidadVendida
FROM 
    titles t
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    t.title_id, t.title
ORDER BY 
    CantidadVendida DESC;
GO

-- 9. Productos Más Vendidos por Categoría
-- Pubs
CREATE VIEW PB_ProductosMasVendidosPorCategoria AS
SELECT 
    t.type AS Categoria,
    t.title AS Titulo,
    SUM(s.qty) AS CantidadVendida,
    ROW_NUMBER() OVER (PARTITION BY t.type ORDER BY SUM(s.qty) DESC) AS Ranking
FROM 
    titles t
    JOIN sales s ON t.title_id = s.title_id
GROUP BY 
    t.type, t.title;
GO

-- 12. Total de Ventas por Cliente
-- Pubs
CREATE VIEW PB_VentasPorCliente AS
SELECT 
    st.stor_id,
    st.stor_name AS NombreCliente,
    SUM(s.qty * t.price) AS VentaTotal
FROM 
    stores st
    JOIN sales s ON st.stor_id = s.stor_id
    JOIN titles t ON s.title_id = t.title_id
GROUP BY 
    st.stor_id, st.stor_name;
GO

-- 13. Número de Órdenes por Cliente
-- Pubs
CREATE VIEW PB_OrdenesPorCliente AS
SELECT 
    st.stor_id,
    st.stor_name AS NombreCliente,
    COUNT(DISTINCT s.ord_num) AS NumeroOrdenes
FROM 
    stores st
    JOIN sales s ON st.stor_id = s.stor_id
GROUP BY 
    st.stor_id, st.stor_name;
GO

-- Nota final: Este script ha creado vistas para ambas bases de datos, Northwind y Pubs.
-- Las vistas de Northwind son más completas debido a la estructura de la base de datos.
-- Las vistas de Pubs son aproximaciones en algunos casos debido a las limitaciones de su estructura.