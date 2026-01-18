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

  // ================= FILTER =================
  String selectedFilter = "1day";

  final Map<String, String> filterOptions = {
    "lasthour": "Last Hour",
    "1day": "1 Day",
    "7days": "7 Days",
    "28days": "28 Days",
  };

  @override
  void initState() {
    super.initState();
    loadLaporan();
  }

  // ================= LOAD LAPORAN =================
  Future<void> loadLaporan() async {
    loading = true;
    setState(() {});

    try {
      laporan = await ApiService.getLaporan(filter: selectedFilter);
    } catch (e) {
      laporan = [];
    }

    loading = false;
    setState(() {});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
      ),
      body: Column(
        children: [
          // ===== FILTER DROPDOWN =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  "Filter:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: filterOptions.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    selectedFilter = val!;
                    loadLaporan();
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // ===== TOMBOL EXPORT =====
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
                        "http://100.79.136.94:8080/admin/export_pdf.php?filter=$selectedFilter",
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
                        "http://100.79.136.94:8080/admin/export_excel.php?filter=$selectedFilter",
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ===== LIST LAPORAN =====
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

                          final tanggal = d['tanggal']?.toString() ?? '-';
                          final transaksi = d['transaksi']?.toString() ?? '0';
                          final total = d['total']?.toString() ?? '0';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text(tanggal),
                              subtitle: Text("Transaksi: $transaksi"),
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
