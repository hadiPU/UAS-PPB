<?php
include 'config.php';

$email = $_POST['email'];
$name  = $_POST['name'];

$q = mysqli_query($conn,
  "SELECT * FROM users WHERE email='$email'"
);

if (mysqli_num_rows($q) == 0) {
  mysqli_query($conn,
    "INSERT INTO users (name, email, password, role)
     VALUES ('$name', '$email', '', 'user')"
  );
}

$user = mysqli_fetch_assoc(
  mysqli_query($conn, "SELECT * FROM users WHERE email='$email'")
);

echo json_encode([
  "status" => "success",
  "user_id" => $user['id'],
  "email" => $user['email'],
  "role" => $user['role']
]);
