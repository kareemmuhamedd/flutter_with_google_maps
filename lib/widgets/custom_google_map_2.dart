import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/core/utils/location_service.dart';
import 'package:flutter_google_maps/core/utils/map_services.dart';
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
  late MapServices mapServices;
  late CameraPosition initialCameraPosition;

  late GoogleMapController googleMapController;
  late TextEditingController searchController;

  final TextFieldListenerUpdate textFieldListenerUpdate =
      TextFieldListenerUpdate(delay: const Duration(milliseconds: 500));
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  List<PlaceAutocompleteModel> places = [];
  late LatLng myCurrentLocation;
  late LatLng myDestination;
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
    mapServices = MapServices();
    searchController = TextEditingController();
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
          await mapServices.getPredictions(
            input: searchController.text,
            sessionToken: sessionToken!,
            places: places,
          );
          setState(() {});
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
              polylines: polyLines,
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
                    mapServices: mapServices,
                    onPlaceSelected:
                        (PlacesDetailsModel placeDetailModel) async {
                      searchController.clear();
                      places.clear();
                      sessionToken = null;
                      setState(() {});
                      myDestination = LatLng(
                        placeDetailModel.geometry!.location!.lat!,
                        placeDetailModel.geometry!.location!.lng!,
                      );
                      var points = await mapServices.getRouteData(
                        myCurrentLocation: myCurrentLocation,
                        myDestination: myDestination,
                      );
                      mapServices.displayRoute(
                        points,
                        polyLines: polyLines,
                        googleMapController: googleMapController,
                      );
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
      myCurrentLocation = await mapServices.updateCurrentLocation(
        googleMapController: googleMapController,
        markers: markers,
      );
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
