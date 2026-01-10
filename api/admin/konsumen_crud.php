<?php
include '../config.php';

$q = mysqli_query($conn, "SELECT id, name, email FROM users");
$data = [];
while ($r = mysqli_fetch_assoc($q)) {
    $data[] = [
        "id" => $r['id'],
        "nama" => !empty($r['name']) ? $r['name'] : $r['email'],
        "no_hp" => $r['email']
    ];
}
echo json_encode([
    "status" => "success",
    "data" => $data
]);