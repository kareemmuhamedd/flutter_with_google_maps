import 'package:flutter/material.dart';
import 'package:flutter_google_maps/screens/google_map_screen.dart';
import 'package:flutter_google_maps/widgets/custom_google_map.dart';
import 'package:flutter_google_maps/widgets/custom_google_map_2.dart';


void main() {
  runApp(const TestGoogleMapsWithFlutter());
}

class TestGoogleMapsWithFlutter extends StatelessWidget {
  const TestGoogleMapsWithFlutter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomGoogleMap(),
    );
  }
}
