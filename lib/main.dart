
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/provider/image_upload_provider.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/screens/HomeScreen.dart';
import 'package:relate/screens/LoginScreen.dart';
import 'package:relate/screens/SearchScreen.dart';
import 'package:relate/screens/login_verification.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseRepository _repository = FirebaseRepository();


  @override
  Widget build(BuildContext context) {
/*
Test firestore db connectivity by adding a single item into the db

    FirebaseFirestore.instance.collection("users").doc().set({
      "name": "Jake ElevEn"
    }

    );
 */

  /*sign out a currently logged user
  *
  * _repository.signOut();
  *
  * */

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        title: "Relate",
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/SearchScreen': (context) => SearchScreen(),
        },
        home:
        // LoginVerification()
        FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<User> snapshot){
            if(snapshot.hasData){
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        )
      ),
    );
  }
}
