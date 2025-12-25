<?php
include 'config.php';

$id = $_GET['id'];

$q = mysqli_query($conn, "SELECT * FROM products WHERE id='$id'");
$data = mysqli_fetch_assoc($q);

echo json_encode($data);
