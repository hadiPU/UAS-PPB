<?php
include 'config.php';

$q = mysqli_query($conn,
  "SELECT o.id, o.user_id, o.total, o.bayar, o.kembalian, o.created_at,
          u.email
   FROM orders o
   JOIN users u ON o.user_id = u.id
   ORDER BY o.id DESC"
);

$data = [];
while ($r = mysqli_fetch_assoc($q)) {
  $data[] = $r;
}

echo json_encode($data);
?>