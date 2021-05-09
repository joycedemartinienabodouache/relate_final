//this class maps all functions form the application
//locates all the functions and where to find them

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/enum/user_state.dart';
import 'package:relate/models/call.dart';
import 'package:relate/models/message.dart';
import 'package:relate/models/user.dart';
import 'package:relate/provider/image_upload_provider.dart';
import 'package:relate/resources/authentication_methods.dart';
import 'package:relate/resources/call_methods.dart';
import 'package:relate/resources/chat_methods.dart';
import 'package:relate/resources/storage_methods.dart';

class FirebaseRepository{

  StorageMethods _storageMethods = StorageMethods();
  CallMethods _callMethods = CallMethods();
  AuthMethods _authMethods = AuthMethods();
  ChatMethods _chatMethods = ChatMethods();

  CollectionReference _userCollection ;

  //get the current user
  Future <User> getCurrentUser() => _authMethods.getCurrentUser();

  //sign into the app
  Future<UserCredential> signIn() => _authMethods.signin();

  //authenticate a user
  Future<bool> authenticateUser ( User user ) =>
      _authMethods.authenticateUser(user);

  //adds data to the database
  Future<void> addDataToDb (User user) =>
      _authMethods.addDataToDb(user);

  //responsible for signing out a user
  Future<bool> signOut() => _authMethods.signOut();

  //Fetch all the users from the database
  Future <List<Users>> fetchAllUsers (User user) =>
      _authMethods.fetchAllUsers(user);


  Future<void> addMessageToDB(Message message, Users sender, Users receiver ) =>
      _chatMethods.addMessageToDB(message, sender, receiver);

  void uploadImage({
   @required File image,
   @required String receiverId,
   @required String senderId,
   @required ImageUploadProvider imageProvider
  }) {
    return _storageMethods.uploadImage(
      image,
      receiverId,
      senderId,
      imageProvider
    );
  }
  Future <Users> getUserDetails() => _authMethods.getUserDetails();

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _authMethods.getUserStream(uid: uid);

  void setUserState({@required userId, @required UserState userState}) =>
      _authMethods.setUserState(userId: userId, userState: userState);
}