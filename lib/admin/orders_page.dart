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

  // ================= VERIFIKASI =================

  void _openVerifikasiDialog(Map item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Verifikasi Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item['bukti'] != null && item['bukti'] != '')
              Image.network(
                "http://192.168.10.115/blangkis/assets/bukti/${item['bukti']}",
                height: 200,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              )
            else
              const Text("Belum ada bukti pembayaran"),
            const SizedBox(height: 12),
            const Text("Setujui pembayaran ini?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ✅ TUTUP DIALOG DULU

              try {
                final ok = await ApiService.updateOrderStatus(
                  item['id'],
                  'DITOLAK',
                );

                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pembayaran ditolak")),
                  );
                  _fetchOrders();
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error koneksi server")),
                );
              }
            },
            child: const Text(
              "Tolak",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // ✅ TUTUP DIALOG DULU

              try {
                final ok = await ApiService.updateOrderStatus(
                  item['id'],
                  'LUNAS',
                );

                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pembayaran disetujui")),
                  );
                  _fetchOrders();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal verifikasi")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error koneksi server")),
                );
              }
            },
            child: const Text("ACC"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Masuk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchOrders(),
          )
        ],
      ),
      body: _loading && _orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("Belum ada pesanan"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (ctx, i) {
                    final item = _orders[i];
                    final id = item['id'];
                    final email = item['email'] ?? 'User';
                    final total =
                        double.tryParse(item['total'].toString()) ?? 0;
                    final date = item['created_at'] ?? '-';
                    final status = item['status'] ?? 'MENUNGGU';

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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              rupiah.format(total),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (status != 'LUNAS')
                              ElevatedButton(
                                onPressed: () => _openVerifikasiDialog(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: const Size(90, 32),
                                ),
                                child: const Text(
                                  "Verifikasi",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
