import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/enum/user_state.dart';
import 'package:relate/models/user.dart';
import 'package:relate/utils/utilities.dart';

class AuthMethods{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Reference _storageReference;

  static final CollectionReference _userCollection =
  firestore.collection(USERS_COLLECTION);

  Future <User> getCurrentUser() async{
    User currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  Future <Users> getUserDetails() async {

    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
    await _userCollection.doc(currentUser.uid).get();
    return Users.fromMap(documentSnapshot.data());
  }

  Future<Users> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
      await _userCollection.doc(id).get();
      return Users.fromMap(documentSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future <UserCredential> signin() async{
    GoogleSignInAccount _signinAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signinAuthentication =
    await _signinAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: _signinAuthentication.idToken,
        accessToken: _signinAuthentication.accessToken
    );

    return  await _auth.signInWithCredential(credential);
  }

  Future<bool> authenticateUser (User user) async{

    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;
    // if a user is already registered, the length of the list
    //will be greater than 0;
    return docs.length == 0? true : false;

  }

  Future<void> addDataToDb(User currentUser) async {

    String username = Utils.getUsername(currentUser.email);

    Users user = Users(
        uid: currentUser.uid,
        name: currentUser.displayName,
        email: currentUser.email,
        profilePhoto: currentUser.photoURL,
        username: username
    );

    firestore.collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user));
  }

  //disconnect from the current account
  Future<void> signOut() async{
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future <List<Users>> fetchAllUsers(User user) async{
    List <Users> userList = List<Users>();
    QuerySnapshot querySnapshot =
    await firestore.collection(USERS_COLLECTION).get(); // current user is passed to the fetching method
    // to ensure that the current user does not find himself in the search

    for(var i = 0; i < querySnapshot.docs.length; i++ ){
      if(querySnapshot.docs[i].id != user.uid){
        userList.add(Users.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return userList;
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.doc(uid).snapshots();


}