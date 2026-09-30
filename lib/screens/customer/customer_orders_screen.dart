import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class CustomerOrdersScreen extends StatelessWidget {
  CustomerOrdersScreen({super.key});

  final OrderService orderService =
      OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getMyOrders(),

        builder: (context, snapshot) {
          // --------------------------------
          // LOADING
          // --------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // --------------------------------
          // ERROR
          // --------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final orders =
              snapshot.data ?? [];

          // --------------------------------
          // NO ORDERS
          // --------------------------------

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'You have no orders yet.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // --------------------------------
          // ORDERS
          // --------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order = orders[index];

              return CustomerOrderCard(
                order: order,
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// CUSTOMER ORDER CARD
// ============================================================

class CustomerOrderCard extends StatelessWidget {
  final OrderModel order;

  const CustomerOrderCard({
    super.key,
    required this.order,
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
            // ORDER ID
            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // STATUS
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                StatusBadge(
                  status: order.status,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // AREA
            Text(
              'Area: ${order.area}',
            ),

            const SizedBox(height: 5),

            // ADDRESS
            Text(
              'Address: ${order.address}',
            ),

            const SizedBox(height: 5),

            // DELIVERY TYPE
            Text(
              'Delivery: ${order.deliveryType}',
            ),

            const SizedBox(height: 5),

            // TOTAL
            Text(
              'Total: ${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // VIEW DETAILS
            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerOrderDetailsScreen(
                        order: order,
                      ),
                    ),
                  );
                },

                child: const Text(
                  'View Order',
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
// STATUS BADGE
// ============================================================

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';

      case 'accepted':
        return 'Accepted';

      case 'preparing':
        return 'Preparing';

      case 'ready':
        return 'Ready';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'rejected':
        return 'Rejected';

      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),

        color: Colors.grey.shade200,
      ),

      child: Text(
        displayStatus,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// ORDER DETAILS SCREEN
// ============================================================

class CustomerOrderDetailsScreen
    extends StatelessWidget {
  final OrderModel order;

  const CustomerOrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // --------------------------------
            // ORDER INFORMATION
            // --------------------------------

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        StatusBadge(
                          status: order.status,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Area: ${order.area}',
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Address: ${order.address}',
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Delivery Type: '
                      '${order.deliveryType}',
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Total: '
                      '${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------
            // DELIVERY SCHEDULE
            // --------------------------------

            if (order.deliveryType ==
                'scheduled')
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Delivery Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (order.scheduledDate !=
                          null)
                        Text(
                          'Date: '
                          '${order.scheduledDate!.day}/'
                          '${order.scheduledDate!.month}/'
                          '${order.scheduledDate!.year}',
                        ),

                      const SizedBox(height: 5),

                      Text(
                        'Time: '
                        '${order.scheduledStartTime ?? ''}'
                        ' - '
                        '${order.scheduledEndTime ?? ''}',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --------------------------------
            // ORDER ITEMS
            // --------------------------------

            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...order.items.map(
              (item) {
                final String name =
                    item['name'] ?? '';

                final int quantity =
                    item['quantity'] ?? 1;

                final double price =
                    (item['price'] ?? 0)
                        .toDouble();

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: ListTile(
                    title: Text(name),

                    subtitle: Text(
                      'Quantity: $quantity',
                    ),

                    trailing: Text(
                      price.toStringAsFixed(2),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --------------------------------
            // TRACKING
            // --------------------------------

            const Text(
              'Order Tracking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            OrderTracking(
              status: order.status,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ORDER TRACKING
// ============================================================

class OrderTracking extends StatelessWidget {
  final String status;

  const OrderTracking({
    super.key,
    required this.status,
  });

  bool isCompleted(String step) {
    const steps = [
      'pending',
      'accepted',
      'preparing',
      'ready',
      'out_for_delivery',
      'delivered',
    ];

    final currentIndex =
        steps.indexOf(status);

    final stepIndex =
        steps.indexOf(step);

    if (currentIndex == -1 ||
        stepIndex == -1) {
      return false;
    }

    return stepIndex <= currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            TrackingStep(
              title: 'Order Placed',
              completed:
                  isCompleted('pending'),
            ),

            TrackingLine(),

            TrackingStep(
              title: 'Order Accepted',
              completed:
                  isCompleted('accepted'),
            ),

            TrackingLine(),

            TrackingStep(
              title: 'Preparing',
              completed:
                  isCompleted('preparing'),
            ),

            TrackingLine(),

            TrackingStep(
              title: 'Ready for Delivery',
              completed:
                  isCompleted('ready'),
            ),

            TrackingLine(),

            TrackingStep(
              title: 'Out for Delivery',
              completed:
                  isCompleted(
                'out_for_delivery',
              ),
            ),

            TrackingLine(),

            TrackingStep(
              title: 'Delivered',
              completed:
                  isCompleted('delivered'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TRACKING STEP
// ============================================================

class TrackingStep extends StatelessWidget {
  final String title;
  final bool completed;

  const TrackingStep({
    super.key,
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,

          size: 28,

          color: completed
              ? Colors.green
              : Colors.grey,
        ),

        const SizedBox(width: 12),

        Text(
          title,
          style: TextStyle(
            fontWeight: completed
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TRACKING LINE
// ============================================================

class TrackingLine extends StatelessWidget {
  const TrackingLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 2,
      color: Colors.grey,
      margin: const EdgeInsets.only(
        left: 13,
      ),
    );
  }
}