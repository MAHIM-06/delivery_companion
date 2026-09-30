import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/delivery_batch_model.dart';
import '../../models/order_model.dart';
import '../../services/delivery_batch_service.dart';
import '../../services/order_service.dart';

import 'delivery_profile_screen.dart';

import 'delivery_order_details_screen.dart';

import 'batch_route_map_screen.dart';



class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() =>
      _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState
    extends State<DeliveryHomeScreen> {
  int selectedIndex = 0;

  final DeliveryBatchService batchService =
      DeliveryBatchService();

  final OrderService orderService = OrderService();

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Dashboard'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),

          IconButton(
  icon: const Icon(Icons.person),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const DeliveryProfileScreen(),
      ),
    );
  },
),
        ],
      ),

      body: selectedIndex == 0
          ? const AvailableBatchesScreen()
          : const MyBatchesScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Available',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Batches',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AVAILABLE BATCHES
// ============================================================

class AvailableBatchesScreen extends StatelessWidget {
  const AvailableBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeliveryBatchService batchService =
        DeliveryBatchService();

    return StreamBuilder<List<DeliveryBatchModel>>(
      stream: FirebaseFirestore.instance
          .collection('delivery_batches')
          .where('status', isEqualTo: 'created')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return DeliveryBatchModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();
      }),

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

        final batches = snapshot.data ?? [];

        if (batches.isEmpty) {
          return const Center(
            child: Text(
              'No available batches.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: batches.length,

          itemBuilder: (context, index) {
            final batch = batches[index];

            return AvailableBatchCard(
              batch: batch,
              batchService: batchService,
            );
          },
        );
      },
    );
  }
}

// ============================================================
// AVAILABLE BATCH CARD
// ============================================================

class AvailableBatchCard extends StatelessWidget {
  final DeliveryBatchModel batch;
  final DeliveryBatchService batchService;

  const AvailableBatchCard({
    super.key,
    required this.batch,
    required this.batchService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              'Delivery Batch',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Area: ${batch.area}',
            ),

            const SizedBox(height: 5),

            Text(
              'Date: '
              '${batch.scheduledDate.day}/'
              '${batch.scheduledDate.month}/'
              '${batch.scheduledDate.year}',
            ),

            const SizedBox(height: 5),

            Text(
              'Time: '
              '${batch.startTime} - '
              '${batch.endTime}',
            ),

            const SizedBox(height: 5),

            Text(
              'Orders: ${batch.orderIds.length}',
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  showBatchDetails(
                    context,
                    batch,
                  );
                },

                child: const Text(
                  'View Batch',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showBatchDetails(
    BuildContext context,
    DeliveryBatchModel batch,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BatchDetailsScreen(
          batch: batch,
        ),
      ),
    );
  }
}

// ============================================================
// MY BATCHES
// ============================================================

class MyBatchesScreen extends StatelessWidget {
  const MyBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text(
          'User not logged in.',
        ),
      );
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('delivery_batches')
          .where(
            'deliveryPersonId',
            isEqualTo: uid,
          )
          .snapshots(),

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

        final documents =
            snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return const Center(
            child: Text(
              'You have no assigned batches.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        }

        final batches = documents.map((doc) {
          return DeliveryBatchModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: batches.length,

          itemBuilder: (context, index) {
            final batch = batches[index];

            return MyBatchCard(
              batch: batch,
            );
          },
        );
      },
    );
  }
}

// ============================================================
// MY BATCH CARD
// ============================================================

class MyBatchCard extends StatelessWidget {
  final DeliveryBatchModel batch;

