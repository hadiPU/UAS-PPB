import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PaymentDeliveryPage extends StatefulWidget {
  final double total;

  const PaymentDeliveryPage({super.key, required this.total});

  @override
  State<PaymentDeliveryPage> createState() => _PaymentDeliveryPageState();
}

class _PaymentDeliveryPageState extends State<PaymentDeliveryPage> {
  String paket = 'Reguler';
  String tujuan = 'Dalam Kota';
  double ongkir = 10000;

  File? bukti;

  final rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void hitungOngkir() {
    if (paket == 'Express' && tujuan == 'Luar Kota') {
      ongkir = 30000;
    } else if (paket == 'Express') {
      ongkir = 20000;
    } else if (tujuan == 'Luar Kota') {
      ongkir = 15000;
    } else {
      ongkir = 10000;
    }
  }

  Future<void> pilihBukti() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => bukti = File(img.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAkhir = widget.total + ongkir;

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran & Pengiriman")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Belanja: ${rupiah.format(widget.total)}"),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              value: paket,
              items: ['Reguler', 'Express']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                paket = v!;
                setState(hitungOngkir);
              },
              decoration: const InputDecoration(labelText: "Jenis Paket"),
            ),

            DropdownButtonFormField(
              value: tujuan,
              items: ['Dalam Kota', 'Luar Kota']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                tujuan = v!;
                setState(hitungOngkir);
              },
              decoration: const InputDecoration(labelText: "Tujuan"),
            ),

            const SizedBox(height: 12),

            Text("Ongkos Kirim: ${rupiah.format(ongkir)}"),
            const Divider(),
            Text(
              "Total Bayar: ${rupiah.format(totalAkhir)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Upload Bukti Pembayaran"),
              onPressed: pilihBukti,
            ),

            if (bukti != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(bukti!, height: 120),
              ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text("Cetak NOTA"),
              onPressed: () {
                // arahkan ke PHP export_nota.php
              },
            ),
          ],
        ),
      ),
    );
  }
}
