import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class Colorcontainer extends StatelessWidget {
  String childtext;
  Colorcontainer({super.key, required this.childtext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderradius),
        color: primaryColor.withOpacity(0.12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Text(childtext, style: colortext),
      ),
    );
  }
}
