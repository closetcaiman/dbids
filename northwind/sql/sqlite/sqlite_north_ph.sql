CREATE TABLE product_history (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   productid INT,
   productname VARCHAR(40) NOT NULL,
   supplierid INT,
   categoryid INT,
   quantityperunit VARCHAR(20),
   unitprice DECIMAL(10,2),
   quantity INT,
   value DECIMAL(10,2),
   date DATE
);

INSERT INTO product_history (
    productid, productname, supplierid, categoryid, 
    quantityperunit, unitprice, quantity, value, date
)
WITH RECURSIVE days(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM days WHERE n < 30000
)
SELECT 
    p.ProductID, 
    p.ProductName, 
    p.SupplierID, 
    p.CategoryID,
    p.QuantityPerUnit,
    ROUND(ABS(RANDOM() % 100) * 0.1 * p.UnitPrice + 10, 2),
    CAST(ABS(RANDOM() % 50) + 10 AS INT),
    0,
    DATE('1940-01-01', '+' || n || ' day')
FROM days
CROSS JOIN Products p;

UPDATE product_history
SET value = unitprice * quantity;