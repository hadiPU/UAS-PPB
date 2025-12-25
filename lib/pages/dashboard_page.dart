import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/api_service.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import 'payment_page.dart';
import 'update_user_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final int userId;
  const DashboardPage({super.key, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Product> products = [];
  final Map<int, int> quantities = {};
  double total = 0;

  int totalTerjual = 0;
  int totalPenjualan = 0;

  final rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadDashboardSummary();
  }

  // ===================== LOAD DATA =====================

  Future<void> loadProducts() async {
    try {
      products = await ApiService.getProducts();
    } catch (_) {
      products = [];
    }
    setState(() {});
  }

  Future<void> loadDashboardSummary() async {
    try {
      final res = await ApiService.getSalesSummary();

      if (res.isNotEmpty && res['status'] == 'success') {
        final d = res['data'];
        totalTerjual = int.tryParse(d['terjual'].toString()) ?? 0;
        totalPenjualan = int.tryParse(d['penjualan'].toString()) ?? 0;
      }
    } catch (_) {
      totalTerjual = 0;
      totalPenjualan = 0;
    }
    setState(() {});
  }

  // ===================== CART =====================

  void addToCart(Product p) {
    if (p.id == null) return;
    quantities[p.id!] = (quantities[p.id!] ?? 0) + 1;
    total += p.price;
    setState(() {});
  }

  void removeFromCart(Product p) {
    if (p.id == null) return;
    if (quantities[p.id!] != null && quantities[p.id!]! > 0) {
      quantities[p.id!] = quantities[p.id!]! - 1;
      total -= p.price;
      if (quantities[p.id!] == 0) {
        quantities.remove(p.id!);
      }
      setState(() {});
    }
  }

  List<Map<String, dynamic>> get cartItems {
    return quantities.entries.map((e) {
      final product = products.firstWhere((p) => p.id == e.key);
      return {
        "product_id": product.id,
        "name": product.name,
        "qty": e.value,
        "price": product.price,
      };
    }).toList();
  }

  void resetCart() {
    quantities.clear();
    total = 0;
    setState(() {});
  }

  // ===================== PAYMENT =====================

  Future<void> openPayment() async {
    if (total <= 0) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          userId: widget.userId,
          total: total,
          items: cartItems,
        ),
      ),
    );

    if (result == true) {
      resetCart();
      loadDashboardSummary(); // 🔥 REAL-TIME UPDATE
    }
  }

  // ===================== LOGOUT =====================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  // ===================== MENU =====================

  PopupMenuButton<String> buildMenu() {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == "call") {
          launchUrl(Uri.parse("tel:08123456789"));
        } else if (v == "sms") {
          launchUrl(Uri.parse("sms:08123456789"));
        } else if (v == "maps") {
          launchUrl(Uri.parse(
              "https://www.google.com/maps/place/Universitas+Dian+Nuswantoro"));
        } else if (v == "update") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UpdateUserPage()),
          );
        } else if (v == "logout") {
          logout(context);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: "call", child: Text("Call Center")),
        PopupMenuItem(value: "sms", child: Text("SMS Center")),
        PopupMenuItem(value: "maps", child: Text("Lokasi / Maps")),
        PopupMenuItem(value: "update", child: Text("Update User & Password")),
        PopupMenuItem(value: "logout", child: Text("Logout")),
      ],
    );
  }

  // ===================== UI =====================

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard UMKM Blangkon"),
        actions: [buildMenu()],
      ),
      body: Column(
        children: [
          // ===== STAT =====
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                statCard(
                  icon: Icons.inventory,
                  title: "Produk",
                  value: products.length.toString(),
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                statCard(
                  icon: Icons.shopping_cart,
                  title: "Terjual",
                  value: totalTerjual.toString(),
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                statCard(
                  icon: Icons.attach_money,
                  title: "Penjualan",
                  value: rupiah.format(totalPenjualan),
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // ===== PRODUCT LIST =====
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                final qty = quantities[p.id] ?? 0;

                return Card(
                  child: ListTile(
                    title: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(product: p),
                          ),
                        );
                      },
                      child: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    subtitle: Text(rupiah.format(p.price)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              qty > 0 ? () => removeFromCart(p) : null,
                        ),
                        Text(qty.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addToCart(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== CART BAR (FITUR LAMA, TIDAK DIHAPUS) =====
          InkWell(
            onTap: openPayment,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green,
              width: double.infinity,
              child: Text(
                "Total Jual : ${rupiah.format(total)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
