<?php
include '../config.php';

$action = $_GET['action'];

if ($action == "read") {
  $q = mysqli_query($conn,"SELECT * FROM products");
  while ($r = mysqli_fetch_assoc($q)) $data[]=$r;
  echo json_encode($data);
}
