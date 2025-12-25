<?php
include 'config.php';

$email = $_POST['email'];
$pass = md5($_POST['password']);

$q = mysqli_query($conn,
  "INSERT INTO users (email, password, role)
   VALUES ('$email','$pass','user')");

if ($q) {
  echo json_encode(["status"=>"success"]);
} else {
  echo json_encode(["status"=>"failed"]);
}
