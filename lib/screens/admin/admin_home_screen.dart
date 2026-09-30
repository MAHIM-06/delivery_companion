import 'package:flutter/material.dart';

import 'admin_orders_screen.dart';
import 'admin_batches_screen.dart';
import 'admin_products_screen.dart';

import 'admin_delivery_persons_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 20),

            const Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Manage your store and deliveries',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            // ==========================================
            // PRODUCTS
            // ==========================================

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminProductsScreen(),
                  ),
                );
              },

              child: const Padding(
                padding:
                    EdgeInsets.all(16),

                child: Text(
                  'Manage Products',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AdminDeliveryPersonsScreen(),
      ),
    );
  },
  icon: const Icon(
    Icons.delivery_dining,
  ),
  label: const Text(
    'Delivery Persons',
  ),
),

            const SizedBox(height: 20),

            // ==========================================
            // ORDERS
            // ==========================================

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminOrdersScreen(),
                  ),
                );
              },

              child: const Padding(
                padding:
                    EdgeInsets.all(16),

                child: Text(
                  'Incoming Orders',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // BATCHES
            // ==========================================

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminBatchesScreen(),
                  ),
                );
              },

              child: const Padding(
                padding:
                    EdgeInsets.all(16),

                child: Text(
                  'Delivery Batches',
                  style: TextStyle(
                    fontSize: 18,
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