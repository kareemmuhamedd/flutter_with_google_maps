import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps/core/utils/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps/models/place_model.dart';
import 'dart:ui' as ui;

import 'package:location/location.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};
  bool isFirstCall = true;

  late LocationService locationService;

  @override
  void initState() {
    /// get initial position when first open the map screen
    initialCameraPosition = const CameraPosition(
      zoom: 1,
      target: LatLng(
        31.268632980924764,
        32.30113237790061,
      ),
    );

    /// create markers for my map
    initMarkers();

    /// create polyLines
    initPolyLiens();

    /// create polygons
    initPolygons();

    /// create circle
    initCircle();
    locationService = LocationService();

    ///checkAndRequestLocationService();
    updateMyLocation(showErrorMessage);

    super.initState();
  }

  @override
  void dispose() {
    googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polyLines,
          polygons: polygons,
          circles: circles,
          zoomControlsEnabled: false,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;

            /// customize map style
            initMapStyle();
          },
          initialCameraPosition: initialCameraPosition,
        ),
      ],
    );
  }

  void initMapStyle() async {
    /// let's load the json from the assets that i was added in pubspec.yaml
    ByteData customWhiteMapStyle = await DefaultAssetBundle.of(context).load(
      'assets/map_styles/white_map_style.json',
    );

    /// let's update map style using googleMapController that we created
    //todo googleMapController!.setMapStyle(mapStyle); deprecated error !!!
  }

  /// i will create function to change the size of marker image icon that i need to display on my map screen
  /// to achieve this we need to get the raw data of image and make some changes on it
  /// let's do this
  Future<Uint8List> getImageFromRawData(String image, double width) async {
    var imageData = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
      imageData.buffer.asUint8List(),
      targetWidth: width.toInt(),
    );
    var imageFrameInfo = await imageCodec.getNextFrame();
    var imageBytData =
        await imageFrameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return imageBytData!.buffer.asUint8List();
  }

  void initMarkers() async {
    var customMapMarkerIcon = BitmapDescriptor.fromBytes(
      await getImageFromRawData(
        'assets/images/map_marker_icon.png',
        60,
      ),
    );
    Set<Marker> myMarkers = places
        .map(
          (placeModel) => Marker(
            icon: customMapMarkerIcon,
            infoWindow: InfoWindow(title: placeModel.name),
            position: placeModel.latLng,
            markerId: MarkerId(
              placeModel.id.toString(),
            ),
          ),
        )
        .toSet();

    /// i will comment this for don't display on the map right now
    //markers.addAll(myMarkers);
    setState(() {});
  }

  void initPolyLiens() {
    Polyline polyline = const Polyline(
      width: 5,
      startCap: Cap.roundCap,
      polylineId: PolylineId('1'),
      points: [
        LatLng(31.271370398673152, 32.304143727569354),
        LatLng(31.26109929122422, 32.27908116588916),
        LatLng(31.250827065869775, 32.302083790992896),
        LatLng(31.228995536759886, 32.29412546321438),
      ],
    );
    Polyline polyline2 = const Polyline(
      width: 5,
      startCap: Cap.roundCap,
      color: Colors.red,
      polylineId: PolylineId('2'),
      points: [
        LatLng(31.246737428269363, 32.32114640372491),
        LatLng(31.266548005978937, 32.2529968376671),
      ],
    );

    /// i will comment this for don't display on the map right now
    // polyLines.add(polyline);
    // polyLines.add(polyline2);
  }

  void initPolygons() {
    Polygon polygon = Polygon(
        holes: const [
          [
            LatLng(31.268012083797377, 32.297417389599865),
            LatLng(31.26636446202006, 32.29523145981167),
            LatLng(31.264326127226838, 32.2971391803541),
            LatLng(31.26639843389358, 32.29992127281181),
          ],
          [
            LatLng(31.26308737659613, 32.2993599037763),
            LatLng(31.25992417152932, 32.2991616633799),
            LatLng(31.257947114525784, 32.303886392827316),
            LatLng(31.26274846683865, 32.30689303883931),
          ]
        ],
        polygonId: const PolygonId('1'),
        fillColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.blue,
        points: const [
          LatLng(31.271041478806612, 32.30276568102676),
          LatLng(31.27511462204521, 32.277576258400096),
          LatLng(31.26522239768847, 32.26759126204358),
          LatLng(31.258627005263797, 32.266002739895946),
          LatLng(31.239032092268, 32.26622967163132),
          LatLng(31.231658696122466, 32.294369206817876),
          LatLng(31.251255138913873, 32.31887783423842),
        ]);

    /// i will comment this for don't display on the map right now
    //polygons.add(polygon);
  }

  void initCircle() {
    Circle matamElauoty = Circle(
        fillColor: Colors.black.withOpacity(0.3),
        circleId: const CircleId('1'),
        strokeWidth: 3,
        center: const LatLng(31.271422328378623, 32.295932610157415),
        radius: 100);

    /// i will comment this for don't display on the map right now
    //circles.add(matamElauoty);
  }

  void updateMyLocation(Function(String) showError) async {
    try {
      await locationService.checkAndRequestLocationService();
      await locationService.checkAndRequestLocationPermission();

      locationService.getRealtimeLocationData((locationData) {
        setMyLocationMarker(locationData);
        updateMyCamera(locationData);
      });
    } catch (e) {
      // Handle exceptions here
      if (e is LocationServiceException) {
        // Handle LocationServiceException
        showError('Location service is not enabled or cannot be enabled.');
      } else if (e is LocationPermissionException) {
        // Handle LocationPermissionException
        showError('Location permission is not granted or cannot be granted.');
      } else {
        // Handle other exceptions
        showError('An error occurred: $e');
      }
    }
  }

  void updateMyCamera(LocationData locationData) {
    var cameraPosition = CameraPosition(
      target: LatLng(
        locationData.latitude!,
        locationData.longitude!,
      ),
      zoom: 15,
    );
    if (isFirstCall) {
      googleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      isFirstCall = false;
    } else {
      googleMapController?.animateCamera(CameraUpdate.newLatLng(LatLng(
        locationData.latitude!,
        locationData.longitude!,
      )));
    }
  }

  void setMyLocationMarker(LocationData locationData) {
    var myLocationMarker = Marker(
      markerId: const MarkerId('myLocationMarker'),
      position: LatLng(locationData.latitude!, locationData.longitude!),
    );
    markers.add(myLocationMarker);
    setState(() {
      print('############################');
    });
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
