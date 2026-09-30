import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen
    extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
  });

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {

  GoogleMapController? mapController;

  LatLng? selectedLocation;

  // Initial map position.
  //
  // Replace this later with a location
  // appropriate for your deployment area.
  static const LatLng initialLocation =
      LatLng(
    24.8949,
    91.8687,
  );

  void selectLocation(
    LatLng location,
  ) {
    setState(() {
      selectedLocation = location;
    });
  }

  void confirmLocation() {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a location.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(
      context,
      selectedLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Delivery Location',
        ),
      ),

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition:
                const CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),

            onMapCreated: (
              controller,
            ) {
              mapController =
                  controller;
            },

            onTap: selectLocation,

            markers:
                selectedLocation == null
                    ? {}
                    : {
                        Marker(
                          markerId:
                              const MarkerId(
                            'selected-location',
                          ),

                          position:
                              selectedLocation!,

                          infoWindow:
                              const InfoWindow(
                            title:
                                'Delivery Location',
                          ),
                        ),
                      },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,

            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  children: [

                    Text(
                      selectedLocation ==
                              null
                          ? 'Tap the map to select your delivery location.'
                          : 'Location selected',
                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      child:
                          ElevatedButton.icon(
                        onPressed:
                            confirmLocation,

                        icon:
                            const Icon(
                          Icons.check,
                        ),

                        label:
                            const Text(
                          'Confirm Location',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}