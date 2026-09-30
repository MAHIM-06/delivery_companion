import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';

class WishlistService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get wishlistCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');
  }

  // Add product to wishlist
  Future<void> addToWishlist(
    ProductModel product,
  ) async {
    await wishlistCollection
        .doc(product.id)
        .set({
      'productId': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'discount': product.discount,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'storeId': product.storeId,
      'available': product.available,
    });
  }

  // Remove product from wishlist
  Future<void> removeFromWishlist(
    String productId,
  ) async {
    await wishlistCollection
        .doc(productId)
        .delete();
  }

  // Check whether a product is already in wishlist
  Future<bool> isInWishlist(
    String productId,
  ) async {
    final document = await wishlistCollection
        .doc(productId)
        .get();

    return document.exists;
  }

  // Get all wishlist products
  Stream<List<ProductModel>> getWishlistProducts() {
    return wishlistCollection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ProductModel.fromMap(
          doc.id,
          data,
        );
      }).toList();
    });
  }
}