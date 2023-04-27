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
    DateTime startTime = doc['startTime'].toDate();
    DateTime endTime = doc['endTime'].toDate();
    return createMarkersFromDatabase(
        context, latLng, userId, startTime, endTime);
  }).toList();

  onMarkersFetched(markers);
}

void createMarker(LatLng latlng, String userId, BuildContext context,
    void Function(Marker newMarker) onMarkerCreated) {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now()
      .add(const Duration(hours: 1)); // Set initial end time to 1 hour from now

  saveMarkerToDatabase(latlng, userId, startTime, endTime);
  Marker newMarker =
      createMarkersFromDatabase(context, latlng, userId, startTime, endTime);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(BuildContext context, LatLng latlng,
    String userId, DateTime startTime, DateTime endTime) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final userEmail = userLogged.email.trim();
  final markerColor = userEmail == userId ? Colors.blue : Colors.black;
  return Marker(
    width: 60.0,
    height: 60.0,
    point: latlng,
    builder: (ctx) => GestureDetector(
      onTap: () {
        showPopup(context, latlng, startTime, endTime);
      },
      child: Container(
        child: Icon(Icons.location_on, color: markerColor, size: 40),
      ),
    ),
  );
}

Future<void> saveMarkerToDatabase(
    LatLng latlng, String userId, DateTime startTime, DateTime endTime) async {
  await _firestore.collection('markers').add({
    'latitude': latlng.latitude,
    'longitude': latlng.longitude,
    'userId': userId,
    'startTime': startTime,
    'endTime': endTime,
  });
}

void showPopup(
    BuildContext context, LatLng latLng, DateTime startTime, DateTime endTime) {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(hours: 1));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
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
                    const Text('Title maybe here'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start Time: ${startTime.hour}:${startTime.minute}'),
                    IconButton(
                      onPressed: () => setState(() {
                        startTime = DateTime.now();
                      }),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('End Time: ${endTime.hour}:${endTime.minute}'),
                    IconButton(
                      onPressed: () async {
                        final newEndTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime),
                        );
                        if (newEndTime != null) {
                          setState(() {
                            endTime = DateTime(
                              endTime.year,
                              endTime.month,
                              endTime.day,
                              newEndTime.hour,
                              newEndTime.minute,
                            );
                            if (endTime.difference(startTime) >
                                const Duration(hours: 24)) {
                              endTime =
                                  startTime.add(const Duration(hours: 24));
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
                Text('Latitude: ${latLng.latitude}',
                    style: const TextStyle(fontSize: 24)),
                Text('Longitude: ${latLng.longitude}',
                    style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
        );
      });
    },
  );
}
