// ignore_for_file: duplicate_ignore, use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class AdminOrdersScreen extends StatelessWidget {
  AdminOrdersScreen({super.key});

  final OrderService orderService =
      OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Incoming Orders',
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getAllOrders(),

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
                'No orders found.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // --------------------------------
          // ORDER LIST
          // --------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order = orders[index];

              return AdminOrderCard(
                order: order,
                orderService: orderService,
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// ADMIN ORDER CARD
// ============================================================

class AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.orderService,
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
            // --------------------------------
            // ORDER ID
            // --------------------------------

            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // --------------------------------
            // CUSTOMER
            // --------------------------------

            Text(
              'Customer ID: ${order.customerId}',
            ),

            const SizedBox(height: 5),

            // --------------------------------
            // AREA
            // --------------------------------

            Text(
              'Area: ${order.area}',
            ),

            const SizedBox(height: 5),

            // --------------------------------
            // ADDRESS
            // --------------------------------

            Text(
              'Address: ${order.address}',
            ),

            const SizedBox(height: 5),

            // --------------------------------
            // DELIVERY TYPE
            // --------------------------------

            Text(
              'Delivery Type: '
              '${order.deliveryType}',
            ),

            const SizedBox(height: 5),

            // --------------------------------
            // SCHEDULE
            // --------------------------------

            if (order.deliveryType ==
                    'scheduled' &&
                order.scheduledDate != null)
              Text(
                'Schedule: '
                '${order.scheduledDate!.day}/'
                '${order.scheduledDate!.month}/'
                '${order.scheduledDate!.year}'
                ' '
                '${order.scheduledStartTime ?? ''}'
                ' - '
                '${order.scheduledEndTime ?? ''}',
              ),

            const SizedBox(height: 5),

            // --------------------------------
            // TOTAL
            // --------------------------------

            Text(
              'Total: '
              '${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // --------------------------------
            // BATCH
            // --------------------------------

            if (order.batchId != null)
              Text(
                'Batch: ${order.batchId}',
              ),

            const SizedBox(height: 10),

            // --------------------------------
            // STATUS
            // --------------------------------

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

            const SizedBox(height: 15),

            // --------------------------------
            // ACTIONS
            // --------------------------------

            _buildActions(context),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ACTION BUTTONS
  // ==========================================================

  Widget _buildActions(
    BuildContext context,
  ) {
    // --------------------------------
    // PENDING
    // --------------------------------

    if (order.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                await orderService.acceptOrder(
                  order.id,
                );

                showMessage(
                  // ignore: use_build_context_synchronously
                  context,
                  'Order accepted',
                );
              },

              child: const Text(
                'Accept',
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                await orderService.rejectOrder(
                  order.id,
                );

                showMessage(
                  // ignore: use_build_context_synchronously
                  context,
                  'Order rejected',
                );
              },

              child: const Text(
                'Reject',
              ),
            ),
          ),
        ],
      );
    }

    // --------------------------------
    // ACCEPTED
    // --------------------------------

    if (order.status == 'accepted') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          onPressed: () async {
            await orderService.startPreparing(
              order.id,
            );

            showMessage(
              // ignore: use_build_context_synchronously
              context,
              'Order is now preparing',
            );
          },

          child: const Text(
            'Start Preparing',
          ),
        ),
      );
    }

    // --------------------------------
    // PREPARING
    // --------------------------------

    if (order.status == 'preparing') {
      return SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          onPressed: () async {
            await orderService.markReady(
              order.id,
            );

            showMessage(
              context,
              'Order is ready for delivery',
            );
          },

          child: const Text(
            'Ready for Delivery',
          ),
        ),
      );
    }

    // --------------------------------
    // READY
    // --------------------------------

    if (order.status == 'ready') {
      if (order.batchId != null) {
        return const Text(
          'Waiting for batch delivery.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      return const Text(
        'Ready for delivery.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // --------------------------------
    // OUT FOR DELIVERY
    // --------------------------------

    if (order.status ==
        'out_for_delivery') {
      return const Text(
        'Order is out for delivery.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // --------------------------------
    // DELIVERED
    // --------------------------------

    if (order.status == 'delivered') {
      return const Text(
        'Order delivered successfully.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // --------------------------------
    // REJECTED
    // --------------------------------

    if (order.status == 'rejected') {
      return const Text(
        'Order was rejected.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return const SizedBox();
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
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
      padding:
          const EdgeInsets.symmetric(
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