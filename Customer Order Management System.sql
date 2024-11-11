-- SQL analysis
-- SELECT, WHERE and JOINS... Queries

	-- Retrieve all orders: Write a query to retrieve all orders placed in the last 30 days.
	SELECT * FROM customers c
    JOIN orders o ON  c.customer_id = o.customer_id
    ORDER BY order_purchase_date DESC
    limit 30;
    
	-- Retrieve all customers who have placed orders worth more than $1000. 
    SELECT DISTINCT(c.customer_id), o.order_id, o.order_status, p.payment_installments, p.payment_value
    from customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE payment_value >= 1000.00
    ORDER BY payment_value;
    
    -- count pf customers
    SELECT COUNT(DISTINCT(c.customer_id))
    from customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    WHERE payment_value >= 1000.00
    ORDER BY payment_value;
    -- Identify customers from a specific city who made multiple purchases in the last month.
    SELECT c.customer_id, c.customer_city, COUNT(order_id) AS no_of_orders
    FROM customers c
    JOIN orders o on c.customer_id = o.customer_id
    WHERE o.order_purchase_date >= NOW() - INTERVAL 30 DAY
    GROUP BY c.customer_id, c.customer_city
    HAVING no_of_orders > 1 
    ORDER BY c.customer_id, c.customer_city;
    
    -- Retrieve order details for orders containing a specific product category.
    SELECT DISTINCT(p.product_category_name) ,o.order_id, o.order_purchase_date
	FROM orders o
	JOIN orderitems oi ON o.order_id = oi.order_id
	JOIN products p ON oi.product_id = p.product_id
    WHERE p.product_category_name IS NOT NULL AND TRIM(p.product_category_name) != " "
    ORDER BY p.product_category_name ASC;
    
	-- Find customers who have made a purchase (for each payment method).
	SELECT c.customer_id, c.customer_city , p.payment_type
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN payments p ON o.order_id = p.order_id
    ORDER BY c.customer_city,c.customer_id, p.payment_type;
    
    -- for specific payment type (say wallet)
    SELECT DISTINCT c.customer_id, c.customer_city , p.payment_type
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_type = 'wallet';
	
    SELECT DISTINCT p.payment_type 
	FROM payments p;

	-- Calculate the total revenue generated from each product category.
	SELECT p.product_category_name, SUM(oi.price) as total_revenue 
	FROM products p
	JOIN orderitems oi ON p.product_id = oi.product_id
	GROUP BY p.product_category_name
	ORDER BY total_revenue DESC;
    
    -- Determine the average shipping charges per product category.
    SELECT p.product_category_name, AVG(oi.shipping_charges) as avg_shipping_charges 
	FROM products p
	JOIN orderitems oi ON p.product_id = oi.product_id
    WHERE p.product_category_name IS NOT NULL AND TRIM(p.product_category_name) != " "
	GROUP BY p.product_category_name;
    
    -- Find the top 10 customers by total amount spent.
    SELECT c.customer_id, SUM(p.payment_value) as total_spent 
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN payments p ON o.order_id = p.order_id
	GROUP BY c.customer_id
	ORDER BY total_spent DESC
	LIMIT 10;

