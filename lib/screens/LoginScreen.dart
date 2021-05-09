
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:relate/api/local_auth_api.dart';
import 'package:relate/models/user.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/screens/HomeScreen.dart';
import 'package:relate/screens/login_verification.dart';
import 'package:relate/utils/variables.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool biometricsGranted;

  bool grantRecording;

  FirebaseRepository _repository = FirebaseRepository();

  //checks if the login button has been pressed to start the loading screen
  bool isLoginPressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //
    // if(!grantRecording){
    //   secureScreen();
    // }

  }

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthorized = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Variables.blackColor,

      body: Stack(
        children: [
          Center(
            child: loginButton(),
          ),
          //if login btn is pressed, display the loading screen...
          //else display a container
          isLoginPressed
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Container(),
        ]
      ),
    );
  }

  Widget loginButton(){
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Variables.senderColor,
      child: FlatButton(
        padding: EdgeInsets.all(35),
        child: Text(
            "LOGIN",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2
          ),
        ),
        onPressed: ()=> authentication(),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future <void> _checkBiometrics() async{
    bool canCheckBiometrics = false;
    try{
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch(e){
      print(e);
    }

    if(!mounted) return;

    setState(() {
      if(canCheckBiometrics){
        _canCheckBiometrics = true;
      }
      else{
        _canCheckBiometrics = false;
      }
    });
  }

  _authorizeBiometrics() async{
    bool isAuthorized = false;
    try{
      isAuthorized = await _localAuth.authenticateWithBiometrics(
          localizedReason: "Biometrics check required to proceed");
    } on PlatformException catch(e){
      print(e);
    }

    if(!mounted) return;

    setState(() {
      if(isAuthorized){
        _isAuthorized = true;
      }
      else{
        _isAuthorized = false;
        isLoginPressed = false;
      }
    });
  }

  authentication() async{
    setState(() {
      isLoginPressed = true;
    });
    await _checkBiometrics();


    if(_canCheckBiometrics){
      await _authorizeBiometrics();

    if(_isAuthorized){
        performLogin();

        setState(() {
          isLoginPressed = false;
        });
      } else{

        setState(() {
          isLoginPressed = false;
        });
      }
    } else {
      performLogin();
    }

  }

  void performLogin() async{


      _repository.signIn().then((credential) {
        User user = credential.user;
        if( user != null){

          // _localAuth.authenticateWithBiometrics(
          //     localizedReason: "Biometrics required to continue");

          // _authorizeBiometrics();
          // if(_isAuthorized)
          authenticateUser(user);

        }
        else {
          print("There was an error");
        }
      });

  }

  void authenticateUser(User user) {

    _repository.authenticateUser(user).then((isNewUser) {

      setState(() {
        isLoginPressed = false;
      });



      if (isNewUser) {
        _repository.addDataToDb(user);
        _repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return HomeScreen();
              }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return HomeScreen();
              // return HomeScreen();
            }));
      }
    });
  }

}
