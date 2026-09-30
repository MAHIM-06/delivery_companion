import 'package:flutter/material.dart';

import '../../models/product_model.dart';

import '../../services/cart_service.dart';

import '../../widgets/wishlist_button.dart';

import '../../widgets/product_reviews.dart';
import 'write_review_screen.dart';

final CartService cartService = CartService();

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  int quantity = 1;

  double get finalPrice {
    return widget.product.price -
        (widget.product.price *
            widget.product.discount /
            100);
  }

  double get totalPrice {
    return finalPrice * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
  title: const Text('Product Details'),

  actions: [
    WishlistButton(
      product: product,
    ),
  ],
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // Product image
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: product.imageUrl.isEmpty
                  ? const Icon(
                      Icons.image,
                      size: 100,
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 20),

            // Product name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Category
            Text(
              product.category,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            // Price
            Row(
              children: [

                Text(
                  '৳${finalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (product.discount > 0) ...[
                  const SizedBox(width: 12),

                  Text(
                    '৳${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration:
                          TextDecoration.lineThrough,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    '${product.discount.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 25),

            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            const SizedBox(height: 25),

            //36 additional code for reviews section

            const Text(
           'Reviews',
            style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            ),
            ),

const SizedBox(height: 10),

ProductReviews(
  productId: product.id,
),

            // Quantity
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.remove,
                  ),
                ),

                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Total
            Text(
              'Total: ৳${totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Add to cart
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
  try {
    await cartService.addToCart(
      widget.product,
      quantity,
    );

    if (!mounted) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Added to cart successfully',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Failed to add to cart: $e',
        ),
      ),
    );
  }
},
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}