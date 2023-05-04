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
import '../settings/pages/vehicles/addVehiclesPage.dart';

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
    String reservedId = doc['reservedId'];
    DateTime startTime = doc['startTime'].toDate();
    DateTime endTime = doc['endTime'].toDate();
    DateTime prevEndTime = doc['prevEndTime'].toDate();
    bool isGreenMarker = doc['isGreenMarker'];
    return createMarkersFromDatabase(context, latLng, reservedId, startTime,
        endTime, prevEndTime, isGreenMarker);
  }).toList();
  onMarkersFetched(markers);
}

void createMarker(LatLng latlng, String reservedId, BuildContext context,
    void Function(Marker newMarker) onMarkerCreated) {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(const Duration(minutes: 1));
  DateTime prevEndTime = startTime;
  bool isGreenMarker = true;
  saveMarkerToDatabase(
      //TODO: parked ID toevoegen
      latlng,
      reservedId,
      '',
      startTime,
      endTime,
      prevEndTime,
      isGreenMarker);
  Marker newMarker = createMarkersFromDatabase(context, latlng, reservedId,
      startTime, endTime, prevEndTime, isGreenMarker);
  onMarkerCreated(newMarker);
}

Marker createMarkersFromDatabase(
    BuildContext context,
    LatLng latlng,
    String reservedId,
    DateTime startTime,
    DateTime endTime,
    DateTime prevEndTime,
    bool isGreenMarker) {
  final userLogged = Provider.of<UserLogged>(context, listen: false);
  final userEmail = userLogged.email.trim();
  Color markerColor;

  if (isGreenMarker) {
    markerColor = Colors.green;
  } else if (userEmail == reservedId) {
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
        if (isGreenMarker && userEmail != reservedId) {
          showPopupReserve(
              context, latlng, reservedId, startTime, endTime, true);
        }
        if (userEmail == reservedId) {
          showPopupEdit(context, latlng, reservedId, startTime, endTime,
              prevEndTime, false);
        }
      },
      child: Icon(Icons.location_on, color: markerColor, size: iconSizeNav),
    ),
  );
}

//TODO:
// parked_user
// reserved user

Future<void> saveMarkerToDatabase(
  LatLng latlng,
  String reservedId,
  String parkedId,
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
    'reservedId': reservedId,
    'parkedId': parkedId,
    'startTime': startTime,
    'endTime': endTime,
    'prevEndTime': prevEndTime,
    'isGreenMarker': isGreenMarker,
  });
}

Future<void> removeExpiredMarkers() async {
  final markersSnapshot = await _firestore.collection('markers').get();
  for (var doc in markersSnapshot.docs) {
    DateTime endTime = doc['endTime'].toDate();
    if (endTime.isBefore(DateTime.now())) {
      await _firestore.collection('markers').doc(doc.id).delete();
    }
  }
}

Future<void> updateMarkerState() async {
  try {
    final markersSnapshot = await _firestore.collection('markers').get();
    for (var doc in markersSnapshot.docs) {
      DateTime prevEndTime = doc['prevEndTime'].toDate();
      if (prevEndTime.isBefore(DateTime.now())) {
        await doc.reference.update({'isGreenMarker': true});
      }
    }
  } catch (e) {
    // Ignore the error and continue
    print('Error occurred, but ignoring it: $e');
  }
}

Future<void> updateCarState() async {
  try {
    final docUser = FirebaseFirestore.instance.collection('users');
    final markersSnapshot = await _firestore.collection('users').get();
    for (var doc in markersSnapshot.docs) {
      DateTime prevEndTime = doc['prevEndTime'].toDate();
      if (prevEndTime.isBefore(DateTime.now())) {
        await doc.reference.update({'isGreenMarker': true});
      }
    }
  } catch (e) {
    // Ignore the error and continue
    print('Error occurred, but ignoring it: $e');
  }
}

void showPopupPark(BuildContext context, LatLng latLng, String reservedId) {
  late String selectedVehicle = '';

  List<Vehicle> _vehicles = [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StreamBuilder<UserAccount>(
        stream: readUserByLive(reservedId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            _vehicles = user!.vehicles;
            if (user != null) {
              final vehicles = user.vehicles
                  .where((v) => v.availability)
                  .toList(); // Filter vehicles with availability = true

              bool buttonDisabled = vehicles.isEmpty;
              if (selectedVehicle == '' && vehicles.isNotEmpty) {
                selectedVehicle = vehicles.first.model;
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
                                    .map((vehicle) => vehicle.model)
                                    .toList(),
                                value: selectedVehicle,
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    selectedVehicle = value;
                                    final selectedVehicleIndex =
                                        _vehicles.indexWhere((vehicle) =>
                                            vehicle.model == selectedVehicle);
                                  });
                                },
                              )
                            : const Text('voeg een vervoer toe aan je account'),
                        const SizedBox(height: 80), //dit aangepast om te testen
                        //knop mischien groter doen ???
                        BlackButton(
                          text: buttonDisabled ? 'ongeldige' : 'parkeren',
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
                                          vehicle.model == selectedVehicle);
                                  if (selectedVehicleIndex >= 0) {
                                    final selectedVehicle2 =
                                        vehicles[selectedVehicleIndex];
                                    await saveMarkerToDatabase(
                                        latLng,
                                        reservedId,
                                        '', //TODO: parkedID doen
                                        DateTime.now(),
                                        endTime,
                                        DateTime.now(),
                                        true);
                                    await toggleVehicleAvailability(
                                        reservedId, selectedVehicle2);
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

void showPopupReserve(BuildContext context, LatLng latLng, String reservedId,
    DateTime startTime, DateTime endTime, bool isGreenMarker) {
  DateTime previousEndTime = endTime;
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
                      await saveMarkerToDatabase(latLng, userLogged.email, '',
                          startTime, endTime, previousEndTime, false);
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
                    await saveMarkerToDatabase(latLng, userLogged.email, '',
                        startTime, replacingEndTime, previousEndTime, true);
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
