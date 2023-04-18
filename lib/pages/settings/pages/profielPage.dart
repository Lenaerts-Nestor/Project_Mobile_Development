// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user.dart';

class ProfielPage extends StatefulWidget {
  const ProfielPage({Key? key}) : super(key: key);

  @override
  _ProfielPageState createState() => _ProfielPageState();
}

class _ProfielPageState extends State<ProfielPage> {
  //controllers =>
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  bool _isChanged = false;
  //bewaren de initial data, want anders krijgen we rare bugs
  String? initialEmail;
  String? initialName;
  String? initialFamilyName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              FutureBuilder<User_account?>(
                future: readUser(),
                builder: (context, snapshot) {
                  //controls met if =>
                  if (snapshot.hasData) {
                    final user = snapshot.data;
                    //als het leeg is zetten we '' om errors te voorkomen
                    if (initialEmail == null) {
                      initialEmail = user?.email;
                      emailController.text = initialEmail ?? '';
                    }
                    if (initialName == null) {
                      initialName = user?.name;
                      nameController.text = initialName ?? '';
                    }
                    if (initialFamilyName == null) {
                      initialFamilyName = user?.familiename;
                      familyNameController.text = initialFamilyName ?? '';
                    }
                    //kijken als de user leeg is, anders =>
                    return user == null
                        ? const Center(child: Text('user is empty'))
                        : Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(children: [
                                _buildTextField(
                                    'Email', emailController, user.id),
                                _buildTextField(
                                    'Naam', nameController, user.id),
                                _buildTextField('FamilieNaam',
                                    familyNameController, user.id),
                              ]),
                            ),
                          );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              //om de knop te laten zichtbaar maken, futuristische haha
              if (_isChanged)
                ElevatedButton(
                  onPressed: () {
                    updateUser();
                  },
                  child: const Text('Update Profile'),
                )
            ],
          ),
        ),
      ),
    );
  }

  //creert de Textfield =>
  Widget _buildTextField(
      String label, TextEditingController controller, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            _isChanged = true;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 18.0),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  //lees de user =>
  Future<User_account?> readUser() async {
    final userId = FirebaseAuth.instance.currentUser!;
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userId.uid);
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User_account.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<void> updateUser() async {
    final userId = FirebaseAuth.instance.currentUser!;
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userId.uid);
    await docUser.update({
      'Email': emailController.text,
      'Naam': nameController.text,
      'FamilieNaam': familyNameController.text,
    });

    setState(() {
      _isChanged = false;
    });
  }
}
