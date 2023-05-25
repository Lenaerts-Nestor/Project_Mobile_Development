// ignore_for_file: file_names

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:parkflow/components/custom_appbar.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/pages/map/functions/popUps/editing_function.dart';
import 'package:parkflow/pages/settings/pages/vehicles/set_vehicle_properties.dart';
import 'package:provider/provider.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';

import '../map/functions/markers/marker.dart';
import '../map/functions/markers/marker_functions.dart';


///Beschrijving: pagina waar ik de [reservatie], [parkeringen] zie, ik kan ook hier in deze file de [editing] function aanroepen,
///op basis van de [listTile] met de gewenste vervoer/vehicle
class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late double getlatidude;
  late double getlotitude;
  late Stream<QuerySnapshot> parkedUserStream;
  late Stream<QuerySnapshot> reservedUserStream;
  late Timer _timer;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    final userLogged = Provider.of<UserLogged>(context, listen: false);
    final currentUserId = userLogged.email.trim();

    parkedUserStream = FirebaseFirestore.instance
        .collection('markers')
        .where('parkedUserId', isEqualTo: currentUserId)
        .snapshots();

    reservedUserStream = FirebaseFirestore.instance
        .collection('markers')
        .where('reservedUserId', isEqualTo: currentUserId)
        .snapshots();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      updateMarkerState();
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    getMarkersFromDatabase(context, (List<Marker> markers) {
      setState(() {
        _markers = markers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final currentUserId = userLogged.email.trim();

    return Scaffold(
      appBar: MyAppBar(
        backgroundcolor: color4,
        titleText: "Spots",
        marginleft: 0,
        onPressed: () {},
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: parkedUserStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> parkedSnapshot) {
          if (parkedSnapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (parkedSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return StreamBuilder<QuerySnapshot>(
            stream: reservedUserStream,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> reservedSnapshot) {
              if (reservedSnapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (reservedSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final allDocs = [
                ...parkedSnapshot.data!.docs,
                ...reservedSnapshot.data!.docs,
              ];

              final markers = allDocs.map((doc) {
                final markerData = doc.data() as Map<String, dynamic>;
                markerData['id'] = doc.id;
                getlatidude = markerData['latitude'];
                getlotitude = markerData['longitude'];
                return MarkerInfo.fromJson(markerData);
              }).toList();

              if (markers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: Text(
                      'U heeft momenteel geen voertuigen in gebruik. U kunt parkeren en reserveren op de kaart.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(padding),
                child: ListView.builder(
                  itemCount: markers.length,
                  itemBuilder: (context, index) {
                    final marker = markers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: verticalSpacing1),
                      child: Container(
                        height: marker.reservedUserId == '' ? 100 : 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.black12),
                          color: color2,
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
                                      marker.reservedUserId == '' &&
                                      marker.reservedUserId != userLogged.email
                                  ? () {
                                      showPopupEdit(
                                          context, marker, userLogged.email);
                                    }
                                  : () {
                                      // Show a message that you cannot make changes
                                    },
                            ),
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
