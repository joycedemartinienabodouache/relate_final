import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/models/contact.dart';
import 'package:relate/pagewiews/chats/widgets/contact_view.dart';
import 'package:relate/pagewiews/chats/widgets/quietbox.dart';
import 'package:relate/pagewiews/contacts/widgets/contact_item.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/chat_methods.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_appbar.dart';
import 'package:relate/widgets/mAppbar.dart';

class ContactList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Variables.blackColor,
        appBar: MAppbar(
          title: Text("Contacts"),
          actions: null,
          ),
      body: ContactListContainer(),
    );
  }
}

class ContactListContainer extends StatelessWidget {

  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);


    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchOrderedContacts(userId: userProvider.getUser.uid),
          builder: (context, snapshot) {

            if(snapshot.hasData){

              List<QueryDocumentSnapshot> docList =snapshot.data.docs;

              if(docList.isEmpty){
                return QuietBox(
                  heading: "This is where all the contacts are listed",
                  subtitle:
                  "Search for your friends and family to start calling or chatting with them",
                );
              }
              return ListView.builder(

                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index){
                  Contact contact = Contact.fromMap(docList[index].data());

                  return ContactItem(contact: contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}

