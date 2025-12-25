<?php
include '../config.php';

$from = $_GET['from'];
$to   = $_GET['to'];

$q = mysqli_query($conn, "
  SELECT 
    DATE(created_at) AS tanggal,
    COUNT(id) AS transaksi,
    SUM(total) AS total
  FROM orders
  WHERE DATE(created_at) BETWEEN '$from' AND '$to'
  GROUP BY DATE(created_at)
  ORDER BY tanggal ASC
");

$data = [];
while ($row = mysqli_fetch_assoc($q)) {
  $data[] = [
    "tanggal" => $row['tanggal'],
    "transaksi" => (int)$row['transaksi'],
    "total" => number_format($row['total'], 0, ',', '.')
  ];
}

echo json_encode([
  "status" => "success",
  "type" => "periodik",
  "data" => $data
]);
