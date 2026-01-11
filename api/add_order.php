<?php
// error_reporting(E_ALL);
// ini_set('display_errors', 1);
header('Content-Type: application/json');

try {
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
    if (!is_dir($target_dir)) {
      if (!mkdir($target_dir, 0777, true)) {
        throw new Exception("Gagal membuat folder assets/images");
      }
    }

    // Validate Extension
    $ext = strtolower(pathinfo($_FILES['bukti']['name'], PATHINFO_EXTENSION));
    $allowed = ['jpg', 'jpeg', 'png', 'gif'];
    if (in_array($ext, $allowed)) {
      $filename = "bukti_" . time() . "_" . rand(100, 999) . "." . $ext;
      if (move_uploaded_file($_FILES['bukti']['tmp_name'], $target_dir . $filename)) {
        $proof_name = $filename;
      } else {
        throw new Exception("Gagal upload gambar (move_uploaded_file)");
      }
    }
  }

  // INSERT orders
// Note: using NOW() for created_at if not default
  $sqlOrder = "INSERT INTO orders (user_id, total, bayar, kembalian, bukti_pembayaran)
VALUES ('$user_id', '$total', '$bayar', '$kembalian', '" . ($proof_name ? $proof_name : "") . "')";

  if (!mysqli_query($conn, $sqlOrder)) {
    throw new Exception("DB Error: " . mysqli_error($conn));
  }

  $order_id = mysqli_insert_id($conn);

  // INSERT order_items
  foreach ($items as $item) {
    $pid = $item['product_id'];
    $qty = $item['qty'];
    $price = $item['price'];

    if (
      !mysqli_query(
        $conn,
        "INSERT INTO order_items (order_id, product_id, qty, price)
VALUES ('$order_id','$pid','$qty','$price')"
      )
    ) {
      // Optional: throw exception or ignore? Better to throw.
      throw new Exception("DB Error Items: " . mysqli_error($conn));
    }
  }

  echo json_encode([
    "status" => "success",
    "order_id" => $order_id
  ]);

} catch (Throwable $e) {
  echo json_encode([
    "status" => "failed",
    "msg" => "Server Error: " . $e->getMessage()
  ]);
}
?>