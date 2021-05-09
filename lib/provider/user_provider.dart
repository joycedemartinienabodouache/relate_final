import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:relate/models/user.dart';
import 'package:relate/resources/firebase_repository.dart';

class UserProvider with ChangeNotifier {
  Users _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  Users get getUser => _user;

  Future <void> refreshUser() async {
    Users user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }

}