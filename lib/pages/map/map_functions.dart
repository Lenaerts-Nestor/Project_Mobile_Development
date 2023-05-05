// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/components/custom_dropdown.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:provider/provider.dart';
import '../../model/user/user_logged_controller.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';

import '../../model/user/user_service.dart';
import '../settings/pages/vehicles/add_vehicles_page.dart';

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
    LatLng latLng = LatLng(doc['latitude'], doc['longitude']);
    String parkedUserId = doc['parkedUserId'];
    String reservedUserId = doc['reservedUserId'];
    String parkedVehicleId = doc['parkedVehicleId'];
    String reservedVehicleId = doc['reservedVehicleId'];
    DateTime startTime = doc['startTime'].toDate();
    DateTime endTime = doc['endTime'].toDate();
    DateTime prevEndTime = doc['prevEndTime'].toDate();
    bool isGreenMarker = doc['isGreenMarker'];
    return createMarkersFromDatabase(
        context,
        latLng,
        parkedUserId,
        reservedUserId,
        parkedVehicleId,
        reservedVehicleId,
        startTime,
        endTime,
        prevEndTime,
        isGreenMarker);
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
  saveMarkerToDatabase(latlng, parkedUserId, reservedUserId, parkedVehicleId,
      reservedVehicleId, startTime, endTime, prevEndTime, isGreenMarker);
  Marker newMarker = createMarkersFromDatabase(
      context,
      latlng,
      parkedUserId,
      reservedUserId,
      parkedVehicleId,
      reservedVehicleId,
      startTime,
      endTime,
      prevEndTime,
      isGreenMarker);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(
    BuildContext context,
    LatLng latlng,
    String parkedUserId,
    String reservedUserId,
    String parkedVehicleId,
    String reservedVehicleId,
    DateTime startTime,
    DateTime endTime,
    DateTime prevEndTime,
    bool isGreenMarker) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final currentUserId = userLogged.email.trim();
  Color markerColor;

  if (isGreenMarker) {
    markerColor = Colors.green;
  } else if (currentUserId == reservedUserId) {
    markerColor = Colors.blue;
  } else {
    markerColor = Colors.black;
  }

  return Marker(
    width: 60.0,
    height: 60.0,
    point: latlng,
    builder: (ctx) => GestureDetector(
      onTap: () {
        if (isGreenMarker && currentUserId != parkedUserId) {
          showPopupReserve(context, latlng, parkedUserId, reservedUserId,
              startTime, endTime, true);
        }
        if ((isGreenMarker && currentUserId == parkedUserId) ||
            (!isGreenMarker && currentUserId == reservedUserId)) {
          showPopupEdit(context, latlng, reservedUserId, startTime, endTime,
              prevEndTime, false);
        }
      },
      child: Icon(Icons.location_on, color: markerColor, size: iconSizeNav),
    ),
  );
}

Future<void> saveMarkerToDatabase(
  LatLng latlng,
  String parkedUserId,
  String reservedUserId,
  String parkedVehicleId,
  String reservedVehicleId,
  DateTime startTime,
  DateTime endTime,
  DateTime prevEndTime,
  bool isGreenMarker,
) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
      .collection('markers')
      .where('latitude', isEqualTo: latlng.latitude)
      .where('longitude', isEqualTo: latlng.longitude)
      .get();

  for (var doc in querySnapshot.docs) {
    await _firestore.collection('markers').doc(doc.id).delete();
  }

  await _firestore.collection('markers').add({
    'latitude': latlng.latitude,
    'longitude': latlng.longitude,
    'reservedUserId': reservedUserId,
    'parkedUserId': parkedUserId,
    'reservedVehicleId': reservedVehicleId,
    'parkedVehicleId': parkedVehicleId,
    'startTime': startTime,
    'endTime': endTime,
    'prevEndTime': prevEndTime,
    'isGreenMarker': isGreenMarker,
  });
}

