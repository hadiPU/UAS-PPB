<?php
ob_start(); // PENTING: cegah output sebelum PDF

require_once('../config.php');
require_once('../fpdf/fpdf.php');

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if ($id <= 0) {
    exit("ID tidak valid");
}

/* =========================
   AMBIL DATA ORDER
========================= */
$qOrder = mysqli_query($conn, "
    SELECT * FROM orders WHERE id = $id
");
$order = mysqli_fetch_assoc($qOrder);

if (!$order) {
    exit("Data tidak ditemukan");
}

/* =========================
   AMBIL ITEM ORDER
========================= */
$qItems = mysqli_query($conn, "
    SELECT 
        oi.qty,
        oi.price,
        p.name
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    WHERE oi.order_id = $id
");

/* =========================
   BUAT PDF
========================= */
$pdf = new FPDF('P', 'mm', 'A4');
$pdf->AddPage();

/* HEADER */
$pdf->SetFont('Arial', 'B', 14);
$pdf->Cell(0, 10, 'NOTA PEMBAYARAN', 0, 1, 'C');
$pdf->Ln(5);

/* INFO ORDER */
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(40, 8, 'ID Order');
$pdf->Cell(5, 8, ':');
$pdf->Cell(50, 8, $order['id'], 0, 1);

$pdf->Cell(40, 8, 'Tanggal');
$pdf->Cell(5, 8, ':');
$pdf->Cell(50, 8, $order['created_at'], 0, 1);

$pdf->Ln(5);

/* TABLE HEADER */
$pdf->SetFont('Arial', 'B', 10);
$pdf->Cell(10, 8, 'No', 1);
$pdf->Cell(80, 8, 'Produk', 1);
$pdf->Cell(20, 8, 'Qty', 1, 0, 'C');
$pdf->Cell(40, 8, 'Harga', 1, 0, 'R');
$pdf->Cell(40, 8, 'Subtotal', 1, 1, 'R');

/* TABLE BODY */
$pdf->SetFont('Arial', '', 10);
$no = 1;
$grandTotal = 0;

while ($row = mysqli_fetch_assoc($qItems)) {
    $subtotal = $row['qty'] * $row['price'];
    $grandTotal += $subtotal;

    $pdf->Cell(10, 8, $no++, 1);
    $pdf->Cell(80, 8, $row['name'], 1);
    $pdf->Cell(20, 8, $row['qty'], 1, 0, 'C');
    $pdf->Cell(40, 8, number_format($row['price'], 0, ',', '.'), 1, 0, 'R');
    $pdf->Cell(40, 8, number_format($subtotal, 0, ',', '.'), 1, 1, 'R');
}

/* TOTAL */
$pdf->SetFont('Arial', 'B', 10);
$pdf->Cell(110, 8, 'TOTAL', 1);
$pdf->Cell(40, 8, number_format($grandTotal, 0, ',', '.'), 1, 1, 'R');

$pdf->Ln(5);

/* PEMBAYARAN */
$pdf->SetFont('Arial', '', 10);
$pdf->Cell(40, 8, 'Bayar');
$pdf->Cell(5, 8, ':');
$pdf->Cell(50, 8, number_format($order['bayar'], 0, ',', '.'), 0, 1);

$pdf->Cell(40, 8, 'Kembalian');
$pdf->Cell(5, 8, ':');
$pdf->Cell(50, 8, number_format($order['kembalian'], 0, ',', '.'), 0, 1);

/* OUTPUT */
ob_end_clean(); // bersihkan buffer
$pdf->Output('I', 'Nota_Order_' . $order['id'] . '.pdf');
