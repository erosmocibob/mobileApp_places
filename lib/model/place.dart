import 'package:flutter/foundation.dart';

class PlaceLocation {
  final double latitude;
  final double longitude;

  const PlaceLocation({
    @required this.latitude,
    @required this.longitude,
  });
}

class Place {
  double lat;
  double lng;
  String image;
  String userId;

  Place();

  Place.fromMap(Map<String, dynamic> data) {
    userId = data['user_id'];
    image = data['image'];
    lat = data['coordinates'].latitude;
    lng = data['coordinates'].longitude;
  }
}
