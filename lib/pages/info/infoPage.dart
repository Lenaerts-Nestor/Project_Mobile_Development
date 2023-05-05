import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';

import '../map/marker.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final currentUserId = userLogged.email.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Parked Vehicles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('markers')
            .where('parkedUserId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final markers = snapshot.data!.docs.map((doc) {
            final markerData = doc.data() as Map<String, dynamic>;
            markerData['id'] = doc.id;
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
                      subtitle: Text(
                          'From: ${marker.startTime} - To: ${marker.endTime}'),
                      onTap: () {},
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
