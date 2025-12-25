<?php
include '../config.php';

$email = $_POST['email'];
$pass  = md5($_POST['password']);

$q = mysqli_query($conn,
  "SELECT * FROM users
   WHERE email='$email' AND password='$pass' AND role='admin'");

if (mysqli_num_rows($q) > 0) {
  echo json_encode(["status"=>"success"]);
} else {
  echo json_encode(["status"=>"failed"]);
}
