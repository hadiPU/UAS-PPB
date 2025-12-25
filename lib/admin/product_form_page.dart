import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final imageC = TextEditingController();
  final descC = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameC.text = widget.product!.name;
      priceC.text = widget.product!.price.toString();
      imageC.text = widget.product!.image;
      descC.text = widget.product!.description;
    }
  }

  void save() async {
    bool ok;
    if (widget.product == null) {
      ok = await ApiService.addProduct(
          nameC.text, priceC.text, imageC.text, descC.text);
    } else {
      ok = await ApiService.updateProduct(
          widget.product!.id!,
          nameC.text,
          priceC.text,
          imageC.text,
          descC.text);
    }

    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? "Tambah Produk"
            : "Edit Produk"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nama Produk")),
            TextField(controller: priceC, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: imageC, decoration: const InputDecoration(labelText: "Nama Gambar")),
            TextField(controller: descC, decoration: const InputDecoration(labelText: "Deskripsi")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
