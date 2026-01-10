<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include 'config.php';

$orderId = isset($_GET['order_id']) ? intval($_GET['order_id']) : 0;

if ($orderId <= 0) {
    echo json_encode([
        'status' => 'error',
        'has_proof' => false,
        'message' => 'Invalid order ID'
    ]);
    exit;
}

$sql = "SELECT bukti_pembayaran FROM orders WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $orderId);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    $hasProof = !empty($row['bukti_pembayaran']);
    echo json_encode([
        'status' => 'success',
        'has_proof' => $hasProof
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'has_proof' => false,
        'message' => 'Order not found'
    ]);
}

$stmt->close();
$conn->close();
?>