import 'dart:convert';
import 'dart:io';
import 'package:easygonww/views/resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/APIs/apis.dart';
import 'package:easygonww/controllers/list.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/bookings.dart';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/login.dart';
import 'package:easygonww/views/otp.dart';
import 'package:easygonww/views/reg_otp.dart';
import 'package:easygonww/views/resetpassword.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class PostFunctions {
  void loginUser(
    BuildContext context,
    String emailorpassword,
    String password,
    bool rememberMe,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    onStart();

    var data = {
      "emailorphone_number": emailorpassword,
      "password": password,
      "role": "user",
    };

    try {
      var response = await http.post(
        Uri.parse(loginAPI),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        var user = jsonData['user'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", user['id'].toString());
        prefs.setString("user_name", user['name']);
        prefs.setString("user_email", user['email']);
        prefs.setString("user_password", password);
        prefs.setString("user_role", user['role']);
        prefs.setBool("remember_me", rememberMe);
        prefs.setString("token", user['token']);

        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "Login successful",
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomebottomBar()),
        );
      } else {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "Login failed",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      onFinish();
    }
  }

  void registerUser(
    BuildContext context,
    String name,
    String email,
    String password,
    String contact,
    File AadharFront,
    File AadharBack,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    onStart();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(registerAPI));

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['mobile'] = contact;

      request.files.add(
        await http.MultipartFile.fromPath(
          'adharfront',
          AadharFront.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'adharback',
          AadharBack.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP sent to email",
          gravity: ToastGravity.BOTTOM,
        );

        Navigations.push(RegOtp(email: email), context);
      } else {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "Registration failed",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      onFinish();
    }
  }

  void forgotpassword(
    BuildContext context,
    String email,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    onStart();

    var data = {"email": email, "u_role": "user"};

    try {
      var response = await http.post(
        Uri.parse(forgotPasswordAPI),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP sent successfully",
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Otp(email: email)),
        );
      } else {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "Something went wrong",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      onFinish();
    }
  }

  void verifyOtp(
    BuildContext context,
    String email,
    String otp,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    var data = {"email": email, "otp": otp};

    var url = "$verifyOtpAPI";

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Response: ${response.body}");

      // Decode response regardless of status code
      final jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP Verified",
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResetPassword(email: email)),
        );
      } else {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP verification failed",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void verifyRegistrationOtp(
    BuildContext context,
    String email,
    String otp,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    var data = {"email": email, "otp": otp};
    var url = registerOTPAPI;

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print(response.statusCode);
      print(response.body);

      // Decode response for BOTH 200 & 400
      var jsonData = jsonDecode(response.body);

      if (jsonData['result'] == true) {
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP Verified",
          gravity: ToastGravity.BOTTOM,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // 👇 This will now show: "Invalid OTP"
        Fluttertoast.showToast(
          msg: jsonData['message'] ?? "OTP verification failed",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void resetPasswordloggedout(
    BuildContext context,
    String email,
    String newpassword,
    String pagename,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    onStart();

    var data = {"email": email, "new_password": newpassword};

    try {
      var response = await http.post(
        Uri.parse(changePasswordAPI),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final jsonData = jsonDecode(response.body);

      Fluttertoast.showToast(
        msg: jsonData['message'] ?? "Password reset failed",
        gravity: ToastGravity.BOTTOM,
      );

      if (jsonData['result'] == true) {
        Navigations.pushAndRemoveUntil(LoginPage(), context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      onFinish();
    }
  }

  // reset password
  void resetPasswordloggedin(
    BuildContext context,
    String email,
    String newpassword,
    String? oldpassword,
    String pagename,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    var data = {
      "email": email,
      "new_password": newpassword,
      "old_password": oldpassword,
      "loggedin": "true",
    };

    var url = changePasswordAPI;

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      Map<String, dynamic> jsonData = {};
      if (response.body.isNotEmpty) {
        jsonData = jsonDecode(response.body);
      }

      // ✅ SHOW BACKEND MESSAGE ALWAYS
      Fluttertoast.showToast(
        msg: jsonData['message'] ?? "Something went wrong",
        gravity: ToastGravity.BOTTOM,
      );

      if (response.statusCode == 200 && jsonData['result'] == true) {
        Navigations.pushAndRemoveUntil(LoginPage(), context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network Error",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // {
  //   "user_id": 103,
  //   "bike_id": 18,
  //   "pickup_location": "Vellayambalam",
  //   "pickup_date": "2025-08-07",
  //   "pickup_time": "10:15:00",
  //   "drop_location": "East Fort",
  //   "drop_date": "2025-08-07",
  //   "drop_time": "19:00:00"
  // }

  void addBooking(
    BuildContext context,
    String pickup_location,
    String pickup_date,
    String pickup_time,
    String drop_location,
    String drop_date,
    String drop_time,
    String price_id,
    double fine_amount,
    File selfie,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_id = prefs.getString("user_id");
    String? token = prefs.getString("token");

    if (user_id == null || token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    if (selfie.path.isEmpty) {
      Fluttertoast.showToast(msg: "Please upload selfie");
      return;
    }

    print(token);

    onStart();

    try {
      var url = BookingAPI;
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // ✅ AUTH HEADER
      request.headers.addAll({"Authorization": "Bearer $token"});

      String returnUrl =
          "easygo://payment_return?status=success&user_id=$user_id";

      // ✅ FORM FIELDS
      request.fields.addAll({
        'pickup_location': pickup_location,
        'pickup_date': pickup_date,
        'pickup_time': pickup_time,
        'drop_location': drop_location,
        'drop_date': drop_date,
        'drop_time': drop_time,
        'price_id': price_id,
        'fine_amount': fine_amount.toString(),
        'return_url': returnUrl,
      });

      // ✅ SELFIE FILE
      request.files.add(
        await http.MultipartFile.fromPath(
          'selfie',
          selfie.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print(responseBody);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(responseBody);

        if (jsonData['result'] == true) {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Booking successful",
          );

          final paymentUrl = jsonData['paymentLinkUrl'];
          if (paymentUrl != null && paymentUrl.toString().isNotEmpty) {
            final uri = Uri.parse(paymentUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              Fluttertoast.showToast(msg: "Could not open payment link");
            }
          }
        } else {
          Fluttertoast.showToast(msg: jsonData['message'] ?? "Booking failed");
        }
      } else {
        Fluttertoast.showToast(msg: "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Exception: $e");
    } finally {
      onFinish();
    }
  }

  Future<bool> updateUser(
    BuildContext context,
    File? profileimage,
    String email,
    String name,
    String contact,
    String dob,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    var url = ProfileUpdateAPI;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get token from SharedPreferences
    String? token = prefs.getString("token");
    String? userId = prefs.getString("user_id"); // Or get from token if decoded

    print(token);
    print("name : $name");
    print("email : $email");
    print("contact : $contact");
    print("dob : $dob");
    print("profile image : $profileimage");

    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(
        msg: "Authentication token not found. Please login again.",
        gravity: ToastGravity.BOTTOM,
      );
      Navigations.pushAndRemoveUntil(LoginPage(), context); // Redirect to login
      return false;
    }

    // Call onStart callback
    onStart();

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add authorization header with Bearer token
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['mobile'] = contact;
    request.fields['dob'] = dob;

    // Add profile image
    if (profileimage != null && profileimage.path.isNotEmpty) {
      // Get file extension
      String extension = profileimage.path.split('.').last.toLowerCase();
      String contentType = 'image/jpeg'; // default

      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          profileimage.path,
          contentType: MediaType.parse(contentType),
        ),
      );
    }

    print("Making profile update request with token");
    print("URL: $url");
    print(
      "Token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...",
    ); // Log partial token

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("Status code: ${response.statusCode}");
      print("Response: $responseData");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseData);

        if (jsonData['result'] == true) {
          print("Profile update successful");

          await prefs.setString("user_name", name);
          await prefs.setString("user_email", email);
          await prefs.setString("user_mobile", contact);
          await prefs.setString("user_dob", dob);

          // If the API returns a new token, update it
          if (jsonData['token'] != null) {
            await prefs.setString("token", jsonData['token']);
          }

          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Profile Updated Successfully",
            gravity: ToastGravity.BOTTOM,
          );

          // Return true instead of navigating
          return true;
        } else {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to update profile",
            gravity: ToastGravity.BOTTOM,
          );

          // Handle token expiration
          if (jsonData['error']?.contains('token') == true ||
              jsonData['message']?.toLowerCase().contains('token') == true) {
            // Clear invalid token
            await prefs.remove("token");
            Fluttertoast.showToast(
              msg: "Session expired. Please login again.",
              gravity: ToastGravity.BOTTOM,
            );
            Navigations.pushAndRemoveUntil(LoginPage(), context);
          }
          return false;
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token invalid/expired
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
        );
        await prefs.remove("token");
        Navigations.pushAndRemoveUntil(LoginPage(), context);
        return false;
      } else if (response.statusCode == 403) {
        // Forbidden
        Fluttertoast.showToast(
          msg: "Access denied. Please contact support.",
          gravity: ToastGravity.BOTTOM,
        );
        return false;
      } else {
        Fluttertoast.showToast(
          msg: "Server Error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
        );
        return false;
      }
    } on http.ClientException catch (e) {
      Fluttertoast.showToast(
        msg: "Network error: ${e.message}",
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    } on SocketException catch (e) {
      Fluttertoast.showToast(
        msg: "No internet connection",
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Exception: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    } finally {
      // Call onFinish callback
      onFinish();
    }
  }

  void updateUserStrings(
    BuildContext context,
    String email,
    String name,
    // String id,
    String contact,
    String dob,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print(" :::::::: $dob");
    // print(contact);
    var url = ProfileUpdateAPI;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_id = prefs.getString("user_id");

    if (user_id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }
    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add text fields
    request.fields['u_id'] = user_id;
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['mobile'] = contact;
    request.fields['dob'] = dob;
    print(request.fields['mobile']);

    print("going to try");
    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print(url);
      print("Status code ${response.statusCode}");
      print(responseData);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseData);

        if (jsonData['result'] == true) {
          // var user = jsonData['user'];
          print("in if");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("user_id", user_id.toString());
          prefs.setString("user_name", name ?? '');
          prefs.setString("user_email", email ?? '');
          prefs.setString("user_dob", dob ?? "");
          prefs.setBool("remember_me", true);

          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Profile Updated",
            gravity: ToastGravity.BOTTOM,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 4), context);
        } else {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Something went wrong",
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Server Error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Exception: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<bool> updateDocuments(
    BuildContext context,
    String id,
    File? licenseFront,
    File? licenseBack,
    File? adharFront,
    File? adharBack,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("Starting document upload...");
    // print("licenseFront: $licenseFront");
    // print("licenseBack: $licenseBack");
    // print("adharFront: $adharFront");
    // print("adharBack: $adharBack");

    onStart();

    try {
      var url = AddDocumentsAPI;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['u_id'] = id;

      // Add license front image
      if (licenseFront != null && licenseFront.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'licensefront',
            licenseFront.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Add license back image
      if (licenseBack != null && licenseBack.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'licenseback',
            licenseBack.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Add Aadhaar front image
      if (adharFront != null && adharFront.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'adharfront',
            adharFront.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Add Aadhaar back image
      if (adharBack != null && adharBack.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'adharback',
            adharBack.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("Response: $responseData");

      onFinish();

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseData);

        if (jsonData['result'] == true) {
          // Save status to SharedPreferences if needed
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (licenseFront != null || licenseBack != null) {
            prefs.setString("license", 'License Verified');
          }
          if (adharFront != null || adharBack != null) {
            prefs.setString("aadhar", 'Aadhaar Verified');
          }

          // Show success message
          Fluttertoast.showToast(
            msg: "Documents uploaded successfully!",
            backgroundColor: Colors.white,
            textColor: Colors.green,
          );

          return true;
        }
      }

      // Show error message
      Fluttertoast.showToast(
        msg: "Failed to upload documents",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    } catch (e) {
      print("Error uploading documents: $e");
      onFinish();

      // Show error message
      Fluttertoast.showToast(
        msg: "Error uploading documents: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
  }

  Future<void> supportRequest(
    String name,
    String? email,
    String message,
    String contact,
    String issuetype,
    File? image, // ✅ nullable
    VoidCallback onStart,
    VoidCallback onFinish, {
    required VoidCallback onSuccess,
  }) async {
    onStart();

    try {
      var url = Uri.parse(supportReqAPI);
      var request = http.MultipartRequest("POST", url);

      // fields
      request.fields['name'] = name;
      request.fields['email'] = email ?? "";
      request.fields['message'] = message;
      request.fields['phonenumber'] = contact;
      request.fields['issuetype'] = issuetype;

      // attach image safely
      if (image != null && image.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status'] == true) {
          onSuccess();
        } else {
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Something went wrong",
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to send request");
    } finally {
      onFinish();
    }
  }

  void addRating(
    BuildContext context,
    String user_id,
    String rating,
    String review,
    String booking_id,
    String bike_id,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("====================================");
    print("⭐ Add Rating");
    print("====================================");
    print("User ID: $user_id");
    print("Bike ID: $bike_id");
    print("Booking ID: $booking_id");
    print("Rating: $rating");
    print("Review: $review");

    onStart();

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No authentication token found!");
      Fluttertoast.showToast(
        msg: "Authentication required. Please login again.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      onFinish();
      return;
    }

    var data = {
      "bike_id": bike_id,
      "rating": rating,
      "review": review,
      "booking_id": booking_id,
      "user_id": user_id,
    };

    var url = AddRatingAPI;

    print("🌐 API URL: $url");
    print("📤 Request data: $data");
    print("🔑 Token: $token");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['result'] == true) {
          print("✅ Rating added successfully");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Rating added successfully",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 3), context);
        } else {
          print("❌ Failed to add rating");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to add rating",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 401) {
        print("🔒 Unauthorized - Token expired");
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      onFinish();
    }
  }

  void updatebookingstatus(
    BuildContext context,
    String user_id,
    String status,
    String booking_id,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("====================================");
    print("🔄 Update Booking Status");
    print("====================================");
    print("Booking ID: $booking_id");
    print("User ID: $user_id");
    print("Status: $status");

    onStart();

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No authentication token found!");
      Fluttertoast.showToast(
        msg: "Authentication required. Please login again.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      onFinish();
      return;
    }

    var data = {"b_id": booking_id, "b_status": status, "b_u_id": user_id};

    var url = BookingStatusAPI;

    print("🌐 API URL: $url");
    print("📤 Request data: $data");
    print("🔑 Token: ${token}...");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['result'] == true) {
          print("✅ Booking status updated successfully");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Status updated successfully",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 3), context);
        } else {
          print("❌ Failed to update booking status");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to update status",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 401) {
        print("🔒 Unauthorized - Token expired or invalid");
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      onFinish();
    }
  }

  // Extend booking function (different API endpoint)
  void extendBooking(
    BuildContext context,
    String user_id,
    String booking_id,
    String new_end_date,
    String new_end_time,
    String extend_hours,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("====================================");
    print("⏰ Extend Booking");
    print("====================================");
    print("Booking ID: $booking_id");
    print("User ID: $user_id");
    print("New End Date: $new_end_date");
    print("New End Time: $new_end_time");
    print("Extend Hours: $extend_hours");

    onStart();

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No authentication token found!");
      Fluttertoast.showToast(
        msg: "Authentication required. Please login again.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      onFinish();
      return;
    }

    var data = {
      "b_id": booking_id,
      "b_u_id": user_id,
      "new_end_date": new_end_date,
      "new_end_time": new_end_time,
      "extend_hours": extend_hours,
    };

    // Assuming you have an ExtendBookingAPI endpoint
    var url =
        ExtendbookingAPI; // Make sure this is defined in your apis.dart file

    print("🌐 API URL: $url");
    print("📤 Request data: $data");
    print("🔑 Token: ${token}...");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['result'] == true) {
          print("✅ Booking extended successfully");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Booking extended successfully",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 3), context);
        } else {
          print("❌ Failed to extend booking");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to extend booking",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 401) {
        print("🔒 Unauthorized - Token expired or invalid");
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      onFinish();
    }
  }

  // Extend booking function (different API endpoint)
  void cancelBooking(
    BuildContext context,
    String booking_id,
    String cancelReason,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("====================================");
    print("⏰ Extend Booking");
    print("====================================");
    print("Booking ID: $booking_id");
    print("Cancel Reason: $cancelReason");

    onStart();

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No authentication token found!");
      Fluttertoast.showToast(
        msg: "Authentication required. Please login again.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      onFinish();
      return;
    }

    var data = {"b_id": booking_id, "view_reason": cancelReason};

    // Assuming you have an ExtendBookingAPI endpoint
    var url =
        CancelBookingAPI; // Make sure this is defined in your apis.dart file

    print("🌐 API URL: $url");
    print("📤 Request data: $data");
    print("🔑 Token: ${token}...");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['result'] == true) {
          print("✅ Booking extended successfully");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Booking extended successfully",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 1), context);
        } else {
          print("❌ Failed to extend booking");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to extend booking",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 401) {
        print("🔒 Unauthorized - Token expired or invalid");
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      onFinish();
    }
  }

  // Extend booking function (different API endpoint)
  void downloadreceipt(
    BuildContext context,
    String booking_id,
    VoidCallback onStart,
    VoidCallback onFinish,
  ) async {
    print("====================================");
    print("⏰ Extend Booking");
    print("====================================");
    print("Booking ID: $booking_id");

    onStart();

    // Get token from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("❌ No authentication token found!");
      Fluttertoast.showToast(
        msg: "Authentication required. Please login again.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      onFinish();
      return;
    }

    var data = {"b_id": booking_id};

    // Assuming you have an ExtendBookingAPI endpoint
    var url =
        DownloadReceiptAPI; // Make sure this is defined in your apis.dart file

    print("🌐 API URL: $url");
    print("📤 Request data: $data");
    print("🔑 Token: ${token}...");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['result'] == true) {
          print("✅ Invoice has been sent successfully");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Invoice has been sent to your Email",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
          );

          Navigations.pushAndRemoveUntil(HomebottomBar(navindex: 1), context);
        } else {
          print("❌ Failed to extend booking");
          Fluttertoast.showToast(
            msg: jsonData['message'] ?? "Failed to send Invoice",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      } else if (response.statusCode == 401) {
        print("🔒 Unauthorized - Token expired or invalid");
        Fluttertoast.showToast(
          msg: "Session expired. Please login again.",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      } else {
        print("❌ Server error: ${response.statusCode}");
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("❌ Network error: $e");
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      onFinish();
    }
  }

  _showbottomsheet(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Account Created Successfully!", style: poppinscaps),
                    SizedBox(height: 10),
                    Text(
                      'Thanks for joining — your next ride is just a tap away',
                      style: normalgrey,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Image.asset(
                      'assets/giffys/regsheet.gif',
                      height: 180,
                      width: 180,
                    ),
                    SizedBox(height: 16),
                    GlobalButton(
                      text: "Let's Ride",
                      ontap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (route) => false,
                        );
                      },
                      context: context,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
