create database olist;
use olist;
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATE,
    order_approved_at DATE,
    order_delivered_carrier_date DATE,
    order_delivered_customer_date DATE,
    order_estimated_delivery_date DATE,
    shipping_days INT,
    year INT,
    month INT,
    month_name VARCHAR(20),
    weekend_weekdays VARCHAR(20)
);
SET GLOBAL local_infile = 1;
SET SQL_SAFE_UPDATES = 0;


LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_order.csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10) NOT NULL,
    geolocation_lat DECIMAL(10,8) NOT NULL,
    geolocation_lng DECIMAL(11,8) NOT NULL,
    geolocation_city VARCHAR(100) NOT NULL,
    geolocation_state VARCHAR(50) NOT NULL
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_geolocation.csv"
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



SELECT count(*) FROM orders;

select count(*) from geolocation;

CREATE TABLE order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_orders_items.csv"
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from order_items limit 10;


CREATE TABLE customers (
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(50) NOT NULL,
    PRIMARY KEY (customer_id)
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_customer.csv"
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from customers limit 10;



CREATE TABLE order_payments (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10,2) NOT NULL
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_payment.csv"
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select count(*) from order_payments;

CREATE TABLE order_reviews (
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATE NOT NULL,
    review_answer_timestamp DATE,
    PRIMARY KEY (review_id)
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_orders_review.csv"
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from order_reviews;

CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100) NOT NULL,
    PRIMARY KEY (product_category_name)
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_product_category.csv"
INTO TABLE product_category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE sellers (
    seller_id VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state VARCHAR(50) NOT NULL,
    PRIMARY KEY (seller_id)
);

LOAD DATA LOCAL INFILE "C://Users/KUMUD/Downloads/SQL Project/olist_seller.csv"
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE products (
    product_id VARCHAR(50) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2),
    PRIMARY KEY (product_id)
);

LOAD DATA LOCAL INFILE "C:/Users/KUMUD/Downloads/SQL Project/olist_product.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from products;


create table kpi1 as SELECT
CONCAT(ROUND(COUNT(CASE WHEN WEEKDAY(order_purchase_timestamp) < 5 THEN 1 END)*100 / COUNT(*),0
),'%') AS weekday_percent,

CONCAT(ROUND(COUNT(CASE WHEN WEEKDAY(order_purchase_timestamp) >= 5 THEN 1 END)*100 / COUNT(*),0
),'%') AS weekend_percent
FROM orders;

select * from kpi1;


create table kpi2 as SELECT p.payment_type,CONCAT(ROUND(COUNT(*)/1000,1),'K') AS no_of_orders FROM order_reviews r
JOIN order_payments p ON r.order_id = p.order_id WHERE r.review_score = 5
GROUP BY p.payment_type ORDER BY COUNT(*) DESC;

select * from kpi2;

create table  kpi3 as SELECT pt.product_category_name_english AS category,ROUND(AVG(o.shipping_days),0) AS average_shipping_days
FROM products p JOIN product_category_translation pt ON p.product_category_name = pt.product_category_name
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE pt.product_category_name_english LIKE '%pet%'
GROUP BY category;

select * from kpi3;


create table kpi4 as SELECT
(
    SELECT ROUND(AVG(p.payment_value),0)
    FROM order_payments p
    JOIN orders o ON p.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.customer_city = 'sao paulo'
      AND o.order_status = 'delivered'
) AS avg_payment_value,

(
    SELECT ROUND(AVG(oi.price),0)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.customer_city = 'sao paulo'
      AND o.order_status = 'delivered'
) AS avg_price;

select * from kpi4;

create table kpi5 as SELECT r.review_score,ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)),0) AS avg_delivery_days
FROM order_reviews r JOIN orders o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;


select * from kpi5;
