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




-- How much revenue did the business generate overall?
SELECT SUM(price + freight_value) AS total_revenue
FROM order_items;

-- How many actual orders did the business receive?
SELECT COUNT(DISTINCT order_id) as unique_orders
from orders;

-- How many actual customers do we have?
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customer;

-- On average, how much revenue does one order generate?
SELECT SUM(price + freight_value) / COUNT(DISTINCT order_id) AS aov
FROM order_items;


-- What is the overall monthly revenue pattern?
SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_number,
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month,
    SUM(oi.price + oi.freight_value) AS revenue

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(MONTH FROM o.order_purchase_timestamp),
    TO_CHAR(o.order_purchase_timestamp, 'Month')
ORDER BY month_number , revenue desc;


-- When revenue goes up or down, are orders moving in the same direction?
SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month_number,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    EXTRACT(MONTH FROM order_purchase_timestamp),
    TO_CHAR(order_purchase_timestamp, 'Month')
ORDER BY month_number;

-- AOV

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_number,
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month,
    SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id) AS aov

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    EXTRACT(MONTH FROM o.order_purchase_timestamp),
    TO_CHAR(o.order_purchase_timestamp, 'Month')
ORDER BY month_number ;


-- If orders decreased, which categories caused the decline in order volume?
SELECT
    p.product_category_name,
    COUNT(DISTINCT o.order_id) AS august_orders
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_purchase_timestamp >= '2018-08-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY p.product_category_name
ORDER BY august_orders DESC;


-- sept
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp >= '2018-09-01'
  AND o.order_purchase_timestamp < '2018-10-01'
  AND oi.order_id IS NULL
ORDER BY o.order_purchase_timestamp;


-- What happened to the cancelled September orders in the order fulfillment process?
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_purchase_timestamp >= '2018-09-01'
  AND order_purchase_timestamp < '2018-10-01'
  AND order_status = 'canceled'
ORDER BY order_purchase_timestamp;


-- Did these cancelled orders ever receive payment?
SELECT
    o.order_id,
    o.order_status,
    COUNT(p.order_id) AS payment_records,
    COALESCE(SUM(p.payment_value), 0) AS payment_value
FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-09-01'
  AND o.order_purchase_timestamp < '2018-10-01'
  AND o.order_status = 'canceled'
GROUP BY
    o.order_id,
    o.order_status
ORDER BY o.order_id;


-- Which payment methods were used for the cancelled September orders?

  SELECT
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS cancelled_orders,
    SUM(p.payment_value) AS payment_value
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-09-01'
  AND o.order_purchase_timestamp < '2018-10-01'
  AND o.order_status = 'canceled'
GROUP BY p.payment_type
ORDER BY cancelled_orders DESC;



-- Did the proportion of voucher orders that were cancelled increase dramatically in September?

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'canceled'
        THEN o.order_id
    END) AS cancelled_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'canceled'
            THEN o.order_id
        END) * 100.0
        / COUNT(DISTINCT o.order_id),
        2
    ) AS cancellation_rate
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_purchase_timestamp >= '2018-08-01'
  AND o.order_purchase_timestamp < '2018-10-01'
GROUP BY
    DATE_TRUNC('month', o.order_purchase_timestamp),
    p.payment_type
ORDER BY
    month,
    cancellation_rate DESC;


