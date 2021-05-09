import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/models/contact.dart';
import 'package:relate/models/user.dart';
import 'package:relate/pagewiews/chats/widgets/contact_view.dart';
import 'package:relate/pagewiews/chats/widgets/new_chat_button.dart';
import 'package:relate/pagewiews/chats/widgets/online_dot_indicator.dart';
import 'package:relate/pagewiews/chats/widgets/quietbox.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/chat_methods.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/screens/chatscreens/chat_screen.dart';
import 'package:relate/screens/chatscreens/widgets/cached_image.dart';
import 'package:relate/utils/utilities.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_appbar.dart';
import 'package:relate/widgets/custom_tile.dart';
import 'package:relate/widgets/mAppbar.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  FirebaseRepository _repository = FirebaseRepository();

  final ChatMethods _chatMethods = ChatMethods();

  List<Users> userList = List<Users>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _repository.getCurrentUser().then((User user){
      _repository.fetchAllUsers(user).then((List <Users> mList) {
        setState(() {
          userList = mList; //////////////////////////////////////////////to be checked.....
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);


    return Scaffold(
      backgroundColor: Variables.blackColor,

      // appBar: MAppbar(
      //   title: "Chats",
      //   actions: <Widget> [
      //     IconButton(
      //       icon: Icon(
      //         Icons.search,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         Navigator.pushNamed(context, "/SearchScreen");
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(
      //         Icons.more_vert,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Chats",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.pink[50],
                          ),
                          child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, "/SearchScreen"),
                              child: Row(
                                  children: <Widget>[
                                    Icon( Icons.add,color: Variables.senderColor,size: 20,),
                                    SizedBox(width: 2,),
                                    Text("New",style: TextStyle(

                                        fontSize: 14,fontWeight: FontWeight.bold, color: Variables.senderColor),),
                                  ],
                              ),

                            ),
                        )
                      ],
                    ),

                    // Text(
                    //   'Chats',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 30,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userList.length,
                      itemBuilder: (context, index){
                        final user = userList[index];
                        print(user.name);
                        return Container(
                          margin: const EdgeInsets.only(right: 13),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ChatScreen(
                                    receiver: user,
                                  )
                                  )
                              );
                            },//////////////on item tap////////////////////////////////////////////
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                              child: Stack(
                                children: [
                                  CachedImage(
                                    user.profilePhoto,
                                    radius: 50,
                                    isRound: true,
                                  ),
                                  OnlineDotIndicator(uid: user.uid),
                                ]
                              ),
                            ),

                            // CircleAvatar(
                            //   radius: 24,
                            //   backgroundColor: Colors.white,
                            //   backgroundImage: NetworkImage(user.profilePhoto),
                            // ),
                          ),
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),
            ChatList(),
          ],
        ),
      ),

      // SingleChildScrollView(
      //   physics: BouncingScrollPhysics(),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children:[
      //       SafeArea(
      //         child: Padding(
      //           padding: EdgeInsets.only(left: 16,right: 16,top: 10),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: <Widget>[
      //               Text("Chats",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
      //               Container(
      //                 padding: EdgeInsets.only(left: 8,right: 8,top: 2,bottom: 2),
      //                 height: 30,
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(30),
      //                   color: Colors.pink[50],
      //                 ),
      //                 child: GestureDetector(
      //                   onTap: () => Navigator.pushNamed(context, "/SearchScreen"),
      //                   child: Row(
      //
      //                     children: <Widget>[
      //                       Icon( Icons.add,color: Variables.senderColor,size: 20,),
      //                       SizedBox(width: 2,),
      //                       Text("New",style: TextStyle(
      //
      //                           fontSize: 14,fontWeight: FontWeight.bold),),
      //                     ],
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ),
      //         ),
      //       ),
      //       Padding(
      //         padding: EdgeInsets.only(top: 16,left: 16,right: 16),
      //         child: TextField(
      //           decoration: InputDecoration(
      //             hintText: "Search...",
      //             hintStyle: TextStyle(color: Colors.grey.shade600),
      //             prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
      //             filled: true,
      //             fillColor: Colors.grey.shade100,
      //             contentPadding: EdgeInsets.all(8),
      //             enabledBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(20),
      //                 borderSide: BorderSide(
      //                     color: Colors.grey.shade100
      //                 )
      //             ),
      //           ),
      //         ),
      //       ),
      //       ChatListContainer(),
      //   ], ),
      // ),
    );
  }
}

class ChatList extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
      stream: _chatMethods.fetchContacts(
        userId: userProvider.getUser.uid,
      ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data.docs;

            if (docList.isEmpty) {
              return QuietBox(
                heading: "This is where all the contacts are listed",
                subtitle:
                "Search for your friends and family to start calling or chatting with them",
              );
            }
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(10),
              itemCount: docList.length,
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(docList[index].data());

                return ContactView(contact: contact);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        }),

      ),
    );
  }
}


class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.docs;

              if (docList.isEmpty) {
                return QuietBox(
                  heading: "This is where all the contacts are listed",
                  subtitle:
                      "Search for your friends and family to start calling or chatting with them",
                );
              }
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data());

                  return ContactView(contact: contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
