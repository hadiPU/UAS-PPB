<?php
require_once __DIR__ . '/../config.php';
require_once 'C:/xampp/htdocs/blangkis/api/fpdf/fpdf.php';

$pdf = new FPDF();
$pdf->AddPage();

// JUDUL
$pdf->SetFont('Helvetica', 'B', 14);
$pdf->Cell(0,8,'Tanggal Cetak: '.date('d-m-Y H:i'),0,1,'C');
$pdf->Ln(5);

// HEADER TABEL
$pdf->SetFont('Helvetica', 'B', 10);
$pdf->Cell(50, 8, 'Tanggal', 1);
$pdf->Cell(50, 8, 'Total Transaksi', 1);
$pdf->Cell(50, 8, 'Total Penjualan', 1);
$pdf->Ln();

// ISI
$pdf->SetFont('Helvetica', '', 10);

$q = mysqli_query($conn, "
  SELECT 
    DATE(created_at) AS tanggal,
    COUNT(id) AS transaksi,
    SUM(total) AS total
  FROM orders
  GROUP BY DATE(created_at)
  ORDER BY tanggal DESC
");

while ($d = mysqli_fetch_assoc($q)) {
  $pdf->Cell(50, 8, $d['tanggal'], 1);
  $pdf->Cell(50, 8, $d['transaksi'], 1);
  $pdf->Cell(50, 8, 'Rp ' . number_format($d['total']), 1);
  $pdf->Ln();
}

// OUTPUT
$pdf->Output('I', 'laporan_penjualan.pdf');
