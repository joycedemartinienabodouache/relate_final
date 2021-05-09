
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/models/call.dart';

class CallMethods{

  final CollectionReference callCollection =
  FirebaseFirestore.instance.collection(CALL_COLLECTION);

  //deny screen recording operations
  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  //grant screen recording operations
  Future <void> releaseSecureScreen () async{
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  Stream <DocumentSnapshot> callStream({String uid}) =>
      callCollection.doc(uid).snapshots();

  Future<bool> makeCall({Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.doc(call.callerId).set(hasDialledMap);
      await callCollection.doc(call.receiverId).set(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      //delete the call from firestore database
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}
