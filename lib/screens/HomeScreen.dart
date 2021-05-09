import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:relate/enum/user_state.dart';
import 'package:relate/pagewiews/chats/widgets/user_circle.dart';
import 'package:relate/pagewiews/contacts/contact_list.dart';
import 'package:relate/pagewiews/logs/log_screen.dart';
import 'file:///C:/Users/JakeElevEn/AndroidStudioProjects/relate/lib/pagewiews/chats/chat_list_page.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/resources/firebase_repository.dart';
import 'package:relate/resources/local_db/repository/log_repository.dart';
import 'package:relate/screens/callscreens/pickup/pickup_layout.dart';
import 'package:relate/utils/utilities.dart';
import 'package:relate/utils/variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController pageController;
  int page = 0;

  FirebaseRepository _repository = FirebaseRepository();

  UserProvider userProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);

    SchedulerBinding.instance.addPostFrameCallback((_) async { //ensures that the content is loaded just after the frames are generated

      await userProvider.refreshUser();
      _repository.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Online,
      );

      LogRepository.init(
          isHive: false,
          dbName: userProvider.getUser.uid,
      );

    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState

    String currentUserId =
    (userProvider != null && userProvider.getUser != null)
        ? userProvider.getUser.uid
        : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _repository.setUserState(
            userId: currentUserId, userState: UserState.Online)
            : print("resumed state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _repository.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _repository.setUserState(
            userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _repository.setUserState(
            userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    double labelFontSize = 10;

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Variables.blackColor,
        body: PageView(
          children: [
            ChatListPage(),//set the chat list screen
            LogScreen(),
            // Center(
            //   child: ContactList(),
            // ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
        ),


        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: Variables.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat,
                      color: (page == 0)
                          ? Variables.lightBlueColor
                          : Variables.greyColor),
                  title: Text(
                    "Chats",
                    style: TextStyle(
                        fontSize: labelFontSize,
                        color: (page == 0)
                            ? Variables.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call,
                      color: (page == 1)
                          ? Variables.lightBlueColor
                          : Variables.greyColor),
                  title: Text(
                    "Calls",
                    style: TextStyle(
                        fontSize: labelFontSize,
                        color: (page == 1)
                            ? Variables.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.contact_phone,
                //       color: (page == 2)
                //           ? Variables.lightBlueColor
                //           : Variables.greyColor),
                //   title: Text(
                //     "Contacts",
                //     style: TextStyle(
                //         fontSize: labelFontSize,
                //         color: (page == 2)
                //             ? Variables.lightBlueColor
                //             : Colors.grey),
                //   ),
                // ),
                BottomNavigationBarItem(
                    icon: UserCircle(),
                    label: "Profile",
                ),
              ],
              onTap: navigationTapped,
              currentIndex: page,
            ),
          ),
        ),


        // Container(
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(90.0)),
        //         color: Variables.senderColor,
        //         // boxShadow: Box
        //   ),


          // child:
          // Padding(

            // padding: EdgeInsets.symmetric(vertical: 9),
            // // child: Container(
            // //
            // //   decoration: BoxDecoration(
            // //     borderRadius: BorderRadius.all(Radius.circular(90.0)),
            // //     color: Variables.greyColor,
            // //
            // //   ),
            //
            //   child:
            //   CupertinoTabBar(
            //
            //
            //     backgroundColor: Variables.senderColor,
            //
            //     items: <BottomNavigationBarItem>[
            //
            //       //chat b-nav bar item
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.chat,
            //           color: (page == 0)
            //               ? Variables
            //                   .lightBlueColor //sets the color of a button to blue when it is selected
            //               : Variables
            //                   .greyColor, // set the color of the button to grey when it is not selected
            //         ),
            //         title: Text(
            //           "Chats",
            //           style: TextStyle(
            //             fontSize: labelFontSize,
            //             color: (page == 0)
            //                 ? Variables
            //                     .lightBlueColor //sets the color of the text label to blue when it is selected
            //                 : Variables
            //                     .greyColor, // set the color of the text label to grey when it is not selected
            //           ),
            //         ),
            //       ),
            //
            //       //call log b-nav bar item
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.call,
            //           color: (page == 1)
            //               ? Variables
            //               .lightBlueColor //sets the color of a button to blue when it is selected
            //               : Variables
            //               .greyColor, // set the color of the button to grey when it is not selected
            //         ),
            //         title: Text(
            //           "Calls",
            //           style: TextStyle(
            //             fontSize: labelFontSize,
            //             color: (page == 1)
            //                 ? Variables
            //                 .lightBlueColor //sets the color of the text label to blue when it is selected
            //                 : Variables
            //                 .greyColor, // set the color of the text label to grey when it is not selected
            //           ),
            //         ),
            //       ),
            //
            //       //contact list b-nav bar item
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.contact_phone,
            //           color: (page == 2)
            //               ? Variables
            //               .lightBlueColor //sets the color of a button to blue when it is selected
            //               : Variables
            //               .greyColor, // set the color of the button to grey when it is not selected
            //         ),
            //         title: Text(
            //           "Contacts",
            //           style: TextStyle(
            //             fontSize: labelFontSize,
            //             color: (page == 2)
            //                 ? Variables
            //                 .lightBlueColor //sets the color of the text label to blue when it is selected
            //                 : Variables
            //                 .greyColor, // set the color of the text label to grey when it is not selected
            //           ),
            //         ),
            //       ),
            //       BottomNavigationBarItem(
            //           icon: UserCircle(),
            //         label: "Profile",
            //
            //         ),
            //
            //
            //
            //     ],
            //
            //     onTap: navigationTapped,
            //     currentIndex: page,
            //   ),
            // ),
          // ),
        // ),
      ),
    );
  }

  void onPageChanged(int newPage) {
    setState(() {
      page = newPage;
    });
  }

  void navigationTapped(int newPage) {
    pageController.jumpToPage(newPage);
  }
}
