import 'package:flutter/material.dart';

import '../../models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  String getStatusText(String status) {
    switch (status) {
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
        return status;
    }
  }

  int getStatusStep() {
    switch (order.status) {
      case 'pending':
        return 0;

      case 'accepted':
        return 1;

      case 'preparing':
        return 2;

      case 'out_for_delivery':
        return 3;

      case 'delivered':
        return 4;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentStep = getStatusStep();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================
            // ORDER ID
            // =========================

            Text(
              'Order #${order.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Order Status: ${getStatusText(order.status)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // ORDER STATUS
            // =========================

            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StatusTimeline(
              currentStep: currentStep,
            ),

            const SizedBox(height: 30),

            // =========================
            // DELIVERY INFORMATION
            // =========================

            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // Address
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Icon(
                          Icons.location_on,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(order.address),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Delivery type
                    Row(
                      children: [
                        Icon(
                          order.deliveryType ==
                                  'scheduled'
                              ? Icons.schedule
                              : Icons.flash_on,
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Delivery Type',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              order.deliveryType ==
                                      'scheduled'
                                  ? 'Scheduled Delivery'
                                  : 'Express Delivery',
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Scheduled date/time
                    if (order.deliveryType ==
                            'scheduled' &&
                        order.scheduledDate != null) ...[
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                          ),

                          const SizedBox(width: 10),

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
                            top: 10,
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                '${order.scheduledStartTime} - '
                                '${order.scheduledEndTime}',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // PRODUCTS
            // =========================

            const Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...order.items.map(
              (item) {
                final String name =
                    item['name'] ?? '';

                final int quantity =
                    item['quantity'] ?? 1;

                final double price =
                    (item['price'] ?? 0).toDouble();

                final double discount =
                    (item['discount'] ?? 0).toDouble();

                final double finalPrice =
                    price -
                        (price * discount / 100);

                final double itemTotal =
                    finalPrice * quantity;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      'Quantity: $quantity',
                    ),

                    trailing: Text(
                      '৳${itemTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // PRICE SUMMARY
            // =========================

            const Text(
              'Price Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text('Subtotal'),

                        Text(
                          '৳${order.subtotal.toStringAsFixed(0)}',
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text('Delivery Fee'),

                        Text(
                          '৳${order.deliveryFee.toStringAsFixed(0)}',
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
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
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


// =====================================
// STATUS TIMELINE
// =====================================

class StatusTimeline extends StatelessWidget {
  final int currentStep;

  const StatusTimeline({
    super.key,
    required this.currentStep,
  });

  final List<Map<String, dynamic>> statuses = const [
    {
      'title': 'Pending',
      'icon': Icons.pending,
    },
    {
      'title': 'Accepted',
      'icon': Icons.check_circle_outline,
    },
    {
      'title': 'Preparing',
      'icon': Icons.inventory_2,
    },
    {
      'title': 'Out for Delivery',
      'icon': Icons.delivery_dining,
    },
    {
      'title': 'Delivered',
      'icon': Icons.done_all,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        statuses.length,
        (index) {
          final bool completed =
              index <= currentStep;

          final bool isLast =
              index == statuses.length - 1;

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // Icon + line
              Column(
                children: [

                  Icon(
                    statuses[index]['icon'],
                    size: 30,

                    color: completed
                        ? Colors.green
                        : Colors.grey,
                  ),

                  if (!isLast)
                    Container(
                      width: 2,
                      height: 45,
                      color: index < currentStep
                          ? Colors.green
                          : Colors.grey,
                    ),
                ],
              ),

              const SizedBox(width: 15),

              // Status text
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 5,
                ),

                child: Text(
                  statuses[index]['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: completed
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: completed
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}