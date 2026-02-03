import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easygonww/controllers/list.dart';
import 'package:easygonww/controllers/notificationslist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/bikesdetailed.dart';
import 'package:easygonww/views/notification.dart';
import 'package:easygonww/widgets/appbarnull.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllbikesSkeleton extends StatefulWidget {
  String? name;
  AllbikesSkeleton({super.key, this.name});

  @override
  State<AllbikesSkeleton> createState() => _AllbikesSkeletonState();
}

class _AllbikesSkeletonState extends State<AllbikesSkeleton> {
  // String? _location;
  String? _district;
  double maxHeight = 70;
  double spacing = 80;

  TextEditingController _searchController = TextEditingController();
  BikeController _bikecontroller = BikeController();
  NotificationController _notificationController = NotificationController();
  // List<Map<String, dynamic>> _filteredBikeList = [];
  List<BikeModel> _filteredBikeList = [];

  @override
  void initState() {
    super.initState();
    fetchdata();
    loadlocationdetails();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchdata() async {
    await _bikecontroller.fetchBikes();
    setState(() {
      _filteredBikeList = List.from(_bikecontroller.bikeList);
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

  // Future<void> fetchLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     setState(() {
  //       _location = 'Turn on Location';
  //     });
  //     return;
  //   }

  //   PermissionStatus permissionStatus = await Permission.location.status;

  //   if (permissionStatus.isGranted) {
  //     _getLocation();
  //   } else if (permissionStatus.isDenied) {
  //     PermissionStatus status = await Permission.location.request();
  //     if (status.isGranted) {
  //       _getLocation();
  //     } else {
  //       print('Location Permission Denied');
  //     }
  //   } else if (permissionStatus.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }

  // Future<void> _getLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );

  //   if (placemarks.isNotEmpty) {
  //     Placemark place = placemarks.first;
  //     setState(() {
  //       _location = place.locality ?? 'Unknown';
  //       _district = place.subAdministrativeArea ?? '';
  //     });
  //   } else {
  //     setState(() {
  //       _location = 'Could not fetch address.';
  //     });
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};
  String? _location;

  Future<void> loadlocationdetails() async {
    Map<String, dynamic> data = await prefs.readlocation();
    setState(() {
      locationdata = data;
      _location = data['location'];
      print(_location);
    });
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    return Skeletonizer(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  // this allows it to flex within space
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text('Current location', style: normalblack),
                                      // Text(
                                      //   _location ?? 'Fetching...',
                                      //   style: mediumblack,
                                      //   overflow: TextOverflow.ellipsis,
                                      //   maxLines: 1,
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigations.push(NotificationPage(), context);
                                },
                                child: CircleAvatar(
                                  backgroundColor: primaryColor.withOpacity(
                                    0.2,
                                  ),
                                  child: Icon(
                                    Icons.notifications_rounded,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    // child: Text(
                                    //   unreadCount.toString(),
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     fontSize: 10,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    //   textAlign: TextAlign.center,
                                    // ),
                                  ),
                                ),
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
                              child: Icon(Icons.search, color: Colors.grey),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search by bike model or location",
                                  hintStyle: normalgrey,
                                  contentPadding: const EdgeInsets.symmetric(
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
                    padding: EdgeInsets.zero, // Remove default padding

                    itemBuilder: (context, index) {
                      BikeModel bikemodel = _filteredBikeList[index];
                      // final bike = _filteredBikeList[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigations.push(Bikesdetailed(bikemodel: bikemodel , bikeReviewModel: bikemodel.bikereviews,), context);
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                  ),
                                  child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomLeft,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 3 / 4,
                                            child: Image.network(
                                              bikemodel.bImage ?? " ",
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
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Skeletonizer(
                                                      child: Image.network(
                                                        fit: BoxFit.cover,
                                                        '$Noimage',
                                                      ),
                                                    );
                                                    ;
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
                                                  topRight: Radius.circular(8),
                                                  bottomLeft: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
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
                                                  "${bikemodel.distance.toString()} km ",
                                                  style: normalwhite,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Bike name with ellipsis
                                            Expanded(
                                              child: Text(
                                                bikemodel.bName ?? " ",
                                                style: mediumblack,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1000,
                                              ),
                                            ),

                                            // Rating with ellipsis protection
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '(',
                                                    style: normalblack,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  Text(
                                                    ')',
                                                    style: normalblack,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Rent text with overflow protection
                                            Expanded(
                                              child: Text(
                                                '${bikemodel.bPrice}/Day',
                                                style: normalblack,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 100,
                                              ),
                                            ),

                                            SizedBox(width: 8),

                                            // Reviews text with overflow protection
                                            Expanded(
                                              child: Text(
                                                "${bikemodel.bikereviews.length} reviews",
                                                style: normalblack,
                                                textAlign: TextAlign.end,
                                                overflow: TextOverflow.ellipsis,
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
                                                  "Max speed ${bikemodel.maxSpeed} km/hr",
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
                                              // Navigations.push(Bikesdetailed(bikemodel: bikemodel, bikeReviewModel: bikemodel.bikereviews), context);
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
                                              bordercolor: Colors.transparent,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
