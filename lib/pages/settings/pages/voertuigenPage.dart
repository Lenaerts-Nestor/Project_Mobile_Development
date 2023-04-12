import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../model/user.dart';

class VoertuigenPage extends StatefulWidget {
  const VoertuigenPage({Key? key}) : super(key: key);

  @override
  State<VoertuigenPage> createState() => _voertuigenPageState();
}

class _voertuigenPageState extends State<VoertuigenPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voertuigen'),
          centerTitle: true,
        ),
        body: StreamBuilder<List<User_account>>(
          stream: readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final users = snapshot.data!;
              return ListView(children: users.map(buildUsers).toList());
            } else {
              return const Center(child: Text('no data in this account'));
            }
          },
        ));
  }

  //info lezen van database
  Stream<List<User_account>> readUsers() =>
      FirebaseFirestore.instance.collection('users').snapshots().map((event) =>
          event.docs.map((e) => User_account.fromJson(e.data())).toList());

  // testen om info af te halen van database alle users.
  Widget buildUsers(User_account user) => ListTile(
        leading: CircleAvatar(child: Text('${user.id}')),
        title: Text(user.name),
        subtitle: Text(user.email),
      );
}
