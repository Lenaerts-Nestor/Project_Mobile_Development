// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/components/custom_button.dart';
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
    bool isGreenMarker = doc['isGreenMarker'];

    return createMarkersFromDatabase(
        context, latLng, userId, startTime, endTime, isGreenMarker);
  }).toList();

  onMarkersFetched(markers);
}

void createMarker(LatLng latlng, String userId, BuildContext context,
    void Function(Marker newMarker) onMarkerCreated) {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(minutes: 1));
  bool isGreenMarker = true;

  saveMarkerToDatabase(latlng, userId, startTime, endTime, isGreenMarker);

  Marker newMarker = createMarkersFromDatabase(
      context, latlng, userId, startTime, endTime, isGreenMarker);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(BuildContext context, LatLng latlng,
    String userId, DateTime startTime, DateTime endTime, bool isGreenMarker) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final userEmail = userLogged.email.trim();
  Color markerColor;
  if (isGreenMarker) {
    markerColor = Colors.green;
  } else if (userEmail == userId) {
    markerColor = Colors.blue;
  } else {
    markerColor = Colors.orange;
  }

  return Marker(
    width: 60.0,
    height: 60.0,
    point: latlng,
    builder: (ctx) => GestureDetector(
      onTap: () {
        showPopup(context, latlng, startTime, endTime, userId, isGreenMarker);
      },
      child: Container(
        child: Icon(Icons.location_on, color: markerColor, size: 40),
      ),
    ),
  );
}

Future<void> saveMarkerToDatabase(LatLng latlng, String userId,
    DateTime startTime, DateTime endTime, bool isGreenMarker) async {
  await _firestore.collection('markers').add({
    'latitude': latlng.latitude,
    'longitude': latlng.longitude,
    'userId': userId,
    'startTime': startTime,
    'endTime': endTime,
    'isGreenMarker': isGreenMarker,
  });
}




void showPopup(BuildContext context, LatLng latLng, DateTime startTime,
    DateTime endTime, String userId, bool isGreenMarker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        DateTime calculatedEndTime = endTime;

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
                    const Text('Straat naam hier'),
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
                const Text('Hoe lang wilt u reserveren ?'),
                SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime(0),
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        calculatedEndTime =
                            startTime.add(value.difference(DateTime(0)));
                      });
                    },
                  ),
                ),
                Text(
                  'Eindtijd: ${calculatedEndTime.hour}',
                  style: const TextStyle(fontSize: 16),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      label: "Reserveren",
                      backgroundColor: Colors.blueGrey,
                      onPressed: () {
                        bool newIsGreenMarker = DateTime.now().isBefore(
                            calculatedEndTime
                                .subtract(const Duration(minutes: 10)));
                        saveMarkerToDatabase(latLng, userId, startTime,
                            calculatedEndTime, newIsGreenMarker);
                        Navigator.pop(context);
                      },
                      height: 70,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
