import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/404.dart';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/home.dart';
import 'package:easygonww/views/login.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashpage extends StatefulWidget {
  const Splashpage({super.key});

  @override
  State<Splashpage> createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  String? _location;
  String? _district;
  bool? nointernet;

  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    // Step 1: Check Internet
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        nointernet = true;
      });
      return;
    } else {
      setState(() {
        nointernet = false;
      });
    }

    // Step 2: Fetch Location
    // await _fetchLocation();

    // Step 3: Check Login & Navigate
    await _checkLoginAndNavigate();
  }

  // Future<void> _fetchLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     setState(() {
  //       _location = 'Turn on Location';
  //     });
  //     return;
  //   }

  //   PermissionStatus permissionStatus = await Permission.location.status;

  //   if (permissionStatus.isDenied || permissionStatus.isRestricted) {
  //     // Show prominent disclosure first
  //     bool consent = await showDialog(
  //       context: context,
  //       builder:
  //           (context) => AlertDialog(
  //             title: Text("Background Location Access"),
  //             content: Text(
  //               "EasyGo collects your location even when the app is closed or not in use. "
  //               "This is needed to [insert purpose: e.g., track your rides and provide accurate pickup]. "
  //               "Your location data is never sold to third parties.",
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, false),
  //                 child: Text("Deny"),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, true),
  //                 child: Text("Allow"),
  //               ),
  //             ],
  //           ),
  //     );

  //     if (consent == true) {
  //       permissionStatus = await Permission.locationAlways.request();
  //     } else {
  //       return; // user denied
  //     }
  //   } else if (permissionStatus.isPermanentlyDenied) {
  //     openAppSettings();
  //     return;
  //   }

  //   if (!permissionStatus.isGranted) return;

  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );

  //   if (placemarks.isNotEmpty) {
  //     Placemark place = placemarks.first;
  //     _location = place.locality ?? 'Unknown';
  //     _district = place.subAdministrativeArea ?? '';

  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString("user_location", _location ?? "Unknown");
  //     await prefs.setString("user_district", _district ?? "Unknown");

  //     print("Location saved: $_location ($_district)");
  //   } else {
  //     setState(() {
  //       _location = 'Could not fetch address.';
  //     });
  //   }
  // }

  Future<void> _checkLoginAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    print("loggin sts :  $token");

    await Future.delayed(const Duration(seconds: 2)); // small splash delay

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => token.isNotEmpty ? HomebottomBar() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: nointernet == true
          ? const ErrorPage()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  // const SizedBox(height: 10),
                  // Text("Fetching Your Location...", style: colortext),
                ],
              ),
            ),
    );
  }
}
