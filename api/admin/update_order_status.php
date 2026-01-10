<?php
include '../config.php'; // ← pastikan path ini BENAR


// DEBUG: lihat data masuk
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  echo json_encode([
    "status" => "failed",
    "msg" => "Request bukan POST"
  ]);
  exit;
}

$order_id = $_POST['order_id'] ?? '';
$status   = $_POST['status'] ?? '';

// DEBUG kalau kosong
if ($order_id === '' || $status === '') {
  echo json_encode([
    "status" => "failed",
    "msg" => "Data tidak lengkap",
    "debug" => $_POST
  ]);
  exit;
}

$allowed = ['MENUNGGU','LUNAS','DITOLAK'];
if (!in_array($status, $allowed)) {
  echo json_encode([
    "status" => "failed",
    "msg" => "Status tidak valid"
  ]);
  exit;
}

$q = mysqli_query($conn,
  "UPDATE orders SET status='$status' WHERE id='$order_id'"
);

if ($q) {
  echo json_encode([
    "status" => "success"
  ]);
} else {
  echo json_encode([
    "status" => "failed",
    "msg" => mysqli_error($conn)
  ]);
}
