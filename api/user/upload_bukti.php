<?php
include '../config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  echo json_encode(["status" => "failed", "msg" => "Request bukan POST"]);
  exit;
}

$order_id = $_POST['order_id'] ?? null;

if (!$order_id || !isset($_FILES['bukti'])) {
  echo json_encode(["status" => "failed", "msg" => "Data tidak lengkap"]);
  exit;
}

$uploadDir = __DIR__ . "/uploads/";
if (!is_dir($uploadDir)) {
  mkdir($uploadDir, 0777, true);
}

$filename = time() . "_" . basename($_FILES['bukti']['name']);
$targetPath = $uploadDir . $filename;

if (!move_uploaded_file($_FILES['bukti']['tmp_name'], $targetPath)) {
  echo json_encode(["status" => "failed", "msg" => "Gagal upload file"]);
  exit;
}

// URL PUBLIC (PENTING)
$fileUrl = "http://100.79.136.94/blangkis/api/user/uploads/" . $filename;

$sql = "UPDATE orders 
        SET bukti_pembayaran='$fileUrl', status='MENUNGGU'
        WHERE id='$order_id'";

if (mysqli_query($conn, $sql)) {
  echo json_encode([
    "status" => "success",
    "url" => $fileUrl
  ]);
} else {
  echo json_encode([
    "status" => "failed",
    "msg" => mysqli_error($conn)
  ]);
}
