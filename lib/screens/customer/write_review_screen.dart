// ignore_for_file: control_flow_in_finally

import 'package:flutter/material.dart';

import '../../services/review_service.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String customerName;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.customerName,
  });

  @override
  State<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends State<WriteReviewScreen> {

  final ReviewService _reviewService =
      ReviewService();

  final TextEditingController commentController =
      TextEditingController();

  double rating = 5;

  bool isSubmitting = false;
  bool isChecking = true;
  bool canReview = false;
  bool alreadyReviewed = false;

  @override
  void initState() {
    super.initState();

    _checkReviewPermission();
  }

  // ============================================================
  // CHECK REVIEW PERMISSION
  // ============================================================

  Future<void> _checkReviewPermission() async {
    try {
      final purchased =
          await _reviewService.canReviewProduct(
        widget.productId,
      );

      final reviewed =
          await _reviewService.hasReviewedProduct(
        widget.productId,
      );

      if (!mounted) return;

      setState(() {
        canReview = purchased;
        alreadyReviewed = reviewed;
        isChecking = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isChecking = false;
      });
    }
  }

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  Future<void> submitReview() async {
    final comment =
        commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please write a review.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await _reviewService.addReview(
        productId: widget.productId,
        customerName: widget.customerName,
        rating: rating,
        comment: comment,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Review submitted successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Write Review',
          ),
        ),

        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (alreadyReviewed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Write Review',
          ),
        ),

        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                ),

                SizedBox(height: 20),

                Text(
                  'You already reviewed this product.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!canReview) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Write Review',
          ),
        ),

        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                ),

                SizedBox(height: 20),

                Text(
                  'You can review this product after purchasing and receiving it.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write Review',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              widget.productName,

              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Your Rating',

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: List.generate(
                5,
                (index) {
                  final starNumber =
                      index + 1;

                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating =
                            starNumber.toDouble();
                      });
                    },

                    icon: Icon(
                      starNumber <= rating
                          ? Icons.star
                          : Icons.star_border,

                      size: 38,
                      color: Colors.amber,
                    ),
                  );
                },
              ),
            ),

            Text(
              '${rating.toInt()} / 5',
            ),

            const SizedBox(height: 25),

            const Text(
              'Your Review',

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: commentController,

              maxLines: 5,

              decoration:
                  const InputDecoration(
                hintText:
                    'Write your experience...',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    isSubmitting
                        ? null
                        : submitReview,

                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}