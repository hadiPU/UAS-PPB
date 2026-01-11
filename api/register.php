<?php
include 'config.php';

$email = $_POST['email'];
$pass = md5($_POST['password']);

$name = explode('@', $email)[0]; // Default name from email

$q = mysqli_query(
  $conn,
  "INSERT INTO users (name, email, password, role)
   VALUES ('$name','$email','$pass','user')"
);

if ($q) {
  echo json_encode(["status" => "success"]);
} else {
  echo json_encode(["status" => "failed"]);
}