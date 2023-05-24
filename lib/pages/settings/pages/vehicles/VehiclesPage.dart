// ignore_for_file: prefer_const_constructors, file_names, camel_case_types, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/components/custom_appbar.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/user/user_service.dart';
import 'package:parkflow/pages/settings/pages/vehicles/set_vehicle_properties.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'add_vehicles_page.dart';
import 'package:parkflow/components/custom_button.dart';

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
        titleText: "Voertuigen",
        marginleft: 0,
        onPressed: () => widget.onBackButtonPressed?.call(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(padding),
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

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: verticalSpacing1,
                            horizontal: 0,
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(cornerRadiusTile),
                            child: Dismissible(
                              key: Key(vehicle.id),
                              confirmDismiss: (direction) async {
                                if (!vehicle.availability) {
                                  // Check if the vehicle is in use (red icon)
                                  await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "Cannot remove a vehicle that is in use."),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                  return false;
                                }

                                return true;
                              },
                              onDismissed: (direction) {
                                setState(() {
                                  _vehicles.removeAt(index);
                                });
                                deleteVehicle(user.id, vehicle);
                              },
                              background: Container(
                                color: color7,
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(cornerRadiusTile),
                                  color: color2,
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 35,
                                    child: getSvg(
                                        vehicle.brand, getColor(vehicle.color)),
                                  ),
                                  title: Text(
                                    vehicle.model,
                                    style: const TextStyle(color: color6),
                                  ),
                                  subtitle: Text(
                                    vehicle.brand,
                                    style: const TextStyle(color: color6),
                                  ),
                                  trailing: vehicle.availability
                                      ? const Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.circle,
                                          color: Colors.red,
                                        ),
                                  onTap: () {},
                                ),
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
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 30.0), // Added padding to the bottom
            child: BlackButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddVehicle()),
                );
              },
              text: 'Toevoegen',
            ),
          ),
        ],
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

Vehicle? getVehicleFromUserAccount(UserAccount user, String vehicleId) {
  // Find the vehicle in the user's vehicles list
  for (Vehicle vehicle in user.vehicles) {
    if (vehicle.id == vehicleId) {
      return vehicle;
    }
  }

  return null;
}
