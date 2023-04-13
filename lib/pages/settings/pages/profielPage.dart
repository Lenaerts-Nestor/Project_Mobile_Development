// ignore_for_file: file_names, library_private_types_in_public_api, avoid_unnecessary_containers, unused_local_variable

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
                  if (snapshot.hasData) {
                    final user = snapshot.data;

                    return user == null
                        ? const Center(child: Text('user is empty'))
                        : Container(
                            child: Center(
                              child: Column(
                                children: [Text(user.email)],
                              ),
                            ),
                          );
                  } else {
                    return const Center(child: Text('no data yet'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User_account?> readUser() async {
    final userId = FirebaseAuth.instance.currentUser!;
    final docUser = FirebaseFirestore.instance
        .collection('users')
        .doc('');
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User_account.fromJson(snapshot.data()!);
    }
    return null;
  }
}
