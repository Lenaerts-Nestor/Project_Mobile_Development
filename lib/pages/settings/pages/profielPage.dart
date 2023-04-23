// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/user/user_service.dart';
//kijken als de user ingelogged is =>
import 'package:provider/provider.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';

class ProfielPage extends StatefulWidget {
  const ProfielPage({Key? key}) : super(key: key);

  @override
  _ProfielPageState createState() => _ProfielPageState();
}

class _ProfielPageState extends State<ProfielPage> {
  //controllers =>
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController familyNameController = TextEditingController();
  bool _isChanged = false;

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final userEmail = userLogged.email.trim();

    return Center(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              FutureBuilder<UserAccount?>(
                //methode readUser van user_service.
                future: readUserOnce(userEmail),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data;

                    if (user != null && !_isChanged) {
                      emailController.text = user.email;
                      nameController.text = user.name;
                      familyNameController.text = user.familyname;
                    }

                    return user == null
                        ? const Center(child: Text('user is leeg'))
                        : Container(
                            margin: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  _buildTextField(
                                      'Email', emailController, userEmail),
                                  _buildTextField(
                                      'Naam', nameController, userEmail),
                                  _buildTextField('FamilieNaam',
                                      familyNameController, userEmail),
                                ],
                              ),
                            ),
                          );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              if (_isChanged)
                ElevatedButton(
                  onPressed: () {
                    updateUser(userEmail);
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
      String label, TextEditingController controller, String userEmail) {
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
          hintText: userEmail,
          labelStyle: const TextStyle(fontSize: 18.0),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  //uitvinden
  Future<void> updateUser(String userEmail) async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userEmail);
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
