// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkflow/components/custom_brand_dropdown.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/pages/map/functions/streetname_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import '../../../../model/user/user_service.dart';
import '../../../settings/pages/vehicles/add_vehicles_page.dart';
import '../markers/marker_functions.dart';

Duration selectedTime = const Duration(hours: 0, minutes: 0);

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM HHumm').format(dateTime);
}

//naam van de straat krijgen =>
void showPopupPark(
    BuildContext context, LatLng latLng, String currentUserId) async {
  late String currentVehicleId = '';
  //naam van straat =>
  var streetname = getStreetName(latLng.latitude, latLng.longitude);

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
                DateTime endTime = DateTime.now().add(selectedTime);
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
                        Stack(
                          alignment: Alignment.center,
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
                                    return const Text(
                                        'Error getting street name');
                                  } else {
                                    return Text(
                                      snapshot.data ?? 'Unknown',
                                      style:
                                          const TextStyle(fontSize: fontSize3),
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                iconSize: iconSizeNav,
                              ),
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
                                          vehicle.id == currentVehicleId);
                                  if (selectedVehicleIndex >= 0) {
                                    final selectedVehicle2 =
                                        vehicles[selectedVehicleIndex];

                                    //we creeren een variabele met dat info:
                                    MarkerInfo newMarker = MarkerInfo(
                                        latitude: latLng.latitude,
                                        longitude: latLng.longitude,
                                        parkedUserId: currentUserId,
                                        reservedUserId: '',
                                        parkedVehicleId: currentVehicleId,
                                        reservedVehicleId: '',
                                        startTime: DateTime.now(),
                                        endTime: endTime,
                                        prevEndTime: DateTime.now(),
                                        isGreenMarker: true,
                                        parkedVehicleBrand:
                                            selectedVehicle2.brand,
                                        reservedVehicleBrand: '',
                                        parkedVehicleColor:
                                            selectedVehicle2.color,
                                        reservedVehicleColor: '');

                                    //we bewaren de nieuwe marker:
                                    await saveMarkerToDatabase(newMarker);

                                    //we veranderen de auto status van beschikbaarheid:
                                    await toggleVehicleAvailability(
                                        currentUserId, selectedVehicle2);
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
