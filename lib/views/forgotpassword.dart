import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/widgets/button.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileOrEmailController =
      TextEditingController();

  bool _buttonLoading = false;

  @override
  void dispose() {
    _mobileOrEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),

      /// 🔥 SCROLL SAFE BODY (IMPORTANT FOR RELEASE MODE)
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                /// TITLE
                Text(
                  'Forgot Your\nPassword?',
                  style: largelack.copyWith(color: primaryColor, fontSize: 28),
                ),

                const SizedBox(height: 10),

                /// SUB TITLE
                Text('Enter your registered email address', style: normalgrey),

                const SizedBox(height: 50),

                /// EMAIL / MOBILE FIELD
                TextFormField(
                  controller: _mobileOrEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email address",
                    labelText: 'Email Address',
                    hintStyle: hintgrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: bordercolorgrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: bordercolorgrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email or mobile number is required';
                    }

                    /// mobile
                    final mobileRegex = RegExp(r'^[0-9]{10}$');

                    /// email
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    );

                    if (!mobileRegex.hasMatch(value) &&
                        !emailRegex.hasMatch(value)) {
                      return 'Enter a valid email or mobile number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                /// BUTTON (NO EXPANDED / FLEXIBLE INSIDE)
                SizedBox(
                  width: double.infinity,
                  child: GlobalButton(
                    backgroundcolor: primaryColor,
                    text: _buttonLoading ? "Please wait..." : "Get OTP",
                    ontap: _buttonLoading
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();

                            if (_formKey.currentState!.validate()) {
                              PostFunctions().forgotpassword(
                                context,
                                _mobileOrEmailController.text.trim(),
                                () {
                                  if (mounted) {
                                    setState(() => _buttonLoading = true);
                                  }
                                },
                                () {
                                  if (mounted) {
                                    setState(() => _buttonLoading = false);
                                  }
                                },
                              );
                            }
                          },
                    context: context,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
