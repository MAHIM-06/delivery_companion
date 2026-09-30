import 'package:flutter/material.dart';

import '../../models/order_model.dart';

import '../customer/order_location_map_screen.dart';


class DeliveryOrderDetailsScreen
    extends StatelessWidget {
  final OrderModel order;

  const DeliveryOrderDetailsScreen({
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

            // ==================================================
            // ORDER INFORMATION
            // ==================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Order Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _InfoRow(
                      label: 'Order ID',
                      value: order.id,
                    ),

                    _InfoRow(
                      label: 'Status',
                      value: getStatusLabel(),
                    ),

                    _InfoRow(
                      label: 'Delivery Type',
                      value:
                          order.deliveryType,
                    ),

                    _InfoRow(
                      label: 'Area',
                      value: order.area,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DELIVERY ADDRESS
            // ==================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Icon(
                          Icons.location_on,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            order.address,
                            style:
                                const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (order.latitude != null &&
    order.longitude != null)
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderLocationMapScreen(
              order: order,
            ),
          ),
        );
      },
      icon: const Icon(Icons.location_on),
      label: const Text(
        'View Delivery Location',
      ),
    ),
  ),

            const SizedBox(height: 16),

            // ==================================================
            // SCHEDULE
            // ==================================================

            if (order.scheduledDate !=
                null)
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
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _InfoRow(
                        label: 'Date',
                        value:
                            '${order.scheduledDate!.day}/'
                            '${order.scheduledDate!.month}/'
                            '${order.scheduledDate!.year}',
                      ),

                      _InfoRow(
                        label: 'Time',
                        value:
                            '${order.scheduledStartTime ?? ''}'
                            ' - '
                            '${order.scheduledEndTime ?? ''}',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ==================================================
            // ITEMS
            // ==================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ...order.items.map(
                      (item) {
                        final String name =
                            item['name'] ??
                                'Product';

                        final int quantity =
                            item['quantity'] ??
                                1;

                        final double price =
                            (item['price'] ??
                                    0)
                                .toDouble();

                        final double discount =
                            (item['discount'] ??
                                    0)
                                .toDouble();

                        final double finalPrice =
                            price -
                                (price *
                                    discount /
                                    100);

                        final double total =
                            finalPrice *
                                quantity;

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(
                                      name,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            16,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Quantity: '
                                      '$quantity',
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Price: '
                                      '৳${finalPrice.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '৳${total.toStringAsFixed(2)}',

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // PAYMENT / TOTAL
            // ==================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [

                    _InfoRow(
                      label: 'Subtotal',
                      value:
                          '৳${order.subtotal.toStringAsFixed(2)}',
                    ),

                    _InfoRow(
                      label: 'Delivery Fee',
                      value:
                          '৳${order.deliveryFee.toStringAsFixed(2)}',
                    ),

                    const Divider(
                      height: 24,
                    ),

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
                          '৳${order.totalAmount.toStringAsFixed(2)}',

                          style:
                              const TextStyle(
                            fontSize: 20,
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
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 130,

            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}