// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:parkflow/pages/map/functions/popUps/editing_function.dart';
import 'package:parkflow/pages/map/functions/popUps/reserving_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import 'package:provider/provider.dart';
import '../../../../model/user/user_logged_controller.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';

import '../../../../model/user/user_service.dart';


final _firestore = FirebaseFirestore.instance;

// Dit is voor de tijd
Duration selectedTime = const Duration(hours: 0, minutes: 0);

//tijd formateer methode
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM HHumm').format(dateTime);
}

void getMarkersFromDatabase(BuildContext context,
    void Function(List<Marker> markers) onMarkersFetched) async {
  final markersSnapshot = await _firestore.collection('markers').get();
  List<Marker> markers = markersSnapshot.docs.map((doc) {
    double latitude = doc['latitude'];
    double longitude = doc['longitude'];
    String parkedUserId = doc['parkedUserId'];
    String reservedUserId = doc['reservedUserId'];
    String parkedVehicleId = doc['parkedVehicleId'];
    String reservedVehicleId = doc['reservedVehicleId'];
    DateTime startTime = doc['startTime'].toDate();
    DateTime endTime = doc['endTime'].toDate();
    DateTime prevEndTime = doc['prevEndTime'].toDate();
    bool isGreenMarker = doc['isGreenMarker'];

    MarkerInfo theMarker = MarkerInfo(
        latitude: latitude,
        longitude: longitude,
        parkedUserId: parkedUserId,
        reservedUserId: reservedUserId,
        parkedVehicleId: parkedVehicleId,
        reservedVehicleId: reservedVehicleId,
        startTime: startTime,
        endTime: endTime,
        prevEndTime: prevEndTime,
        isGreenMarker: isGreenMarker);

    return createMarkersFromDatabase(context, theMarker);
  }).toList();
  onMarkersFetched(markers);
}

void createMarker(
    LatLng latlng,
    String parkedUserId,
    String reservedUserId,
    String parkedVehicleId,
    String reservedVehicleId,
    BuildContext context,
    void Function(Marker newMarker) onMarkerCreated) {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(minutes: 1));
  DateTime prevEndTime = startTime;
  bool isGreenMarker = true;
  //de marker =>
  MarkerInfo theMarker = MarkerInfo(
      latitude: latlng.latitude,
      longitude: latlng.longitude,
      parkedUserId: parkedUserId,
      reservedUserId: reservedUserId,
      parkedVehicleId: parkedVehicleId,
      reservedVehicleId: reservedVehicleId,
      startTime: startTime,
      endTime: endTime,
      prevEndTime: prevEndTime,
      isGreenMarker: isGreenMarker);

  saveMarkerToDatabase(theMarker);
  Marker newMarker = createMarkersFromDatabase(context, theMarker);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(BuildContext context, MarkerInfo newMarker) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final currentUserId = userLogged.email.trim();
  Color markerColor;

  if (newMarker.isGreenMarker) {
    markerColor = Colors.green;
  } else if (currentUserId == newMarker.reservedUserId) {
    markerColor = Colors.blue;
  } else {
    markerColor = Colors.black;
  }

  return Marker(
    width: 60.0,
    height: 60.0,
    point: LatLng(newMarker.latitude, newMarker.longitude),
    builder: (ctx) => GestureDetector(
      onTap: () {
        if (newMarker.isGreenMarker &&
            currentUserId != newMarker.parkedUserId) {
          showPopupReserve(context, newMarker, userLogged.email);
        }
        if ((newMarker.isGreenMarker &&
                currentUserId == newMarker.parkedUserId) ||
            (!newMarker.isGreenMarker &&
                currentUserId == newMarker.reservedUserId)) {
          showPopupEdit(context, newMarker, userLogged.email);
        }
      },
      child: Icon(Icons.location_on, color: markerColor, size: iconSizeNav),
    ),
  );
}

