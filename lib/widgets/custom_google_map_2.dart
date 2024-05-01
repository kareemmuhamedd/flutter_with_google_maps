import 'package:flutter/material.dart';
import 'package:flutter_google_maps/core/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap2 extends StatefulWidget {
  const CustomGoogleMap2({super.key});

  @override
  State<CustomGoogleMap2> createState() => _CustomGoogleMap2State();
}

class _CustomGoogleMap2State extends State<CustomGoogleMap2> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
        target: LatLng(
      31.257887239825866,
      32.29238692071138,
    ));
    locationService = LocationService();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: markers,
      onMapCreated: (controller) {
        googleMapController = controller;
        updateCurrentLocation();
      },
      initialCameraPosition: initialCameraPosition,
      zoomControlsEnabled: false,
    );
  }

  Future<String?> updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      LatLng currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      Marker currentLocationMarker = Marker(
        markerId: const MarkerId('myPosition'),
        position: currentPosition,
      );
      CameraPosition myCurrentCameraPosition = CameraPosition(
        target: currentPosition,
        zoom: 16,
      );
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      markers.add(currentLocationMarker);
      setState(() {});
      return null; // No error occurred
    } on Exception catch (e) {
      // Handle exceptions here
      if (e is LocationServiceException) {
        // Handle LocationServiceException
        return 'Location service is not enabled or cannot be enabled.';
      } else if (e is LocationPermissionException) {
        // Handle LocationPermissionException
        return 'Location permission is not granted or cannot be granted.';
      } else {
        // Handle other exceptions
        return 'An error occurred: $e';
      }
    }
  }
}
