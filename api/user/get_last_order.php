<?php
$conn = new mysqli("localhost", "root", "", "blangkis");

$user_id = $_GET['user_id'];

$q = $conn->query("
  SELECT id 
  FROM orders 
  WHERE user_id = '$user_id'
  ORDER BY created_at DESC 
  LIMIT 1
");

$data = $q->fetch_assoc();

echo json_encode([
  "status" => "success",
  "order_id" => $data ? $data['id'] : null
]);
