import 'package:flutter/material.dart';

import 'package:places/models/place.dart';
import 'package:places/screens/map.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;
  String get locationImage {
    final lat = place.placeLocation.latitude;
    final lng = place.placeLocation.longitude;
    return 'https://maptoolkit.p.rapidapi.com/staticmap?center=$lat%2C$lng&zoom=16&size=640x200&maptype=toursprung-terrain&format=png&marker=center%3A$lat%2C$lng%7Cshadow%3Afalse';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            place.image,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              alignment: Alignment.centerLeft,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => MapScreen(
                                    location: place.placeLocation,
                                    isSelecting: false,
                                  )));
                        },
                        child: Image(
                          image: NetworkImage(locationImage, headers: {
                            'X-RapidAPI-Key':
                                "2bae41a194mshe5ade54856540b5p1c2db4jsn0fccbe703150",
                            'X-RapidAPI-Host': "maptoolkit.p.rapidapi.com"
                          }),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      //proper use of expanded
                      child: Text(
                        place.placeLocation.address,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
