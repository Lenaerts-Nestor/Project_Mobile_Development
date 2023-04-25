// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../model/user/user_logged_controller.dart';

final _firestore = FirebaseFirestore.instance;

void getMarkersFromDatabase(BuildContext context,
  void Function(List<Marker> markers) onMarkersFetched) async {
  final markersSnapshot = await _firestore.collection('markers').get();

  List<Marker> markers = markersSnapshot.docs.map((doc) {
    LatLng latLng = LatLng(doc['latitude'], doc['longitude']);
    String userId = doc['userId'];
    return createMarkersFromDatabase(context, latLng, userId);
  }).toList();

  onMarkersFetched(markers);
}

void createMarker(LatLng latlng, String userId, BuildContext context,
    void Function(Marker newMarker) onMarkerCreated) {
  saveMarkerToDatabase(latlng, userId);
  Marker newMarker = createMarkersFromDatabase(context, latlng, userId);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(BuildContext context, LatLng latlng, String userId) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final userEmail = userLogged.email.trim();
  final markerColor = userEmail == userId ? Colors.blue : Colors.black;
  return Marker(
    width: 60.0,
    height: 60.0,
    point: latlng,
    builder: (ctx) => GestureDetector(
      onTap: () {
        showPopup(context, latlng);
      },
      child: Container(
        child: Icon(Icons.location_on, color: markerColor, size: 40),
      ),
    ),
  );
}

Future<void> saveMarkerToDatabase(LatLng latlng, String userId) async {
  await _firestore.collection('markers').add({
    'latitude': latlng.latitude,
    'longitude': latlng.longitude,
    'userId': userId,
  });
}

void showPopup(BuildContext context, LatLng latLng) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('title mischien heir'),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 30,
                  ),
                ],
              ),
              const Divider(
                color: Colors.black,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Text('Latitude: ${latLng.latitude}',
                  style: const TextStyle(fontSize: 24)),
              Text('longitude: ${latLng.longitude}',
                  style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
      );
    },
  );
}
