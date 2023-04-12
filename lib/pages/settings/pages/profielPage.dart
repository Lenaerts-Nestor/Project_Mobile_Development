import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfielPage extends StatefulWidget {
  const ProfielPage({Key? key}) : super(key: key);

  @override
  _ProfielPageState createState() => _ProfielPageState();
}

class _ProfielPageState extends State<ProfielPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Center(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: userDocRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final userDoc = snapshot.data!;
                  final userId = userDoc.id;
                  return Text(userId);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
