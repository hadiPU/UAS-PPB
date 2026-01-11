<?php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json');

include 'config.php';

// AMAN: cek dulu semua key
$user_id = $_POST['user_id'] ?? null;
$total = $_POST['total'] ?? null;
$bayar = $_POST['bayar'] ?? null;
$kembalian = $_POST['kembalian'] ?? null;
$itemsRaw = $_POST['items'] ?? null;

if (!$user_id || !$total || !$bayar || !$itemsRaw) {
  echo json_encode([
    "status" => "failed",
    "msg" => "Data tidak lengkap"
  ]);
  exit;
}

$items = json_decode($itemsRaw, true);
if (!$items) {
  echo json_encode([
    "status" => "failed",
    "msg" => "Item tidak valid"
  ]);
  exit;
}

// HANDLE FILE UPLOAD
$proof_name = null;
if (isset($_FILES['bukti']) && $_FILES['bukti']['error'] == 0) {
  $target_dir = "assets/images/";
  if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
  }

  // Validate Extension
  $ext = strtolower(pathinfo($_FILES['bukti']['name'], PATHINFO_EXTENSION));
  $allowed = ['jpg', 'jpeg', 'png', 'gif'];
  if (in_array($ext, $allowed)) {
    $filename = "bukti_" . time() . "_" . rand(100, 999) . "." . $ext;
    if (move_uploaded_file($_FILES['bukti']['tmp_name'], $target_dir . $filename)) {
      $proof_name = $filename;
    }
  }
}

// INSERT orders
// Note: using NOW() for created_at if not default
$sqlOrder = "INSERT INTO orders (user_id, total, bayar, kembalian, bukti_pembayaran)
             VALUES ('$user_id', '$total', '$bayar', '$kembalian', " . ($proof_name ? "'$proof_name'" : "NULL") . ")";

if (!mysqli_query($conn, $sqlOrder)) {
  echo json_encode([
    "status" => "failed",
    "msg" => "DB Error: " . mysqli_error($conn)
  ]);
  exit;
}

$order_id = mysqli_insert_id($conn);

// INSERT order_items
foreach ($items as $item) {
  $pid = $item['product_id'];
  $qty = $item['qty'];
  $price = $item['price'];

  mysqli_query(
    $conn,
    "INSERT INTO order_items (order_id, product_id, qty, price)
     VALUES ('$order_id','$pid','$qty','$price')"
  );
}

echo json_encode([
  "status" => "success",
  "order_id" => $order_id
]);
?>