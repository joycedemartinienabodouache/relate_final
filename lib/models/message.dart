import 'package:cloud_firestore/cloud_firestore.dart';

class Message{

  String  senderID,
          receiverID,
          type,
          message,
          photoURL;

  Timestamp timestamp;

  Message({this.message,
            this.receiverID,
            this.senderID,
            this.timestamp,
            this.type});

  Message.imageMessage({
    this.senderID,
    this.receiverID,
    this.type,
    this.timestamp,
    this.message,
    this.photoURL
});

//access the firestore dB and retrieve data to store in a map
  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderID;
    map['receiverId'] = this.receiverID;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  // send data to the database from a map object
  Message.fromMap(Map<String, dynamic> map) {
    this.senderID = map['senderId'];
    this.receiverID = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photoURL = map ['photoUrl'];
  }

  Map toImageMap(){
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderID;
    map['receiverId'] = this.receiverID;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoURL;
    return map;
  }

}