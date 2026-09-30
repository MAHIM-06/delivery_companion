import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class ProductReviews extends StatelessWidget {
  final String productId;

  const ProductReviews({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final ReviewService reviewService =
        ReviewService();

    return StreamBuilder<List<ReviewModel>>(
      stream: reviewService
          .getProductReviews(productId),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
          );
        }

        final reviews =
            snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No reviews yet.',
            ),
          );
        }

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...reviews.map(
              (review) {
                return ReviewCard(
                  review: review,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    review.customerName,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                ...List.generate(
                  5,
                  (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  },
                ),

                const SizedBox(width: 8),

                Text(
                  review.rating
                      .toStringAsFixed(1),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              review.comment,
            ),

            const SizedBox(height: 6),

            Text(
              review.createdAt
                  .toString(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}