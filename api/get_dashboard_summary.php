<?php
require_once __DIR__ . '/config.php';

$q = mysqli_query($conn, "
  SELECT 
    COUNT(DISTINCT o.id) AS total_transaksi,
    IFNULL(SUM(oi.qty), 0) AS total_terjual,
    IFNULL(SUM(o.total), 0) AS total_penjualan
  FROM orders o
  LEFT JOIN order_items oi ON o.id = oi.order_id
");

$data = mysqli_fetch_assoc($q);

echo json_encode([
  "status" => "success",
  "total_transaksi" => (int)$data['total_transaksi'],
  "total_terjual" => (int)$data['total_terjual'],
  "total_penjualan" => (int)$data['total_penjualan'],
]);