-- ------------------------------------------------------------------------------------------------------------------
-- Aggregate Functions
	-- Total sales: Calculate the total sales value from the payments table.
    SELECT * from payments;
    SELECT sum(Payment_value) as total_sales
	FROM payments;
    
	-- Calculate the total sales value for each payment type.
    SELECT payment_type , sum(payment_value) as total_sales
    FROM payments
    GROUP BY payment_type
    ORDER BY payment_type;
	-- Determine the average order value.
    SELECT AVG(payment_value) as avg_ordervalue
    FROM payments ;
    
    -- Identify the maximum and minimum values of orders.
    SELECT MAX(payment_value) AS max_order_value, MIN(payment_value) AS min_order_value
	FROM payments;
    
    SELECT (SELECT payment_value FROM payments
    ORDER BY payment_value DESC
    LIMIT 5) as top5, 
     (SELECT payment_value FROM payments
    ORDER BY payment_value ASC
    LIMIT 5) as bottom5
    from payments;
 
    -- Assigning top and botton , UNIONALL
	SELECT payment_value, 'top' AS type
	FROM (
		SELECT payment_value, ROW_NUMBER() OVER (ORDER BY payment_value DESC) AS rn
		FROM payments
	) sub1
	WHERE rn <= 5 -- one select stmt ended
	UNION ALL
	SELECT payment_value, 'bottom' AS type  -- Second select stmt started
	FROM (
		SELECT payment_value, ROW_NUMBER() OVER (ORDER BY payment_value ASC) AS rn
		FROM payments
	) sub2
	WHERE rn <= 5;
    -- ---
    -- CTE starts with WITH clause
	WITH 
    top_payments AS (
    SELECT payment_value, 'top' AS type 
    FROM payments 
    ORDER BY payment_value DESC 
    LIMIT 5
	),
	bottom_payments AS (
    SELECT payment_value, 'bottom' AS type 
    FROM payments 
    ORDER BY payment_value ASC 
    LIMIT 5
	)	
	SELECT * FROM top_payments
	UNION ALL
	SELECT * FROM bottom_payments;
    
    -- HOW CAN YOU LIST OUT TOP 5 AND BOTTOM 5 ORDERS
    -- USING COMMON TABLE EXPRESSION ( CTE ) , for side by side vies of top5 and bottom5
	WITH 
    top_5 AS (
		SELECT payment_value AS top_5, 
			   ROW_NUMBER() OVER (ORDER BY payment_value DESC) AS rn
		FROM payments 
		ORDER BY payment_value DESC 
		LIMIT 5
	),
	bottom_5 AS (
		SELECT payment_value AS bottom_5, 
			   ROW_NUMBER() OVER (ORDER BY payment_value ASC) AS rn
		FROM payments 
		ORDER BY payment_value ASC 
		LIMIT 5
	)
	SELECT t.top_5, b.bottom_5
	FROM top_5 t
	JOIN bottom_5 b ON t.rn = b.rn;

-- ------------------------------------------------------------------------------------------------------------------

