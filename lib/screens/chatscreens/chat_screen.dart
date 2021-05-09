import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:relate/api/speech_to_text_api.dart';
import 'package:relate/api/translation_api.dart';
import 'package:relate/consts/strings.dart';
import 'package:relate/enum/view_state.dart';
import 'package:relate/models/message.dart';
import 'package:relate/models/user.dart';
import 'package:relate/pagewiews/chats/calls/alert_dialog.dart';
import 'package:relate/provider/image_upload_provider.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/utils/call_utillities.dart';
import 'package:relate/utils/permissions.dart';
import 'package:relate/utils/utilities.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_appbar.dart';
import 'package:relate/widgets/custom_tile.dart';

import 'widgets/cached_image.dart';

class ChatScreen extends StatefulWidget {
  final Users receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String translatedMessage;
  Users sender;

  String _currentUserID;
  bool isWriting = false;
  TextEditingController textFieldController = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  ScrollController _listScrollController = ScrollController();

  ImageUploadProvider _imageUploadProvider;

  bool grantRecording = true;

  bool isListening = false;
  // String text = "Press the button and start recording";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _repository.getCurrentUser().then((user) {
      _currentUserID = user.uid;
      setState(() {
        sender = Users(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoURL,
          username: user.displayName,
          email: user.email,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewState
        currentState; // track the current state of the currently logged user (online, waiting or offline)
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    currentState = _imageUploadProvider.getViewState;
    return Scaffold(
      backgroundColor: Variables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: [
          Flexible(
            child: messageList(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(),
                )
              : Container(),
          chatControls(),
        ],
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserID)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          controller: _listScrollController,
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return GestureDetector(
      onLongPress: (){
        ////////////////////////////////////////////////////////////////////delete message from the db
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Container(
            alignment: _message.senderID == _currentUserID
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: _message.senderID == _currentUserID
                ? senderLayout(_message)
                : receiverLayout(_message)),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              0.65), //ensure that the message written does not extend a certain size
      decoration: BoxDecoration(
        color: Variables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  translate(String message) async {
    if (message != null) {
      await TranslationApi.translate(message, "auto", "fr").then((value) {
        setState(() {
          translatedMessage = value;
        });
      });
    } else {
      setState(() {
        translatedMessage = "Could not translate the chat";
      });
      print(translatedMessage);
    }
  }

  getMessage(Message message) {
    if (message.message != null) {
      translate(message.message);
    } else {
      translatedMessage = "could not translate the message";
    }

    // setState(() {
    //   translatedMessage =  TranslationApi.translate(message.message, "auto", "fr") as String;
    //   print(translatedMessage);
    // });

    return message.type != MESSAGE_TYPE_IMAGE
        ? Column(children: [
            Text(
              message.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),

            ///translated text
            Text(
              message.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ])
        : message.photoURL != null
            ? CachedImage(
                message.photoURL,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text("unable to get the image");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Variables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(padding: EdgeInsets.all(10), child: getMessage(message)),
    );
  }

  Widget chatControls() {
    // setWritingTo(bool val) {
    //   setState(() {
    //     isWriting = val;
    //   });
    // }
////////////////////////////////////////////////////////////////////////////////////////////////
    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Variables.blackColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Share more",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Photos and Video",
                        icon: Icons.image,
                        // onTap: (){},
                        onTap: () {
                          pickImage(source: ImageSource.gallery);
                          Navigator.maybePop(context);
                        },
                      ),
                      ModalTile(
                        title: "Documents",
                        subtitle: "Files and Documents",
                        icon: Icons.tab,
                      ),
                      ModalTile(
                          title: "Contact",
                          subtitle: "Share Contacts",
                          icon: Icons.contacts),
                      ModalTile(
                          title: "Location",
                          subtitle: "Share Location",
                          icon: Icons.add_location),
                    ],
                  ),
                ),
              ],
            );
          });
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: Variables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: TextField(
              autofocus: true,
              controller: textFieldController,
              autocorrect: true,
              enableSuggestions: true,
              style: TextStyle(
                color: Colors.white,
              ),
              onChanged: (val) {

                setState(() {
                  (val.length > 0 && val.trim() != "")
                      ? isWriting = true
                      : isWriting = false;
                });
              },
              decoration: InputDecoration(
                hintText: "Type your message",
                hintStyle: TextStyle(
                  color: Variables.greyColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(50),
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                fillColor: Variables.separatorColor,

                ///emoji section
                suffixIcon: GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.face),
                ),
              ),
            ),
          ),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => addModalTextToSpeech(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.record_voice_over),
                  ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Icon(Icons.camera_alt),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: Variables.fabGradient, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => {sendMessage()},
                  ))
              : Container(),
        ],
      ),
    );
  }

  createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertBox(
            sender: sender,
            receiver: widget.receiver,
          );
          // return AlertDialog(
          //
          //   title: Text("Allow Recording"),
          //   content:
          //   // Center(
          //
          //     // child:
          //     Text("Do you want to allow recording from your contact?"),
          //   // ),
          //   actions: [
          //     denyButton,
          //     cancelButton,
          //     allowButton,
          //   ],
          // );
        });
  }

  // Widget denyButton = MaterialButton(
  //     child: Text("Deny"),
  //     onPressed: (){
  //       print("Recording denied");
  //     }
  // );
  // Widget cancelButton = MaterialButton(
  //     child: Text("Cancel"),
  //     onPressed: (){
  //       print("Operation cancelled");
  //     }
  // );
  // Widget allowButton = MaterialButton(
  //     child: Text("Allow"),
  //     onPressed: (){
  //       print("Recording Allowed");
  //     }
  // );

