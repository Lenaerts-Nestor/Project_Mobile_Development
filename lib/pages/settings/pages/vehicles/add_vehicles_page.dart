// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/components/custom_appbar.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:parkflow/components/custom_dropdown.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
/// Beschrijving: pagina waar ik vervoeren kan toevoegen op basis van de 3 dropdowns dat we hebben in de file parkflow/lib/components.
/// zet de gecreerde vervoeren in de database enzovoort.
class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  AddVehicleState createState() => AddVehicleState();
}

class AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _uuid = const Uuid();

  late String valueOfModel;
  late String valueOfBrand;
  late String valueOfColor;

  @override
  void initState() {
    super.initState();
    valueOfBrand = brandList.first;
    valueOfModel = modelList[valueOfBrand]![0];
    valueOfColor = colorList.first;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        backgroundcolor: color4,
        icon: Icons.arrow_back,
        titleText: "Nieuw voertuig",
        marginleft: 0,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VehicleDropdown(
                  items: brandList,
                  value: valueOfBrand,
                  onChanged: (newValue) {
                    if (newValue == null) {
                      return;
                    }
                    setState(() {
                      valueOfBrand = newValue;
                      valueOfModel = modelList[valueOfBrand]![0];
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VehicleDropdown(
                  items: modelList[valueOfBrand]!,
                  value: valueOfModel,
                  onChanged: (newValue) {
                    if (newValue == null) {
                      return;
                    }
                    setState(() {
                      valueOfModel = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VehicleDropdown(
                  items: colorList,
                  value: valueOfColor,
                  onChanged: (newValue) {
                    if (newValue == null) {
                      return;
                    }
                    setState(() {
                      valueOfColor = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 50.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 60,
                width: double.infinity,
                child: BlackButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final model = valueOfModel;
                      final brand = valueOfBrand;
                      final color = valueOfColor;
                      final vehicleId = _uuid.v4();
                      final email =
                          Provider.of<UserLogged>(context, listen: false).email;

                      final userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(email);
                      final userSnap = await userDoc.get();
                      final existingVehicles =
                          userSnap.get('vervoeren') as List<dynamic>;

                      final newVehicle = Vehicle(
                        id: vehicleId,
                        model: model,
                        brand: brand,
                        color: color,
                        availability: true,
                      );
                      existingVehicles.add(newVehicle.toJson());
                      await userDoc.update({'vervoeren': existingVehicles});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voertuig toegevoegd!')),
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  text: 'Toevoegen',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
