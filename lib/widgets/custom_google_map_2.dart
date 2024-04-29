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

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
        target: LatLng(
      31.257887239825866,
      32.29238692071138,
    ));
    locationService = LocationService();
    updateCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      zoomControlsEnabled: false,
    );
  }

  void updateCurrentLocation() async{
    try {
      var locationData = await locationService.getLocation();
    } on Exception catch (e) {
      // TODO
    }
  }
}
