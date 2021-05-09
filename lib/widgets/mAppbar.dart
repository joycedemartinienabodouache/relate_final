import 'package:flutter/material.dart';
import 'package:relate/widgets/custom_appbar.dart';

class MAppbar extends StatelessWidget implements PreferredSizeWidget{

  final dynamic title;
  final List<Widget> actions;

  const MAppbar({
    Key key,
    @required this.title,
    @required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: (title is String)
          ? Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )
          : title,
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
