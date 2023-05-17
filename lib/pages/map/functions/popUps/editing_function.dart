// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:parkflow/pages/map/functions/streetname_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import 'package:provider/provider.dart';
import '../markers/marker_functions.dart';

final _firestore = FirebaseFirestore.instance;
Duration selectedTime = const Duration(hours: 0, minutes: 0);

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM HHumm').format(dateTime);
}

void showPopupEdit(
    BuildContext context, MarkerInfo deMarker, String currentUserId) {
  late String currentVehicleId = '';
  var streetname = getStreetName(deMarker.latitude, deMarker.longitude);
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          DateTime replacingEndTime = deMarker.startTime.add(selectedTime);
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
                      FutureBuilder<String>(
                        future: streetname,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error getting street name');
                          } else {
                            return Text(
                              snapshot.data ?? 'Unknown',
                              style: TextStyle(fontSize: fontSize3),
                            );
                          }
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                          selectedTime = Duration(
                              hours: value.hour, minutes: value.minute);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: verticalSpacing2),
                  Text('van ${formatDateTime(deMarker.startTime)}'),
                  Text(
                    'tot ${formatDateTime(deMarker.endTime)}',
                    style:
                        const TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  Text('tot ${formatDateTime(replacingEndTime)}'),
                  const SizedBox(height: verticalSpacing2),
                  BlackButton(
                    onPressed: () async {
                      final userLogged =
                          Provider.of<UserLogged>(context, listen: false);
                      //we bewaren de gegeven marker in een nieuwe marker met de verschil.
                      MarkerInfo newMarker = MarkerInfo(
                          latitude: deMarker.latitude,
                          longitude: deMarker.longitude,
                          parkedUserId: currentUserId,
                          reservedUserId: deMarker.reservedUserId,
                          parkedVehicleId: currentVehicleId,
                          reservedVehicleId: deMarker.reservedVehicleId,
                          startTime: deMarker.startTime,
                          endTime:
                              replacingEndTime, //dit is het nieuwe verschil !
                          prevEndTime: deMarker.prevEndTime,
                          isGreenMarker: true);
                      await updateMarker(newMarker, newMarker.isGreenMarker);
                      Navigator.pop(context);

                      //dit is nodig om bij het annuleren de auto opnieuw te kunnen gebruiken
                      final userDoc = await _firestore
                          .collection('users')
                          .doc(currentUserId)
                          .get();
                      List<dynamic> vervoeren = userDoc.get('vervoeren');
                      List<Vehicle> vehicles =
                          vervoeren.map((v) => Vehicle.fromJson(v)).toList();
                      final selectedVehicleIndex = vervoeren.indexWhere(
                          (vehicle) =>
                              vehicle['model'] == deMarker.parkedVehicleId &&
                              vehicle['beschikbaar'] == false);
                      if (replacingEndTime.isBefore(DateTime.now()) &&
                          selectedVehicleIndex > -1) {
                        Vehicle currentVehicle = vehicles[selectedVehicleIndex];
                        await toggleVehicleAvailability(
                            currentUserId, currentVehicle);
                      }
                    },
                    text: replacingEndTime.isAfter(DateTime.now())
                        ? 'aanpassen'
                        : 'annuleren',
                    isRed:
                        replacingEndTime.isAfter(DateTime.now()) ? true : false,
                  ),
                ],
              ),
            ),
          );
        });
      });
}
