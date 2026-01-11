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

// FIX: Save to user/uploads as requested
$uploadDir = __DIR__ . "/uploads/";
if (!is_dir($uploadDir)) {
  if (!mkdir($uploadDir, 0777, true)) {
    echo json_encode(["status" => "failed", "msg" => "Gagal membuat folder uploads"]);
    exit;
  }
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

// FIX: Store path relative to assets/images so Admin can read it
// Admin URL: .../assets/images/ + $path
// Result:    .../assets/images/../../user/uploads/$filename
$dbPath = "../../user/uploads/" . $filename;

$sql = "UPDATE orders 
        SET bukti_pembayaran='$dbPath', status='MENUNGGU'
        WHERE id='$order_id'";

if (mysqli_query($conn, $sql)) {
  echo json_encode([
    "status" => "success",
    "filename" => $dbPath
  ]);
} else {
  echo json_encode([
    "status" => "failed",
    "msg" => mysqli_error($conn)
  ]);
}
?>