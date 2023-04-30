// ignore_for_file: prefer_const_constructors, file_names, camel_case_types, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:parkflow/model/vehicle.dart';

import '../../../../model/user/user_account.dart';
import 'addVehiclesPage.dart';
import 'package:parkflow/components/blackButton.dart'; //test

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  List<Vehicle> _vehicles = [];

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final userEmail = userLogged.email.trim();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<UserAccount>(
              stream: readUserByLive(userEmail),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  _vehicles = user.vehicles;

                  return ListView.builder(
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];

                      return Dismissible(
                        key: Key(vehicle.model),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            _vehicles.removeAt(index);
                          });
                          deleteVehicle(user.id, vehicle);
                        },
                        child: Padding(
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
                              title: Text(vehicle.model,
                                  style: const TextStyle(color: Colors.black)),
                              subtitle: Text(vehicle.brand,
                                  style: const TextStyle(color: Colors.black)),
                              onTap: () {},
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
        child: BlackButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddVehicle()),
            );
          },
          text: 'Voertuig toevoegen',
        ),
      ),
    );
  }

  Future<void> deleteVehicle(String userId, Vehicle vehicle) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(userId);
    await docUser.update({
      'vervoeren': FieldValue.arrayRemove([vehicle.toJson()])
    });
  }
}
