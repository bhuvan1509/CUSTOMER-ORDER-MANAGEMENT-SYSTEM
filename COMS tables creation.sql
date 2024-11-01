-- data base
use supplychain;

-- set auto commit on
SET AUTOCOMMIT = on;
show tables;
rollback;


-- To create 5 tables
Create table Payments
(
  order_id varchar(20),
  payment_sequential int,
  payment_type varchar(20),
  payment_installments int,
  payment_value decimal
);
desc Payments;
Create table Products
(
  product_id varchar(20),
  product_category_name	varchar(20),
  product_weight_g int,
  product_length_cm	int,
  product_height_cm	int,
  product_width_cm int
);

Create table Customers
(
  customer_id varchar(20),
  customer_zip_code_prefix varchar(20),
  customer_city	varchar(20),
  customer_state varchar(20)
);

Create table OrderItems
(
  order_id	varchar(20),
  product_id varchar(20),
  seller_id	varchar(20),
  price decimal,
  shipping_charges decimal
);
Create table Orders
(
 order_id varchar(50),
 customer_id varchar(50),
 order_status varchar(50),
 order_purchase_date date,
 order_purchase_time time,
 order_approved_at date,
 order_approved_time time,
 order_delivered_date date,
 order_delivered_time time,
 order_estimated_delivery_date date
);

show tables;

-- To find the last 5 rows from the table
WITH OrderedRows AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (ORDER BY order_purchase_timestamp) AS rownum
    FROM 
        Orders
)
SELECT *
FROM OrderedRows
WHERE rownum > (SELECT MAX(rownum) - 5 FROM OrderedRows);




-- to change the data type of a column
ALTER TABLE Customers
MODIFY customer_zip_code_prefix VARCHAR(50);

ALTER TABLE orderitems
MODIFY shipping_charges decimal(10,2);

ALTER TABLE orderitems
MODIFY price decimal(10,2);

ALTER TABLE orderitems 
MODIFY order_id varchar(50);

ALTER TABLE orderitems 
MODIFY product_id varchar(50);

ALTER TABLE orderitems 
MODIFY seller_id varchar(50);

ALTER TABLE payments 
MODIFY order_id varchar(30);

ALTER TABLE payments
MODIFY payment_value decimal(10,2);

ALTER TABLE products 
MODIFY product_category_name varchar(50);

ALTER TABLE products 
MODIFY Product_id varchar(30);



SELECT * FROM customers;
SELECT * FROM orderitems;
SELECT * FROM orders; 
SELECT * FROM payments;
SELECT * FROM Products;


desc orders;


select count(*) from customers; 
select count(*) from orderitems;
select count(*) from orders;
select count(*) from Products; 
select count(*) from Payments; 






