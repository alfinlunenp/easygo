import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/views/login.dart';
import 'package:easygonww/widgets/button.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  double _strength = 0.0;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _buttonLoading = false; // only for button

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;

    setState(() {
      _strength = strength.clamp(0, 1);
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.unfocus();
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Reset Your Password',
                    style: poppinscaps,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Center(
                  child: Text(
                    'Choose a strong password you haven’t used before',
                    style: normalgrey,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: heightgapnormal),

                Center(
                  child: Image.asset(
                    'assets/giffys/restpassword.gif',
                    height: 217,
                    width: 225,
                  ),
                ),

                SizedBox(height: heightgapnormal),

                // New Password Field
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    hintStyle: hintgrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderradius),
                      borderSide: BorderSide(color: ThemeData().dividerColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                          if (!_obscureNew) {
                            _obscureConfirm =
                                true; // Auto-hide confirm password
                          }
                        });
                      },
                    ),
                  ),
                  onChanged: _checkPasswordStrength,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: heightgapnormal),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: hintgrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderradius),
                      borderSide: BorderSide(color: ThemeData().dividerColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                          if (!_obscureConfirm) {
                            _obscureNew = true; // Auto-hide new password
                          }
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirmation password is required';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                SizedBox(height: heightgapnormal),

                // Password Strength Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Password Strength',
                      style: normalgrey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _strength,
                        backgroundColor: Colors.grey.shade300,
                        color: _strength < 0.4
                            ? Colors.red
                            : _strength < 0.7
                            ? Colors.orange
                            : primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Text('Must be at least 6–8 characters'),

                // Password Guidelines
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '• Must be at least 6–8 characters\n• 1 upper & lower case, and 1 special character',
                      style: normalgrey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),

                SizedBox(height: heightgapnormal),

                GlobalButton(
                  backgroundcolor: primaryColor,
                  text: "Continue to Login",
                  ontap: _buttonLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            // // TODO: Submit the password to backend
                            // Navigator.of(context).pushReplacement(
                            //     MaterialPageRoute(builder: (_) => const RegistrationPage()));
                            // Navigations.push(LoginPage(), context);
                            print("tapped");
                            PostFunctions().resetPasswordloggedout(
                              context,
                              widget.email,
                              _newPasswordController.text,
                              "loginpage",
                              () => setState(() => _buttonLoading = true),
                              () => setState(() => _buttonLoading = false),
                            );
                          }
                        },

                  context: context,
                ),

                SizedBox(height: heightgapnormal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
