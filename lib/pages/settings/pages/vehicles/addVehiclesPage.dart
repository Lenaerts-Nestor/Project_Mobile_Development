// ignore_for_file: file_names, library_private_types_in_public_api, unused_local_variable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/model/vehicle.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({Key? key}) : super(key: key);

  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _licensePlateController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voeg een voertuig toe'),
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
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Nummerplaat',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gelieve een nummerplaat in te voeren';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Merk',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gelieve een merk in te voeren';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Kleur',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gelieve een kleur in te voeren';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final licensePlate = _licensePlateController.text;
                      final brand = _brandController.text;
                      final color = _colorController.text;

                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      final userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(firebaseUser!.uid);

                      final userSnap = await userDoc.get();
                      final existingVehicles =
                          userSnap.get('Vervoeren') as List<dynamic>;

                      final newVehicle = Vehicle(
                        licensePlate: licensePlate,
                        brand: brand,
                        color: color,
                      );

                      final licensePlateExists = existingVehicles
                          .any((v) => v['NummerPlaat'] == licensePlate);

                      if (!licensePlateExists) {
                        existingVehicles.add(newVehicle.toJson());
                        await userDoc.update({'Vervoeren': existingVehicles});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voertuig toegevoegd!')),
                        );

                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Nummerplaat bestaat al!')),
                        );
                      }
                    }
                  },
                  child: const Text('Voeg uw voertuig toe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
