// ignore_for_file: prefer_const_constructors, file_names, camel_case_types, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/src/picture_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parkflow/components/custom_appbar.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:parkflow/pages/settings/pages/vehicles/set_vehicle_properties.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:parkflow/model/vehicle.dart';

import '../../../../model/user/user_account.dart';
import 'add_vehicles_page.dart';
import 'package:parkflow/components/custom_button.dart'; //test

class VehiclesPage extends StatefulWidget {
  final Function? onBackButtonPressed;
  const VehiclesPage({Key? key, this.onBackButtonPressed}) : super(key: key);

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
      appBar: MyAppBar(
        backgroundcolor: color4,
        icon: Icons.arrow_back,
        titleText: "Vervoeren",
        marginleft: 60,
        onPressed: () => widget.onBackButtonPressed?.call(),
      ),
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
                              leading: getSvg(
                                vehicle.brand,
                                getColor(vehicle.color),
                              ),
                              title: Text(vehicle.model,
                                  style: const TextStyle(color: Colors.black)),
                              subtitle: Text(vehicle.brand,
                                  style: const TextStyle(color: Colors.black)),
                              trailing: vehicle.availability
                                  ? Column(
                                      children: const [
                                        Text('vrij'),
                                        Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                        )
                                      ],
                                    )
                                  : Column(
                                      children: const [
                                        Text('vrij'),
                                        Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                        )
                                      ],
                                    ),
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
