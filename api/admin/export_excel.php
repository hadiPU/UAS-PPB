<?php
include '../config.php';

// Header agar terbaca sebagai Excel
header("Content-Type: application/vnd.ms-excel");
header("Content-Disposition: attachment; filename=laporan_penjualan.xls");
header("Pragma: no-cache");
header("Expires: 0");

// Judul
echo "LAPORAN PENJUALAN UMKM BLANGKIS\n\n";

// Header tabel
echo "Tanggal Cetak: ".date('d-m-Y H:i')."\n\n";
echo "Tanggal\tTransaksi\tTotal\n";

// Query data
$q = mysqli_query($conn,"
  SELECT DATE(created_at) AS tanggal,
         COUNT(id) AS transaksi,
         SUM(total) AS total
  FROM orders
  GROUP BY DATE(created_at)
  ORDER BY DATE(created_at) DESC
");

// Isi data
while ($d = mysqli_fetch_assoc($q)) {
  echo $d['tanggal'] . "\t";
  echo $d['transaksi'] . "\t";
  echo $d['total'] . "\n";
}
