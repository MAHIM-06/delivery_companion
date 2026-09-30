import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/wishlist_service.dart';

class WishlistButton extends StatefulWidget {
  final ProductModel product;

  const WishlistButton({
    super.key,
    required this.product,
  });

  @override
  State<WishlistButton> createState() =>
      _WishlistButtonState();
}

class _WishlistButtonState
    extends State<WishlistButton> {

  final WishlistService _wishlistService =
      WishlistService();

  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    try {
      final result =
          await _wishlistService.isInWishlist(
        widget.product.id,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isFavorite) {
        await _wishlistService
            .removeFromWishlist(
          widget.product.id,
        );
      } else {
        await _wishlistService
            .addToWishlist(
          widget.product,
        );
      }

      if (!mounted) return;

      setState(() {
        isFavorite = !isFavorite;
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Added to wishlist'
                : 'Removed from wishlist',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Wishlist error: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading
          ? null
          : _toggleWishlist,

      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,

              color: isFavorite
                  ? Colors.red
                  : null,
            ),
    );
  }
}