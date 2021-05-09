import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LoginVerification extends StatefulWidget {
  @override
  _LoginVerificationState createState() => _LoginVerificationState();
}

class _LoginVerificationState extends State<LoginVerification> {

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.authenticateWithBiometrics(
        localizedReason: "Biometrics required"
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
