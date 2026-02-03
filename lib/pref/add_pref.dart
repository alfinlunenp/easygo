import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalPreference {
  late SharedPreferences _prefs;

  GlobalPreference() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> addlocation(String _location) async {
    await _initPrefs(); // ensure prefs is ready
    await _prefs.setString('location', _location);
  }

  Future<Map<String, dynamic>> readlocation() async {
    await _initPrefs();
    return {'location': _prefs.getString('location') ?? ''};
  }

  Future<Map<String, dynamic>> getlogin() async {
    await _initPrefs();
    return {
      'remember_me': _prefs.getBool('remember_me') ?? false,
      'user_email': _prefs.getString('user_email') ?? '',
      'user_password': _prefs.getString('user_password') ?? '',
    };
  }

  //   /// ✅ Save full login details
  //   Future<void> loginpreference(
  //     String id,
  //     String name,
  //     String email,
  //     String password,
  //     String contact,
  //     String location,
  //     String course_id,
  //     String resume_id,
  //     String status,
  //     String profile_url,
  //     BuildContext context,
  //   ) async {
  //     await _initPrefs(); // ensure prefs is ready
  //     await _prefs.setString('studentId', id);
  //     await _prefs.setString('studentname', name);
  //     await _prefs.setString('studentEmail', email);
  //     await _prefs.setString('studentPassword', password);
  //     await _prefs.setString('studentContact', contact);
  //     await _prefs.setString('studentLocation', location);
  //     await _prefs.setString('studentCourse_id', course_id);
  //     await _prefs.setString('studentResume_id', resume_id);
  //     await _prefs.setString('studentStatus', status);
  //     await _prefs.setString('studentProfile', profile_url);
  //     await _prefs.setBool('isLogged', true);

  //     Fluttertoast.showToast(
  //       msg: "Welcome $name",
  //       gravity: ToastGravity.CENTER,
  //     );

  //     // Navigator.pushReplacement(
  //     //   context,
  //     //   MaterialPageRoute(builder: (_) => HomePage()),
  //     // );
  //   }

  //   /// ✅ Read all preferences as a map
  // Future<Map<String, dynamic>> readPreference() async {
  //   await _initPrefs();
  //   return {
  //     'studentId': _prefs.getString('studentId') ?? '',
  //     'studentname': _prefs.getString('studentname') ?? '',
  //     'studentEmail': _prefs.getString('studentEmail') ?? '',
  //     'studentPassword': _prefs.getString('studentPassword') ?? '',
  //     'studentContact': _prefs.getString('studentContact') ?? '',
  //     'studentLocation': _prefs.getString('studentLocation') ?? '',
  //     'studentCourse_id': _prefs.getString('studentCourse_id') ?? '',
  //     'studentResume_id': _prefs.getString('studentResume_id') ?? '',
  //     'studentStatus': _prefs.getString('studentStatus') ?? '',
  //     'studentProfile': _prefs.getString('studentProfile') ?? '',
  //     'isLogged': _prefs.getBool('isLogged') ?? false,
  //   };
  // }

  //   /// ✅ New: Update specific profile fields
  //   Future<void> updatePreference({
  //     String? name,
  //     String? email,
  //     String? contact,
  //     String? location,
  //     String? password,
  //     BuildContext? context ,

  //   }) async {
  //     await _initPrefs();

  //     if (name != null) await _prefs.setString('studentname', name);
  //     if (email != null) await _prefs.setString('studentEmail', email);
  //     if (contact != null) await _prefs.setString('studentContact', contact);
  //     if (location != null) await _prefs.setString('studentLocation', location);
  //     if (password != null) await _prefs.setString('studentPassword', password);

  //     Fluttertoast.showToast(
  //       msg: "Profile updated successfully",
  //       gravity: ToastGravity.BOTTOM,
  //     );

  //     Navigator.pushAndRemoveUntil(
  //   context!,
  //   MaterialPageRoute(builder: (context) => HomePage()),
  //   (Route<dynamic> route) => false, // remove all previous routes
  // );

  //   }
  Future<void> clearUserSession() async {
    await _initPrefs();
    bool rememberMe = _prefs.getBool('remember_me') ?? false;

    await _prefs.remove('token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_name');
    await _prefs.remove('user_role');
    await _prefs.remove('user_mobile');
    await _prefs.remove('user_dob');

    if (!rememberMe) {
      await _prefs.remove('user_email');
      await _prefs.remove('user_password');
      await _prefs.remove('remember_me');
    }
  }
}
