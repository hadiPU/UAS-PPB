<?php
include '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  echo json_encode(["status"=>"failed","msg"=>"POST only"]);
  exit;
}

$order_id = $_POST['order_id'] ?? null;
$status   = $_POST['status'] ?? null;

if (!$order_id || !$status) {
  echo json_encode(["status"=>"failed","msg"=>"Data tidak lengkap"]);
  exit;
}

$allowed = ['MENUNGGU','LUNAS','DITOLAK'];
if (!in_array($status, $allowed)) {
  echo json_encode(["status"=>"failed","msg"=>"Status invalid"]);
  exit;
}

$q = mysqli_query(
  $conn,
  "UPDATE orders SET status='$status' WHERE id='$order_id'"
);

echo json_encode([
  "status" => $q ? "success" : "failed"
]);
