import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap2 extends StatefulWidget {
  const CustomGoogleMap2({super.key});

  @override
  State<CustomGoogleMap2> createState() => _CustomGoogleMap2State();
}

class _CustomGoogleMap2State extends State<CustomGoogleMap2> {
  late CameraPosition initialCameraPosition;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
        target: LatLng(
      31.257887239825866,
      32.29238692071138,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      zoomControlsEnabled: false,
    );
  }
}
