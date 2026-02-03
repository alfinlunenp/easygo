import 'package:flutter/material.dart';

class Appbarnull extends StatelessWidget implements PreferredSizeWidget {
  const Appbarnull({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}