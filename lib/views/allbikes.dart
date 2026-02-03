import 'dart:math';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/bikesdetailed.dart';
import 'package:easygonww/views/notification.dart';
import 'package:easygonww/views/skeltons/allbike_skeleton.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Distance Calculator Utility
class DistanceCalculator {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
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
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class Allbikes extends StatefulWidget {
  String? name;
  Allbikes({super.key, this.name});

  @override
  State<Allbikes> createState() => _AllbikesState();
}

class _AllbikesState extends State<Allbikes> {
  String? _location;
  String? _district;
  double? _currentLatitude;
  double? _currentLongitude;
  double maxHeight = 70;
  double spacing = 80;

  TextEditingController _searchController = TextEditingController();
  BikeController _bikecontroller = BikeController();
  NotificationController _notificationController = NotificationController();
  List<BikeModel> _filteredBikeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeLocationAndData() async {
    await fetchlocationpref();
    await _getCurrentLocation();
    await fetchdata();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });

      print('Current location: $_currentLatitude, $_currentLongitude');

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _location = place.locality ?? 'Unknown Location';
          _district = place.subAdministrativeArea ?? '';
        });

        // Save to shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_location", _location!);
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _location = 'Unable to fetch location';
      });
    }
  }

  // Helper method to parse coordinate safely
  double? _parseCoordinate(dynamic coordinate) {
    if (coordinate == null) return null;

    try {
      if (coordinate is double) return coordinate;
      if (coordinate is int) return coordinate.toDouble();
      if (coordinate is String) {
        return double.tryParse(coordinate);
      }
      return null;
    } catch (e) {
      print('Error parsing coordinate: $e');
      return null;
    }
  }

  Future<void> fetchdata() async {
    setState(() {
      isLoading = true;
    });

    await _bikecontroller.fetchBikes();
    await _notificationController.fetchNotifications();

    // Calculate distances for each bike if we have current location
    if (_currentLatitude != null && _currentLongitude != null) {
      print(
        "Calculating distances for ${_bikecontroller.bikeList.length} bikes...",
      );
      print("Current location: $_currentLatitude, $_currentLongitude");

      for (var bike in _bikecontroller.bikeList) {
        // Parse coordinates safely
        double? bikeLat = _parseCoordinate(bike.bLatitude);
        double? bikeLon = _parseCoordinate(bike.bLongitude);

        // Check if bike has valid coordinates
        if (bikeLat == null ||
            bikeLon == null ||
            bikeLat == 0.0 ||
            bikeLon == 0.0) {
          bike.distance = 0; // Set to null instead of 1
          print(
            'Bike ${bike.bName}: No valid coordinates (lat: $bikeLat, lon: $bikeLon), setting to null',
          );
          continue;
        }

        try {
          double distance = DistanceCalculator.calculateDistance(
            _currentLatitude!,
            _currentLongitude!,
            bikeLat,
            bikeLon,
          );

          // Update the bike's distance
          bike.distance = distance.toInt();
          print(
            'Bike ${bike.bName}: ${distance.toStringAsFixed(1)} km away (bike location: $bikeLat, $bikeLon)',
          );
        } catch (e) {
          print('Error calculating distance for bike ${bike.bName}: $e');
          bike.distance = 0; // Set to null on error instead of 1
        }
      }
    } else {
      print('Current location not available, setting distances to null');
      for (var bike in _bikecontroller.bikeList) {
        bike.distance = 0; // Set to null when no location
      }
    }

    setState(() {
      _filteredBikeList = List.from(_bikecontroller.bikeList);
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBikeList = _bikecontroller.bikeList.where((bike) {
        String name = bike.bName?.toLowerCase() ?? '';
        String rent = bike.bPrice?.toString().toLowerCase() ?? '';
        return name.contains(query) || rent.contains(query);
      }).toList();
    });
  }

  // Helper method to get display distance
  // Helper method to get display distance
  String _getDisplayDistance(BikeModel bikeModel) {
    // If distance is already calculated and valid, use it
    if (bikeModel.distance != null && bikeModel.distance! > 0) {
      return "${bikeModel.distance} km";
    }

    // If distance is null or 0, try to calculate it
    if (_currentLatitude != null && _currentLongitude != null) {
      double? bikeLat = _parseCoordinate(bikeModel.bLatitude);
      double? bikeLon = _parseCoordinate(bikeModel.bLongitude);

      if (bikeLat != null &&
          bikeLon != null &&
          bikeLat != 0.0 &&
          bikeLon != 0.0) {
        try {
          double distance = DistanceCalculator.calculateDistance(
            _currentLatitude!,
            _currentLongitude!,
            bikeLat,
            bikeLon,
          );
          return "${distance.toStringAsFixed(1)} km";
        } catch (e) {
          print('Error calculating distance for display: $e');
          return "N/A";
        }
      }
    }

    return "N/A"; // Default fallback when no valid data
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};

  Future<void> fetchlocationpref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _location = prefs.getString("user_location") ?? 'Fetching location...';
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? AllbikesSkeleton()
          : GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  currentFocus.unfocus();
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Expanded(
                                //   child: Row(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Icon(Icons.location_on, color: primaryColor, size: 16),
                                //       const SizedBox(width: 4),
                                //       Expanded(
                                //         child: Column(
                                //           crossAxisAlignment: CrossAxisAlignment.start,
                                //           children: [
                                //             Text('Current location', style: normalblack),
                                //             Text(
                                //               _location ?? 'Fetching...',
                                //               style: normalblack,
                                //               overflow: TextOverflow.ellipsis,
                                //               maxLines: 1,
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigations.push(
                                          NotificationPage(),
                                          context,
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: primaryColor
                                            .withOpacity(0.2),
                                        child: Icon(
                                          Icons.notifications_rounded,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    // if (unreadCount > 0)
                                    //   Positioned(
                                    //     right: 2,
                                    //     top: 2,
                                    //     child: Container(
                                    //       padding: const EdgeInsets.all(2),
                                    //       decoration: const BoxDecoration(
                                    //         color: Colors.red,
                                    //         shape: BoxShape.circle,
                                    //       ),
                                    //       constraints: const BoxConstraints(
                                    //         minWidth: 16,
                                    //         minHeight: 16,
                                    //       ),
                                    //       child: Text(
                                    //         unreadCount.toString(),
                                    //         style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontSize: 10,
                                    //           fontWeight: FontWeight.bold,
                                    //         ),
                                    //         textAlign: TextAlign.center,
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Globalcontainer(
                              height: 50,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            "Search by bike model or location",
                                        hintStyle: normalgrey,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        ListView.builder(
                          itemCount: _filteredBikeList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            BikeModel bikemodel = _filteredBikeList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigations.push(
                                  Bikesdetailed(
                                    bikemodel: bikemodel,
                                    bikeReviewModel: bikemodel.bikereviews,
                                    BikeImages: bikemodel.bikeimages,
                                  ),
                                  context,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: containerColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE4E4E7),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 0.0,
                                        ),
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.bottomLeft,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: AspectRatio(
                                                  aspectRatio: 3 / 4,
                                                  child: Image.network(
                                                    bikemodel
                                                            .bikeimages
                                                            .isNotEmpty
                                                        ? "https://lunarsenterprises.com:6032/${bikemodel.bikeimages[0].imagePath}"
                                                        : "$Noimage",
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Image.network(
                                                          fit: BoxFit.cover,
                                                          '$Noimage',
                                                        ),
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Skeletonizer(
                                                            child:
                                                                Image.network(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  '$Noimage',
                                                                ),
                                                          );
                                                        },
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 80,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: secondaryColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        _getDisplayDistance(
                                                          bikemodel,
                                                        ),
                                                        style: normalwhite,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      bikemodel.bName ?? " ",
                                                      style: mediumblack,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1000,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          '(',
                                                          style: normalblack,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            bikemodel.bRatings
                                                                .toString(),
                                                            style: normalblack,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        Text(
                                                          ')',
                                                          style: normalblack,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${bikemodel.bPrice}/Day',
                                                      style: normalblack,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 100,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "${bikemodel.bikereviews.length} reviews",
                                                      style: normalblack,
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            borderradius,
                                                          ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12.0,
                                                            vertical: 4,
                                                          ),
                                                      child: Text(
                                                        "Maximum speed ${bikemodel.maxSpeed}",
                                                        style: colortextmall,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            borderradius,
                                                          ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12.0,
                                                            vertical: 4,
                                                          ),
                                                      child: Text(
                                                        "mileage ${bikemodel.bMilage}",
                                                        style: colortextmall,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            borderradius,
                                                          ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12.0,
                                                            vertical: 4,
                                                          ),
                                                      child: Text(
                                                        "maxPower ${bikemodel.bBhp}",
                                                        style: colortextmall,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 16.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigations.push(
                                                      Bikesdetailed(
                                                        bikemodel: bikemodel,
                                                        bikeReviewModel:
                                                            bikemodel
                                                                .bikereviews,
                                                        BikeImages: bikemodel
                                                            .bikeimages,
                                                      ),
                                                      context,
                                                    );
                                                  },
                                                  child: Globalcontainer(
                                                    bgcolor: primaryColor,
                                                    width: double.infinity,
                                                    child: Center(
                                                      child: Text(
                                                        "Rent Now",
                                                        style: normalwhite,
                                                      ),
                                                    ),
                                                    bordercolor:
                                                        Colors.transparent,
                                                    textstyle: normalwhite,
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
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
