import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final int userId;
  final double total;
  final List<Map<String, dynamic>> items;

  const PaymentPage({
    super.key,
    required this.userId,
    required this.total,
    required this.items,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final bayarC = TextEditingController();
  bool loading = false;

  // ===== ONGKIR =====
  String paket = 'Reguler';
  String tujuan = 'Dalam Kota';
  double ongkir = 10000;

  File? bukti;

  final rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double get bayar => double.tryParse(bayarC.text.replaceAll('.', '')) ?? 0;

  double get totalAkhir => widget.total + ongkir;

  double get kembalian => bayar - totalAkhir;

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
    setState(() {});
  }

  Future<void> pilihBukti() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => bukti = File(img.path));
    }
  }

  // =========================
  // SIMPAN PEMBAYARAN
  // =========================
  Future<void> simpanPembayaran() async {
    if (bayar < totalAkhir) {
      _msg("Uang kurang!");
      return;
    }

    setState(() => loading = true);

    try {
      final req = http.MultipartRequest(
        'POST',
        Uri.parse("http://100.79.136.94:8080/add_order.php"),
      );

      req.fields['user_id'] = widget.userId.toString();
      req.fields['total'] = totalAkhir.toString();
      req.fields['bayar'] = bayar.toString();
      req.fields['kembalian'] = kembalian.toString();
      req.fields['paket'] = paket;
      req.fields['tujuan'] = tujuan;
      req.fields['ongkir'] = ongkir.toString();
      req.fields['items'] = jsonEncode(widget.items);

      if (bukti != null) {
        req.files.add(
          await http.MultipartFile.fromPath('bukti', bukti!.path),
        );
      }

      final res = await req.send();
      final body = await res.stream.bytesToString();
      final data = json.decode(body);

      if (data['status'] == 'success') {
        final orderId = data['order_id'];

        _msg("Pembayaran berhasil");

        final url =
            "http://100.79.136.94:8080/admin/export_nota_pdf.php?id=$orderId";
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

        // 🔥 INI SATU-SATUNYA YANG WAJIB DIGANTI
        Navigator.pop(context, orderId);
      } else {
        _msg(data['msg'] ?? "Gagal menyimpan transaksi");
      }
    } catch (e) {
      _msg("Error: $e");
    }

    setState(() => loading = false);
  }

  void _msg(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Belanja: ${rupiah.format(widget.total)}"),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: paket,
              decoration: const InputDecoration(labelText: "Jenis Paket"),
              items: ['Reguler', 'Express']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                paket = v!;
                hitungOngkir();
              },
            ),
            DropdownButtonFormField(
              value: tujuan,
              decoration: const InputDecoration(labelText: "Tujuan Pengiriman"),
              items: ['Dalam Kota', 'Luar Kota']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                tujuan = v!;
                hitungOngkir();
              },
            ),
            const SizedBox(height: 8),
            Text("Ongkir: ${rupiah.format(ongkir)}"),
            Text(
              "Total Bayar: ${rupiah.format(totalAkhir)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bayarC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Uang Dibayar",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              "Kembalian: ${rupiah.format(kembalian < 0 ? 0 : kembalian)}",
              style: TextStyle(
                color: kembalian < 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            if (bukti != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.file(bukti!, height: 120),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : simpanPembayaran,
                child: Text(loading ? "Menyimpan..." : "Selesai"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}