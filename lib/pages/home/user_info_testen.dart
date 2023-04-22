import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/model/user/user_account.dart';
import 'package:parkflow/model/user/user_logged_controller.dart';
import 'package:provider/provider.dart';

//dit is een test file om dingens te testen.

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final userEmail = userLogged.email.trim();

    return Scaffold(
        appBar: AppBar(
          title: const Text('user Informatie'),
        ),
        body: FutureBuilder<UserAccount?>(
            future: readUser(userEmail),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data;

                return user == null
                    ? const Center(child: Text('user is leeg'))
                    : Container(
                        margin: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(children: [
                            Text(user.email),
                            Text(user.familyname)
                          ]),
                        ),
                      );
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}

Future<UserAccount?> readUser(String idEmail) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(idEmail);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    return UserAccount.fromJson(snapshot.data()!);
  }
  return null;
}
