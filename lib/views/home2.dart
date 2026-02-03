import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easygonww/APIs/apis.dart';
import 'package:easygonww/controllers/bookinglist.dart';
import 'package:easygonww/controllers/list.dart';
import 'package:easygonww/controllers/notificationslist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';

import 'package:easygonww/views/notification.dart';
import 'package:easygonww/views/pickundrop.dart';
import 'package:easygonww/views/skeltons/home_skeleton.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:easygonww/widgets/onride.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Enhanced Distance Calculator Utility
class DistanceCalculator {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    try {
      const double earthRadius = 6371; // Radius of the earth in km

      double dLat = _degreesToRadians(lat2 - lat1);
      double dLon = _degreesToRadians(lon2 - lon1);

      double a =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(_degreesToRadians(lat1)) *
              cos(_degreesToRadians(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);

      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = earthRadius * c; // Distance in km

      return distance;
    } catch (e) {
      print('Error in distance calculation: $e');
      return -1; // Return -1 to indicate error
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final BikeController _bikeController = BikeController();
  final MyBookingController _myBookingController = MyBookingController();
  final RentController _rentController = RentController();
  final NotificationController _notificationController =
      NotificationController();

  String? _location;
  String? _district;
  double? _currentLatitude;
  double? _currentLongitude;
  String? username;
  int selectedrentDurationID = 1;
  double? selectedrentAmount;
  String? selectedrentDuration;
  String? selectedrentDurationText;
  double? selectedgstamount;
  double? selectedrentdeposite;
  double? selectedtotalpayableamount;
  int? rentduration;
  String? rentdurationtext;

  double maxHeight = 70;
  double spacing = 80;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<BikeModel> _filteredBikeList = [];

  // Refresh indicator key
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // First get location, then fetch data
    await fetchlocationpref();
    await _getCurrentLocation();

    // Fetch data from controllers
    await Future.wait([
      // _bikeController.fetchBikes(),
      _myBookingController.fetchBikes(),
      _notificationController.fetchNotifications(),
      _rentController.fetchRent(),
    ]);

    // Set default selected rent (id = 1)
    if (_rentController.rentList.isNotEmpty) {
      RentModel? defaultRent = _rentController.rentList.firstWhere(
        (rent) => rent.rentId == 1,
        orElse: () => _rentController.rentList.first,
      );

      setState(() {
        selectedrentDurationID = defaultRent.rentId;
        selectedrentAmount = double.parse(defaultRent.rentAmount.toString());
        selectedrentDuration = defaultRent.rentDurationText;
        selectedtotalpayableamount = defaultRent.rentTotal;
        selectedgstamount = defaultRent.rentGst;
        selectedrentdeposite = double.parse(defaultRent.rentDeposit.toString());
        rentduration = defaultRent.rentDuration;
        rentdurationtext = defaultRent.rentDurationText;
      });
    }

    // Set up search listener after initial data load
    _searchController.addListener(_onSearchChanged);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Method to trigger refresh manually if needed
  Future<void> _refreshData() async {
    print("Refreshing data...");
    await _initializeApp();
    print("Data refresh completed.");
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (mounted) {
        setState(() {
          if (_location == null) _location = 'Getting location...';
        });
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        if (mounted) {
          setState(() {
            _location = 'Location services disabled';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          if (mounted) {
            setState(() {
              _location = 'Location permission denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        if (mounted) {
          setState(() {
            _location = 'Location permanently denied';
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 10),
      ).timeout(Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }

      print('Current location obtained: $_currentLatitude, $_currentLongitude');

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName =
            place.locality ?? place.subAdministrativeArea ?? 'Unknown Location';

        if (mounted) {
          setState(() {
            _location = locationName;
            _district = place.subAdministrativeArea ?? '';
          });
        }

        // Save to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_location", _location!);
        await prefs.setDouble("user_latitude", _currentLatitude!);
        await prefs.setDouble("user_longitude", _currentLongitude!);
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        setState(() {
          _location = 'Unable to fetch location';
        });
      }

      // Try to get cached location from preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      double? cachedLat = prefs.getDouble("user_latitude");
      double? cachedLon = prefs.getDouble("user_longitude");

      if (cachedLat != null && cachedLon != null) {
        if (mounted) {
          setState(() {
            _currentLatitude = cachedLat;
            _currentLongitude = cachedLon;
          });
        }
        print('Using cached location: $_currentLatitude, $_currentLongitude');
      }
    }
  }

  Future<void> fetchlocationpref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _location = prefs.getString("user_location") ?? 'Fetching location...';
        // Also try to get cached coordinates
        _currentLatitude ??= prefs.getDouble("user_latitude");
        _currentLongitude ??= prefs.getDouble("user_longitude");
        username ??= prefs.getString("user_name");
      });
    }
  }

  // Helper method to parse coordinate safely with better validation
  double? _parseCoordinate(dynamic coordinate) {
    if (coordinate == null) return null;

    try {
      if (coordinate is double) {
        return coordinate != 0.0 ? coordinate : null;
      }
      if (coordinate is int) {
        return coordinate != 0 ? coordinate.toDouble() : null;
      }
      if (coordinate is String) {
        if (coordinate.isEmpty || coordinate.toLowerCase() == 'null') {
          return null;
        }
        double? parsed = double.tryParse(coordinate);
        return parsed != 0.0 ? parsed : null;
      }
      return null;
    } catch (e) {
      print('Error parsing coordinate: $e, value: $coordinate');
      return null;
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBikeList = _bikeController.bikeList.where((bike) {
        String name = bike.bName?.toLowerCase() ?? '';
        String location = bike.bLocation?.toLowerCase() ?? '';
        String model = bike.bGeartype?.toLowerCase() ?? '';
        return name.contains(query) ||
            location.contains(query) ||
            model.contains(query);
      }).toList();
    });
  }

  // Helper method to get display distance with better formatting
  String _getDisplayDistance(BikeModel bikeModel) {
    // Use the calculated distance from the bike model
    if (bikeModel.distance != null && bikeModel.distance! > 0) {
      if (bikeModel.distance! < 1) {
        // Less than 1 km, show in meters
        return "${(bikeModel.distance! * 1000).toInt()} m";
      } else if (bikeModel.distance! < 10) {
        // Less than 10 km, show one decimal
        return "${bikeModel.distance!.toStringAsFixed(1)} km";
      } else {
        // 10 km or more, show integer
        return "${bikeModel.distance} km";
      }
    }

    // Fallback: Try to calculate on the fly if not pre-calculated
    if (_currentLatitude != null && _currentLongitude != null) {
      double? bikeLat = _parseCoordinate(bikeModel.bLatitude);
      double? bikeLon = _parseCoordinate(bikeModel.bLongitude);

      if (bikeLat != null && bikeLon != null) {
        try {
          double distance = DistanceCalculator.calculateDistance(
            _currentLatitude!,
            _currentLongitude!,
            bikeLat,
            bikeLon,
          );

          if (distance >= 0) {
            if (distance < 1) {
              return "${(distance * 1000).toInt()} m";
            } else if (distance < 10) {
              return "${distance.toStringAsFixed(1)} km";
            } else {
              return "${distance.toInt()} km";
            }
          }
        } catch (e) {
          print('Error calculating on-the-fly distance: $e');
        }
      }
    }

    return "N/A"; // Default when distance cannot be calculated
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<BookingModel> onrideList = _myBookingController.mybookingList
        .where(
          (booking) =>
              booking.bStatus == 'onride' ||
              booking.bStatus == 'extendedreq' ||
              booking.bStatus == 'extended',
        )
        .toList();

    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    super.build(context);

    // Main content widget that will be wrapped with RefreshIndicator
    Widget buildContent() {
      return Padding(
        padding: EdgeInsets.only(
          top: onrideList.isEmpty ? 0 : MediaQuery.of(context).padding.top,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              onrideList.isNotEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [OnrideWidget()],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8,
                        top: kToolbarHeight,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// CENTER - TITLE (Perfectly Centered)
                          Text(
                            'Easy Go',
                            style: largelack.copyWith(color: primaryColor),
                          ),

                          /// LEFT + RIGHT CONTENT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// LEFT SIDE - LOCATION
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon(
                                  //   Icons.location_on,
                                  //   color: secondprimaryColor,
                                  //   size: 20,
                                  // ),
                                  // const SizedBox(width: 4),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text(
                                  //       'Current location',
                                  //       style: smalltextblk,
                                  //     ),
                                  //     const SizedBox(height: 4),
                                  //     SizedBox(
                                  //       width: 120, // optional
                                  //       child: Text(
                                  //         _location ?? 'Fetching...',
                                  //         style: smalltextblk,
                                  //         overflow: TextOverflow.ellipsis,
                                  //         maxLines: 2,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),

                              /// RIGHT - NOTIFICATION ICON
                              GestureDetector(
                                onTap: () {
                                  Navigations.push(NotificationPage(), context);
                                },
                                child: CircleAvatar(
                                  backgroundColor: secondprimaryColor
                                      .withOpacity(0.2),
                                  child: Stack(
                                    children: [
                                      Icon(
                                        Icons.notifications_rounded,
                                        color: secondprimaryColor,
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 12,
                                              minHeight: 12,
                                            ),
                                            // child: Text(
                                            //   '$unreadCount',
                                            //   style: TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: 8,
                                            //   ),
                                            //   textAlign: TextAlign.center,
                                            // ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello,",
                      style: mediumgrey,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1000,
                    ),

                    Text(
                      "${username ?? 'User'}!",
                      style: largelack,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1000,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: isLoading
                    ? Center(child: HomeSkeleton())
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,

                          // image: DecorationImage(
                          //   image: AssetImage('assets/giffys/bgimg.png'),
                          //   fit: BoxFit.fitHeight,
                          // ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(padding),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      secondprimaryColor.withOpacity(0.2),
                                    ],
                                  ),

                                  borderRadius: BorderRadius.circular(
                                    borderradius,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(padding),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 16),
                                      Text(
                                        '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            167,
                                            178,
                                            179,
                                            170,
                                          ).withOpacity(0.2),
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/home/homeimg.png',
                                        width: 300,
                                      ),
                                      SizedBox(height: 10),

                                      Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '25 KM / hr',
                                                style: normalblack,
                                              ),
                                              Text(
                                                'MAX SPEED',
                                                style: smalltextgrey,
                                              ),
                                            ],
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '130 KM',
                                                style: normalblack,
                                              ),
                                              Text(
                                                'RANGE',
                                                style: smalltextgrey,
                                              ),
                                            ],
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text('250 W', style: normalblack),
                                              Text(
                                                'MOTOR',
                                                style: smalltextgrey,
                                              ),
                                            ],
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '250 KG',
                                                style: normalblack,
                                              ),
                                              Text(
                                                'MAX LOAD',
                                                style: smalltextgrey,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),

                                      Container(
                                        height: 50,
                                        // remove fixed height and width
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap:
                                              true, // makes ListView take only required space
                                          itemCount:
                                              _rentController.rentList.length,
                                          itemBuilder: (context, index) {
                                            RentModel rentModel =
                                                _rentController.rentList[index];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8,
                                                  ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedrentDurationID =
                                                        rentModel.rentId;
                                                    selectedrentAmount =
                                                        double.parse(
                                                          rentModel.rentAmount
                                                              .toString(),
                                                        );
                                                    selectedrentDuration =
                                                        rentModel.rentDuration
                                                            .toString();
                                                    selectedtotalpayableamount =
                                                        rentModel.rentTotal;
                                                    selectedgstamount =
                                                        rentModel.rentGst;
                                                    selectedrentdeposite =
                                                        double.parse(
                                                          rentModel.rentDeposit
                                                              .toString(),
                                                        );
                                                    selectedrentDurationText =
                                                        rentModel
                                                            .rentDurationText;
                                                    rentduration =
                                                        rentModel.rentDuration;
                                                    rentdurationtext = rentModel
                                                        .rentDurationText;
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selectedrentDurationID ==
                                                            rentModel.rentId
                                                        ? secondprimaryColor
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          selectedrentDurationID ==
                                                              rentModel.rentId
                                                          ? Colors.transparent
                                                          : const Color.fromARGB(
                                                              255,
                                                              216,
                                                              216,
                                                              216,
                                                            ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${rentModel.rentDurationText}",
                                                      style:
                                                          selectedrentDurationID ==
                                                              rentModel.rentId
                                                          ? normalwhite
                                                          : normalblack,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.visible,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("Rs: ", style: largelack),
                                          Text(
                                            "$selectedrentAmount",
                                            style: largelack,
                                            maxLines: 1,
                                            overflow: TextOverflow.visible,
                                            softWrap: false,
                                          ),
                                          Text(
                                            ' (For ${selectedrentDuration})',
                                            style: smalltextgrey,
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),
                                      GlobalButton(
                                        ontap: () {
                                          Navigations.push(
                                            PickundropPage(
                                              rentamount:
                                                  selectedrentAmount ?? 0.00,
                                              gstamount:
                                                  selectedgstamount ?? 0.00,
                                              rentdeposite:
                                                  selectedrentdeposite ?? 0.00,
                                              totalpayableamount:
                                                  selectedtotalpayableamount ??
                                                  0.00,
                                              rentID: selectedrentDurationID
                                                  .toString(),
                                              rentDurationText:
                                                  selectedrentDurationText ??
                                                  "",
                                              rentDuration: rentduration ?? 0,
                                            ),
                                            context,
                                          );
                                        },
                                        backgroundcolor: secondprimaryColor,
                                        bordercolor: Colors.transparent,
                                        text: "Rent Now",
                                        context: context,
                                      ),
                                      SizedBox(height: 5),

                                      Text(
                                        'Final amount including GST & deposit shown next',
                                        style: smalltextblk.copyWith(
                                          color: secondprimaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        color: primaryColor, // Use your app's primary color
        backgroundColor: Colors.white,
        strokeWidth: 2.0,
        displacement: 40.0,
        edgeOffset: 0.0,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                // Added SingleChildScrollView to make RefreshIndicator work
                physics: const AlwaysScrollableScrollPhysics(),
                child: buildContent(),
              ),
      ),
    );
  }
}
