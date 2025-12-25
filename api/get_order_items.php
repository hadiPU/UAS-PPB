<?php
include 'config.php';

$order_id = $_GET['order_id'] ?? '';

$q = mysqli_query($conn,
  "SELECT p.name, oi.qty, oi.price
   FROM order_items oi
   JOIN products p ON oi.product_id = p.id
   WHERE oi.order_id = '$order_id'"
);

$data = [];
while ($r = mysqli_fetch_assoc($q)) {
  $data[] = $r;
}

echo json_encode($data);
