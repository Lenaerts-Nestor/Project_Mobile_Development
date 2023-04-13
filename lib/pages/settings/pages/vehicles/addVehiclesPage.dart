// ignore_for_file: file_names, library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';

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
        title: const Text('Add Vehicle'),
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
                  labelText: 'License Plate',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a license plate';
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
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final licensePlate = _licensePlateController.text;
                      final address = _addressController.text;

                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