Future<void> saveMarkerToDatabase(MarkerInfo theMarker) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
      .collection('markers')
      .where('latitude', isEqualTo: theMarker.latitude)
      .where('longitude', isEqualTo: theMarker.longitude)
      .get();

  for (var doc in querySnapshot.docs) {
    await _firestore.collection('markers').doc(doc.id).delete();
  }

  await _firestore.collection('markers').add({
    'latitude': theMarker.latitude,
    'longitude': theMarker.longitude,
    'reservedUserId': theMarker.reservedUserId,
    'parkedUserId': theMarker.parkedUserId,
    'reservedVehicleId': theMarker.reservedVehicleId,
    'parkedVehicleId': theMarker.parkedVehicleId,
    'startTime': theMarker.startTime,
    'endTime': theMarker.endTime,
    'prevEndTime': theMarker.prevEndTime,
    'isGreenMarker': theMarker.isGreenMarker,
  });
}

Future<void> updateMarker(MarkerInfo updatedMarker, bool isGreenMarker) async {
  try {
    final markerSnapshot = await _firestore
        .collection('markers')
        .where('latitude', isEqualTo: updatedMarker.latitude)
        .where('longitude', isEqualTo: updatedMarker.longitude)
        .get();

    for (var doc in markerSnapshot.docs) {
      doc.reference.update({
        'parkedUserId': updatedMarker.parkedUserId,
        'reservedUserId': updatedMarker.reservedUserId,
        'parkedVehicleId': updatedMarker.parkedVehicleId,
        'reservedVehicleId': updatedMarker.reservedVehicleId,
        'startTime': updatedMarker.startTime,
        'endTime': updatedMarker.endTime,
        'prevEndTime': updatedMarker.prevEndTime,
        'isGreenMarker': isGreenMarker,
      });
    }
  } catch (e) {
    print('Error updating marker: $e');
  }
}

Future<void> removeExpiredMarkers() async {
  String parkedVehicleId = '';
  final markersSnapshot = await _firestore.collection('markers').get();
  for (var doc in markersSnapshot.docs) {
    String parkedUserId = doc['parkedUserId'];
    parkedVehicleId = doc['parkedVehicleId'];
    DateTime endTime = doc['endTime'].toDate();
    final userDoc =
        await _firestore.collection('users').doc(parkedUserId).get();
    List<dynamic> vervoeren = userDoc.get('vervoeren');
    List<Vehicle> vehicles = vervoeren.map((v) => Vehicle.fromJson(v)).toList();
    final selectedVehicleIndex =
        vervoeren.indexWhere((vehicle) => vehicle['model'] == parkedVehicleId);
    //model zou eigenlijk id moeten zijn
    if (endTime.isBefore(DateTime.now())) {
      await _firestore.collection('markers').doc(doc.id).delete();
      if (selectedVehicleIndex > -1) {
        Vehicle parkedVehicle = vehicles[selectedVehicleIndex];
        await toggleVehicleAvailability(parkedUserId, parkedVehicle);
      }
    }
  }
}

Future<void> updateMarkerState(BuildContext context) async {
  try {
    final userLogged = Provider.of<UserLogged>(context, listen: false);
    final currentUserId = userLogged.email.trim();
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();

    List<Vehicle> vervoeren = userDoc.get('vervoeren');

    final markersSnapshot = await _firestore.collection('markers').get();
    for (var doc in markersSnapshot.docs) {
      DateTime prevEndTime = doc['prevEndTime'].toDate();
      String parkedUserId = doc['parkedUserId'].toString();
      String parkedVehicleId = doc['parkedVehicleId'].toString();
      String reservedUserId = doc['reservedUserId'].toString();
      String reservedVehicleId = doc['reservedVehicleId'].toString();

      final selectedVehicleIndex =
          vervoeren.indexWhere((vehicle) => vehicle.model == parkedVehicleId);
      Vehicle parkedVehicle = vervoeren[selectedVehicleIndex];

      if (prevEndTime.isBefore(DateTime.now())) {
        doc.reference.update({'isGreenMarker': true});
        doc.reference.update({'parkedUserId': reservedUserId});
        doc.reference.update({'parkedVehicleId': reservedVehicleId});
        toggleVehicleAvailability(parkedUserId, parkedVehicle);
      }
    }
  } catch (e) {
    print('');
  }
}

