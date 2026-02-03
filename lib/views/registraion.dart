import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/views/login.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/controllers_/post_controllers.dart';

import 'package:easygonww/views/forgotpassword.dart';
import 'package:easygonww/views/privacypolicy.dart';
import 'package:easygonww/views/terms&conditions.dart';
import 'package:easygonww/widgets/button.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  bool _buttonLoading = false; // only for button

  bool isChecked = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  // Aadhar file variables
  File? _aadharFront;
  File? _aadharBack;
  bool _isFrontUploaded = false;
  bool _isBackUploaded = false;

  // Method to pick Aadhar files
  Future<void> _pickAadharFile(bool isFront) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        if (isFront) {
          _aadharFront = File(image.path);
          _isFrontUploaded = true;
        } else {
          _aadharBack = File(image.path);
          _isBackUploaded = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Create Account', // Bug 01 fixed
                        style: poppinscaps.copyWith(fontSize: 32),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Fill your information or register ',
                        style: normalgrey,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: heightgapnormal),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Full name",
                        hintText: "Enter your name",
                        hintStyle: hintgrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: ThemeData().dividerColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Only letters are allowed in name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: heightgapnormal),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        hintStyle: hintgrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: ThemeData().dividerColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: heightgapnormal),

                    // Mobile with Country Code
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(borderradius),
                          ),
                          child: Text('+91', style: normalgrey),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _mobileController,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Enter your mobile number",
                              hintStyle: hintgrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                borderSide: BorderSide(
                                  color: ThemeData().dividerColor,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 10) {
                                return 'Enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightgapnormal),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter password",
                        hintStyle: hintgrey,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: ThemeData().dividerColor,
                          ),
                        ),
                      ),
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
                        if (!RegExp(
                          r'[!@#$%^&*(),.?":{}|<>]',
                        ).hasMatch(value)) {
                          return 'Must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    // Bug 06: Password Strength
                    if (_passwordController.text.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getPasswordStrength(_passwordController.text),
                          style: TextStyle(
                            color: _getPasswordStrengthColor(
                              _passwordController.text,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: heightgapnormal),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Re-enter password",
                        hintStyle: hintgrey,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(
                            color: ThemeData().dividerColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: heightgapnormal),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => _pickAadharFile(true),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                color: _isFrontUploaded
                                    ? Colors.green[50]
                                    : dividercolor,
                              ),
                              child: _isFrontUploaded
                                  ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: const Icon(
                                        Icons.check_circle_outline_sharp,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.add,
                                        color: const Color(0xFF878787),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aadhar Front',
                                    style: _isFrontUploaded
                                        ? normalblack
                                        : normalgrey,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (_aadharFront != null)
                                    Text(
                                      _aadharFront!.path.split('/').last,
                                      style: smalltextgrey,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: heightgapnormal),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => _pickAadharFile(false),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  borderradius,
                                ),
                                color: _isBackUploaded
                                    ? Colors.green[50]
                                    : dividercolor,
                              ),
                              child: _isBackUploaded
                                  ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: const Icon(
                                        Icons.check_circle_outline_sharp,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.add,
                                        color: const Color(0xFF878787),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aadhar Back',
                                    style: _isBackUploaded
                                        ? normalblack
                                        : normalgrey,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (_aadharBack != null)
                                    Text(
                                      _aadharBack!.path.split('/').last,
                                      style: smalltextgrey,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Checkbox with Terms & Privacy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          activeColor: primaryColor,
                          side: BorderSide(color: ThemeData().dividerColor),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              Text("I agree to the ", style: normalgrey),
                              GestureDetector(
                                onTap: () {
                                  Navigations.push(Termsconditions(), context);
                                },
                                child: Text("Terms", style: colortext),
                              ),
                              Text(" & ", style: colortext),
                              GestureDetector(
                                onTap: () {
                                  Navigations.push(Privacypolicy(), context);
                                },
                                child: Text("Privacy Policy", style: colortext),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Register Button
                    GlobalButton(
                      backgroundcolor: primaryColor,
                      text: "Register",
                      ontap: _buttonLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (!isChecked) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please accept terms & conditions',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Check if Aadhar files are selected
                                if (_aadharFront == null ||
                                    _aadharBack == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please upload both Aadhar front and back',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                PostFunctions().registerUser(
                                  context,
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                  _mobileController.text,
                                  _aadharFront!,
                                  _aadharBack!,
                                  () => setState(() => _buttonLoading = true),
                                  () => setState(() => _buttonLoading = false),
                                );
                              }
                            },
                      context: context,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigations.push(Forgotpassword(), context);
                          },
                          child: Text('Forgot Password ?', style: colortext),
                        ),
                      ],
                    ),
                    SizedBox(height: heightgapnormal),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: normalgrey),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigations.push(LoginPage(), context);
                          },
                          child: Text('SignIn', style: colortext),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getPasswordStrength(String password) {
    if (password.length < 6) return 'Weak';
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return 'Strong';
    }
    return 'Medium';
  }

  Color _getPasswordStrengthColor(String password) {
    switch (_getPasswordStrength(password)) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
