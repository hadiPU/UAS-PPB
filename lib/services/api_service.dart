import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "http://100.79.136.94:8080/";

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
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
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

  /// ADD ORDER (VERSI LAMA - TIDAK DIUBAH)
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

  /// ADD ORDER + RETURN ORDER ID (FUNGSI BARU)
  static Future<int?> addOrderWithId({
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

    if (data['status'] == 'success') {
      return int.tryParse(data['order_id'].toString());
    }
    return null;
  }

  /// GET ALL ORDERS (ADMIN)
  static Future<List<dynamic>> getOrders() async {
    final res = await http.get(Uri.parse("$baseUrl/get_orders.php"));
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

  /// ✅ GET LAST ORDER BY USER + STATUS BUKTI (TAMBAHAN BARU)
  static Future<Map<String, dynamic>?> getLastOrderWithStatus(
      int userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_last_order.php?user_id=$userId"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data['status'] == 'success') {
          return {
            'order_id': data['order_id'],
            'has_proof': data['has_proof'] ?? false,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting last order: $e');
      return null;
    }
  }

  /// GET LAST ORDER BY USER (VERSI LAMA - TETAP DIPERTAHANKAN)
  static Future<int?> getLastOrderId(int userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_last_order.php?user_id=$userId"),
      );

      if (res.statusCode != 200) return null;

      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        return int.tryParse(data['order_id'].toString());
      }
      return null;
    } catch (e) {
      print("getLastOrderId error: $e");
      return null;
    }
  }

  /// ✅ CEK APAKAH ORDER SUDAH PUNYA BUKTI PEMBAYARAN
  static Future<bool> checkOrderHasProof(int orderId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/check_order_proof.php?order_id=$orderId"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['has_proof'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking proof: $e');
      return false;
    }
  }

  /// UPLOAD BUKTI PEMBAYARAN
  static Future<bool> uploadBuktiPembayaran(int orderId, File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/user/upload_bukti.php"),
      );

      request.fields['order_id'] = orderId.toString();
      request.files.add(
        await http.MultipartFile.fromPath('bukti', file.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload response: $responseBody');

      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(responseBody);
      return decoded['status'] == 'success';
    } catch (e) {
      print('Error uploading: $e');
      return false;
    }
  }

  static Future<int?> getLastOrderNeedProof(int userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_last_unpaid_order.php?user_id=$userId"),
      );

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        return int.tryParse(data['order_id'].toString());
      }
      return null;
    } catch (e) {
      print("getLastOrderNeedProof error: $e");
      return null;
    }
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

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      "status": "failed",
      "total_transaksi": 0,
      "total_penjualan": 0,
    };
  }

  /// LAPORAN GLOBAL
  static Future<List<dynamic>> getLaporanGlobal() async {
    final res = await http.get(Uri.parse("$baseUrl/admin/laporan_global.php"));
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

  /// UPDATE ORDER STATUS
  static Future<bool> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    final res = await http.post(
      Uri.parse(
        "$baseUrl/admin/update_order_status.php",
      ),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "order_id": orderId.toString(),
        "status": status,
      },
    );

    final data = jsonDecode(res.body);
    return data['status'] == 'success';
  }

  static Future<List> getLaporan({String filter = "1day"}) async {
    String url;

    if (filter == "all") {
      url = "http://100.79.136.94:8080/admin/laporan_global.php";
    } else {
      url =
          "http://100.79.136.94:8080/admin/laporan_periodik.php?filter=$filter";
    }

    final res = await http.get(Uri.parse(url));

    final body = jsonDecode(res.body);

    return body["data"] ?? [];
  }
}
