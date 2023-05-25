// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/components/custom_dropdown.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:parkflow/pages/map/functions/streetname_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import 'package:parkflow/pages/settings/pages/vehicles/add_vehicles_page.dart';
import '../../../../components/custom_brand_dropdown.dart';
import '../markers/marker_functions.dart';

Duration selectedTime = const Duration(hours: 0, minutes: 0);

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM HHumm').format(dateTime);
}


/// Beschrijving: Deze methode toont een pop-up venster waarin je gegevens kunt bewerken. Het pop-up venster wordt geopend wanneer je aan bepaalde voorwaarden voldoet, 
/// zoals het hebben van een marker en een gebruikers-ID. Je kunt de [reservatietijd] zetten op bassis van je gewenste uren,.
/// Nadat je een actie hebt gekozen, worden de bijgewerkte gegevens opgeslagen en wordt het pop-up venster gesloten.
 

void showPopupReserve(
    BuildContext context, MarkerInfo deMarker, String currentUserId) {
  DateTime previousEndTime = deMarker.endTime;
  String currentVehicleId = '';
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
                currentVehicleId = vehicles.first.id;
              }
              return StatefulBuilder(builder: (context, setState) {
                DateTime endTime = previousEndTime.add(selectedTime);
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
                        const Text(
                            'Hoe lang gaat u na de reservatie parkeren?'),
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
                        Text('van ${formatDateTime(previousEndTime)}'),
                        Text('tot  ${formatDateTime(endTime)}'),
                        const SizedBox(height: verticalSpacing2),
                        //carpicker
                        vehicles.isNotEmpty
                            ? VehicleDropdown_brand(
                                vehicles: vehicles,
                                selectedVehicle: vehicles.firstWhere(
                                  (vehicle) => vehicle.id == currentVehicleId,
                                  orElse: () => vehicles.first,
                                ),
                                onChanged: (vehicle) {
                                  setState(() {
                                    currentVehicleId = vehicle?.id ?? '';
                                  });
                                },
                              )
                            : const Text('voeg een vervoer toe aan je account'),
                        const SizedBox(height: 80),
                        BlackButton(
                          text: buttonDisabled ? 'auto tekort' : 'reserveren',
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
                                  if (deMarker.isGreenMarker) {
                                    final selectedVehicleIndex =
                                        vehicles.indexWhere((vehicle) =>
                                            vehicle.id == currentVehicleId);
                                    if (selectedVehicleIndex >= 0) {
                                      final currentVehicle =
                                          vehicles[selectedVehicleIndex];

                                      MarkerInfo newMarker = MarkerInfo(
                                          latitude: deMarker.latitude,
                                          longitude: deMarker.longitude,
                                          parkedUserId: deMarker.parkedUserId,
                                          reservedUserId: currentUserId,
                                          parkedVehicleId:
                                              deMarker.parkedVehicleId,
                                          reservedVehicleId: currentVehicleId,
                                          startTime: deMarker.startTime,
                                          endTime: endTime, //dit is veranderd :
                                          prevEndTime: previousEndTime,
                                          isGreenMarker: false,
                                          parkedVehicleBrand:
                                              deMarker.parkedVehicleBrand,
                                          reservedVehicleBrand:
                                              currentVehicle.brand,
                                          parkedVehicleColor:
                                              deMarker.parkedVehicleColor,
                                          reservedVehicleColor:
                                              currentVehicle.color);
                                      await updateMarker(
                                          newMarker, newMarker.isGreenMarker);

                                      //we veranderen de auto status van beschikbaarheid:
                                      await toggleVehicleAvailability(
                                          currentUserId, currentVehicle);
                                    }
                                  }
                                  Navigator.pop(context);
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
