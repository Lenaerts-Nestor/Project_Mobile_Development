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
  BuildContext context,
  MarkerInfo deMarker,
  String currentUserId,
) {
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
                  user.vehicles.where((v) => !v.availability).toList();
              if (currentVehicleId == '' && vehicles.isNotEmpty) {
                currentVehicleId = vehicles.first.id;
              }
              return StatefulBuilder(builder: (context, setState) {
                DateTime replacingEndTime = DateTime(0);
                if (deMarker.parkedUserId == currentUserId) {
                  replacingEndTime = deMarker.startTime.add(selectedTime);
                } else if (deMarker.reservedUserId == currentUserId) {
                  replacingEndTime = deMarker.prevEndTime.add(selectedTime);
                }
                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: color3,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cornerRadiusButton),
                      topRight: Radius.circular(cornerRadiusButton),
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
                        if (deMarker.parkedUserId == currentUserId)
                          Text('van ${formatDateTime(deMarker.startTime)}'),
                        if (deMarker.reservedUserId == currentUserId)
                          Text('van ${formatDateTime(deMarker.prevEndTime)}'),
                        Text(
                          'tot ${formatDateTime(deMarker.endTime)}',
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough),
                        ),
                        Text('tot ${formatDateTime(replacingEndTime)}'),
                        const SizedBox(height: verticalSpacing2),
                        BlackButton(
                          onPressed: () async {
                            MarkerInfo newMarker;
                            //annuleren
                            if (deMarker.reservedUserId == currentUserId &&
                                replacingEndTime.isBefore(deMarker.prevEndTime
                                    .add(const Duration(seconds: 60)))) {
                              newMarker = MarkerInfo(
                                latitude: deMarker.latitude,
                                longitude: deMarker.longitude,
                                parkedUserId: deMarker.parkedUserId,
                                reservedUserId: "",
                                parkedVehicleId: deMarker.parkedVehicleId,
                                reservedVehicleId: "",
                                startTime: deMarker.startTime,
                                endTime: replacingEndTime,
                                prevEndTime: deMarker.prevEndTime,
                                isGreenMarker: true,
                                parkedVehicleBrand: deMarker.parkedVehicleBrand,
                                reservedVehicleBrand: "",
                              );

                              //dit zet de auto op beschikbaar
                              final selectedVehicleIndex = vehicles.indexWhere(
                                (vehicle) => vehicle.id == currentVehicleId,
                              );
                              if (selectedVehicleIndex >= 0) {
                                Vehicle currentVehicle =
                                    vehicles[selectedVehicleIndex];
                                await toggleVehicleAvailability(
                                    currentUserId, currentVehicle);
                              } //aanpassen
                            } else {
                              newMarker = MarkerInfo(
                                latitude: deMarker.latitude,
                                longitude: deMarker.longitude,
                                parkedUserId: deMarker.parkedUserId,
                                reservedUserId: deMarker.reservedUserId,
                                parkedVehicleId: deMarker.parkedVehicleId,
                                reservedVehicleId: deMarker.reservedVehicleId,
                                startTime: deMarker.startTime,
                                endTime: replacingEndTime,
                                prevEndTime: deMarker.prevEndTime,
                                isGreenMarker: deMarker.isGreenMarker,
                                parkedVehicleBrand: deMarker.parkedVehicleBrand,
                                reservedVehicleBrand: "",
                              );
                            }
                            //we bewaren de gegeven marker in een nieuwe marker met de verschil.
                            await updateMarker(
                                newMarker, newMarker.isGreenMarker);
                            Navigator.pop(context);
                          },
                          text: (deMarker.parkedUserId == currentUserId &&
                                      replacingEndTime
                                          .isAfter(deMarker.startTime)) ||
                                  (deMarker.reservedUserId == currentUserId &&
                                      replacingEndTime
                                          .isAfter(deMarker.prevEndTime))
                              ? 'aanpassen'
                              : 'annuleren',
                          isRed: (deMarker.parkedUserId == currentUserId &&
                                  replacingEndTime
                                      .isAfter(deMarker.startTime)) ||
                              (deMarker.reservedUserId == currentUserId &&
                                  replacingEndTime
                                      .isAfter(deMarker.prevEndTime)),
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
