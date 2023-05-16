# 1.(1) Find model number, speed and size of hd for all PC, that cost at least $500 dollars. Show only model, speed and hd

SELECT model, speed, hd FROM pc WHERE price<500


# 1.(2) Find all printer manufacturers. Output: creator

SELECT DISTINCT maker FROM product WHERE type='Printer'


# 1.(3) Find model number, memory capacity and screen sizes of PC notebooks, the price of which exceeds $1,000

SELECT model, ram, screen FROM laptop WHERE price>1000


# 1.(4) Find all entries from the Printer table for color printers.

SELECT * FROM Printer WHERE color='y'


# 1.(5) Find the model number, speed and size of the hard disk with a 12x or 24x CD and a price of less than $600

Select model, speed, hd from PC where (CD='12x' or CD='24x') and price<600


# 2.(6) For each manufacturer that produces laptops with a hard disk capacity of at least 10 GB, find the speeds. Show only manufacturer and speed.

SELECT DISTINCT Product.maker, Laptop.speed FROM Laptop 
FULL OUTER JOIN Product ON Product.model=Laptop.model
WHERE Laptop.hd>=10
ORDER BY speed


# 2.(7) Find the model numbers and prices of all commercially available products (of any type) from manufacturer B

SELECT DISTINCT b.model, b.price FROM 
(SELECT model, price FROM PC
UNION ALL
SELECT model, price FROM Laptop
UNION ALL
SELECT model, price FROM Printer) AS b 
INNER JOIN Product ON Product.model=b.model
WHERE Product.maker='B'


# 2.(8) Find a manufacturer that produces PCs, but not laptops

SELECT DISTINCT maker FROM Product WHERE type ='PC'
EXCEPT 
SELECT DISTINCT maker FROM Product WHERE type = 'Laptop'


# 3.(58) For each type of product and each manufacturer from the Product table with an accuracy of two decimal places, find the percentage ratio of the number of models of this type of this manufacturer to the total number of models of this manufacturer

With all_makers_types AS (Select DISTINCT p.maker as maker, p1.type as type FROM Product as p CROSS JOIN Product as p1)
 
SELECT t1.maker, t1.type, CAST(CAST(COUNT(model) AS NUMERIC(6,2))
/(SUM(COUNT(model)) OVER(PARTITION BY t1.maker))*100 AS NUMERIC(6,2))
FROM all_makers_types AS t1
LEFT JOIN Product ON t1.maker = Product.maker AND t1.type = Product.type
GROUP BY t1.maker, t1.type


# 3.(65) Rank the unique {maker, type} pairs from Product, ordering them as follows:
- the name of the manufacturer (maker) in ascending order;
- Product type (type) in the order of PC, Laptop, Printer.
If a certain manufacturer produces several types of products, then output his name only in the first line;
the remaining lines for THIS manufacturer must contain an empty string of characters (").

WITH temp AS (Select DISTINCT maker, type, LEN(type) as sort FROM Product)
, makers AS (Select ROW_NUMBER() OVER(ORDER BY maker ASC, sort ASC) as num, maker, type, ROW_NUMBER() OVER(PARTITION BY maker ORDER BY maker, sort) as m 
FROM temp)

Select num, CASE WHEN m = 1 THEN maker ELSE '' END as maker, type FROM makers

