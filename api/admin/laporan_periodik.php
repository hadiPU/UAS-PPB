<?php
include '../config.php';

$filter = $_GET['filter'] ?? "1day";

switch($filter){
  case "lasthour":
    $where = "created_at >= NOW() - INTERVAL 1 HOUR";
    break;

  case "7days":
    $where = "created_at >= NOW() - INTERVAL 7 DAY";
    break;

  case "28days":
    $where = "created_at >= NOW() - INTERVAL 28 DAY";
    break;

  default:
    $where = "created_at >= NOW() - INTERVAL 1 DAY";
}

$q = mysqli_query($conn, "
  SELECT 
    DATE(created_at) AS tanggal,
    COUNT(id) AS transaksi,
    SUM(total) AS total
  FROM orders
  WHERE $where
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
  "filter" => $filter,
  "data" => $data
]);
