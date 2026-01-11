<?php
include 'config.php';
header('Content-Type: application/json');

$response = [
    "connection" => $conn ? "OK" : "FAILED",
    "db_error" => mysqli_connect_error(),
    "tables" => [],
    "orders_columns" => [],
    "row_counts" => [],
    "last_order" => null,
    "last_sql_error" => mysqli_error($conn),
    "get_orders_check" => "pending"
];

// 1. List Tables
$q = mysqli_query($conn, "SHOW TABLES");
if ($q) {
    while ($r = mysqli_fetch_row($q)) {
        $response['tables'][] = $r[0];
    }
}

// 2. Check Order Columns
$q = mysqli_query($conn, "SHOW COLUMNS FROM orders");
if ($q) {
    while ($r = mysqli_fetch_assoc($q)) {
        $response['orders_columns'][] = $r['Field'];
    }
}

// 3. Count Rows
$tables = ['users', 'orders', 'order_items', 'products'];
foreach ($tables as $t) {
    $q = mysqli_query($conn, "SELECT COUNT(*) as c FROM $t");
    if ($q) {
        $r = mysqli_fetch_assoc($q);
        $response['row_counts'][$t] = $r['c'];
    }
}

// 4. Try Query from get_orders.php
$sql = "SELECT o.id, u.email FROM orders o JOIN users u ON o.user_id = u.id LIMIT 1";
$q = mysqli_query($conn, $sql);
if ($q) {
    $response['get_orders_check'] = "OK";
} else {
    $response['get_orders_check'] = "FAILED: " . mysqli_error($conn);
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>