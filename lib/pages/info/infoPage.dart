// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/pages/map/functions/popUps/editing_function.dart';
import 'package:parkflow/pages/settings/pages/vehicles/set_vehicle_properties.dart';
import 'package:provider/provider.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:rxdart/rxdart.dart';

import '../map/functions/markers/marker.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late double getlatidude;
  late double getlotitude;
  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final currentUserId = userLogged.email.trim();

    final parkedUserQuery = FirebaseFirestore.instance
        .collection('markers')
        .where('parkedUserId', isEqualTo: currentUserId);

    final reservedUserQuery = FirebaseFirestore.instance
        .collection('markers')
        .where('reservedUserId', isEqualTo: currentUserId);

    return Scaffold(
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: Rx.combineLatest2(
          parkedUserQuery.snapshots(),
          reservedUserQuery.snapshots(),
          (QuerySnapshot a, QuerySnapshot b) => [a, b],
        ),
        builder: (BuildContext context,
            AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final allDocs = [
            ...snapshot.data![0].docs,
            ...snapshot.data![1].docs,
          ];

          final markers = allDocs.map((doc) {
            final markerData = doc.data() as Map<String, dynamic>;
            markerData['id'] = doc.id;
            getlatidude = markerData['latitude'];
            getlotitude = markerData['longitude'];
            return MarkerInfo.fromJson(markerData);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: markers.length,
              itemBuilder: (context, index) {
                final marker = markers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    height: marker.reservedUserId == '' ? 100 : 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black),
                      color: Colors.black12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                            isThreeLine: true,
                            title: Text(
                                'Parked Vehicle: ${marker.parkedVehicleBrand}'),
                            subtitle: marker.reservedUserId == ''
                                ? Text(
                                    'From: ${formatDateTime(marker.startTime)} - To: ${formatDateTime(marker.endTime)}')
                                : Text(
                                    'From: ${formatDateTime(marker.startTime)} - To: ${formatDateTime(marker.prevEndTime)}'),
                            trailing: SizedBox(
                              width: 50,
                              height: 50,
                              child: getSvg(marker.parkedVehicleBrand,
                                  getColor(marker.parkedVehicleColor)),
                            ),
                            onTap: userLogged.email == marker.parkedUserId &&
                                    marker.reservedUserId == "" &&
                                    marker.reservedUserId != userLogged.email
                                ? () {
                                    showPopupEdit(
                                        context, marker, userLogged.email);
                                  }
                                : () {
                                    //een messenger tonen dat je kan niet aanpassen ofzo
                                  }),
                        if (marker.reservedUserId != '')
                          ListTile(
                            isThreeLine: true,
                            title: Text(
                                'Reserved Vehicle: ${marker.reservedVehicleBrand}'),
                            subtitle: Text(
                                'From: ${formatDateTime(marker.prevEndTime)} - To: ${formatDateTime(marker.endTime)}'),
                            trailing: SizedBox(
                              width: 50,
                              height: 50,
                              child: getSvg(marker.reservedVehicleBrand,
                                  getColor(marker.reservedVehicleColor)),
                            ),
                            onTap: userLogged.email == marker.reservedUserId
                                ? () {
                                    showPopupEdit(
                                        context, marker, userLogged.email);
                                  }
                                : () {},
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String formatDateTime(DateTime dateTime) {
  final dayFormatter = DateFormat.EEEE();
  final timeFormatter = DateFormat('HH:mm');

  final day = dayFormatter.format(dateTime);
  final time = timeFormatter.format(dateTime);

  return '$day  $time';
}
