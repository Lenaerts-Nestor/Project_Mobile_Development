// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:parkflow/model/vehicle.dart';
import 'package:provider/provider.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({Key? key}) : super(key: key);

  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();

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
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gelieve een model in te voeren';
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
                      final model = _modelController.text;
                      final brand = _brandController.text;
                      final color = _colorController.text;

                      final email =
                          Provider.of<UserLogged>(context, listen: false).email;

                      final userDoc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(email);

                      final userSnap = await userDoc.get();
                      final existingVehicles =
                          userSnap.get('vervoeren') as List<dynamic>;

                      final newVehicle = Vehicle(
                        model: model,
                        brand: brand,
                        color: color,
                      );

                      existingVehicles.add(newVehicle.toJson());
                      await userDoc.update({'vervoeren': existingVehicles});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voertuig toegevoegd!')),
                      );

                      Navigator.of(context).pop();
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
