

import 'package:flutter/material.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/models/call.dart';
import 'package:relate/models/log.dart';
import 'package:relate/resources/call_methods.dart';
import 'package:relate/resources/local_db/repository/log_repository.dart';
import 'package:relate/screens/chatscreens/widgets/cached_image.dart';
import 'package:relate/utils/permissions.dart';

import '../call_screen.dart';


class PickupScreen extends StatefulWidget {

  final Call call;


  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  bool isCallMissed = true;


  //init and adds logs to the database
  addToLocalStorage({@required String callStatus}){

    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverPic: widget.call.receiverPic,
      receiverName: widget.call.receiverName,
      timeStamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);

  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(isCallMissed){
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }

    // if(isRecordingGranted = false){
    //   callMethods.releaseSecureScreen();
    //   isRecordingGranted = true;
    // }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 15),
            Text(
              widget.call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                    await callMethods.endCall(call: widget.call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallScreen(call: widget.call),
                      ),
                    )
                        : (){};
                  }

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
