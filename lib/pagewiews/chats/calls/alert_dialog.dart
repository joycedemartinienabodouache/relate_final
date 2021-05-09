import 'package:flutter/material.dart';
import 'package:relate/models/user.dart';
import 'package:relate/utils/call_utillities.dart';
import 'package:relate/utils/permissions.dart';

class AlertBox extends StatelessWidget {
  final Users sender;
  final Users receiver;


  const AlertBox(
      {Key key,
      @required this.sender,
      @required this.receiver,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("Do you want to allow recording from your contact?"),
      title: Text("Allow recording"),
      elevation: 24,
      actions: [
        MaterialButton(
            child: Text("Deny"),
            onPressed: () async {
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: receiver,

                      ///
                      isRecordingGranted: false,
                      context: context,
                    )
                  : {};

            }),
        MaterialButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        MaterialButton(
            child: Text("Allow"),
            onPressed: () async {
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: receiver,

                      ///
                      isRecordingGranted: true,
                      context: context,
                    )
                  : {};
            }),
      ],
    );
  }

//   Widget denyButton = MaterialButton(
//       child: Text("Deny"),
//       onPressed: (){
//         print("Recording denied");
//       }
//   );
//   Widget cancelButton = MaterialButton(
//       child: Text("Cancel"),
//       onPressed: (){
//       }
//   );
//   Widget allowButton = MaterialButton(
//       child: Text("Allow"),
//       onPressed: (){
//         print("Recording Allowed");
//       }
//   );
}
