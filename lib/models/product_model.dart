class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discount;
  final String category;
  final String imageUrl;
  final String storeId;
  final bool available;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.category,
    required this.imageUrl,
    required this.storeId,
    required this.available,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'category': category,
      'imageUrl': imageUrl,
      'storeId': storeId,
      'available': available,
    };
  }

  factory ProductModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      storeId: map['storeId'] ?? '',
      available: map['available'] ?? true,
    );
  }
}