import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class GlobalButton extends StatelessWidget {
  final Color? backgroundcolor;
  final Color? textcolor;
  final Color? bordercolor;
  final BuildContext context;
  final String text;
  final VoidCallback? ontap;
  final bool isLoading;

  GlobalButton({
    super.key,
    this.backgroundcolor,
    this.bordercolor,
    required this.text,
    this.textcolor,
    this.ontap,
    required this.context,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundcolor,
        borderRadius: BorderRadius.circular(borderradius),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : ontap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundcolor ?? primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderradius),
          ),
          side: BorderSide(color: bordercolor ?? primaryColor),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(text, style: buttontext),
        ),
      ),
    );
  }
}
