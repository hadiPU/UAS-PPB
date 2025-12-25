<?php
include 'config.php';

$username = $_POST['username'];
$password = md5($_POST['password']);

$q = mysqli_query($conn,
  "SELECT id, email, role 
   FROM users 
   WHERE email='$username' 
   AND password='$password'"
);

if (mysqli_num_rows($q) > 0) {
  $user = mysqli_fetch_assoc($q);

  echo json_encode([
    "status" => "success",
    "user_id" => $user['id'],
    "email" => $user['email'],
    "role" => $user['role']
  ]);
} else {
  echo json_encode(["status" => "failed"]);
}
