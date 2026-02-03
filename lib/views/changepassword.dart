import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/home2.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _buttonLoading = false; // only for button

  double _strength = 0.0;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchpassword();
  }

  String? user_password;
  String? user_email;

  void fetchpassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user_password = prefs.getString("user_password");
    user_email = prefs.getString("user_email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigations.pop(context);
            },
            child: Container(
              child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Change Password", style: mediumblack),
            Text(
              'Update your password to keep your account secure',
              style: smalltextgrey,
            ),
          ],
        ),
      ),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16),

                  // Current Password Field
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      hintText: "Current Password",
                      hintStyle: hintgrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderradius),
                        borderSide: BorderSide(color: ThemeData().dividerColor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrent = !_obscureCurrent;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current Password is required';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: heightgapnormal),

                  // New Password Field - This is where we check password strength
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
                          });
                        },
                      ),
                    ),
                    onChanged:
                        _checkPasswordStrength, // Moved here from current password field
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Must contain at least one lowercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Must contain at least one number';
                      }
                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return 'Must contain at least one special character';
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

                  // Password Strength Indicator - Now shows strength of new password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          'Password Strength',
                          style: normalgrey,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 10000,
                        ),
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
                              : secondprimaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Password Guidelines
                  Container(
                    decoration: BoxDecoration(
                      color: dividercolor,
                      borderRadius: BorderRadius.circular(borderradius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements: ',
                            style: normalblack.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Keep it short but strong: Your password must be 6–8 characters long and contain at least one of each: Uppercase, lowercase, and a special symbol.',
                            style: normalblack,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1000,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.all(16),
        child: GlobalButton(
          backgroundcolor: primaryColor,
          text: "Reset Password",
          ontap: _buttonLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    if (_currentPasswordController.text.trim() !=
                        (user_password ?? '')) {
                      Fluttertoast.showToast(
                        msg: 'Current password is incorrect',
                        backgroundColor: const Color.fromARGB(255, 255, 92, 81),
                        textColor: Colors.white,
                      );

                      return; // Stop execution
                    }

                    // If correct, call the function
                    PostFunctions().resetPasswordloggedin(
                      context,
                      user_email!,
                      _newPasswordController.text,
                      _currentPasswordController.text,
                      "home",
                      () => setState(
                        () => _buttonLoading = true,
                      ), // disable button
                      () => setState(
                        () => _buttonLoading = false,
                      ), // enable button
                    );
                  }
                },
          context: context,
        ),
      ),
    );
  }
}
