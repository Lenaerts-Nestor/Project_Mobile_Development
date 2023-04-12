import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../model/user.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _voertuigenPageState();
}

class _voertuigenPageState extends State<VehiclesPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voertuigen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<User_account>>(
              stream: readUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  late final users = snapshot.data!;
                  return ListView(
                    children: users.map(buildUsers).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('error ${snapshot.error}'),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 5),
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Add vehicles'),
            ),
          ),
        ],
      ),
    );
  }

  //info lezen van database
  Stream<List<User_account>> readUsers() =>
      FirebaseFirestore.instance.collection('users').snapshots().map((event) =>
          event.docs.map((e) => User_account.fromJson(e.data())).toList());

  // testen om info af te halen van database alle users.
  Widget buildUsers(User_account user) => ListTile(
        leading: CircleAvatar(child: Text('${user.familiename}')),
        title: Text(user.name),
        subtitle: Text(user.email),
      );
}
