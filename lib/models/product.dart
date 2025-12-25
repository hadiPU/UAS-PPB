
class Product {
  int? id;
  final String name;
  final double price;
  final String image;
  final String description;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      name: map['name'] ?? '',
      price: double.tryParse(map['price'].toString()) ?? 0,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
    );
  }
}



  // data sample untuk seed awal DB
  /*static List<Product> sampleProducts() {
    return [
      Product(
        name: 'Mi Telur',
        price: 10000,
        image: 'assets/images/mie-telur.jpg',
        description:
            'Mi telur adalah mi berwarna kuning yang dibuat dari tepung terigu dan telur. Teksturnya kenyal dan lembut. Cocok untuk mi goreng atau kuah.',
      ),
      Product(
        name: 'Ramen',
        price: 35000,
        image: 'assets/images/ramen.jpg',
        description:
            'Ramen khas Jepang dengan kuah kaya rasa, disajikan bersama topping seperti telur dan daging.',
      ),
      Product(
        name: 'Kwetiau',
        price: 16000,
        image: 'assets/images/kwetiau.jpg',
        description:
            'Kwetiau adalah mi pipih terbuat dari tepung beras, nikmat dimasak goreng atau berkuah.',
      ),
      Product(
        name: 'Udon',
        price: 40000,
        image: 'assets/images/udon.jpg',
        description:
            'Udon adalah mi tebal Jepang yang lembut dan kenyal, biasanya disajikan dalam kuah hangat.',
      ),
      Product(
        name: 'Lo Mein',
        price: 23000,
        image: 'assets/images/lo-mein.jpg',
        description:
            'Lo Mein mi gandum asal China dimasak dengan saus gurih dan sayuran/daging.',
      ),
      Product(
        name: 'Mi Sagu',
        price: 20000,
        image: 'assets/images/mie-sagu.jpg',
        description:
            'Mi Sagu khas Kepulauan Riau, terbuat dari tepung sagu dengan tekstur kenyal dan aroma khas.',
      ),
    ];
  }*/

