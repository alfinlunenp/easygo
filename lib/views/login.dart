import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/forgotpassword.dart';
import 'package:easygonww/views/registraion.dart';
import 'package:easygonww/widgets/appbarnull.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/widgets/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _buttonLoading = false; // only for button

  final TextEditingController _mobileOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  void _loadLoginData() async {
    Map<String, dynamic> loginData = await GlobalPreference().getlogin();
    bool rememberMe = loginData['remember_me'] ?? false;
    String email = loginData['user_email'] ?? '';
    String password = loginData['user_password'] ?? '';

    if (rememberMe == true) {
      _mobileOrEmailController.text = email;
      _passwordController.text = password;
      setState(() {
        isChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Appbarnull(),
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
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: heightgapnormal),
                    Center(
                      child: Image.asset(
                        'assets/login/loginimg.png',
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: heightgapnormal),

                    // Mobile/Email Field
                    TextFormField(
                      controller: _mobileOrEmailController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Enter mobile number or Email",
                        labelText: "Email ",
                        labelStyle: hintgrey,
                        hintStyle: hintgrey,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(color: bordercolorgrey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email or Phone number is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: heightgapnormal),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Enter Your Password",
                        labelText: "Password",
                        labelStyle: hintgrey,
                        hintStyle: hintgrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderradius),
                          borderSide: BorderSide(color: bordercolorgrey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
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

                    Row(
                      children: [
                        Checkbox(
                          activeColor: primaryColor,
                          side: BorderSide(color: bordercolorgrey),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Remember Me",
                            style: normalgrey,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

                    GlobalButton(
                      backgroundcolor: primaryColor,
                      text: "Login",
                      ontap: _buttonLoading
                          ? null
                          : () async {
                              print("tfhf");
                              if (_formKey.currentState!.validate()) {
                                PostFunctions().loginUser(
                                  context,
                                  _mobileOrEmailController.text.trim(),
                                  _passwordController.text,
                                  isChecked,
                                  () => setState(() => _buttonLoading = true),
                                  () => setState(() => _buttonLoading = false),
                                );
                              }
                            },
                      context: context,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigations.push(Forgotpassword(), context);
                        },
                        child: Text(
                          'Forgot Password ?',
                          style: colortext,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    SizedBox(height: heightgapnormal),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?', style: normalgrey),
                        SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Navigations.push(Registration(), context);
                          },
                          child: Text('Signup', style: colortext),
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
}
