import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  Timer? _timer;
  List<dynamic> _orders = [];
  bool _loading = true;

  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // 🔥 BASE URL UNTUK GAMBAR
  final String baseImageUrl =
      "http://100.79.136.94:8080/assets/images/";

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders({bool silent = false}) async {
    try {
      final data = await ApiService.getOrders();
      if (!mounted) return;

      setState(() {
        _orders = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ==================================================
  // DIALOG DETAIL + BUKTI PEMBAYARAN (INI YANG DIPERBAIKI)
  // ==================================================
  void _showVerifyDialog(Map order) {
    final int id = int.parse(order['id'].toString());
    final String status = order['status'] ?? 'MENUNGGU';
    final String? bukti = order['bukti_pembayaran'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detail Pembayaran"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order ID: $id"),
              Text("Status: $status"),
              const SizedBox(height: 12),

              const Text(
                "Bukti Pembayaran:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // ====== GAMBAR BUKTI ======
              // ====== GAMBAR BUKTI ======
              if (bukti != null && bukti.isNotEmpty)
                Builder(
                  builder: (ctx) {
                    // FIX: Handle relative path from DB (../../user/uploads/...)
                    // Clean URL: remove anything before the last slash if it contains "uploads"
                    String cleanUrl = baseImageUrl + bukti;
                    if (bukti.contains("user/uploads")) {
                         // Convert: assets/images/../../user/uploads/file.jpg
                         // To:      user/uploads/file.jpg
                         cleanUrl = "http://100.79.136.94:8080/user/uploads/" + bukti.split('/').last;
                    }

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                cleanUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        cleanUrl,
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Column(
                          children: [
                            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            Text("Gagal memuat: $cleanUrl", style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }
                )
              else
                const Text(
                  "Belum ada bukti pembayaran",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          if (status == 'MENUNGGU') ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStatus(id, 'DITOLAK');
              },
              child: const Text(
                "Tolak",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStatus(id, 'LUNAS');
              },
              child: const Text("ACC"),
            ),
          ]
        ],
      ),
    );
  }

  // =========================
  // UPDATE STATUS (POST)
  // =========================
  Future<void> _updateStatus(int orderId, String status) async {
    print("Updating Order $orderId to $status"); // DEBUG
    final ok = await ApiService.updateOrderStatus(orderId, status);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status berhasil diubah ke $status")),
      );
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal update status (Cek Log)")),
      );
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Masuk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchOrders(),
          ),
        ],
      ),
      body: _loading && _orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("Belum ada pesanan"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    final int id = int.parse(o['id'].toString());
                    final String email = o['email'] ?? 'User';
                    final double total =
                        double.tryParse(o['total'].toString()) ?? 0;
                    final String date = o['created_at'] ?? '-';
                    final String status = o['status'] ?? 'MENUNGGU';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(id.toString()),
                        ),
                        title: Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(date),
                            const SizedBox(height: 4),
                            Text(
                              "Status: $status",
                              style: TextStyle(
                                color: status == 'LUNAS'
                                    ? Colors.green
                                    : status == 'DITOLAK'
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          rupiah.format(total),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // 🔥 ADMIN BISA TAP SEMUA ORDER UNTUK LIHAT BUKTI
                        onTap: () {
                          _showVerifyDialog(o);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}