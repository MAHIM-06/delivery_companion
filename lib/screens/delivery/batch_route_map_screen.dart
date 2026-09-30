import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../models/order_model.dart';


class BatchRouteMapScreen extends StatefulWidget {
  final List<OrderModel> orders;

  const BatchRouteMapScreen({
    super.key,
    required this.orders,
  });

  @override
  State<BatchRouteMapScreen> createState() =>
      _BatchRouteMapScreenState();
}

class _BatchRouteMapScreenState
    extends State<BatchRouteMapScreen> {
  GoogleMapController? mapController;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<OrderModel> optimizedOrders = [];

  LatLng? mapCenter;

  bool isLoadingRoute = true;
  String? routeError;

  double? routeDistanceKm;
  String? routeDuration;

  // ==========================================================
  // GOOGLE ROUTES API KEY
  // ==========================================================
  //
  // Replace this with your Google Maps API key.
  //
  // For production, move this request to a backend.
  //

  static const String googleMapsApiKey =
      'YOUR_GOOGLE_MAPS_API_KEY';

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    loadRoadRoute();
  }

  // ==========================================================
  // LOAD ROAD ROUTE
  // ==========================================================

  Future<void> loadRoadRoute() async {
    final ordersWithLocation = widget.orders
        .where(
          (order) =>
              order.latitude != null &&
              order.longitude != null,
        )
        .toList();

    if (ordersWithLocation.isEmpty) {
      setState(() {
        isLoadingRoute = false;
        routeError =
            'No delivery locations are available.';
      });

      return;
    }

    if (ordersWithLocation.length == 1) {
      setState(() {
        optimizedOrders = ordersWithLocation;
        isLoadingRoute = false;
      });

      createMarkers(
        ordersWithLocation,
      );

      return;
    }

    try {
      await calculateRoadRoute(
        ordersWithLocation,
      );
    } catch (e) {
      setState(() {
        isLoadingRoute = false;
        routeError =
            'Could not calculate the road route.\n\n$e';
      });
    }
  }

  // ==========================================================
  // CALL GOOGLE ROUTES API
  // ==========================================================

  Future<void> calculateRoadRoute(
    List<OrderModel> orders,
  ) async {
    final OrderModel originOrder =
        orders.first;

    final OrderModel destinationOrder =
        orders.last;

    final List<OrderModel> intermediateOrders =
        orders.sublist(
      1,
      orders.length - 1,
    );

    final List<Map<String, dynamic>>
        intermediates = intermediateOrders
            .map(
              (order) => {
                'location': {
                  'latLng': {
                    'latitude': order.latitude,
                    'longitude': order.longitude,
                  },
                },
                'vehicleStopover': true,
              },
            )
            .toList();

    final Map<String, dynamic> requestBody = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': originOrder.latitude,
            'longitude': originOrder.longitude,
          },
        },
      },

      'destination': {
        'location': {
          'latLng': {
            'latitude':
                destinationOrder.latitude,
            'longitude':
                destinationOrder.longitude,
          },
        },
      },

      'intermediates': intermediates,

      'travelMode': 'DRIVE',

      'routingPreference': 'TRAFFIC_AWARE',

      'computeAlternativeRoutes': false,

      'optimizeWaypointOrder':
          intermediateOrders.isNotEmpty,

      'languageCode': 'en-US',

      'units': 'METRIC',

      'polylineQuality': 'HIGH_QUALITY',
    };

    final response = await http.post(
      Uri.parse(
        'https://routes.googleapis.com/'
        'directions/v2:computeRoutes',
      ),

      headers: {
        'Content-Type': 'application/json',

        'X-Goog-Api-Key':
            googleMapsApiKey,

        'X-Goog-FieldMask':
            'routes.distanceMeters,'
            'routes.duration,'
            'routes.polyline.encodedPolyline,'
            'routes.optimizedIntermediateWaypointIndex',
      },

      body: jsonEncode(
        requestBody,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Routes API error '
        '${response.statusCode}: '
        '${response.body}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    final List<dynamic> routes =
        data['routes'] ?? [];

    if (routes.isEmpty) {
      throw Exception(
        'Google could not find a route.',
      );
    }

    final Map<String, dynamic> route =
        Map<String, dynamic>.from(
      routes.first,
    );

    final String? encodedPolyline =
        route['polyline']
            ?['encodedPolyline'];

    if (encodedPolyline == null) {
      throw Exception(
        'No route polyline was returned.',
      );
    }

    final int distanceMeters =
        route['distanceMeters'] ?? 0;

    final String duration =
        route['duration'] ?? '';

    final List<dynamic>
        optimizedWaypointIndexes =
        route[
                'optimizedIntermediateWaypointIndex'] ??
            [];

    final List<OrderModel>
        roadOrderedOrders =
        buildOptimizedOrderList(
      orders,
      optimizedWaypointIndexes,
    );

    final List<LatLng> routePoints =
        decodePolyline(
      encodedPolyline,
    );

    setState(() {
      optimizedOrders =
          roadOrderedOrders;

      routeDistanceKm =
          distanceMeters / 1000;

      routeDuration =
          formatDuration(duration);

      isLoadingRoute = false;
    });

    createMarkers(
      roadOrderedOrders,
    );

    createRoadPolyline(
      routePoints,
    );
  }

  // ==========================================================
  // BUILD ORDER USING GOOGLE'S OPTIMIZED WAYPOINT ORDER
  // ==========================================================

  List<OrderModel> buildOptimizedOrderList(
    List<OrderModel> originalOrders,
    List<dynamic> optimizedIndexes,
  ) {
    if (originalOrders.length <= 2 ||
        optimizedIndexes.isEmpty) {
      return originalOrders;
    }

    final OrderModel first =
        originalOrders.first;

    final OrderModel last =
        originalOrders.last;

    final List<OrderModel>
        intermediateOrders =
        originalOrders.sublist(
      1,
      originalOrders.length - 1,
    );

    final List<OrderModel>
        reorderedIntermediates = [];

    for (final dynamic index
        in optimizedIndexes) {
      final int integerIndex =
          (index as num).toInt();

      if (integerIndex >= 0 &&
          integerIndex <
              intermediateOrders.length) {
        reorderedIntermediates.add(
          intermediateOrders[
              integerIndex],
        );
      }
    }

    return [
      first,
      ...reorderedIntermediates,
      last,
    ];
  }

  // ==========================================================
  // CREATE MARKERS
  // ==========================================================

  void createMarkers(
    List<OrderModel> orders,
  ) {
    final Set<Marker> newMarkers = {};

    double totalLatitude = 0;
    double totalLongitude = 0;

    for (int i = 0;
        i < orders.length;
        i++) {
      final OrderModel order =
          orders[i];

      final LatLng location = LatLng(
        order.latitude!,
        order.longitude!,
      );

      totalLatitude +=
          location.latitude;

      totalLongitude +=
          location.longitude;

      newMarkers.add(
        Marker(
          markerId: MarkerId(
            order.id,
          ),

          position: location,

          infoWindow: InfoWindow(
            title:
                'Delivery ${i + 1}',

            snippet:
                order.address,
          ),
        ),
      );
    }

    final double averageLatitude =
        totalLatitude / orders.length;

    final double averageLongitude =
        totalLongitude / orders.length;

    setState(() {
      markers = newMarkers;

      mapCenter = LatLng(
        averageLatitude,
        averageLongitude,
      );
    });
  }

  // ==========================================================
  // CREATE ROAD POLYLINE
  // ==========================================================

  void createRoadPolyline(
    List<LatLng> routePoints,
  ) {
    if (routePoints.isEmpty) {
      return;
    }

    final Polyline roadPolyline =
        Polyline(
      polylineId: const PolylineId(
        'google-road-route',
      ),

      points: routePoints,

      width: 6,

      color: Colors.blue,

      startCap: Cap.roundCap,

      endCap: Cap.roundCap,

      jointType: JointType.round,
    );

    setState(() {
      polylines = {
        roadPolyline,
      };
    });
  }

  // ==========================================================
  // DECODE GOOGLE ENCODED POLYLINE
  // ==========================================================

  List<LatLng> decodePolyline(
    String encoded,
  ) {
    final List<LatLng> points = [];

    int index = 0;

    int latitude = 0;

    int longitude = 0;

    while (index < encoded.length) {
      int result = 0;

      int shift = 0;

      int byte;

      do {
        byte = encoded.codeUnitAt(
              index++,
            ) -
            63;

        result |=
            (byte & 0x1f) << shift;

        shift += 5;
      } while (byte >= 0x20);

      final int latitudeChange =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      latitude += latitudeChange;

      result = 0;

      shift = 0;

      do {
        byte = encoded.codeUnitAt(
              index++,
            ) -
            63;

        result |=
            (byte & 0x1f) << shift;

        shift += 5;
      } while (byte >= 0x20);

      final int longitudeChange =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      longitude += longitudeChange;

      points.add(
        LatLng(
          latitude / 100000.0,
          longitude / 100000.0,
        ),
      );
    }

    return points;
  }

  // ==========================================================
  // FORMAT DURATION
  // ==========================================================

  String formatDuration(
    String duration,
  ) {
    final String cleaned =
        duration.replaceAll(
      's',
      '',
    );

    final double seconds =
        double.tryParse(
              cleaned,
            ) ??
            0;

    final int minutes =
        (seconds / 60).round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final int hours =
        minutes ~/ 60;

    final int remainingMinutes =
        minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr '
        '$remainingMinutes min';
  }

  // ==========================================================
  // FIT MAP
  // ==========================================================

  void fitAllMarkers() {
    if (markers.isEmpty ||
        mapController == null) {
      return;
    }

    final List<LatLng> locations =
        markers
            .map(
              (marker) =>
                  marker.position,
            )
            .toList();

    double minLatitude =
        locations.first.latitude;

    double maxLatitude =
        locations.first.latitude;

    double minLongitude =
        locations.first.longitude;

    double maxLongitude =
        locations.first.longitude;

    for (final LatLng location
        in locations) {
      if (location.latitude <
          minLatitude) {
        minLatitude =
            location.latitude;
      }

      if (location.latitude >
          maxLatitude) {
        maxLatitude =
            location.latitude;
      }

      if (location.longitude <
          minLongitude) {
        minLongitude =
            location.longitude;
      }

      if (location.longitude >
          maxLongitude) {
        maxLongitude =
            location.longitude;
      }
    }

    if (minLatitude ==
        maxLatitude) {
      minLatitude -= 0.01;
      maxLatitude += 0.01;
    }

    if (minLongitude ==
        maxLongitude) {
      minLongitude -= 0.01;
      maxLongitude += 0.01;
    }

    final LatLngBounds bounds =
        LatLngBounds(
      southwest: LatLng(
        minLatitude,
        minLongitude,
      ),
      northeast: LatLng(
        maxLatitude,
        maxLongitude,
      ),
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        80,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (isLoadingRoute) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Delivery Route',
          ),
        ),

        body: const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              CircularProgressIndicator(),

              SizedBox(height: 20),

              Text(
                'Calculating road route...',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (routeError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Delivery Route',
          ),
        ),

        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),

            child: Text(
              routeError!,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    if (optimizedOrders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Delivery Route',
          ),
        ),

        body: const Center(
          child: Text(
            'No delivery locations found.',
          ),
        ),
      );
    }

    final LatLng center =
        mapCenter ??
            LatLng(
              optimizedOrders
                  .first.latitude!,
              optimizedOrders
                  .first.longitude!,
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Route',
        ),
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(
              target: center,
              zoom: 13,
            ),

            markers: markers,

            polylines: polylines,

            mapType:
                MapType.normal,

            onMapCreated:
                (controller) {
              mapController =
                  controller;

              Future.delayed(
                const Duration(
                  milliseconds: 500,
                ),
                () {
                  fitAllMarkers();
                },
              );
            },
          ),

          // ==================================================
          // ROUTE SUMMARY
          // ==================================================

          Positioned(
            top: 16,
            left: 16,
            right: 16,

            child: Card(
              elevation: 5,

              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.route,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Expanded(
                          child: Text(
                            'Road Route',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Deliveries: '
                      '${optimizedOrders.length}',
                    ),

                    if (routeDistanceKm !=
                        null)
                      Text(
                        'Distance: '
                        '${routeDistanceKm!.toStringAsFixed(2)} km',
                      ),

                    if (routeDuration !=
                        null)
                      Text(
                        'Estimated time: '
                        '$routeDuration',
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // DELIVERY SEQUENCE
          // ==================================================

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,

            child: Card(
              elevation: 5,

              child: Padding(
                padding:
                    const EdgeInsets.all(
                  12,
                ),

                child: SizedBox(
                  height: 130,

                  child:
                      ListView.builder(
                    itemCount:
                        optimizedOrders
                            .length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final OrderModel
                          order =
                          optimizedOrders[
                              index];

                      return Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 5,
                        ),

                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,

                              child: Text(
                                '${index + 1}',
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                order.address,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // FIT MAP
          // ==================================================

          Positioned(
            right: 16,
            bottom: 170,

            child:
                FloatingActionButton(
              onPressed:
                  fitAllMarkers,

              child: const Icon(
                Icons.fit_screen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}