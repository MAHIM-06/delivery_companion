// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';


class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> items;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Address
  final TextEditingController addressController =
      TextEditingController();
  
  final TextEditingController areaController =
    TextEditingController();

  // Order service
  final OrderService orderService = OrderService();

  // Delivery type
  String deliveryType = 'scheduled';

  // Scheduled delivery date
  DateTime? scheduledDate;

  // Scheduled delivery time
  String? scheduledStartTime;
  String? scheduledEndTime;

  LatLng? selectedLocation;

  // Loading state
  bool isPlacingOrder = false;

  // Delivery fee
  double get deliveryFee {
    if (deliveryType == 'express') {
      return 100;
    }

    return 40;
  }

  // Final total
  double get totalAmount {
    return widget.subtotal + deliveryFee;
  }

  // Available time slots
  final List<Map<String, String>> timeSlots = [
    {
      'start': '09:00',
      'end': '11:00',
      'display': '9:00 AM - 11:00 AM',
    },
    {
      'start': '12:00',
      'end': '14:00',
      'display': '12:00 PM - 2:00 PM',
    },
    {
      'start': '16:00',
      'end': '18:00',
      'display': '4:00 PM - 6:00 PM',
    },
    {
      'start': '18:00',
      'end': '20:00',
      'display': '6:00 PM - 8:00 PM',
    },
  ];

  // Select date
  Future<void> selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 30),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        scheduledDate = pickedDate;
      });
    }
  }

  Future<void> selectDeliveryLocation() async {
  final LatLng? location = await Navigator.push<LatLng>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const LocationPickerScreen(),
    ),
  );

  if (location == null) return;

  setState(() {
    selectedLocation = location;
  });
}

  // Select time slot
  void selectTimeSlot(
    String startTime,
    String endTime,
  ) {
    setState(() {
      scheduledStartTime = startTime;
      scheduledEndTime = endTime;
    });
  }

  // Place order
  Future<void> placeOrder() async {
    // Validate address
    if (addressController.text.trim().isEmpty) {
      showMessage('Please enter your delivery address');
      return;
    }

    if (areaController.text.trim().isEmpty) {
      showMessage('Please enter your delivery area');
      return;
    }

    // Validate scheduled delivery
    if (deliveryType == 'scheduled') {
      if (scheduledDate == null) {
        showMessage('Please select a delivery date');
        return;
      }

      if (scheduledStartTime == null ||
          scheduledEndTime == null) {
        showMessage('Please select a delivery time slot');
        return;
      }

      if (selectedLocation == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please select your delivery location.',
      ),
    ),
  );

  return;
}
    }

    // Get current user
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login first');
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Create order
      final OrderModel order = OrderModel(
        id: '',
        customerId: user.uid,
        items: widget.items
            .map(
              (item) => item.toMap(),
            )
            .toList(),
        subtotal: widget.subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        address: addressController.text.trim(),
        area: areaController.text.trim().toLowerCase(),
        deliveryType: deliveryType,
        status: 'pending',
        createdAt: DateTime.now(),
        latitude: null,
        longitude: null,

        // Scheduled delivery information
        scheduledDate: deliveryType == 'scheduled'
            ? scheduledDate
            : null,

        scheduledStartTime:
            deliveryType == 'scheduled'
                ? scheduledStartTime
                : null,

        scheduledEndTime:
            deliveryType == 'scheduled'
                ? scheduledEndTime
                : null,
        deliveryPersonId: null,
        assignedAt: null,
        batchId: null,
      );

      // Save order to Firestore
      await orderService.createOrder(order);

      // Clear cart
      await orderService.clearCart();

      if (!mounted) return;

      showMessage('Order placed successfully!');

      // Go back to cart
      Navigator.pop(context);

      // Go back to customer home
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Failed to place order: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  // Show SnackBar
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // DELIVERY ADDRESS
            // =========================

            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: selectDeliveryLocation,
            icon: const Icon(Icons.location_on),
            label: Text(
              selectedLocation == null
                  ? 'Select Location on Map'
                  : 'Change Location',
            ),
          ),
        ),

        if (selectedLocation != null) ...[
          const SizedBox(height: 10),

          Text(
            'Latitude: ${selectedLocation!.latitude}',
          ),

          Text(
            'Longitude: ${selectedLocation!.longitude}',
          ),
        ],
      ],
    ),
  ),
),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your delivery address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 15),

TextField(
  controller: areaController,
  decoration: const InputDecoration(
    labelText: 'Delivery Area',
    hintText: 'Example:Ruet',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.map),
  ),
),

            const SizedBox(height: 25),

            // =========================
            // DELIVERY TYPE
            // =========================

            const Text(
              'Delivery Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: RadioListTile<String>(
                value: 'express',
                groupValue: deliveryType,
                onChanged: (value) {
                  setState(() {
                    deliveryType = value!;
                    scheduledDate = null;
                    scheduledStartTime = null;
                    scheduledEndTime = null;
                  });
                },
                title: const Text(
                  'Express Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Fast delivery',
                ),
                secondary: const Icon(
                  Icons.flash_on,
                ),
              ),
            ),

            Card(
              child: RadioListTile<String>(
                value: 'scheduled',
                groupValue: deliveryType,
                onChanged: (value) {
                  setState(() {
                    deliveryType = value!;
                  });
                },
                title: const Text(
                  'Scheduled Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Choose your preferred date and time',
                ),
                secondary: const Icon(
                  Icons.schedule,
                ),
              ),
            ),

            // =========================
            // SCHEDULED DELIVERY
            // =========================

            if (deliveryType == 'scheduled') ...[
              const SizedBox(height: 20),

              const Text(
                'Delivery Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: selectDate,
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                  label: Text(
                    scheduledDate == null
                        ? 'Select Delivery Date'
                        : '${scheduledDate!.day}/'
                          '${scheduledDate!.month}/'
                          '${scheduledDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Delivery Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Column(
                children: timeSlots.map((slot) {

                  final bool isSelected =
                      scheduledStartTime ==
                              slot['start'] &&
                          scheduledEndTime ==
                              slot['end'];

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),

                      title: Text(
                        slot['display']!,
                      ),

                      onTap: () {
                        selectTimeSlot(
                          slot['start']!,
                          slot['end']!,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 25),

            // =========================
            // ORDER SUMMARY
            // =========================

            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...widget.items.map(
              (item) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name} × ${item.quantity}',
                        ),
                      ),
                      Text(
                        '৳${item.totalPrice.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Subtotal
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text(
                  '৳${widget.subtotal.toStringAsFixed(0)}',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Delivery fee
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee'),
                Text(
                  '৳${deliveryFee.toStringAsFixed(0)}',
                ),
              ],
            ),

            const Divider(),

            // Total
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '৳${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =========================
            // PLACE ORDER BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isPlacingOrder ? null : placeOrder,
                child: isPlacingOrder
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}