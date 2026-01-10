<?php
$conn = new mysqli("localhost", "root", "", "blangkis");

$order_id = $_POST['order_id'];

if (!isset($_FILES['bukti'])) {
  echo json_encode(["status" => "error", "msg" => "No file"]);
  exit;
}

$filename = time() . "_" . $_FILES['bukti']['name'];
$path = "uploads/" . $filename;

move_uploaded_file($_FILES['bukti']['tmp_name'], $path);

// UPDATE KE TABEL ORDERS
$sql = "UPDATE orders 
        SET bukti_pembayaran = '$path', status = 'MENUNGGU'
        WHERE id = '$order_id'";

$conn->query($sql);

echo json_encode([
  "status" => "success",
  "file" => $path
]);
