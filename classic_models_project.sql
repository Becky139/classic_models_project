-- Calculate the average order amount for each country
SELECT c.country, AVG(od.quantityOrdered * od.priceEach) AS avg_order_amount
FROM classicmodels.customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber
INNER JOIN orderdetails od ON O.orderNumber = od.orderNumber
GROUP BY country 
ORDER BY avg_order_amount DESC;

-- Calculate the total sales amount for each product line

SELECT pl.productLine, SUM(od.quantityOrdered * od.priceEach) AS total_sales
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
JOIN productlines pl ON p.productLine = pl.productLine
GROUP BY pl.productLine
ORDER BY total_sales DESC;

-- List the top 10 best-selling products based on total quantity sold

SELECT p.productName, SUM(od.quantityOrdered) AS total_quantity_sold
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productName
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Evaluate the sales performance of each sales representative

SELECT e.firstName, e.lastName, SUM(quantityOrdered * priceEach) AS order_value
FROM employees e
INNER JOIN customers c 
ON employeeNumber = salesRepEmployeeNumber AND e.jobTitle = 'Sales Rep'
LEFT JOIN orders o
ON c.customerNumber = o.customerNumber
LEFT JOIN orderdetails od
ON o.orderNumber = od.orderNumber
GROUP BY e.firstName, e.lastName;

-- Calculate the average number of orders placed by each customer

SELECT COUNT(o.orderNumber) / COUNT(DISTINCT c.customerNumber) AS avg_orders_per_customer 
FROM customers c
LEFT JOIN orders o ON c.customerNumber = o.customerNumber;

-- Calculate the percentage of orders that were shipped on time

SELECT 
    SUM(CASE WHEN o.shippedDate <= o.requiredDate THEN 1 ELSE 0 END) / COUNT(*) * 100 AS percentage_on_time
FROM orders o;

select *
from orders o
where o.shippedDate >= o.requiredDate;

-- Calculate the profit margin for each product by subtracting the cost of goods sold (COGS) from the sales revenue

SELECT productName, SUM((priceEach*quantityOrdered) - (buyPrice*quantityOrdered)) AS net_profit
FROM products p
INNER JOIN orderdetails o 
ON p.productCode = o.productCode
GROUP BY productName;

SELECT 
    p.productCode,
    p.productName,
    (SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice)) AS profit_margin
FROM 
    products p
JOIN 
    orderdetails od ON p.productCode = od.productCode
GROUP BY 
    p.productCode, p.productName;
    
-- Segment customers based on their total purchase amount

SELECT 
    customerNumber,
    total_purchase_amount,
    CASE 
        WHEN total_purchase_amount > 100000 THEN 'High Value'
        WHEN total_purchase_amount > 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM 
    (SELECT customerNumber, SUM(quantityOrdered * priceEach) AS total_purchase_amount
     FROM orderdetails OD
     INNER JOIN orders O ON od.orderNumber = o.orderNumber
     GROUP BY customerNumber) AS customer_purchase_amounts;
     
select *
from customers c
left join 
(
SELECT 
    customerNumber,
    total_purchase_amount,
    CASE 
        WHEN total_purchase_amount > 100000 THEN 'High Value'
        WHEN total_purchase_amount > 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM 
    (SELECT customerNumber, SUM(quantityOrdered * priceEach) AS total_purchase_amount
     FROM orderdetails OD
     INNER JOIN orders O ON od.orderNumber = o.orderNumber
     GROUP BY customerNumber) AS customer_purchase_amounts
) v
on c.customerNumber = v.customerNumber
;

-- Identify frequently co-purchased products to understand cross-selling opportunities
SELECT 
    od1.productCode AS product1,
    p1.productname AS productname1, 
    od2.productCode AS product2,
    p2.productname AS productname2,
    COUNT(*) AS co_purchase_count
FROM 
    orderdetails od1
JOIN 
    orderdetails od2 ON od1.orderNumber = od2.orderNumber AND od1.productCode <> od2.productCode
JOIN 
	products p1 ON od1.productCode = p1.productCode
JOIN 
	products p2 ON od2.productCode = p2.productCode
GROUP BY 
    product1, productname1, product2, productname2
ORDER BY 
    co_purchase_count DESC;
    