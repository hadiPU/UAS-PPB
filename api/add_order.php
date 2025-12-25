<?php
include 'config.php';

// AMAN: cek dulu semua key
$user_id   = $_POST['user_id']   ?? null;
$total     = $_POST['total']     ?? null;
$bayar     = $_POST['bayar']     ?? null;
$kembalian = $_POST['kembalian'] ?? null;
$itemsRaw  = $_POST['items']     ?? null;

if (!$user_id || !$total || !$bayar || !$itemsRaw) {
  echo json_encode([
    "status" => "failed",
    "msg" => "Data tidak lengkap",
    "debug" => $_POST
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

// INSERT orders
mysqli_query($conn,
  "INSERT INTO orders (user_id, total, bayar, kembalian)
   VALUES ('$user_id','$total','$bayar','$kembalian')"
);

$order_id = mysqli_insert_id($conn);

// INSERT order_items
foreach ($items as $item) {
  $pid   = $item['product_id'];
  $qty   = $item['qty'];
  $price = $item['price'];

  mysqli_query($conn,
    "INSERT INTO order_items (order_id, product_id, qty, price)
     VALUES ('$order_id','$pid','$qty','$price')"
  );
}

echo json_encode(["status"=>"success"]);
