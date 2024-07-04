import 'package:flutter/material.dart';
import 'package:flutter_google_maps/core/utils/google_maps_places_service.dart';
import 'package:flutter_google_maps/models/places_details_model/places_details_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomSuggestionsList extends StatelessWidget {
  final List<PlaceAutocompleteModel> places;
  final GoogleMapsPlacesService googleMapsPlacesService;
  final void Function(PlacesDetailsModel) onPlaceSelected;

  const CustomSuggestionsList({
    super.key,
    required this.places,
    required this.googleMapsPlacesService,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              places[index].description!,
            ),
            leading: const Icon(
              FontAwesomeIcons.locationDot,
              color: Colors.blue,
            ),
            trailing: IconButton(
              onPressed: () async {
                var placeDetails =
                    await googleMapsPlacesService.getPlaceDetails(
                  placeId: places[index].placeId.toString(),
                );
                onPlaceSelected(placeDetails);
              },
              icon: const Icon(
                FontAwesomeIcons.locationArrow,
                color: Colors.blue,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: places.length,
      ),
    );
  }
}
