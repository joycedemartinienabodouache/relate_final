import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:relate/models/user.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/utils/variables.dart';
import 'package:relate/widgets/custom_tile.dart';

import 'chatscreens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  FirebaseRepository _repository = FirebaseRepository();

  List<Users> userList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _repository.getCurrentUser().then((User user){
      _repository.fetchAllUsers(user).then((List <Users> mlist) {
        setState(() {
          userList = mlist; //////////////////////////////////////////////to be checked.....
        });
      });
    });

  }

  searchAppBar(BuildContext context){

    return GradientAppBar(

      backgroundColorStart: Variables.gradientColorStart ,
      backgroundColorEnd: Variables.gradientColorEnd,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
        color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (val){
              setState(() {
                query = val;
              });
            },
            cursorColor: Variables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white,),
                onPressed:() {
                    searchController.clear();
                  }),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              )
            ),
          ),
        ),
      ),
    );

  }

  getSuggestions(String query){
    final List<Users> suggestionList = query.isEmpty
        ? []
        : userList.where((Users user) {
      String _getUsername = user.username.toString().toLowerCase();
      String _query = query.toLowerCase();
      String _getName = user.name;
      bool matchesUsername = _getUsername.contains(_query);
      bool matchesName = _getName.contains(_query);

      return (matchesUsername || matchesName);

      // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) ||
      //     (user.name.toLowerCase().contains(query.toLowerCase()))),
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: ((context, index){
        Users suggestedUser = Users(
          uid: suggestionList[index].uid,
          name: suggestionList[index].name,
          username: suggestionList[index].username,
          profilePhoto: suggestionList[index].profilePhoto
        );

        return CustomTile(
          mini: false,
          onTap: (){

            Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatScreen(
                receiver: suggestedUser,
              ))
            );
          },
          leading: CircleAvatar(
            backgroundImage: NetworkImage(suggestedUser.profilePhoto),
            backgroundColor: Colors.grey,
          ),
          title: Text(
            suggestedUser.username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            suggestedUser.name,
            style: TextStyle(
              color: Variables.greyColor,
            ),
          ),
        );
      }),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Variables.blackColor,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: getSuggestions(query),
      ),

    );
  }
}
