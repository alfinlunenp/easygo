import 'dart:math';
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
import 'package:easygonww/views/allbikes.dart';
import 'package:easygonww/views/bikesdetailed.dart';
import 'package:easygonww/views/bottombar/home_bottombar.dart';
import 'package:easygonww/views/notification.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:easygonww/widgets/onride.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keeps the widget alive in memory

  BikeController _bikeController = BikeController();
  NotificationController _notificationController = NotificationController();
  String? _location;
  String? _district;
  double maxHeight = 70;
  double spacing = 80;

  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<BikeModel> _filteredBikeList = [];

  @override
  void initState() {
    super.initState();
    loadlocationdetails();
    print("object 1");
    fetchdata();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchdata() async {
    isLoading = true;
    print("object 2");
    await _bikeController.fetchBikes();
    setState(() {
      _filteredBikeList = List.from(_bikeController.bikeList);
      print("bike list in home");
      print(_bikeController.bikeList[0]);
      isLoading = false;
    });
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

  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};

  Future<void> loadlocationdetails() async {
    Map<String, dynamic> data = await prefs.readlocation();
    setState(() {
      locationdata = data;
      _location = data['location'];
      print(_location);
    });
  }

  bool _isImagePrecached = false;
  final AssetImage _homeIcon = const AssetImage('assets/home/homeicon.png');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      precacheImage(_homeIcon, context).then((_) {
        if (mounted) {
          setState(() {
            _isImagePrecached = true;
          });
        }
      });
    }
  }

  Future<void> fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Turn on Location';
      });
      return;
    }

    PermissionStatus permissionStatus = await Permission.location.status;

    if (permissionStatus.isGranted) {
      _getLocation();
    } else if (permissionStatus.isDenied) {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        _getLocation();
      } else {
        print('Location Permission Denied');
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _location = place.locality ?? 'Unknown';
        _district = place.subAdministrativeArea ?? '';

        GlobalPreference().addlocation(_location.toString());
      });
    } else {
      setState(() {
        _location = 'Could not fetch address.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BikeModel> onrideList = _bikeController.bikeList
        .where((booking) => booking.bStatus == 'onride')
        .toList();

    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    super.build(context);
    return Skeletonizer(
      child: Padding(
        padding: EdgeInsets.only(
          top: onrideList.isEmpty ? 0 : MediaQuery.of(context).padding.top,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              onrideList.isNotEmpty
                  ? OnrideWidget()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: double.infinity,
                        height: 430,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _homeIcon,
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30.0,
                            horizontal: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        // Expanded(
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.start,
                                        //     children: [
                                        //       Text('Current location',
                                        //           style: normalwhite),
                                        //       const SizedBox(height: 4),
                                        //       Text(
                                        //         _location ?? 'Fetching...',
                                        //         style: normalwhite,
                                        //         overflow: TextOverflow.ellipsis,
                                        //         maxLines: 1,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print("notii");
                                          Navigations.push(
                                            NotificationPage(),
                                            context,
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                          child: const Icon(
                                            Icons.notifications_rounded,
                                            color: Colors.white,
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
                                            //   style: const TextStyle(
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
                              SizedBox(height: 24),
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
                                      child: TextField(
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
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'MOST RATED',
                                  style: poppinscapswhite,
                                ),
                              ),
                              const SizedBox(height: 0),
                              Center(
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: List.generate(
                                    _bikeController.topRatedBikes.length,
                                    (index) {
                                      BikeModel bikeModel =
                                          _bikeController.topRatedBikes[index];

                                      double x =
                                          index -
                                          (_bikeController
                                                      .topRatedBikes
                                                      .length -
                                                  1) /
                                              2;
                                      double y =
                                          -1 * pow(x, 2) * 20 + maxHeight;
                                      print(bikeModel.bImage);
                                      return Transform.translate(
                                        offset: Offset(x * spacing, y),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 32,
                                              backgroundColor: Colors.white,
                                              child: Image.network(
                                                "https://lunarsenterprises.com:6032/${bikeModel.bImage}" ??
                                                    "",
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
                                                        child: Image.network(
                                                          fit: BoxFit.cover,
                                                          '$Noimage',
                                                        ),
                                                      );
                                                      ;
                                                    },
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ), // Add spacing between image and text
                                            Container(
                                              width:
                                                  80, // Constrain the width of the text container
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Text(
                                                bikeModel.bName ?? "",
                                                style: smalltextwhite,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "What's Available Around You?",
                        style: mediumblack,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1000,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigations.push(HomebottomBar(navindex: 1), context);
                      },
                      child: Text("view all", style: normalblack),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredBikeList.isEmpty
                    ? Center(child: Text("No bikes found", style: smalltextblk))
                    : ListView.builder(
                        itemCount: _filteredBikeList.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          BikeModel bikeModel = _filteredBikeList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {},
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
                                                  bikeModel.bImage ?? "",
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
                                                        return CircularProgressIndicator();
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
                                                      topRight: Radius.circular(
                                                        8,
                                                      ),
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
                                                      "${bikeModel.distance.toString()} km",
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        bikeModel.bName ?? "",
                                                        style: mediumblack,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 100,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          const Text(
                                                            '(',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 16,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              bikeModel.bRatings
                                                                  .toString(),
                                                              style:
                                                                  normalblack,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                          const Text(
                                                            ')',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        '${bikeModel.bPrice} /Day',
                                                        style: normalblack,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${bikeModel.bikereviews.length} reviews",
                                                        style: normalblack,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
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
                                                      "Maximum speed ${bikeModel.maxSpeed}",
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
                                                      "mileage ${bikeModel.bMilage}",
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
                                                      "${bikeModel.bBhp.toString()} bhp",
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
                                                onTap: () {},
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
              ),
              SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
