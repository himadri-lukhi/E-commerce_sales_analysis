CREATE TABLE customer(
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

SELECT * FROM customer;


CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat DECIMAL(10, 7),
    geolocation_lng DECIMAL(10, 7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

SELECT * FROM geolocation;


CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

SELECT * FROM order_items;


CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value DECIMAL(10,2)
);

SELECT * FROM payments;


CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

SELECT * FROM reviews;


CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

SELECT * FROM orders;


CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);
ALTER TABLE products
ALTER COLUMN product_name_lenght TYPE DECIMAL(10,2),
ALTER COLUMN product_photos_qty TYPE DECIMAL(10,2),
ALTER COLUMN product_description_lenght TYPE DECIMAL(10,2);

SELECT * FROM products;


CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);
SELECT * FROM sellers;


CREATE TABLE category_translation (
    category_name VARCHAR(100),
    category_eng VARCHAR(100)
);

SELECT * FROM category_translation;



-- How much revenue did the business generate overall? TOTAL REVENUE
select sum(price) as total_revenue
from order_items;

-- How many actual orders did the business receive?
select distinct count(order_id) as total_orders
from orders;
-- How many actual customers do we have?
select distinct count(customer_unique_id) as total_customers
from customer;

-- On average, how much revenue does one order generate?
select sum(oi.price)/  count(distinct(o.order_id)) 
from order_items oi
join orders o 
on o.order_id = oi.order_id

-- What is the overall monthly revenue pattern?
select extract('month' from o.order_purchase_timestamp) as month_no,
		to_char(o.order_purchase_timestamp,'Month') as month,
		sum(oi.price) as total_revenue
		
from orders o
join order_items oi
on o.order_id = oi.order_id

group by extract('month' from o.order_purchase_timestamp),
		to_char(o.order_purchase_timestamp,'Month')
order by month_no;

-- When revenue goes up or down, are orders moving in the same direction? 
-- total monthly orders by 3 yrs 
select extract('month' from o.order_purchase_timestamp) as month_no,
		to_char(o.order_purchase_timestamp,'Month') as month,
		count(distinct(o.order_id)) as total_orders
		
from orders o
group by extract('month' from o.order_purchase_timestamp),
		to_char(o.order_purchase_timestamp,'Month')
order by month_no;


-- AOV
select extract('month' from o.order_purchase_timestamp) as month_no,
		to_char(o.order_purchase_timestamp,'Month') as month,
		sum(oi.price) / count(distinct(o.order_id)) as aov
		
from orders o
join order_items oi
on o.order_id = oi.order_id
group by extract('month' from o.order_purchase_timestamp),
		to_char(o.order_purchase_timestamp,'Month')
order by month_no;


-- total orders is aug 2018
select extract('month' from o.order_purchase_timestamp) as month_no,
		to_char(o.order_purchase_timestamp,'Month') as month,
		count(distinct(o.order_id)) as total_orders
		
from orders o
where order_purchase_timestamp  >= '2018-08-01' and  o.order_purchase_timestamp < '2018-09-01' 
group by extract('month' from o.order_purchase_timestamp),
		to_char(o.order_purchase_timestamp,'Month')
order by month_no;


-- If orders decreased, which categories caused the decline in order volume?
--aug 2018 orders by category 
select p.product_category_name, c.category_eng,
		count(distinct(o.order_id)) as aug_orders,
		o.order_status
from orders o
join order_items oi
on o.order_id = oi.order_id
join products p
on p.product_id = oi.product_id 
join category_translation c
on p.product_category_name = c.category_name
where  o.order_purchase_timestamp >= '2018-08-01' and  o.order_purchase_timestamp < '2018-09-01'
		
group by product_category_name, c.category_eng,o.order_status
order by aug_orders desc,order_status;

-- total sept 2018 orders 
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp >= '2018-09-01'
  AND o.order_purchase_timestamp < '2018-10-01'
ORDER BY o.order_purchase_timestamp;


-- sept orders by category(having order item)
select p.product_category_name, c.category_eng,
		count(distinct(o.order_id)) as sept_orders,
		o.order_status
from orders o
join order_items oi
on o.order_id = oi.order_id
join products p
on p.product_id = oi.product_id 
join category_translation c
on p.product_category_name = c.category_name
where  o.order_purchase_timestamp >= '2018-09-01' and  o.order_purchase_timestamp < '2018=10-01'
group by product_category_name, c.category_eng , o.order_status
order by sept_orders ,order_status;


-- sept orders that are not having order items
select
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
from orders o
left join order_items oi
    on o.order_id = oi.order_id
where o.order_purchase_timestamp >= '2018-09-01'
  and o.order_purchase_timestamp < '2018-10-01'
  and oi.order_id IS NULL
order by o.order_purchase_timestamp;


-- What happened to the cancelled September orders in the order fulfillment process?
select * from orders
where order_purchase_timestamp >= '2018-09-01'and order_purchase_timestamp < '2018-10-01'
   		and order_status = 'canceled'
order by order_purchase_timestamp;

-- Did these cancelled orders ever receive payment?
select o.order_id,o.order_status,SUM(p.payment_value) as payment_value
from orders o
left join payments p
on o.order_id = p.order_id
where order_purchase_timestamp >= '2018-09-01'and order_purchase_timestamp < '2018-10-01' 
		and order_status = 'canceled'
group by o.order_id , o.order_status
order by o.order_id;


-- Which payment methods were used for the cancelled September orders?
select  o.order_id,p.payment_type, o.order_status, SUM(p.payment_value) as payment_value
from orders o
left join payments p
on o.order_id = p.order_id
where order_purchase_timestamp >= '2018-09-01'and order_purchase_timestamp < '2018-10-01' 
		and order_status = 'canceled'
group by o.order_id , o.order_status,p.payment_type
order by o.order_id;


-- Did the proportion of voucher orders that were cancelled increase dramatically in September?
select extract('month'from order_purchase_timestamp)as month_no,to_char(order_purchase_timestamp,'month')as month,
		p.payment_type, count(distinct(o.order_id))as total_orders,
		count(distinct case 
						when o.order_status='canceled'
						then o.order_id end)as cancelled_orders,
		round(count(distinct case 
						when o.order_status='canceled'
						then o.order_id end) * 100.0
						/count(distinct(o.order_id)),2)as cancellation_rate

from orders o
join payments p
on o.order_id = p.order_id
where order_purchase_timestamp >= '2018-08-01'and order_purchase_timestamp < '2018-10-01' 
group by p.payment_type, extract('month'from order_purchase_timestamp),to_char(order_purchase_timestamp,'month')
order by to_char(order_purchase_timestamp,'month'),cancellation_rate desc;


