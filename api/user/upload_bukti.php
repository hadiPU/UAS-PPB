<?php
include '../config.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  echo json_encode(["status" => "failed", "msg" => "Request bukan POST"]);
  exit;
}

$order_id = $_POST['order_id'] ?? null;

if (!$order_id || !isset($_FILES['bukti'])) {
  echo json_encode(["status" => "failed", "msg" => "Data tidak lengkap"]);
  exit;
}

// FIX: Save to assets/images so it matches add_order.php
$uploadDir = __DIR__ . "/../../assets/images/";
if (!is_dir($uploadDir)) {
  mkdir($uploadDir, 0777, true);
}

// Validate Extension
$ext = strtolower(pathinfo($_FILES['bukti']['name'], PATHINFO_EXTENSION));
$allowed = ['jpg', 'jpeg', 'png', 'gif'];
if (!in_array($ext, $allowed)) {
  echo json_encode(["status" => "failed", "msg" => "Format file tidak valid"]);
  exit;
}

$filename = "bukti_dashboard_" . time() . "_" . rand(100, 999) . "." . $ext;
$targetPath = $uploadDir . $filename;

if (!move_uploaded_file($_FILES['bukti']['tmp_name'], $targetPath)) {
  echo json_encode(["status" => "failed", "msg" => "Gagal upload file ke server"]);
  exit;
}

// FIX: Store ONLY filename, not full URL
$sql = "UPDATE orders 
        SET bukti_pembayaran='$filename', status='MENUNGGU'
        WHERE id='$order_id'";

if (mysqli_query($conn, $sql)) {
  echo json_encode([
    "status" => "success",
    "filename" => $filename
  ]);
} else {
  echo json_encode([
    "status" => "failed",
    "msg" => mysqli_error($conn)
  ]);
}
?>