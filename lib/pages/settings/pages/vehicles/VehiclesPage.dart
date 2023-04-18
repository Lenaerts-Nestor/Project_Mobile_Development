// ignore_for_file: prefer_const_constructors, file_names, camel_case_types, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/model/vehicle.dart';

import '../../../../model/user.dart';
import 'addVehiclesPage.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<User_account>(
              stream: readUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;

                  return ListView.builder(
                    itemCount: user.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = user.vehicles[index];

                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: 62.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.black),
                            color: Colors.black12,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.directions_car_filled,
                                color: Colors.black),
                            title: Text(vehicle.licensePlate,
                                style: const TextStyle(color: Colors.black)),
                            subtitle: Text(vehicle.brand,
                                style: const TextStyle(color: Colors.black)),
                            onTap: () {},
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteVehicle(user.id, vehicle);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 55,
        margin: EdgeInsets.only(bottom: 5),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddVehicle()),
            );
          },
          child: const Text('Voertuig toevoegen'),
        ),
      ),
    );
  }

  Stream<User_account> readUser() {
    final userId = FirebaseAuth.instance.currentUser!;
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userId.uid);
    return docUser.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User_account.fromJson(snapshot.data()!);
      } else {
        return User_account(
          id: userId.uid,
          familiename: '',
          name: '',
          email: '',
          wachtwoord: '',
          vehicles: [],
        );
      }
    });
  }

  Future<void> deleteVehicle(String userId, Vehicle vehicle) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(userId);
    await docUser.update({
      'Vervoeren': FieldValue.arrayRemove([vehicle.toJson()])
    });
  }
}
