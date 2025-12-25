<?php
include '../config.php';

$q = mysqli_query($conn,"SELECT * FROM konsumen");
$data=[];
while($r=mysqli_fetch_assoc($q)) $data[]=$r;
echo json_encode($data);
