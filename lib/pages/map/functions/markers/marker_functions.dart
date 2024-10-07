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

/// Beschrijving: Haalt markers op uit de database en roept een [callback_functie] aan met de opgehaalde markers.

void getMarkersFromDatabase(BuildContext context,
    void Function(List<Marker> markers) onMarkersFetched) async {
  final markersSnapshot = await _firestore.collection('markers').get();
  List<Marker> markers = markersSnapshot.docs.map((doc) {
    double latitude = doc['latitude'];
    double longitude = doc['longitude'];

    //parked user =>
    String parkedUserId = doc['parkedUserId'];
    String parkedVehicleId = doc['parkedVehicleId'];
    String parkedVehicleBrand = doc['parkedVehicleBrand'];
    String parkedVehicleColor = doc['parkedVehicleColor'];

    //reserved user =>
    String reservedUserId = doc['reservedUserId'];
    String reservedVehicleBrand = doc['reservedVehicleBrand'];
    String reservedVehicleId = doc['reservedVehicleId'];
    String reservedVehicleColor = doc['reservedVehicleColor'];

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
        isGreenMarker: isGreenMarker,
        parkedVehicleBrand: parkedVehicleBrand,
        reservedVehicleBrand: reservedVehicleBrand,
        parkedVehicleColor: parkedVehicleColor,
        reservedVehicleColor: reservedVehicleColor);

    return createMarkersFromDatabase(context, theMarker);
  }).toList();
  onMarkersFetched(markers);
}

/// Beschrijving: Creëert een marker op basis van de gegeven [MarkerInfo] en het huidige gebruikerscontext.
/// De marker wordt teruggegeven en kan worden gebruikt in de kaartweergave.

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
    child: GestureDetector(
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

/// Beschrijving: Slaat de gegeven [MarkerInfo] op in de database.
/// Als er al een marker bestaat met dezelfde [Latidude] en [longitude], wordt deze eerst verwijderd en vervolgens wordt de nieuwe [marker] toegevoegd.

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
    'parkedVehicleBrand': theMarker.parkedVehicleBrand,
    'reservedVehicleBrand': theMarker.reservedVehicleBrand,
    'reservedVehicleColor': theMarker.reservedVehicleColor,
    'parkedVehicleColor': theMarker.parkedVehicleColor,
    'startTime': theMarker.startTime,
    'endTime': theMarker.endTime,
    'prevEndTime': theMarker.prevEndTime,
    'isGreenMarker': theMarker.isGreenMarker,
  });
}

/// Beschrijving: Werkt de gegeven [MarkerInfo] bij in de database.
/// Zoekt naar de marker met dezelfde [Latidude] en [longitude] en werkt de relevante velden bij met de nieuwe gegevens.

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
        'parkedVehicleColor': updatedMarker.parkedVehicleColor,
        'reservedVehicleId': updatedMarker.reservedVehicleId,
        'reservedVehicleBrand': updatedMarker.reservedVehicleBrand,
        'reservedVehicleColor': updatedMarker.reservedVehicleColor,
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

/// Beschrijving: Werkt de status van de [markers] bij in de database op basis van de eindtijden. 
/// Als de eindtijd van een marker voorbij is, wordt de marker [verwijderd] en wordt de beschikbaarheid van het geparkeerde voertuig [gewijzigd]. 
/// Als de vorige eindtijd van een marker voorbij is en er een gereserveerde gebruiker is, wordt de marker bijgewerkt om [groen] te zijn, 
/// met de vorige eindtijd als nieuwe starttijd en de originele eindtijd als nieuwe vorige eindtijd. 
/// De gereserveerde gebruiker wordt de geparkeerde gebruiker en de bijbehorende voertuiggegevens worden bijgewerkt.
/// De beschikbaarheid van het geparkeerde voertuig wordt ook gewijzigd.

Future<void> updateMarkerState() async {
  final markersSnapshot = await _firestore.collection('markers').get();
  for (var doc in markersSnapshot.docs) {
    DateTime endTime = doc['endTime'].toDate();
    DateTime prevEndTime = doc['prevEndTime'].toDate();
    String parkedUserId = doc['parkedUserId'].toString();
    String parkedVehicleId = doc['parkedVehicleId'].toString();
    String reservedUserId = doc['reservedUserId'].toString();
    String reservedVehicleId = doc['reservedVehicleId'].toString();
    String reservedVehicleBrand = doc['reservedVehicleBrand'].toString();

    final userDoc =
        await _firestore.collection('users').doc(parkedUserId).get();
    List<dynamic> vervoeren = userDoc.get('vervoeren');
    List<Vehicle> vehicles = vervoeren.map((v) => Vehicle.fromJson(v)).toList();

    final selectedVehicleIndex =
        vervoeren.indexWhere((vehicle) => vehicle['id'] == parkedVehicleId);

    if (endTime.isBefore(DateTime.now())) {
      await _firestore.collection('markers').doc(doc.id).delete();
      if (selectedVehicleIndex > -1) {
        Vehicle parkedVehicle = vehicles[selectedVehicleIndex];
        await toggleVehicleAvailability(parkedUserId, parkedVehicle);
      }
    }
    if (prevEndTime.isBefore(DateTime.now()) && reservedUserId != "") {
      doc.reference.update({'isGreenMarker': true});
      doc.reference.update({'startTime': prevEndTime});
      doc.reference.update({'prevEndTime': endTime});
      doc.reference.update({'parkedUserId': reservedUserId});
      doc.reference.update({'parkedVehicleId': reservedVehicleId});
      doc.reference.update({'parkedVehicleBrand': reservedVehicleBrand});
      doc.reference.update({'reservedUserId': ''});
      doc.reference.update({'reservedVehicleId': ''});
      doc.reference.update({'reservedVehicleBrand': ''});
      if (selectedVehicleIndex >= 0) {
        Vehicle parkedVehicle = vehicles[selectedVehicleIndex];
        //dit hoort te kloppen
        toggleVehicleAvailability(parkedUserId, parkedVehicle);
      }
    }
  }
}