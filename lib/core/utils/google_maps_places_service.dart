import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/place_autocomplete_model/place_autocomplete_model.dart';

class GoogleMapsPlacesService {
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String apiKey = 'AIzaSyAKOGW483EvisJTOBF8XsmbVxkI7jGEPFQ';

  Future<List<PlaceAutocompleteModel>> getPredictions(
      {required String input}) async {
    var response = await http
        .get(Uri.parse('$baseUrl/autocomplete/json?key=$apiKey&input=$input'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['predictions'];
      List<PlaceAutocompleteModel> places = [];
      for (var item in data) {
        places.add(PlaceAutocompleteModel.fromJson(item));
      }
      print(places.length);
      return places;
    } else {
      throw Exception();
    }
  }
}
