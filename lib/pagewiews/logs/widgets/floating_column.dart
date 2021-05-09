import 'package:flutter/material.dart';
import 'package:relate/utils/variables.dart';

class FloatingColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Variables.fabGradient,
          ),
          child: Icon(
            Icons.dialpad,
            color: Colors.white,
            size: 25,
          ),
          padding: EdgeInsets.all(15),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Variables.blackColor,
              border: Border.all(
                width: 2,
                color: Variables.gradientColorEnd,
              )),
          child: Icon(
            Icons.add_call,
            color: Variables.gradientColorEnd,
            size: 25,
          ),
          padding: EdgeInsets.all(15),
        )
      ],
    );
  }
}