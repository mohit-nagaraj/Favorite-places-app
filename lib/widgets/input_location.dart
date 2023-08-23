import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:places/models/place.dart';
import 'package:places/screens/map.dart';

class LocationInput extends StatefulWidget {
  LocationInput(this.onSelectLocation, {super.key});
  void Function(PlaceLocation location) onSelectLocation;
  @override
  State<LocationInput> createState() {
    // TODO: implement createState
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? pickedLocation;
  late final MapController mapController;
  bool whileGettingLocation = false;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  String get locationImage {
    if (pickedLocation == null) {
      return '';
    }
    final lat = pickedLocation!.latitude;
    final lng = pickedLocation!.longitude;
    return 'https://maptoolkit.p.rapidapi.com/staticmap?center=$lat%2C$lng&zoom=15&size=640x480&maptype=toursprung-terrain&format=png&marker=center%3A$lat%2C$lng%7Cshadow%3Afalse';
  }

  void getlocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      whileGettingLocation = true;
    });
    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) return;
    var headers = {
      'X-RapidAPI-Key': '2bae41a194mshe5ade54856540b5p1c2db4jsn0fccbe703150',
      'X-RapidAPI-Host': 'forward-reverse-geocoding.p.rapidapi.com'
    };
    final url = Uri.parse(
        'https://forward-reverse-geocoding.p.rapidapi.com/v1/reverse?lat=$lat&lon=$lng&accept-language=en&polygon_threshold=0.0');

    final response = await http.get(url, headers: headers);
    final data = json.decode(response.body);
    final address = data['display_name'];
    final saddress = data['address']['city'] + ', ' + data['address']['state'];
    setState(() {
      whileGettingLocation = false;
      pickedLocation = PlaceLocation(
          latitude: lat, longitude: lng, address: address, saddress: saddress);
    });
    widget.onSelectLocation(pickedLocation!);
  }

  Future<void> selectOnMap() async {
    final chooseLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
          builder: (ctx) => const MapScreen(
                isSelecting: true,
              )),
    );
    if (chooseLocation == null) return;
    final lat = chooseLocation.latitude;
    final lng = chooseLocation.longitude;
    var headers = {
      'X-RapidAPI-Key': '2bae41a194mshe5ade54856540b5p1c2db4jsn0fccbe703150',
      'X-RapidAPI-Host': 'forward-reverse-geocoding.p.rapidapi.com'
    };
    final url = Uri.parse(
        'https://forward-reverse-geocoding.p.rapidapi.com/v1/reverse?lat=$lat&lon=$lng&accept-language=en&polygon_threshold=0.0');

    final response = await http.get(url, headers: headers);
    final data = json.decode(response.body);
    final address = data['display_name'];
    final saddress =
        data['address']['city'] ?? '' + ', ' + data['address']['state'] ?? '';
    setState(() {
      whileGettingLocation = false;
      pickedLocation = PlaceLocation(
          latitude: lat, longitude: lng, address: address, saddress: saddress);
    });
    widget.onSelectLocation(pickedLocation!);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    Widget content = Text(
      'Not yet chosen',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (whileGettingLocation) {
      content = CircularProgressIndicator();
    }

    if (pickedLocation != null) {
      content = Image(
        image: NetworkImage(locationImage, headers: {
          'X-RapidAPI-Key':
              "2bae41a194mshe5ade54856540b5p1c2db4jsn0fccbe703150",
          'X-RapidAPI-Host': "maptoolkit.p.rapidapi.com"
        }),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    // TODO: implement build
    return Column(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.075),
          ),
          child: content,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8)),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.075),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                  onPressed: whileGettingLocation ? null : getlocation,
                  icon: Icon(Icons.location_on),
                  label: Text('Current location')),
              TextButton.icon(
                  onPressed: selectOnMap,
                  icon: Icon(Icons.map),
                  label: Text('Choose on map'))
            ],
          ),
        )
      ],
    );
  }
}
