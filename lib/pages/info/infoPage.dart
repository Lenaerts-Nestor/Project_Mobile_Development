import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/pages/map/functions/popUps/editing_function.dart';
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
      appBar: AppBar(
        title: const Text('My Parked Vehicles'),
      ),
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
                    height: 62.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black),
                      color: Colors.black12,
                    ),
                    child: ListTile(
                      title: Text('Parked Vehicle: ${marker.parkedVehicleId}'),
                      subtitle: marker.reservedUserId == ''
                          ? Text(
                              'From: ${marker.startTime} - To: ${marker.endTime}')
                          : Text(
                              'From: ${marker.startTime} - To: ${marker.prevEndTime}'),
                      onTap: () {
                        showPopupEdit(context, marker, userLogged.email);
                      },
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
