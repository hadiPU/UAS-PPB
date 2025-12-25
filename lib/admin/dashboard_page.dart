  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:url_launcher/url_launcher.dart';

  import 'product_page.dart';
  import 'konsumen_page.dart';
  import 'laporan_page.dart';
  import '../pages/login_page.dart';

  class AdminDashboardPage extends StatelessWidget {
    const AdminDashboardPage({super.key});

    // =========================
    // LOGOUT ADMIN (FIREBASE + GOOGLE)
    // =========================
    Future<void> logout(BuildContext context) async {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard Admin"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () => logout(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blue),
                title: const Text("Kelola Produk"),
                subtitle: const Text("Tambah, ubah, dan hapus produk"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminProductPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.green),
                title: const Text("Kelola Konsumen"),
                subtitle: const Text("Manajemen data pelanggan"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminKonsumenPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.orange),
                title: const Text("Laporan Penjualan"),
                subtitle: const Text("Ringkasan transaksi & omzet"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLaporanPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
