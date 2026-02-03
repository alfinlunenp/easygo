import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class Globalcontainer extends StatelessWidget {
  double? height;
  double? width;
  double? BorderRadius;
  Widget? child;
  Color? bgcolor;
  Color? bordercolor;
  TextStyle? textstyle;

  Globalcontainer({
    super.key,
    this.BorderRadius,
    this.bgcolor,
    this.bordercolor,
    this.height,
    this.child,
    this.width,
    this.textstyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 40,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: bgcolor ?? Colors.white,
        border: Border.all(color: bordercolor ?? secondaryColor),
        borderRadius: BorderRadiusDirectional.circular(borderradius ?? 100),
      ),
      child: child ?? Text(""),
    );
  }
}
