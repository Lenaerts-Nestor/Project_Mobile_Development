// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/pages/map/functions/streetname_function.dart';
import 'package:parkflow/pages/map/functions/markers/marker.dart';
import 'package:provider/provider.dart';
import '../markers/marker_functions.dart';

Duration selectedTime = const Duration(hours: 0, minutes: 0);

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM HHumm').format(dateTime);
}

void showPopupReserve(BuildContext context, MarkerInfo deMarker) {
  DateTime previousEndTime = deMarker.endTime;
  //nog te implementeren !!!
  String reservedVehicleId = "";
  var streetname = getStreetName(deMarker.latitude, deMarker.longitude);
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
                    //moet futurbuilder zijn. laat het zo. anders kunnen we de naam van de straat niet krijgen.
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
                            style: const TextStyle(fontSize: fontSize3),
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
                    if (deMarker.isGreenMarker) {
                      final userLogged =
                          Provider.of<UserLogged>(context, listen: false);

                      MarkerInfo newMarker = MarkerInfo(
                          latitude: deMarker.latitude,
                          longitude: deMarker.longitude,
                          parkedUserId: deMarker.parkedUserId,
                          reservedUserId: userLogged.email,
                          parkedVehicleId: deMarker.parkedVehicleId,
                          reservedVehicleId: reservedVehicleId,
                          startTime: deMarker.startTime,
                          endTime: endTime, //dit is veranderd : 
                          prevEndTime: previousEndTime,
                          isGreenMarker: false);

                      await updateMarker(newMarker, false);
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