  const MyBatchCard({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'My Delivery Batch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Area: ${batch.area}',
            ),

            const SizedBox(height: 5),

            Text(
              'Date: '
              '${batch.scheduledDate.day}/'
              '${batch.scheduledDate.month}/'
              '${batch.scheduledDate.year}',
            ),

            const SizedBox(height: 5),

            Text(
              'Time: '
              '${batch.startTime} - '
              '${batch.endTime}',
            ),

            const SizedBox(height: 5),

            Text(
              'Orders: ${batch.orderIds.length}',
            ),

            const SizedBox(height: 5),

            Text(
              'Status: ${batch.status}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BatchDetailsScreen(
                        batch: batch,
                      ),
                    ),
                  );
                },

                child: const Text(
                  'View Orders',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BATCH DETAILS
// ============================================================

class BatchDetailsScreen extends StatelessWidget {
  final DeliveryBatchModel batch;

  const BatchDetailsScreen({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Batch Details',
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where(
              FieldPath.documentId,
              whereIn: batch.orderIds,
            )
            .snapshots(),

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

          final documents =
              snapshot.data?.docs ?? [];

          final orders = documents.map((doc) {
            return OrderModel.fromMap(
              doc.id,
              doc.data(),
            );
          }).toList();

          return Column(
            children: [
              // --------------------------------
              // BATCH INFORMATION
              // --------------------------------

              Padding(
                padding: const EdgeInsets.all(16),

                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Area: ${batch.area}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Time: '
                          '${batch.startTime} - '
                          '${batch.endTime}',
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Total Orders: '
                          '${batch.orderIds.length}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BatchRouteMapScreen(
            orders: orders,
          ),
        ),
      );
    },
    icon: const Icon(
      Icons.map,
    ),
    label: const Text(
      'View Delivery Map',
    ),
  ),
),

              // --------------------------------
              // ORDERS
              // --------------------------------

              Expanded(
                child: orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders found.',
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        itemCount: orders.length,

                        itemBuilder:
                            (context, index) {
                          final order =
                              orders[index];

                          return OrderCard(
                            order: order,
                          );
                        },
                      ),
              ),

              // --------------------------------
              // START BUTTON
              // --------------------------------

              if (batch.status == 'assigned')
                Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {
                        await startBatch(
                          context,
                          batch.id,
                          orders,
                        );
                      },

                      child: const Padding(
                        padding:
                            EdgeInsets.all(14),

                        child: Text(
                          'Start Batch',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // --------------------------------
              // COMPLETE BUTTON
              // --------------------------------

              if (batch.status == 'in_progress')
                Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {
                        await completeBatch(
                          context,
                          batch.id,
                          orders,
                        );
                      },

                      child: const Padding(
                        padding:
                            EdgeInsets.all(14),

                        child: Text(
                          'Complete Batch',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // START BATCH
  // ==========================================================

  Future<void> startBatch(
    BuildContext context,
    String batchId,
    List<OrderModel> orders,
  ) async {
    final firestore =
        FirebaseFirestore.instance;

    final batchReference = firestore
        .collection('delivery_batches')
        .doc(batchId);

    final writeBatch = firestore.batch();

    writeBatch.update(
      batchReference,
      {
        'status': 'in_progress',
      },
    );

    for (final order in orders) {
      final orderReference = firestore
          .collection('orders')
          .doc(order.id);

      writeBatch.update(
        orderReference,
        {
          'status': 'out_for_delivery',
        },
      );
    }

    await writeBatch.commit();

    await DeliveryBatchService()
    .notifyCustomersBatchStarted(
    orders,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Batch started.',
        ),
      ),
    );
  }

  // ==========================================================
  // COMPLETE BATCH
  // ==========================================================

  Future<void> completeBatch(
    BuildContext context,
    String batchId,
    List<OrderModel> orders,
  ) async {
    final firestore =
        FirebaseFirestore.instance;

    final batchReference = firestore
        .collection('delivery_batches')
        .doc(batchId);

    final writeBatch = firestore.batch();

    writeBatch.update(
      batchReference,
      {
        'status': 'completed',
      },
    );

    for (final order in orders) {
      final orderReference = firestore
          .collection('orders')
          .doc(order.id);

      writeBatch.update(
        orderReference,
        {
          'status': 'delivered',
        },
      );
    }

    await writeBatch.commit();

    await DeliveryBatchService()
    .notifyCustomersBatchCompleted(
    orders,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Batch completed.',
        ),
      ),
    );
  }
}

// ============================================================
// ORDER CARD
// ============================================================

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({
    super.key,
    required this.order,
  });

  String getStatusLabel() {
    switch (order.status) {
      case 'ready':
        return 'Ready for Delivery';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'rejected':
        return 'Rejected';

      default:
        return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              'Order: ${order.id}',
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Icon(
                  Icons.location_on,
                  size: 20,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    order.address,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Area: ${order.area}',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Status: ${getStatusLabel()}',
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Items: ${order.items.length}',
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Total: '
              '৳${order.totalAmount.toStringAsFixed(2)}',

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeliveryOrderDetailsScreen(
                        order: order,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.visibility,
                ),

                label: const Text(
                  'View Order Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}