-- Window Functions
	-- How can you list OUT top5 5 and bottom 5 orders
	SELECT 
    MAX(CASE WHEN rn_top <= 5 THEN payment_value END) AS Top1,
    MAX(CASE WHEN rn_top = 2 THEN payment_value END) AS Top2,
    MAX(CASE WHEN rn_top = 3 THEN payment_value END) AS Top3,
    MAX(CASE WHEN rn_top = 4 THEN payment_value END) AS Top4,
    MAX(CASE WHEN rn_top = 5 THEN payment_value END) AS Top5,
    MAX(CASE WHEN rn_bottom <= 5 THEN payment_value END) AS Bottom1,
    MAX(CASE WHEN rn_bottom = 2 THEN payment_value END) AS Bottom2,
    MAX(CASE WHEN rn_bottom = 3 THEN payment_value END) AS Bottom3,
    MAX(CASE WHEN rn_bottom = 4 THEN payment_value END) AS Bottom4,
    MAX(CASE WHEN rn_bottom = 5 THEN payment_value END) AS Bottom5
	FROM (
		SELECT 
			payment_value,
			ROW_NUMBER() OVER (ORDER BY payment_value DESC) AS rn_top,
			ROW_NUMBER() OVER (ORDER BY payment_value ASC) AS rn_bottom  -- this select stmt will return a table with 2columns with same data but in reverse order ie ,.asc and desc
		FROM payments
	) sub;

	-- How can you rank orders based on the purchase value within each customer group?
	SELECT  c.customer_id, o.order_id,p.payment_value,
			rank() OVER(ORDER BY p.payment_value DESC) as Rank_of_order
	From customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id;
    
	-- Running total of sales: Calculate the running total of sales for each day.
    SELECT o.order_purchase_date, 
		   SUM(p.payment_value) OVER (PARTITION BY o.order_purchase_date 
							          ORDER BY o.order_purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_sales
	FROM orders o
	JOIN payments p ON o.order_id = p.order_id;
    
	 -- How can you calculate the sum of shipping charges for each seller?
     SELECT seller_id, 
			SUM(shipping_charges) OVER(PARTITION BY seller_id ORDER BY shipping_charges) AS sc_of_seller
     FROM orderitems;
     
     -- How can you assign a unique row number to each customer within each state in the CUSTOMERS table?
	 SELECT ROW_NUMBER() OVER( PARTITION BY customer_state ORDER BY customer_id ASC ) AS r_num,
			customer_id, customer_state
     FROM customers;


	-- Ranking products: Rank products by total sales within each category and also CATEGORY RANK .
    WITH 
    ranked_orders_in_categories AS
    (
    SELECT p.product_category_name, p.product_id ,
		   SUM(pt.payment_value) AS total_sales,
		   RANK() OVER( PARTITION BY p.product_category_name ORDER BY SUM(pt.payment_value) DESC) AS rank_in_category
   FROM products p
   JOIN orderitems oi ON p.product_id = oi.product_id
   JOIN orders o ON oi.order_id = o.order_id
   JOIN payments pt ON pt.order_id = o.order_id
   WHERE p.product_category_name IS NOT NULL AND TRIM(p.product_category_name) != ""
   GROUP BY p.product_category_name,p.product_id
   )
   SELECT product_category_name, product_id ,
		  total_sales,
		  rank_in_category,
          DENSE_RANK() OVER(ORDER BY  product_category_name ) AS cat_rank
	FROM ranked_orders_in_categories
    ORDER BY product_category_name, rank_in_category;
   

	-- Customer purchase frequency: Calculate the frequency of purchases by each customer.
    SELECT 
    c.customer_id, 
    COUNT(o.order_id) AS purchase_frequency
    FROM customers c
    join orders o ON c.customer_id = o.customer_id
    where COUNT(o.order_id) > 1 
    GROUP BY c.customer_id
    ORDER BY purchase_frequency DESC;
    
    -- How do you compare each product's weight to the previous and next product's weight in the PRODUCTS table?
	SELECT 
		product_id,
        product_weight_g,
        LAG(product_weight_g) OVER( ORDER BY product_id ) AS privious_p_w,
        LEAD(product_weight_g) OVER(ORDER BY product_id) AS next_p_w
    FROM products
    ORDER BY product_id;

	-- How can you calculate the cumulative sum of payment values over time for each order?
    SELECT 
		o.order_id,
        p.payment_type,
        p.payment_value,
        SUM(p.payment_value) OVER( ORDER BY o.order_purchase_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS cumulative_sum
    FROM ORDERS o
    JOIN payments p ON o.order_id = p.order_id;
    
	-- How do you rank product categories based on the total number of sales in each category?	
    SELECT 
	p.product_category_name,
    COUNT(o.order_id) AS total_sales    ,
    DENSE_RANK() OVER( ORDER BY COUNT(o.order_id) DESC) AS cat_rank
    FROM orders o
    JOIN orderitems oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.Product_id
    GROUP BY p.product_category_name
    HAVING p.product_category_name IS NOT NULL AND TRIM(p.product_category_name) != ''
    ORDER BY cat_rank ASC;
    
	-- What is the first and last purchase date for each customer?
    SELECT 
         c.customer_id,
         FIRST_VALUE (o.order_purchase_date) OVER( PARTITION BY c.customer_id ORDER BY o.order_purchase_date)  AS first_val,
         LAST_VALUE(o.order_purchase_date) OVER( PARTITION BY c.customer_id ORDER BY o.order_purchase_date DESC) AS last_val
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id;
    
	-- How do you calculate the moving average of product prices over a series of orders?
    SELECT 
		o.order_id,
        oi.product_id,
        oi.price AS product_price,
        AVG(oi.price) OVER( ORDER BY order_purchase_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS m_avg_product_price
    FROM orders o
    JOIN orderitems oi ON o.order_id = oi.order_id;
    
-- ------------------------------------------------------------------------------------------------------------------

-- Views
	CREATE VIEW order_details_view AS
	SELECT o.order_id, o.order_status, o.order_purchase_date, 
		   c.customer_id, c.customer_city, c.customer_state,
		   oi.product_id, p.product_category_name
	FROM orders o
	JOIN customers c ON o.customer_id = c.customer_id
	JOIN orderitems oi ON o.order_id = oi.order_id
	JOIN products p ON oi.product_id = p.product_id;

DESCRIBE order_details_view;

-- ------------------------------------------------------------------------------------------------------------------

-- Indexing
	-- How do you create a composite index on the product_id and seller_id columns in the ORDERITEMS table?
	CREATE INDEX index_pid_sid ON orderitems(product_id, seller_id);


	SHOW INDEX FROM orderitems;
	desc orderitems;
	select count(*) from orderitems;
    
-- --------------------------------------------------------------------------------------------------------------------
-- Functions
	-- Calculate Total Order Value (including Shipping Charges)
	DELIMITER $$

	CREATE FUNCTION calculate_total_order_value(orderId INT)
	RETURNS DECIMAL(10, 2)
	BEGIN
		DECLARE totalValue DECIMAL(10, 2);

		SELECT SUM(oi.price + oi.shipping_charges)
		INTO totalValue
		FROM ORDERITEMS oi
		WHERE oi.order_id = orderId;

		RETURN totalValue;
	END$$

	DELIMITER ;