/////////////////////////////////////////////////////////////////////////////////////////////
  //send a message
  sendMessage() {
    var text = textFieldController.text;

    Message _message = Message(
      receiverID: widget.receiver.uid,
      senderID: sender.uid,
      message: text,
      timestamp: Timestamp.now(),
    );
    setState(() {
      isWriting = false;
    });

    textFieldController.text = "";
    _repository.addMessageToDB(_message, sender, widget.receiver);
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);

    _repository.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserID,
        imageProvider: _imageUploadProvider);
  }

  //designing the appBar of the chat screen
  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(widget.receiver.name),
      actions: [
        IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {
              createAlertDialog(context);

              // onPressed: () async {
              //   await Permissions.cameraAndMicrophonePermissionsGranted()
              //   ? CallUtils.dial(
              //     from: sender,
              //     to: widget.receiver,
              //     ///
              //     grantRecording: grantRecording,
              //     context: context,
              //   ) : {};
            }),
        IconButton(icon: Icon(Icons.phone), onPressed: () {})
      ],
    );
  }

  addModalTextToSpeech() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (context) {
          String text = "Press the button and start recording";
          String recordedText = "";
          bool isRecording = false;
          bool isRecorded = false;
          return BottomSheet(onClosing: () {
            // if (recordedText != "Press the button and start recording") {
            //   this.textFieldController.text = recordedText;
            // }
          }, builder: (BuildContext context) {
            // String recordedText = "Press the button and start recording";

            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Container(
                  height: 300,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          recordedText == "" ?
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.normal,
                            ),
                          ):
                          Text(
                            recordedText,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          /////////////////////////////////////////////////////////////////////////////////
                          AvatarGlow(
                            animate: isRecording,
                            endRadius: 70,
                            glowColor: Theme.of(context).primaryColor,
                            child: FloatingActionButton(
                                elevation: 5,
                                child: Icon(
                                  isRecording ? Icons.mic : Icons.mic_none,
                                  size: 36,
                                ),
                                onPressed: () async =>
                                    await SpeechApi.toggleRecording(
                                      onResult: (text) => setState(() {
                                        isRecorded = true;
                                        recordedText = text;

                                        // this.text = text;
                                      }),
                                      onListening: (isListening) {
                                        setState(() => isRecording = true
                                            // this.isListening = isListening
                                            );
                                      }, ///////////////////
                                    )
                                // await toggleRecording(),
                                ),
                          ),

                          isRecorded ?
                          IconButton(
                              icon: Icon(Icons.send_rounded),
                              onPressed: () {
                                this.setState(() {
                                  textFieldController.text = recordedText;
                                  isWriting = true;
                                });
                                Navigator.pop(context);
                              }):
                          IconButton(
                            icon: Icon(Icons.cancel_schedule_send),
                            onPressed: (){},
                          ),
                        ]),
                  ),
                );
              },
            );
          }
              // return StatefulBuilder(
              //     builder: (BuildContext context, myState){
              //
              //     }
              // );

              );
        });
  }

  //toggle the voice recording
//   Future toggleRecording() async => await SpeechApi.toggleRecording(
//
//     onResult: (text) => setState(() {
//               this.text = text;
//             }),
//     onListening: (isListening){
//       setState(() => this.isListening = isListening);
//     },///////////////////
//   );
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Variables.receiverColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Variables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Variables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
