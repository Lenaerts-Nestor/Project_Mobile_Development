// ignore_for_file: implementation_imports

import 'package:flutter/src/widgets/framework.dart';
import 'package:parkflow/pages/login/loginPage.dart';
import '../signup/signUpPage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool islogin = true;

  @override
  Widget build(BuildContext context) => islogin
      ? LoginPage(onClickSignUp: toggle)
      : SignUpPage(onClickedSignIn: toggle);

  void toggle() => setState(() => islogin = !islogin);
}
