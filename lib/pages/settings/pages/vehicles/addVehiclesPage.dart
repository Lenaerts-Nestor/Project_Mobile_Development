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
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _licensePlateController.dispose();
    _addressController.dispose();
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
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gelieve een adres in te voeren';
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
                      // inputs bewaren =>
                      final licensePlate = _licensePlateController.text;
                      final address = _addressController.text;

                      // de user van firebase halen =>
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      final userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(firebaseUser!.uid);

                      // de inhoud van vehicles bekijken en bewaren =>
                      final userSnap = await userDoc.get();
                      final existingVehicles =
                          userSnap.get('vehicles') as List<dynamic>;

                      // Creer de vehicle met de inputs =>
                      final newVehicle = Vehicle(
                        licensePlate: licensePlate,
                        address: address,
                      );

                      // controleren als de licensePlate bestaat al =>
                      final licensePlateExists = existingVehicles
                          .any((v) => v['licensePlate'] == licensePlate);

                      if (!licensePlateExists) {
                        // voeg de vehicle in de array die al bestaat, opletten als een user de vehicles array
                        // niet in heeft zal het niet werken
                        existingVehicles.add(newVehicle.toJson());

                        // update de user document
                        await userDoc.update({'vehicles': existingVehicles});

                        // een message aangeven dat het gelukt is =>
                        //TODO: scaffoldmessenger over all zetten bij login ofzo.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('vehicle is added!')),
                        );

                        // terug naar de pagina voertuigen
                        Navigator.of(context).pop();
                      } else {
                        // als de array licensplaat bestaat
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('licensePlate bestaat al!')),
                        );
                      }
                    }
                  },
                  child: const Text('Add ur vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
