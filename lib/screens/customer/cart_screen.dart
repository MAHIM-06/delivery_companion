import 'package:flutter/material.dart';
import 'checkout_screen.dart';

import '../../models/cart_item_model.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: StreamBuilder<List<CartItemModel>>(
        stream: cartService.getCartItems(),
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

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          double grandTotal = 0;

          for (final item in items) {
            grandTotal += item.totalPrice;
          }

          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {

                    final item = items[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Row(
                          children: [

                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                              child: item.imageUrl
                                      .isEmpty
                                  ? const Icon(
                                      Icons.image,
                                      size: 40,
                                    )
                                  : Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  Text(
                                    item.name,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Text(
                                    '৳${item.finalPrice.toStringAsFixed(0)}',
                                  ),

                                  Row(
                                    children: [

                                      IconButton(
                                        onPressed: () {
                                          cartService
                                              .updateQuantity(
                                            item.productId,
                                            item.quantity -
                                                1,
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons.remove,
                                        ),
                                      ),

                                      Text(
                                        '${item.quantity}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          cartService
                                              .updateQuantity(
                                            item.productId,
                                            item.quantity +
                                                1,
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons.add,
                                        ),
                                      ),

                                      const Spacer(),

                                      IconButton(
                                        onPressed: () {
                                          cartService
                                              .removeFromCart(
                                            item.productId,
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons.delete,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [

                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Text(
                          '৳${grandTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          CheckoutScreen(
        items: items,
        subtotal: grandTotal,
      ),
    ),
  );
},
                        child: const Text(
                          'Proceed to Checkout',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}