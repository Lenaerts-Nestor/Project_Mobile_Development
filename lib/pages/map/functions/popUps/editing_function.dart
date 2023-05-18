// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:parkflow/pages/map/functions/streetname_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import '../markers/marker_functions.dart';

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
      return StreamBuilder<UserAccount>(
        stream: readUserByLive(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user != null) {
              final vehicles =
                  user.vehicles.where((v) => v.availability).toList();
              bool buttonDisabled = vehicles.isEmpty;
              if (currentVehicleId == '' && vehicles.isNotEmpty) {
                currentVehicleId = vehicles.first.model;
              }
              return StatefulBuilder(builder: (context, setState) {
                DateTime replacingEndTime =
                    deMarker.startTime.add(selectedTime);
                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: color3,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cornerRadius),
                      topRight: Radius.circular(cornerRadius),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FutureBuilder<String>(
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
                                  style: const TextStyle(fontSize: fontSize3),
                                  textAlign: TextAlign.center,
                                );
                              }
                            },
                          ),
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
                            //we bewaren de gegeven marker in een nieuwe marker met de verschil.
                            MarkerInfo newMarker = MarkerInfo(
                              latitude: deMarker.latitude,
                              longitude: deMarker.longitude,
                              parkedUserId: currentUserId,
                              reservedUserId: deMarker.reservedUserId,
                              parkedVehicleId: deMarker.parkedVehicleId,
                              reservedVehicleId: deMarker.reservedVehicleId,
                              startTime: deMarker.startTime,
                              endTime:
                                  replacingEndTime, //dit is het nieuwe verschil !
                              prevEndTime: deMarker.prevEndTime,
                              isGreenMarker: deMarker.isGreenMarker,
                            );
                            await updateMarker(newMarker, newMarker.isGreenMarker);

                            //dit zet de auto op beschikbaar
                            final selectedVehicleIndex = vehicles.indexWhere(
                                (vehicle) => vehicle.model == currentVehicleId);
                            if (selectedVehicleIndex >= 0) {
                              Vehicle currentVehicle = vehicles[selectedVehicleIndex];
                              await toggleVehicleAvailability(
                                  currentUserId, currentVehicle);
                            }
                            Navigator.pop(context);
                          },
                          text: replacingEndTime.isAfter(DateTime.now())
                              ? 'aanpassen'
                              : 'annuleren',
                          isRed: replacingEndTime.isAfter(DateTime.now()) ? true : false,
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
