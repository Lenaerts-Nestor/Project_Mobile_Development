// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parkflow/firebase_options.dart';
import 'package:parkflow/pages/login-register/login/login_page.dart';
import 'model/user/user_logged_controller.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MainApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserLogged(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'parkflow',
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
