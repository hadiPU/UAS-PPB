import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onNameTap;
  final VoidCallback onImageTap;

  const ProductItem({
    super.key,
    required this.product,
    required this.onNameTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ListTile(
      leading: GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(product.image,
              width: 60, height: 60, fit: BoxFit.cover),
        ),
      ),
      title: GestureDetector(
        onTap: onNameTap,
        child: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
      ),

      subtitle: Text(
        rupiah.format(product.price),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
