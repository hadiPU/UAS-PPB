<?php
include 'config.php';

$user_id = $_GET['user_id'] ?? 0;

$q = mysqli_query($conn,
  "SELECT id 
   FROM orders 
   WHERE user_id='$user_id'
     AND status='MENUNGGU'
     AND bukti_pembayaran IS NULL
   ORDER BY id DESC
   LIMIT 1"
);

if ($r = mysqli_fetch_assoc($q)) {
  echo json_encode([
    "status" => "success",
    "order_id" => $r['id']
  ]);
} else {
  echo json_encode([
    "status" => "empty"
  ]);
}
