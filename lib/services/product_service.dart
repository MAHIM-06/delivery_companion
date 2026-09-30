import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET AVAILABLE PRODUCTS
  // ============================================================

  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .where(
          'available',
          isEqualTo: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // GET ALL PRODUCTS - ADMIN
  // ============================================================

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  Future<void> addProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection('products')
        .add(product.toMap());
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<void> updateProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  // ============================================================
  // DELETE PRODUCT
  // ============================================================

  Future<void> deleteProduct(
    String productId,
  ) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .delete();
  }
}