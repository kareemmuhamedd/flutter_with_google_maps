import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/core/utils/google_maps_places_service.dart';
import 'package:flutter_google_maps/core/utils/location_service.dart';
import 'package:flutter_google_maps/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:flutter_google_maps/models/places_details_model/places_details_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/helper.dart';
import 'custom_map_search_field.dart';
import 'custom_suggestions_list.dart';

class CustomGoogleMap2 extends StatefulWidget {
  const CustomGoogleMap2({super.key});

  @override
  State<CustomGoogleMap2> createState() => _CustomGoogleMap2State();
}

class _CustomGoogleMap2State extends State<CustomGoogleMap2> {
  late CameraPosition initialCameraPosition;
  late LocationService locationService;
  late GoogleMapController googleMapController;
  late TextEditingController searchController;
  late GoogleMapsPlacesService googleMapsPlacesService;
  final TextFieldListenerUpdate textFieldListenerUpdate =
      TextFieldListenerUpdate(delay: const Duration(milliseconds: 500));
  Set<Marker> markers = {};
  List<PlaceAutocompleteModel> places = [];
  late Uuid uuid;
  String? sessionToken;

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      target: LatLng(
        31.257887239825866,
        32.29238692071138,
      ),
    );
    locationService = LocationService();
    searchController = TextEditingController();

    googleMapsPlacesService = GoogleMapsPlacesService();
    fetchPredictions();
    uuid = const Uuid();

    super.initState();
  }

  void fetchPredictions() {
    searchController.addListener(
      () async {
        // Use textFieldListenerUpdate to delay clearing the list
        textFieldListenerUpdate.run(() async {
          sessionToken ??= uuid.v4();
          if (searchController.text.isNotEmpty) {
            List<PlaceAutocompleteModel> result =
                await googleMapsPlacesService.getPredictions(
              input: searchController.text,
              sessionToken: sessionToken!,
            );
            setState(() {
              places.clear();
              places.addAll(result);
            });
          } else {
            setState(() {
              places.clear();
            });
          }
        });
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: markers,
              onMapCreated: (controller) {
                googleMapController = controller;
                updateCurrentLocation();
              },
              initialCameraPosition: initialCameraPosition,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  CustomMapSearchField(
                    searchController: searchController,
                  ),
                  const SizedBox(height: 16),
                  CustomSuggestionsList(
                    places: places,
                    googleMapsPlacesService: googleMapsPlacesService,
                    onPlaceSelected: (PlacesDetailsModel placeDetailModel) {
                      searchController.clear();
                      places.clear();
                      sessionToken = null;
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
