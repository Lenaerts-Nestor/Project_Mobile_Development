// ignore_for_file: file_names, library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:parkflow/components/style/designStyle.dart';
import 'package:parkflow/pages/settings/pages/profielPage.dart';
import 'package:parkflow/pages/settings/pages/vehicles/VehiclesPage.dart';
import 'package:parkflow/components/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../login-register/login/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showDefaultPage = true;
  bool _showProfielPage = false;
  bool _showVehiclesPage = false;

  void _onButton1Pressed() {
    setState(() {
      _showDefaultPage = false;
      _showProfielPage = true;
    });
  }

  void _onButton2Pressed() {
    setState(() {
      _showDefaultPage = false;
      _showVehiclesPage = true;
    });
  }

  void _onBackButtonPressed() {
    setState(() {
      _showDefaultPage = true;
      _showProfielPage = false;
      _showVehiclesPage = false; // reset the vehicles page flag as well
    });
  }

  Future<void> signOut(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _showDefaultPage
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      Center(
                        child: SvgPicture.asset(
                          'assets/logo.svg',
                          width: MediaQuery.of(context).size.width - 60,
                        ),
                      ),
                      const SizedBox(height: 100),
                      BlackButton(
                        onPressed: _onButton1Pressed,
                        text: 'Profiel',
                      ),
                      const SizedBox(height: 20),
                      BlackButton(
                        onPressed: _onButton2Pressed,
                        text: 'Voertuigen',
                      ),
                      const SizedBox(height: 20),
                      BlackButton(
                        onPressed: () => signOut(context),
                        text: 'Uitloggen',
                      ),
                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          "Parkflow\nv1.0.0",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: color5
                          )
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          _showProfielPage ? const ProfielPage() : const SizedBox.shrink(),
          _showVehiclesPage ? const VehiclesPage() : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
