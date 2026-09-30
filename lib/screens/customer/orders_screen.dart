// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

import 'order_details_screen.dart';


class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final OrderService orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),

      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getMyOrders(),

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
                textAlign: TextAlign.center,
              ),
            );
          }

          final orders = snapshot.data ?? [];

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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order = orders[index];

              return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(
          order: order,
        ),
      ),
    );
  },
  child: OrderCard(
    order: order,
  ),
);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({
    super.key,
    required this.order,
  });

  Color getStatusColor() {
    switch (order.status) {
      case 'pending':
        return Colors.orange;

      case 'accepted':
        return Colors.blue;

      case 'preparing':
        return Colors.purple;

      case 'out_for_delivery':
        return Colors.indigo;

      case 'delivered':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String getStatusText() {
    switch (order.status) {
      case 'pending':
        return 'Pending';

      case 'accepted':
        return 'Accepted';

      case 'preparing':
        return 'Preparing';

      case 'out_for_delivery':
        return 'Out for Delivery';

      case 'delivered':
        return 'Delivered';

      case 'cancelled':
        return 'Cancelled';

      default:
        return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // Order ID
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Order #${order.id.substring(
                    0,
                    order.id.length > 6
                        ? 6
                        : order.id.length,
                  )}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: getStatusColor()
                        .withOpacity(0.15),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    getStatusText(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Number of items
            Text(
              '${order.items.length} item(s)',
            ),

            const SizedBox(height: 6),

            // Delivery type
            Row(
              children: [
                Icon(
                  order.deliveryType ==
                          'scheduled'
                      ? Icons.schedule
                      : Icons.flash_on,
                  size: 20,
                ),

                const SizedBox(width: 6),

                Text(
                  order.deliveryType ==
                          'scheduled'
                      ? 'Scheduled Delivery'
                      : 'Express Delivery',
                ),
              ],
            ),

            // Scheduled information
            if (order.deliveryType ==
                    'scheduled' &&
                order.scheduledDate != null) ...[
              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 20,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '${order.scheduledDate!.day}/'
                    '${order.scheduledDate!.month}/'
                    '${order.scheduledDate!.year}',
                  ),
                ],
              ),

              if (order.scheduledStartTime != null &&
                  order.scheduledEndTime != null)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 6,
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        '${order.scheduledStartTime} - '
                        '${order.scheduledEndTime}',
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 12),

            const Divider(),

            // Total
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  '৳${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}