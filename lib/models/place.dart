import 'package:uuid/uuid.dart';
import 'dart:io';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.saddress,
  });
  final double latitude;
  final double longitude;
  final String address;
  final String saddress;
}

class Place {
  Place({
    required this.title,
    required this.image,
    required this.placeLocation,
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final File image;
  final PlaceLocation placeLocation;
}
