<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "blangkis";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
  echo json_encode(["error" => "Koneksi database gagal"]);
  exit;
}
?>
