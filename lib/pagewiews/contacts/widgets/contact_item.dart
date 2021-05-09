import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/models/contact.dart';
import 'package:relate/models/user.dart';
import 'package:relate/pagewiews/chats/widgets/last_message_container.dart';
import 'package:relate/pagewiews/chats/widgets/online_dot_indicator.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/authentication_methods.dart';
import 'package:relate/resources/chat_methods.dart';
import 'package:relate/screens/chatscreens/chat_screen.dart';
import 'package:relate/screens/chatscreens/widgets/cached_image.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_tile.dart';


class ContactItem extends StatelessWidget {

  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactItem({this.contact});



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
            color: Colors.white,
            fontFamily: "Arial",
            fontSize: 19
        ),
      ),
      subtitle: Text(""),
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

