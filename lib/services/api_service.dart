import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://192.168.10.115/blangkis/api";

  // =====================================================
  // ===================== PRODUCT =======================
  // =====================================================

  // GET PRODUCTS
  static Future<List<Product>> getProducts() async {
    final res = await http.get(Uri.parse("$baseUrl/get_products.php"));
    final data = json.decode(res.body);

    if (data is Map && data['status'] == 'success') {
      return (data['data'] as List).map((e) => Product.fromMap(e)).toList();
    }
    return [];
  }

  // INSERT PRODUCT (ADMIN)
  static Future<bool> addProduct(
      String name, String price, String image, String desc) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/products_crud.php"),
      body: {
        "action": "add",
        "name": name,
        "price": price,
        "image": image,
        "description": desc,
      },
    );

    final data = json.decode(res.body);
    return data['status'] == 'success';
  }

  // UPDATE PRODUCT (ADMIN)
  static Future<bool> updateProduct(
      int id, String name, String price, String image, String desc) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/products_crud.php"),
      body: {
        "action": "update",
        "id": id.toString(),
        "name": name,
        "price": price,
        "image": image,
        "description": desc,
      },
    );

    final data = json.decode(res.body);
    return data['status'] == 'success';
  }

  // DELETE PRODUCT (ADMIN)
  static Future<bool> deleteProduct(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/admin/products_crud.php"),
      body: {
        "action": "delete",
        "id": id.toString(),
      },
    );

    final data = json.decode(res.body);
    return data['status'] == 'success';
  }

  // =====================================================
  // ===================== ORDER =========================
  // =====================================================

  /// ADD ORDER (PAYMENT)
  static Future<bool> addOrder({
    required int userId,
    required int total,
    required int bayar,
    required int kembalian,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/add_order.php"),
      body: {
        "user_id": userId.toString(),
        "total": total.toString(),
        "bayar": bayar.toString(),
        "kembalian": kembalian.toString(),
        "items": json.encode(items),
      },
    );

    final data = json.decode(res.body);
    return data['status'] == 'success';
  }

  /// GET ALL ORDERS (ADMIN)
  static Future<List<dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse("$baseUrl/get_orders.php"),
    );

    final data = json.decode(res.body);

    if (data is Map && data['status'] == 'success') {
      return data['data'];
    }
    return [];
  }

  /// GET ORDER ITEMS
  static Future<List<dynamic>> getOrderItems(int orderId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/get_order_items.php?order_id=$orderId"),
    );

    final data = json.decode(res.body);

    if (data is Map && data['status'] == 'success') {
      return data['data'];
    }
    return [];
  }

  // =====================================================
  // ===================== REPORT ========================
  // =====================================================

  /// SALES SUMMARY (ADMIN)
  static Future<Map<String, dynamic>> getSalesSummary() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/get_sales_summary.php"),
    );

    final decoded = json.decode(res.body);

    // ✅ Jika API sudah Map → langsung pakai
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    // ✅ Jika API return List → ubah ke Map kosong
    return {
      "status": "failed",
      "total_transaksi": 0,
      "total_penjualan": 0,
    };
  }

  /// LAPORAN GLOBAL
  static Future<List<dynamic>> getLaporanGlobal() async {
    final res = await http.get(
      Uri.parse("$baseUrl/admin/laporan_global.php"),
    );

    final data = json.decode(res.body);

    if (data is Map && data['status'] == 'success') {
      return data['data'];
    }
    return [];
  }

  /// LAPORAN PERIODIK
  static Future<List<dynamic>> getLaporanPeriodik(
      String from, String to) async {
    final res = await http.get(
      Uri.parse(
        "$baseUrl/admin/laporan_periodik.php?from=$from&to=$to",
      ),
    );

    final data = json.decode(res.body);

    if (data is Map && data['status'] == 'success') {
      return data['data'];
    }
    return [];
  }
}
