import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relate/models/user.dart';
import 'package:relate/screens/chatscreens/chat_screen.dart';


class ChatHeaderWidget extends StatelessWidget {

  final QuerySnapshot users;

   const ChatHeaderWidget({
    @required this.users,
    Key key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    List<Users> userList;


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.74,
            child: Text(
              "Chats",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox( height: 10,),
          Container(
            color: Colors.green,
            height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.docs.length,
                itemBuilder: (context, index){

                  final contact = users.docs[index];
                    print(contact.data());
                    if (index == 0) {
                      return Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.search),
                        ),
                      );
                    } else {
                      return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                              onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(receiver: contact[index]),
                              ));
                  },
                                    child: CircleAvatar(
                                        radius: 24,
                      // backgroundImage: NetworkImage(contact.),
                  ),

                      ));
                    }


                }
              ),
          )
        ],
      ),
    );
  }
}
