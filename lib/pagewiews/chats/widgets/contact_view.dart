import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/models/contact.dart';
import 'package:relate/models/user.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/authentication_methods.dart';
import 'package:relate/resources/chat_methods.dart';
import 'package:relate/screens/chatscreens/chat_screen.dart';
import 'package:relate/screens/chatscreens/widgets/cached_image.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_tile.dart';

import 'last_message_container.dart';
import 'online_dot_indicator.dart';

class ContactView extends StatelessWidget {

  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView({this.contact});



  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Users>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context,snapshot){
        if(snapshot.hasData){
          Users user = snapshot.data;

          return ViewLayout(
              contact: user
          );
        }
        return Center(
          // child: Text("chat item not working"),
          child: CircularProgressIndicator(),
        );
      },
    );

  }
}

class ViewLayout extends StatelessWidget {

  final Users contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({@required this.contact});

  @override
  Widget build(BuildContext context) {

    UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(

      mini: false,
      onLongPress: () {},
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatScreen(
              receiver: contact,
            )
            )
        );
      },
      title: Text(
        contact ?. name ?? "..",
        style: TextStyle(
            color: Colors.black,
            fontFamily: "Arial",
            fontSize: 16
        ),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
            senderId: userProvider.getUser.uid,
            receiverId: contact.uid),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: [
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(
                uid: contact.uid
            ),
          ],
        ),
      ),

    );
  }
}

