import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/widgets/appbarnull.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/widgets/button.dart';

class Otp extends StatefulWidget {
  String email;
  Otp({super.key, required this.email});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  bool _buttonLoading = false; // only for button

  int _secondsRemaining = 30;
  Timer? _timer;

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String formatTime(int seconds) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  // void _submitOtp() {
  //   String otp = _controllers.map((e) => e.text).join();
  //   if (otp.length == 4) {
  //     // You can call your verification function here.
  //     print("Entered OTP: $otp");
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Submitted: $otp")));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter all 4 digits")));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Appbarnull(),
      body: Center(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'OTP VERIFICATION',
                      style: largelack.copyWith(
                        color: primaryColor,
                        fontSize: 28,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'We sent a 4-digit verification code to ${widget.email}. Please enter it below.',
                      style: normalgrey,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 100,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: width * 0.15,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_focusNodes[index - 1]);
                            }
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: bordercolorgrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: bordercolorgrey),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  GlobalButton(
                    text: 'Submit',
                    ontap: _buttonLoading
                        ? null
                        : () {
                            String otp = _controllers.map((e) => e.text).join();

                            PostFunctions().verifyOtp(
                              context,
                              widget.email,
                              otp,
                              () => setState(() => _buttonLoading = true),
                              () => setState(() => _buttonLoading = false),
                            );
                          },
                    context: context,
                  ),

                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _secondsRemaining == 0
                        ? _buttonLoading
                              ? null
                              : () {
                                  setState(() {
                                    _secondsRemaining = 30;
                                  });

                                  startCountdown();
                                  PostFunctions().forgotpassword(
                                    context,
                                    widget.email,
                                    () => setState(() => _buttonLoading = true),
                                    () =>
                                        setState(() => _buttonLoading = false),
                                  );
                                }
                        : null, // Disable tap while countdown is running
                    child: Text(
                      _secondsRemaining > 0
                          ? "Resend in ${formatTime(_secondsRemaining)}"
                          : "Resend Code",

                      style: _secondsRemaining > 0 ? normalgrey : colortext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