Future<void> removeExpiredMarkers() async {
  //alle date in een list zetten -> als id hier niet in zit availability op true zetten
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
    //model zou eigenlijk id moeten zijn??
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

void showPopupPark(BuildContext context, LatLng latLng, String parkedUserId) {
  late String parkedVehicleId = '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StreamBuilder<UserAccount>(
        stream: readUserByLive(parkedUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user != null) {
              final vehicles = user.vehicles
                  .where((v) => v.availability)
                  .toList(); // Filter vehicles with availability = true
              bool buttonDisabled = vehicles.isEmpty;
              if (parkedVehicleId == '' && vehicles.isNotEmpty) {
                parkedVehicleId = vehicles.first.model;
              }
              return StatefulBuilder(builder: (context, setState) {
                DateTime endTime = DateTime.now().add(selectedTime);
                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: color3,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Testerstraat',
                              style: TextStyle(fontSize: fontSize3),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              iconSize: iconSizeNav,
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                        const Text('Hoe lang gaat u parkeren?'),
                        SizedBox(
                          height: 180,
                          child: CupertinoDatePicker(
                            initialDateTime: DateTime(0).add(selectedTime),
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime value) {
                              setState(() {
                                selectedTime = Duration(
                                    hours: value.hour, minutes: value.minute);
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: verticalSpacing2),
                        Text('van ${formatDateTime(DateTime.now())}'),
                        Text('tot  ${formatDateTime(endTime)}'),
                        const SizedBox(height: verticalSpacing2),
                        vehicles.isNotEmpty
                            ? VehicleDropdown(
                                items: vehicles
                                    .map((vehicle) =>
                                        vehicle.model) //this should be id
                                    .toList(),
                                value: parkedVehicleId,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    parkedVehicleId = value;
                                  });
                                },
                              )
                            : const Text('voeg een vervoer toe aan je account'),
                        const SizedBox(height: 80), //dit aangepast om te testen
                        //knop mischien groter doen ???
                        BlackButton(
                          text: buttonDisabled ? 'auto tekort' : 'parkeren',
                          isRed: buttonDisabled ? false : true,
                          onPressed: buttonDisabled
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddVehicle()),
                                  );
                                }
                              : () async {
                                  final selectedVehicleIndex =
                                      vehicles.indexWhere((vehicle) =>
                                          vehicle.model == parkedVehicleId);
                                  if (selectedVehicleIndex >= 0) {
                                    final selectedVehicle2 =
                                        vehicles[selectedVehicleIndex];
                                    await saveMarkerToDatabase(
                                        latLng,
                                        parkedUserId,
                                        '',
                                        parkedVehicleId,
                                        '',
                                        DateTime.now(),
                                        endTime,
                                        DateTime.now(),
                                        true);
                                    await toggleVehicleAvailability(
                                        parkedUserId, selectedVehicle2);
                                    Navigator.pop(context);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                );
              });
            }
          }
          return const SizedBox.shrink();
        },
      );
    },
  );
}

void showPopupReserve(
    BuildContext context,
    LatLng latLng,
    String parkedUserId,
    String parkedVehicleId,
    DateTime startTime,
    DateTime endTime,
    bool isGreenMarker) {
  DateTime previousEndTime = endTime;
  //nog te implementeren !!!
  String reservedVehicleId = "";
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        DateTime endTime = previousEndTime.add(selectedTime);
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: color3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Testerstraat',
                      style: TextStyle(fontSize: fontSize3),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: iconSizeNav,
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const Text('Hoe lang gaat u na de reservatie parkeren?'),
                SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime(0).add(selectedTime),
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        selectedTime =
                            Duration(hours: value.hour, minutes: value.minute);
                      });
                    },
                  ),
                ),
                const SizedBox(height: verticalSpacing2),
                //moet previousEndTime zijn
                Text('van ${formatDateTime(previousEndTime)}'),
                Text('tot  ${formatDateTime(endTime)}'),
                const SizedBox(height: verticalSpacing2),
                BlackButton(
                  onPressed: () async {
                    if (isGreenMarker) {
                      final userLogged =
                          Provider.of<UserLogged>(context, listen: false);
                      //Parked ID toevoegen
                      await saveMarkerToDatabase(
                          latLng,
                          parkedUserId,
                          userLogged.email,
                          parkedVehicleId,
                          reservedVehicleId,
                          startTime,
                          endTime,
                          previousEndTime,
                          false);
                    }
                    Navigator.pop(context);
                  },
                  text: 'reserveren',
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

// bij annuleren auto vrijgeven!
void showPopupEdit(
    BuildContext context,
    LatLng latLng,
    String reservedId,
    DateTime startTime,
    DateTime endTime,
    DateTime previousEndTime,
    bool isGreenMarker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        DateTime replacingEndTime = startTime.add(selectedTime);
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: color3,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Testerstraat',
                      style: TextStyle(fontSize: fontSize3),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: iconSizeNav,
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const Text('verander hier uw parkeertijd'),
                SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime(0).add(selectedTime),
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        selectedTime =
                            Duration(hours: value.hour, minutes: value.minute);
                      });
                    },
                  ),
                ),
                const SizedBox(height: verticalSpacing2),
                Text('van ${formatDateTime(startTime)}'),
                Text(
                  'tot ${formatDateTime(endTime)}',
                  style:
                      const TextStyle(decoration: TextDecoration.lineThrough),
                ),
                Text('tot ${formatDateTime(replacingEndTime)}'),
                const SizedBox(height: verticalSpacing2),
                BlackButton(
                  onPressed: () async {
                    final userLogged =
                        Provider.of<UserLogged>(context, listen: false);
                    await saveMarkerToDatabase(latLng, userLogged.email, '', '',
                        '', startTime, replacingEndTime, previousEndTime, true);
                    Navigator.pop(context);
                  },
                  text: selectedTime != const Duration(seconds: 0)
                      ? 'aanpassen'
                      : 'annuleren',
                  isRed:
                      selectedTime != const Duration(seconds: 0) ? true : false,
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
