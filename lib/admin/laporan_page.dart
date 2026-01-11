import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminLaporanPage extends StatefulWidget {
  const AdminLaporanPage({super.key});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  List laporan = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLaporan();
  }

  // ===================== LOAD LAPORAN =====================
  Future<void> loadLaporan() async {
    try {
      laporan = await ApiService.getLaporanGlobal();
    } catch (e) {
      laporan = [];
    }
    loading = false;
    setState(() {});
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
      ),
      body: Column(
        children: [
          // ===== TOMBOL EXPORT (FITUR LAMA, TIDAK DIHAPUS) =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () {
                      launchUrl(Uri.parse(
                        "http://100.79.136.94/blangkis/api/admin/export_pdf.php",
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.table_chart),
                    label: const Text("Export Excel"),
                    onPressed: () {
                      launchUrl(Uri.parse(
                        "http://100.79.136.94/blangkis/api/admin/export_excel.php",
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ===== ISI LAPORAN =====
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : laporan.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada transaksi",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: laporan.length,
                        itemBuilder: (_, i) {
                          final d = laporan[i];

                          final tanggal =
                              d['tanggal']?.toString() ?? '-';
                          final transaksi =
                              d['transaksi']?.toString() ?? '0';
                          final total =
                              d['total']?.toString() ?? '0';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.receipt_long),
                              title: Text(tanggal),
                              subtitle:
                                  Text("Transaksi: $transaksi"),
                              trailing: Text(
                                "Rp $total",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
