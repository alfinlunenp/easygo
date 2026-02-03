import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class Profilefield extends StatelessWidget {
  final String category;
  final String content;
  final bool editsts;
  final TextEditingController? controller;

  const Profilefield({
    super.key,
    required this.category,
    required this.content,
    this.controller,
    required this.editsts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: TextFormField(
        initialValue: content,
        readOnly: editsts,
        style: normalgrey,
        decoration: InputDecoration(
          labelText: category,
          labelStyle: normalblack,
          floatingLabelBehavior: editsts
              ? FloatingLabelBehavior
                    .never // ✅ Keep label as placeholder
              : FloatingLabelBehavior.auto, // ✅ Normal floating label
          filled: true,
          enabled: true,
          fillColor: primaryColor.withOpacity(0.012),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderradius),
            borderSide: BorderSide(color: bordercolorgrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderradius),
            borderSide: BorderSide(color: bordercolorgrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderradius),
            borderSide: BorderSide(color: bordercolorgrey),
          ),
        ),
      ),
    );
  }
}
