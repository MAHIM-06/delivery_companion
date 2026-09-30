import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get reviewCollection {
    return _firestore.collection('reviews');
  }

  // ============================================================
  // CHECK WHETHER CUSTOMER CAN REVIEW PRODUCT
  // ============================================================

  Future<bool> canReviewProduct(
    String productId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final ordersSnapshot = await _firestore
        .collection('orders')
        .where(
          'customerId',
          isEqualTo: user.uid,
        )
        .where(
          'status',
          isEqualTo: 'delivered',
        )
        .get();

    for (final orderDocument
        in ordersSnapshot.docs) {
      final data = orderDocument.data();

      final List<dynamic> items =
          data['items'] ?? [];

      for (final item in items) {
        final itemMap =
            Map<String, dynamic>.from(item);

        if (itemMap['productId'] == productId) {
          return true;
        }
      }
    }

    return false;
  }

  // ============================================================
  // CHECK WHETHER CUSTOMER ALREADY REVIEWED PRODUCT
  // ============================================================

  Future<bool> hasReviewedProduct(
    String productId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final snapshot = await reviewCollection
        .where(
          'productId',
          isEqualTo: productId,
        )
        .where(
          'customerId',
          isEqualTo: user.uid,
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // ============================================================
  // ADD REVIEW
  // ============================================================

  Future<void> addReview({
    required String productId,
    required String customerName,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    // Check purchase history
    final canReview =
        await canReviewProduct(productId);

    if (!canReview) {
      throw Exception(
        'You can only review a product after receiving it.',
      );
    }

    // Prevent multiple reviews
    final alreadyReviewed =
        await hasReviewedProduct(productId);

    if (alreadyReviewed) {
      throw Exception(
        'You have already reviewed this product.',
      );
    }

    // Validate rating
    if (rating < 1 || rating > 5) {
      throw Exception(
        'Rating must be between 1 and 5.',
      );
    }

    // Validate comment
    if (comment.trim().isEmpty) {
      throw Exception(
        'Review cannot be empty.',
      );
    }

    await reviewCollection.add({
      'productId': productId,
      'customerId': user.uid,
      'customerName': customerName,
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': Timestamp.now(),
    });
  }

  // ============================================================
  // GET PRODUCT REVIEWS
  // ============================================================

  Stream<List<ReviewModel>> getProductReviews(
    String productId,
  ) {
    return reviewCollection
        .where(
          'productId',
          isEqualTo: productId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // GET AVERAGE RATING
  // ============================================================

  Stream<double> getAverageRating(
    String productId,
  ) {
    return getProductReviews(productId)
        .map((reviews) {
      if (reviews.isEmpty) {
        return 0.0;
      }

      double total = 0;

      for (final review in reviews) {
        total += review.rating;
      }

      return total / reviews.length;
    });
  }

  // ============================================================
  // DELETE REVIEW
  // ============================================================

  Future<void> deleteReview(
    String reviewId,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final reviewReference =
        reviewCollection.doc(reviewId);

    final snapshot =
        await reviewReference.get();

    if (!snapshot.exists) {
      return;
    }

    final data = snapshot.data()!;

    if (data['customerId'] != user.uid) {
      throw Exception(
        'You can only delete your own review.',
      );
    }

    await reviewReference.delete();
  }
}