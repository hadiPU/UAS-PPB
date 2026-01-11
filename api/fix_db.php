<?php
require_once __DIR__ . '/config.php';

// Check if status column exists
$check = mysqli_query($conn, "SHOW COLUMNS FROM orders LIKE 'status'");

if (mysqli_num_rows($check) == 0) {
    // Add status column
    $sql = "ALTER TABLE orders ADD COLUMN status ENUM('MENUNGGU', 'LUNAS', 'DITOLAK') DEFAULT 'MENUNGGU'";
    if (mysqli_query($conn, $sql)) {
        echo json_encode(["status" => "success", "message" => "Column 'status' added successfully"]);
    } else {
        echo json_encode(["status" => "failed", "message" => "Error adding column: " . mysqli_error($conn)]);
    }
} else {
    echo json_encode(["status" => "success", "message" => "Column 'status' already exists"]);
}
?>