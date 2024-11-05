-- Create the database
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Drop tables if they already exist (to avoid errors during import)
DROP TABLE IF EXISTS order_logs;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;

-- Create the Categories table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL
);

-- Create the Products table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- Create the Orders table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    order_quantity INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

-- Create the order_logs table
CREATE TABLE order_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    order_quantity INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- Trigger to log orders in the order_logs table when a new order is added
DELIMITER //
CREATE TRIGGER after_order_insert
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO order_logs (order_id, order_quantity, timestamp)
    VALUES (NEW.order_id, NEW.order_quantity, NOW());
END;
//
DELIMITER ;

-- Stored procedure to get product details and total orders
DELIMITER //
CREATE PROCEDURE getProductInfo(IN p_product_id INT)
BEGIN
    SELECT 
        p.product_name,
        c.category_name,
        (SELECT SUM(o.order_quantity) FROM Orders o WHERE o.product_id = p.product_id) AS total_orders
    FROM 
        Products p
    LEFT JOIN 
        Categories c ON p.category_id = c.category_id
    WHERE 
        p.product_id = p_product_id;
END;
//
DELIMITER ;

-- INSERT INTO Categories (category_name) VALUES 
--     ('Electronics'),
--     ('Accessories');

-- INSERT INTO Orders (product_id, order_quantity, order_date) VALUES 
--     (1, 2, NOW()),
--     (2, 1, NOW()),
--     (3, 5, NOW());


INSERT INTO Products (product_name, price, stock_quantity, category_id)
VALUES 
    ('Board Game', 24.99, 70, (SELECT category_id FROM Categories WHERE category_name = 'Toys')),
    ('Smartphone', 699.99, 50, (SELECT category_id FROM Categories WHERE category_name = 'Electronics')),
    ('Laptop', 1199.99, 30, (SELECT category_id FROM Categories WHERE category_name = 'Electronics')),
    ('Doll', 19.99, 100, (SELECT category_id FROM Categories WHERE category_name = 'Toys')),
    ('Puzzle', 9.99, 200, (SELECT category_id FROM Categories WHERE category_name = 'Toys')),
    ('Headphones', 149.99, 100, (SELECT category_id FROM Categories WHERE category_name = 'Electronics')),
    ('Vacuum Cleaner', 99.99, 50, (SELECT category_id FROM Categories WHERE category_name = 'Home')),
    ('Microwave', 89.99, 40, (SELECT category_id FROM Categories WHERE category_name = 'Home')),
    ('Sneakers', 79.99, 60, (SELECT category_id FROM Categories WHERE category_name = 'Clothing')),
    ('T-shirt', 19.99, 200, (SELECT category_id FROM Categories WHERE category_name = 'Clothing')),
    ('Jacket', 89.99, 50, (SELECT category_id FROM Categories WHERE category_name = 'Clothing')),
    ('Blender', 49.99, 80, (SELECT category_id FROM Categories WHERE category_name = 'Home')),
    ('Jeans', 49.99, 100, (SELECT category_id FROM Categories WHERE category_name = 'Clothing')),
    ('Smartwatch', 249.99, 70, (SELECT category_id FROM Categories WHERE category_name = 'Electronics')),
    ('History Book', 24.99, 60, (SELECT category_id FROM Categories WHERE category_name = 'Books')),
    ('Cooking Book', 19.99, 100, (SELECT category_id FROM Categories WHERE category_name = 'Books')),
    ('Fiction Novel', 14.99, 120, (SELECT category_id FROM Categories WHERE category_name = 'Books')),
    ('Action Figure', 12.99, 150, (SELECT category_id FROM Categories WHERE category_name = 'Toys')),
    ('Science Book', 29.99, 80, (SELECT category_id FROM Categories WHERE category_name = 'Books')),
    ('Coffee Maker', 59.99, 70, (SELECT category_id FROM Categories WHERE category_name = 'Home'));
