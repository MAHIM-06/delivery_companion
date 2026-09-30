class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final double discount;
  final String imageUrl;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.quantity,
  });

  double get finalPrice {
    return price - (price * discount / 100);
  }

  double get totalPrice {
    return finalPrice * quantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'discount': discount,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}