import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/wishlist_service.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistService wishlistService =
        WishlistService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: wishlistService.getWishlistProducts(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Add products you like to see them here.',
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),

            itemCount: products.length,

            itemBuilder: (context, index) {
              final product = products[index];

              return WishlistProductCard(
                product: product,
                wishlistService: wishlistService,
              );
            },
          );
        },
      ),
    );
  }
}

class WishlistProductCard extends StatelessWidget {
  final ProductModel product;
  final WishlistService wishlistService;

  const WishlistProductCard({
    super.key,
    required this.product,
    required this.wishlistService,
  });

  double get finalPrice {
    return product.price -
        (product.price * product.discount / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // Product image
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
                ),

                Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    backgroundColor:
                        Colors.white,

                    child: IconButton(
                      padding: EdgeInsets.zero,

                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),

                      onPressed: () async {
                        await wishlistService
                            .removeFromWishlist(
                          product.id,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product information
          Padding(
            padding:
                const EdgeInsets.all(8),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  product.category,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '৳${finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(
                            product: product,
                          ),
                        ),
                      );
                    },

                    child: const Text(
                      'View Product',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}