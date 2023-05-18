// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parkflow/components/custom_appbar.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/user/user_service.dart';
//kijken als de user ingelogged is =>
import 'package:provider/provider.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';

class ProfielPage extends StatefulWidget {
  final Function? onBackButtonPressed;
  const ProfielPage({Key? key, this.onBackButtonPressed}) : super(key: key);

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
        appBar: MyAppBar(
          backgroundcolor: color4,
          icon: Icons.arrow_back,
          titleText: "Profiel",
          marginleft: 90,
          onPressed: () => widget.onBackButtonPressed?.call(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              children: [
                const SizedBox(height: negativeSizePP / 4 * 3),
                //Dit zou verbeterd moeten worden
                SvgPicture.asset('assets/usericon.svg',
                    width: MediaQuery.of(context).size.width - negativeSizePP, color: color6),
                const SizedBox(height: negativeSizePP / 4 * 1),
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
                              margin: const EdgeInsets.all(1),
                              child: Center(
                                child: Column(
                                  children: [
                                    _buildTextField(
                                        'Email', emailController, userEmail),
                                    _buildTextField(
                                        'Voornaam', nameController, userEmail),
                                    _buildTextField('Familienaam',
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
                    child: const Text('Wijzigen'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: verticalSpacing1),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            _isChanged = true;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(fontSize: fontSize2),
          border: const UnderlineInputBorder(),
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
