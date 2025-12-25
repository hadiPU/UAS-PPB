<?php
require_once __DIR__ . '/../config.php';

$q = mysqli_query($conn, "
  SELECT
    (SELECT COUNT(*) FROM products) AS produk,
    (SELECT IFNULL(SUM(qty),0) FROM order_items) AS terjual,
    (SELECT IFNULL(SUM(total),0) FROM orders) AS penjualan
");

$data = mysqli_fetch_assoc($q);

echo json_encode([
  "status" => "success",
  "data" => $data
]);
