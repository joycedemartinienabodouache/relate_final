import 'package:flutter/material.dart';
import 'package:relate/utils/variables.dart';

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: Variables.fabGradient,
          borderRadius: BorderRadius.circular(50)
      ),
      child: Icon(
        Icons.edit,
        color: Colors.white,
        size: 25,
      ),
      padding: EdgeInsets.all(15),
    );
  }
}