import 'dart:math';

import 'package:flutter/material.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/models/call.dart';
import 'package:relate/models/log.dart';
import 'package:relate/models/user.dart';
import 'package:relate/resources/call_methods.dart';
import 'package:relate/resources/local_db/repository/log_repository.dart';
import 'package:relate/screens/callscreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({Users from, Users to, isRecordingGranted, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,

      isRecordingGranted: isRecordingGranted,
      channelId: Random().nextInt(1000).toString(),
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timeStamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {

       //add a call to the database
      LogRepository.addLogs(log);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}