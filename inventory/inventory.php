<?php

// header("Content-Type: application/json");
// echo "<script>console.log('PHP code is running');</script>";
$conn=mysqli_connect("localhost","root","","ecommerce") or die(mysqli_error($conn));
// if($conn){
//     echo "<script>console.log('connection successful');</script>";
// }
// else{
//     echo "<script>console.log('Error in connection');</script>";
// }
// Function to insert sample data into the tables
// function insertSampleData($conn) {
    // Insert sample products
    // $conn->query("INSERT INTO products (product_id, product_name, price, stock_quantity) VALUES
    //     (1, 'Laptop', 999.99, 10),
    //     (2, 'Smartphone', 599.99, 15),
    //     (3, 'Headphones', 199.99, 30),
    //     (4, 'Tablet', 299.99, 20),
    //     (5, 'Smartwatch', 149.99, 25),
    //     (6, 'Camera', 499.99, 8),
    //     (7, 'Bluetooth Speaker', 79.99, 50),
    //     (8, 'Gaming Console', 399.99, 12)"
    // );

    // // Insert sample categories
    // $conn->query("INSERT INTO categories (category_id, category_name) VALUES
    //     (1, 'Electronics'),
    //     (2, 'Accessories')"
    // );




// Function to place an order and update inventory
function placeOrder($productId, $orderQuantity, $conn) {
    // Check if the product exists and fetch current stock quantity
    $stockQuery = $conn->query("SELECT stock_quantity FROM products WHERE product_id = $productId");
    
    if ($stockQuery->num_rows == 0) {
        throw new Exception("Product not found.");
    }

    $stock = $stockQuery->fetch_assoc()['stock_quantity'];
    
    // Check if enough stock is available
    if ($orderQuantity > $stock) {
        throw new Exception("Error: Quantity ordered exceeds stock available.");
    }
    
    // Update the stock quantity
    $conn->query("UPDATE products SET stock_quantity = stock_quantity - $orderQuantity WHERE product_id = $productId");
    
    // Insert order record
    $conn->query("INSERT INTO orders (product_id, order_quantity, order_date) VALUES ($productId, $orderQuantity, NOW())");

    // Get the newly created order ID
    $orderId = $conn->insert_id;

    // Log the order in order_logs
    $conn->query("INSERT INTO order_logs (order_id, order_quantity, timestamp) VALUES ($orderId, $orderQuantity, NOW())");
}

// Handle AJAX requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Decode the incoming JSON data
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['action']) && $data['action'] === 'placeOrder') {
        $productId = (int)$data['productId'];
        $orderQuantity = (int)$data['orderQuantity'];
        
        try {
            placeOrder($productId, $orderQuantity, $conn);
            echo json_encode(['success' => true, 'message' => 'Order placed successfully']);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'error' => $e->getMessage()]);
        }
    }
} 


if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action'])) {
    if ($_GET['action'] === 'getInventory') {
        
        // Existing code for fetching inventory
        $result = $conn->query("SELECT products.product_id, products.product_name, products.price, products.stock_quantity, categories.category_name 
        FROM products
        LEFT JOIN categories ON products.category_id = categories.category_id");
        if ($result->num_rows > 0) {
            $inventory = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["success" => true, "data" => $inventory]);
        } else {
            echo json_encode(["success" => false, "error" => "No inventory found."]);
        }
    } elseif ($_GET['action'] === 'getOrderLogs') {
        // New code for fetching order logs
        $result = $conn->query("SELECT * FROM order_logs");
        if ($result->num_rows > 0) {
            $logs = $result->fetch_all(MYSQLI_ASSOC);
            echo json_encode(["success" => true, "logs" => $logs]);
        } else {
            echo json_encode(["success" => false, "error" => "No order logs found."]);
        }
    }
    exit;
}


// Call insertSampleData to populate tables with initial data (only uncomment if you want to insert data once)
// insertSampleData($conn);

$conn->close();
?>
