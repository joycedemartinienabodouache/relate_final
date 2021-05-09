import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relate/pagewiews/chats/widgets/user_details_container.dart';
import 'package:relate/provider/user_provider.dart';
import 'package:relate/utils/utilities.dart';
import 'package:relate/utils/variables.dart';

class UserCircle extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
          backgroundColor: Variables.blackColor,
          builder:(context) => UserDetailsContainer(),
          isScrollControlled: true,
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Variables.separatorColor,
        ),
        child: Stack(
          children: <Widget> [
            Align(
              alignment: Alignment.center,
              child: Text(
                Utils.getInitials(userProvider.getUser.name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Variables.lightBlueColor,
                  fontSize: 13,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Variables.blackColor,
                    width: 2,
                  ),
                  color: Variables.onlineDotColor,
                ),
              ),
            )
          ],

        ),
      ),
    );
  }
}