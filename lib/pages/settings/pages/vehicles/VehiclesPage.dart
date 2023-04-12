// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../model/user.dart';
import 'addVehiclesPage.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _voertuigenPageState();
}

class _voertuigenPageState extends State<VehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voertuigen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: readUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  late final user = snapshot.data;

                  return user == null
                      ? Center(child: Text('user is empty'))
                      : buildUsers(user);
                } else {
                  return const Center(child: Text('no data yet'));
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 5),
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddVehicle()),
                );
              },
              child: const Text('Add vehicles'),
            ),
          ),
        ],
      ),
    );
  }

  //lees alle users in collectie 'users'
  Stream<List<User_account>> readUsers() =>
      FirebaseFirestore.instance.collection('users').snapshots().map((event) =>
          event.docs.map((e) => User_account.fromJson(e.data())).toList());

  //lees één user.
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

  // testen om info af te halen van database alle users.
  Widget buildUsers(User_account user) => Container(
        color: Colors.black38,
        child: ListTile(
          onTap: () {},
          leading: Icon(Icons.directions_car_filled, color: Colors.white),
          title: Text(user.name, style: TextStyle(color: Colors.white)),
          subtitle: Text(user.email, style: TextStyle(color: Colors.white)),
        ),
      );
}
