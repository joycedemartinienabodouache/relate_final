

import 'package:flutter/material.dart';
import 'package:relate/utils/variables.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      child: Shimmer.fromColors(
        baseColor: Variables.blackColor,
        highlightColor: Colors.white,
        child: Image.asset("assets/app_logo.png"),
        period: Duration(seconds: 1),
      ),
    );
  }
}