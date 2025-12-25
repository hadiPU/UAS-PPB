import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  final rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double get bayar =>
      double.tryParse(bayarC.text.replaceAll('.', '')) ?? 0;

  double get kembalian => bayar - widget.total;

  // =========================
  // SIMPAN TRANSAKSI
  // =========================
  Future<void> simpanPembayaran() async {
    if (bayar < widget.total) {
      _msg("Uang kurang!");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("http://192.168.10.115/blangkis/api/add_order.php"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "user_id": widget.userId.toString(),
          "total": widget.total.toString(),
          "bayar": bayar.toString(),
          "kembalian": kembalian.toString(),
          "items": jsonEncode(widget.items),
        },
      );

      final data = json.decode(res.body);

      if (data['status'] == 'success') {
        _msg("Pembayaran berhasil");

        // KEMBALI KE DASHBOARD + RESET
        Navigator.pop(context, true);
      } else {
        _msg(data['msg'] ?? "Gagal menyimpan transaksi");
      }
    } catch (e) {
      _msg("Error koneksi server");
    }

    setState(() => loading = false);
  }

  void _msg(String s) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s)));
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
            Text(
              "Total Bayar: ${rupiah.format(widget.total)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: bayarC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Uang Dibayar",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            Text(
              "Kembalian: ${rupiah.format(kembalian < 0 ? 0 : kembalian)}",
              style: TextStyle(
                fontSize: 16,
                color: kembalian < 0 ? Colors.red : Colors.green,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : simpanPembayaran,
                child: Text(
                  loading ? "Menyimpan..." : "Selesai",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
