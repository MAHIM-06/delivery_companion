import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/order_model.dart';

class OrderLocationMapScreen extends StatefulWidget {
  final OrderModel order;

  const OrderLocationMapScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderLocationMapScreen> createState() =>
      _OrderLocationMapScreenState();
}

class _OrderLocationMapScreenState
    extends State<OrderLocationMapScreen> {
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final double latitude = widget.order.latitude!;
    final double longitude = widget.order.longitude!;

    final LatLng deliveryLocation = LatLng(
      latitude,
      longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Location'),
      ),

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: deliveryLocation,
          zoom: 16,
        ),

        onMapCreated: (controller) {
          mapController = controller;
        },

        markers: {
          Marker(
            markerId: const MarkerId(
              'delivery-location',
            ),

            position: deliveryLocation,

            infoWindow: InfoWindow(
              title: 'Delivery Location',
              snippet: widget.order.address,
            ),
          ),
        },
      ),
    );
  }
}