<?php
require_once __DIR__ . '/../config.php';

$q = mysqli_query($conn, "
  SELECT
    (SELECT COUNT(*) FROM products) AS produk,
    (SELECT IFNULL(SUM(oi.qty),0) FROM order_items oi 
     INNER JOIN orders o ON oi.order_id = o.id 
     WHERE o.status = 'LUNAS') AS terjual,
    (SELECT IFNULL(SUM(total),0) FROM orders WHERE status = 'LUNAS') AS penjualan
");

$data = mysqli_fetch_assoc($q);

echo json_encode([
  "status" => "success",
  "data" => $data
]);