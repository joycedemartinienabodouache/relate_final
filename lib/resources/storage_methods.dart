import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:relate/models/user.dart';
import 'package:relate/provider/image_upload_provider.dart';

import 'chat_methods.dart';

class StorageMethods{

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Reference _storageReference;

  //user Class implementation
  Users user = Users();

  Future <String> uploadImageToStorage(File imageFile) async
  {

    String url;

    _storageReference = FirebaseStorage
        .instance.ref()
        .child('${DateTime
        .now()
        .millisecondsSinceEpoch
    }');
    UploadTask _storageUploadTask =
    _storageReference
        .putFile(imageFile);
    _storageUploadTask.snapshotEvents.listen((event) {
      print('task state = ${event.state}');

    }, onError: (e){
      print(_storageUploadTask.snapshot);
    });
    try {

      await _storageUploadTask;

      url = await _storageReference.getDownloadURL();

      print('Upload complete');//////////////////////////////////////////////////////

      return url;

      // _storageUploadTask.whenComplete(() {
      //   url = _storageReference.getDownloadURL();
      //   }
    } catch (e) {
      return null;
    }
  }

  void uploadImage(
       File image,
      String receiverId,
      String senderId,
      ImageUploadProvider imageUploadProvider) async {

    final ChatMethods chatMethods = ChatMethods();

    //show the circular loading progress indicator
    imageUploadProvider.setToLoading();

    //get url from the image bucket
    String url = await uploadImageToStorage(image);

    //hide loading
    imageUploadProvider.setToIdle();

    chatMethods.setImageMsg(url, receiverId, senderId);
  }


}