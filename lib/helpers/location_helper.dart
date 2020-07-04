import 'dart:convert';

import 'package:http/http.dart' as http;

const MAPBOX_API_KEY =
    'pk.eyJ1IjoiY29kZTY2NiIsImEiOiJjazlzOTVzdWUxMWxzM2lxcG80Nmhrcmg1In0.p8fgq07xyqzYgQlbzQhBbQ';

class Adress {
  String city;
  String country;

  Adress(this.city, this.country);
}

class LocationHelper {
  static String generateLocationPreviewImage(
      {double latitude, double longitude}) {
    return 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v11/static/pin-s-marker+285A98($longitude,$latitude)/$longitude,$latitude,17,0/400x300@2x?access_token=$MAPBOX_API_KEY&attribution=false';
  }

  static Future<Map<String, String>> getAdress(
      double latitude, double longitude) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?types=region,place&access_token=pk.eyJ1IjoiY29kZTY2NiIsImEiOiJjazlzOTVzdWUxMWxzM2lxcG80Nmhrcmg1In0.p8fgq07xyqzYgQlbzQhBbQ';

    final response = await http.get(url);
    var data = json.decode(response.body.toString());
    var city = data['features'][0]['text'];

    var contextLength = data['features'][0]['context'].length;
    var country = data['features'][0]['context'][contextLength - 1]['text'];

    Map<String, String> address = {
      'city': city,
      'country': country,
    };

    return address;
  }
}
