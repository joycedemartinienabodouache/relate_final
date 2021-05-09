import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/models/contact.dart';
import 'package:relate/models/message.dart';
import 'package:relate/models/user.dart';

class ChatMethods{

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection = firestore.collection(MESSAGES_COLLECTION);
  final CollectionReference _userCollection = firestore.collection(USERS_COLLECTION);

  Future<void> addMessageToDB(Message message, Users sender, Users receiver) async{

    var map = message.toMap();

    await _messageCollection
        .doc(message.senderID)
        .collection(message.receiverID)
        .add(map);

    addToContacts(senderId: message.senderID, receiverId: message.receiverID);

    return await _messageCollection
        .doc(message.receiverID)
        .collection(message.senderID)
        .add(map);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection
          .doc(of)
          .collection(CONTACTS_COLLECTION)
          .doc(forContact);

  addToContacts({String senderId, String receiverId}) async{
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);

  }

  Future<void> addToSenderContacts(
      String senderId,
      String receiverId,
      currentTime,
      ) async {
    DocumentSnapshot senderSnapshot =
    await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

    Future<void> addToReceiverContacts(
        String senderId,
        String receiverId,
        currentTime,
        ) async {
      DocumentSnapshot receiverSnapshot =
      await getContactsDocument(of: receiverId, forContact: senderId).get();

      if (!receiverSnapshot.exists) {
        //does not exists
        Contact senderContact = Contact(
          uid: senderId,
          addedOn: currentTime,
        );

        var senderMap = senderContact.toMap(senderContact);

        await getContactsDocument(of: receiverId, forContact: senderId)
            .set(senderMap);
      }
    }


    void setImageMsg(String url, String receiverId, String senderId) async {
      Message message = Message.imageMessage(
        message: "IMAGE",
        senderID: senderId,
        receiverID: receiverId,
        photoURL: url,
        timestamp: Timestamp.now(),
        type: 'image',

      );

      var map = message.toImageMap();


      await _messageCollection
          .doc(message.senderID)
          .collection(message.receiverID)
          .add(map);

      await _messageCollection
          .doc(message.receiverID)
          .collection(message.senderID)
          .add(map);
    }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
      .doc(userId)
      .collection(CONTACTS_COLLECTION)
      .snapshots();

  void deleteMessage({@required String senderID, @required receiverID, @required Message message}) async{
    await _messageCollection
        .doc(senderID)
        .collection(receiverID)
        .doc(message.messageID)
        .delete();
  }

  Stream<QuerySnapshot> fetchOrderedContacts({String userId}) => _userCollection
      .doc(userId)
      .collection(CONTACTS_COLLECTION)
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();
}