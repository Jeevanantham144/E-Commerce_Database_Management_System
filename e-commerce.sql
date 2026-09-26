  ----- E-Commerce Project -----

-- 12 Tables Create --

-- 1.Users, 2.Categories, 3.Products, 4.Inventory, 5.Suppliers, 6.Orders, 7.Order_items, 8.Payments, 9.Shipping, 10.Cart, 11.Cart_items, 12.Reviews --

-- USERS
CREATE TABLE users(
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(120) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CATEGORIES
CREATE TABLE categories(
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- SUPPLIERS
CREATE TABLE suppliers(
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(120)
);

-- PRODUCTS
CREATE TABLE products(
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(120),
    price NUMERIC(10,2),
    category_id INT REFERENCES categories(category_id),
    supplier_id INT REFERENCES suppliers(supplier_id)
);

-- INVENTORY
CREATE TABLE inventory(
    product_id INT PRIMARY KEY REFERENCES products(product_id),
    stock INT
);

-- ORDERS
CREATE TABLE orders(
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(40)
);

-- ORDER ITEMS
CREATE TABLE order_items(
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    price NUMERIC(10,2)
);

-- PAYMENTS
CREATE TABLE payments(
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    amount NUMERIC(10,2)
);

-- SHIPPING
CREATE TABLE shipping(
    shipping_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    status VARCHAR(40)
);

-- CART
CREATE TABLE cart(
    cart_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id)
);

-- CART ITEMS
CREATE TABLE cart_items(
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES cart(cart_id),
    product_id INT REFERENCES products(product_id),
    quantity INT
);

-- REVIEWS
CREATE TABLE reviews(
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    user_id INT REFERENCES users(user_id),
    rating INT
);


-- Insert The 100 Records --

INSERT INTO users(name,email)
SELECT 'User'||g, 'user'||g||'@mail.com'
FROM generate_series(1,100) g;


INSERT INTO categories(name)
SELECT 'Category'||g FROM generate_series(1,10) g;


INSERT INTO suppliers(name)
SELECT 'Supplier'||g FROM generate_series(1,10) g;


INSERT INTO products(name,price,category_id,supplier_id)
SELECT
 'Product'||g,
 (random()*1000)::numeric(10,2),
 (random()*9+1)::int,
 (random()*9+1)::int
FROM generate_series(1,100) g;


INSERT INTO inventory
SELECT product_id, (random()*200)::int
FROM products;


INSERT INTO orders(user_id,status)
SELECT (random()*99+1)::int,
       (ARRAY['Placed','Shipped','Delivered','Cancelled'])[floor(random()*4+1)]
FROM generate_series(1,100);


INSERT INTO order_items(order_id,product_id,quantity,price)
SELECT
 (random()*99+1)::int,
 (random()*99+1)::int,
 (random()*5+1)::int,
 (random()*1000)::numeric(10,2)
FROM generate_series(1,100);


INSERT INTO payments(order_id,amount)
SELECT order_id,(random()*2000)::numeric(10,2)
FROM orders;


INSERT INTO shipping(order_id,status)
SELECT order_id,
       (ARRAY['Pending','Shipped','Delivered'])[floor(random()*3+1)]
FROM orders;



INSERT INTO cart(user_id)
SELECT user_id FROM users;


INSERT INTO cart_items(cart_id,product_id,quantity)
SELECT
 (random()*99+1)::int,
 (random()*99+1)::int,
 (random()*5+1)::int
FROM generate_series(1,100);


INSERT INTO reviews(product_id,user_id,rating)
SELECT
 (random()*99+1)::int,
 (random()*99+1)::int,
 (random()*4+1)::int
FROM generate_series(1,100);


-- Feath the Tables --


SELECT * FROM users;

SELECT * FROM categories;

SELECT * FROM suppliers;

SELECT * FROM products;

SELECT 
    p.product_id,
    p.name,
    p.price,
    c.name AS category,
    s.name AS supplier
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id;

SELECT * FROM inventory;

SELECT p.name, i.stock
FROM products p
JOIN inventory i USING(product_id)
WHERE i.stock = 0;

SELECT * FROM orders;

SELECT 
    o.order_id,
    u.name AS customer,
    o.order_date,
    o.status
FROM orders o
JOIN users u USING(user_id);

SELECT * FROM order_items;

SELECT 
    oi.order_id,
    p.name,
    oi.quantity,
    oi.price
FROM order_items oi
JOIN products p USING(product_id);

SELECT * FROM payments;

SELECT 
    p.payment_id,
    p.amount,
    o.user_id,
    o.order_date
FROM payments p
JOIN orders o USING(order_id);

SELECT * FROM shipping;

SELECT * FROM shipping WHERE status = 'Delivered';

SELECT * FROM cart;

SELECT * FROM cart_items;

SELECT 
    c.cart_id,
    u.name,
    p.name AS product,
    ci.quantity
FROM cart c
JOIN users u USING(user_id)
JOIN cart_items ci USING(cart_id)
JOIN products p USING(product_id);

SELECT * FROM reviews;

SELECT 
    u.name,
    p.name,
    r.rating
FROM reviews r
JOIN users u USING(user_id)
JOIN products p USING(product_id);

SELECT * FROM orders
ORDER BY order_date DESC
LIMIT 10;

SELECT product_id, SUM(quantity) qty
FROM order_items
GROUP BY product_id
ORDER BY qty DESC
LIMIT 5;

SELECT SUM(amount) AS total_revenue FROM payments;

SELECT 
    u.name,
    SUM(p.amount) spending
FROM users u
JOIN orders o USING(user_id)
JOIN payments p USING(order_id)
GROUP BY u.name;

SELECT
    o.order_id,
    u.name,
    SUM(oi.quantity*oi.price) total_amount,
    s.status
FROM orders o
JOIN users u USING(user_id)
JOIN order_items oi USING(order_id)
JOIN shipping s USING(order_id)
GROUP BY o.order_id, u.name, s.status;



--- 25 Querys ---


-- 1. How many users --

SELECT COUNT(*) FROM users;

-- 2. Show all products with price --

SELECT name, price FROM products;

-- 3. Top 5 costly products --

SELECT * FROM products ORDER BY price DESC LIMIT 5;

-- 4. Out of stock items --

SELECT p.name
FROM products p JOIN inventory i USING(product_id)
WHERE stock = 0;

-- 5. Total revenue --

SELECT SUM(amount) FROM payments;

-- 6. Orders per user --

SELECT user_id, COUNT(*) FROM orders GROUP BY user_id;

-- 7. Most sold products --

SELECT product_id, SUM(quantity)
FROM order_items GROUP BY product_id
ORDER BY SUM(quantity) DESC;

-- 8. Low stock (<10) --

SELECT * FROM inventory WHERE stock < 10;

-- 9. Average price --

SELECT AVG(price) FROM products;

-- 10. Orders today --

SELECT * FROM orders WHERE order_date::date=CURRENT_DATE;

-- 11. Highest revenue order --

SELECT order_id, SUM(quantity*price) total
FROM order_items GROUP BY order_id
ORDER BY total DESC LIMIT 1;

-- 12. Products never ordered --

SELECT p.product_id
FROM products p
LEFT JOIN order_items o USING(product_id)
WHERE o.product_id IS NULL;

-- 13.  Deliverd orders --

SELECT * FROM shipping WHERE status='Delivered';

-- 14. Pending orders --

SELECT * FROM shipping WHERE status='Pending';

-- 15. Count products per category --

SELECT category_id, COUNT(*) FROM products GROUP BY category_id;

-- 16. Best customers --

SELECT user_id, COUNT(*) 
FROM orders GROUP BY user_id ORDER BY 2 DESC LIMIT 5;

-- 17. Average rating per product --

SELECT product_id, AVG(rating) FROM reviews GROUP BY product_id;

-- 18. Supplier product count --

SELECT supplier_id, COUNT(*) FROM products GROUP BY supplier_id;

-- 19. Cart total quantity --

SELECT cart_id, SUM(quantity) FROM cart_items GROUP BY cart_id;

-- 20. Monthly revenue --

SELECT DATE_TRUNC('month', order_date), SUM(amount)
FROM orders JOIN payments USING(order_id)
GROUP BY 1;

-- 21. Update stock after sale --

UPDATE inventory SET stock = stock - 1 WHERE product_id=1;

-- 22. Cancel order --

UPDATE orders SET status='Cancelled' WHERE order_id=5;

-- 23. Delect old reviews --

DELETE FROM reviews WHERE rating=1;

-- 24. Search product by name --

SELECT * FROM products WHERE name ILIKE '%10%';

-- 25. Top 3 categories by sales --

SELECT 
    p.category_id, 
    SUM(oi.quantity * oi.price) AS total
FROM order_items oi
JOIN products p USING(product_id)
GROUP BY p.category_id
ORDER BY total DESC
LIMIT 3;