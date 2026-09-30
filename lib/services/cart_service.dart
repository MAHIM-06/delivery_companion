import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get cartCollection {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  Future<void> addToCart(
    ProductModel product,
    int quantity,
  ) async {
    final cartRef =
        cartCollection.doc(product.id);

    final existingItem =
        await cartRef.get();

    if (existingItem.exists) {
      final currentQuantity =
          existingItem.data()!['quantity'] ?? 0;

      await cartRef.update({
        'quantity': currentQuantity + quantity,
      });
    } else {
      final cartItem = CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        discount: product.discount,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );

      await cartRef.set(
        cartItem.toMap(),
      );
    }
  }

  Stream<List<CartItemModel>> getCartItems() {
    return cartCollection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItemModel.fromMap(
          doc.data(),
        );
      }).toList();
    });
  }

  Future<void> updateQuantity(
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    await cartCollection
        .doc(productId)
        .update({
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart(
    String productId,
  ) async {
    await cartCollection
        .doc(productId)
        .delete();
  }
}