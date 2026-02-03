import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/controllers/bookinglist.dart';
import 'package:easygonww/controllers/notificationslist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/extendbooking.dart';
import 'package:easygonww/views/notification.dart';
import 'package:easygonww/views/rating.dart';
import 'package:easygonww/views/skeltons/booking_skeleton.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Mybookings extends StatefulWidget {
  dynamic? paymentStatus;
  Mybookings({super.key, this.paymentStatus});

  @override
  State<Mybookings> createState() => _MybookingsState();
}

class _MybookingsState extends State<Mybookings> {
  String selectedStatus = 'All';
  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};
  String? _location;
  String? user_id;
  String reason = "This is the static reason declared before @onride";
  String customercontact = "";
  TextEditingController _reasoncontrller = TextEditingController();
  bool _buttonLoading = false; // only for button

  bool isLoading = true; // <-- added
  MyBookingController _bookingController = MyBookingController();
  UserController _userController = UserController();

  NotificationController _notificationController = NotificationController();

  @override
  void initState() {
    super.initState();
    getpref();
    fetchlocationpref();
    fetchnotifications();
  }

  Future<void> fetchnotifications() async {
    await _notificationController.fetchNotifications();
    setState(() {});
  }

  Future<void> getpref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    print("Fetching from prefs...");

    user_id = pref.getString("user_id");
    print("User ID from prefs: $user_id");

    if (user_id != null) {
      await fetchdata(user_id!);
    }

    setState(() {
      isLoading = false; // <-- stop loading after fetch
    });
  }

  Future<void> fetchdata(String userId) async {
    print("Fetching bikes for: $userId");
    await _bookingController.fetchBikes();
    await _userController.fetchUser("admin");
    setState(() {});

    if (_userController.userList.isNotEmpty) {
      final user = _userController.userList.first;

      setState(() {
        customercontact = user.uMobile.toString();
      });
    }
  }

  Future<void> fetchlocationpref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _location = prefs.getString("user_location");
  }

  @override
  Widget build(BuildContext context) {
    // Replace your current filtering logic with this corrected version
    final filteredBookings = selectedStatus == 'All'
        ? _bookingController.mybookingList
        : _bookingController.mybookingList.where((booking) {
            // Convert both to lowercase for case-insensitive comparison
            String bookingStatus = booking.bStatus.toLowerCase();
            String selected = selectedStatus.toLowerCase();

            switch (selected) {
              case 'on ride':
                return bookingStatus == 'onride';
              case 'upcoming':
                return bookingStatus == 'approved';
              case 'completed':
                return bookingStatus == 'completed';
              case 'cancelreq':
                return bookingStatus == 'cancelreq';
              case 'cancelled':
                return bookingStatus == 'cancelled';
              case 'pending': // Added this case
                return bookingStatus == 'pending';
              case 'extendedreq': // Added this case
                return bookingStatus == 'extendedreq';
              default:
                return false; // Changed from true to false for safety
            }
          }).toList();

    // Helper function
    Color _getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return Color(0xFFB3009F);
        case 'completed':
          return Color(0xFF24B300);
        case 'onride':
          return primaryColor;
        case 'pending':
          return Color.fromARGB(255, 107, 8, 255);
        case 'cancelled':
          return Colors.red;
        case 'cancelreq':
          return Colors.deepOrange;
        case 'extendedreq':
          return Colors.purpleAccent;
        default:
          return secondaryColor;
      }
    }

    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    // Show loader while fetching
    if (isLoading) {
      return Scaffold(body: Center(child: MybookingsSkeleton()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: _bookingController.mybookingList.isEmpty
          ? GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  currentFocus.unfocus();
                }
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.all(padding),
                          child: Row(
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current location',
                                            style: normalblack,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            (_location == null ||
                                                    (_location
                                                            ?.trim()
                                                            .isEmpty ??
                                                        true))
                                                ? 'Not fetched'
                                                : _location!.trim(),
                                            style: mediumblack,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: primaryColor.withOpacity(
                                      0.2,
                                    ),
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      color: primaryColor,
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
                                        //   '${unreadCount.toString()}',
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
                        ),
                        const SizedBox(height: 16),
                        Container(
                          child: Image.asset('assets/home/noBookings.png'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon(
                              //   Icons.location_on,
                              //   color: primaryColor,
                              //   size: 16,
                              // ),
                              // const SizedBox(width: 4),
                              // Expanded(
                              //   child: Column(
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Current location',

                              //         style: normalblack,
                              //         maxLines: 1,
                              //       ),
                              //       Text(
                              //         _location ?? 'Fetching...',
                              //         style: normalblack,
                              //         maxLines: 1,
                              //         overflow: TextOverflow.ellipsis,
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
                                Navigations.push(NotificationPage(), context);
                              },
                              child: CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.2),
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
                                  padding: const EdgeInsets.all(5),
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
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: dividercolor),
                  Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("My Bookings", style: poppinscaps),
                    ),
                  ),
                  // Filter Tabs
                  // Filter Tabs
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:
                            [
                              'All',
                              'On Ride',
                              'Upcoming',
                              'Completed',
                              'Pending',
                              'Cancelled',
                            ].map((status) {
                              final isSelected =
                                  selectedStatus.toLowerCase() ==
                                  status.toLowerCase();

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedStatus = status;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : bordercolorgrey,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color: isSelected
                                        ? primaryColor
                                        : cardcolor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : secondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  // Booking List
                  ListView.builder(
                    itemCount: filteredBookings.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 16), // Remove default padding
                    physics: const NeverScrollableScrollPhysics(),

                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      // print("              this is       :::::::https://lunarsenterprises.com:6032${booking.bikeImagePath[0]['image_path']
                      // }");s

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: padding,
                          vertical: 4,
                        ),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderradius),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: secondprimaryColor.withOpacity(
                                          0.2,
                                        ),
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                            BorderRadiusGeometry.circular(
                                              borderradius,
                                            ),
                                        border: Border.all(
                                          color: containerColor ?? Colors.grey,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(
                                              borderradius,
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset(
                                            "assets/home/bikeimg.png",
                                            // fallback when empty
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Image.network(
                                                    "$Noimage",
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // Set a fixed height for the row
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Important to prevent 3licts
                                                children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.4, // Limit name width
                                                    ),
                                                    child: Text(
                                                      "Easy Go Scooter",
                                                      style: mediumblack
                                                          .copyWith(
                                                            fontSize: 20,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  // SizedBox(width: 8),
                                                  // Container(
                                                  //   decoration: BoxDecoration(
                                                  //     borderRadius:
                                                  //         BorderRadius.circular(
                                                  //           100,
                                                  //         ),
                                                  //     border: Border.all(
                                                  //       color:
                                                  //           _getStatusColor(
                                                  //             booking.bStatus
                                                  //                 .toString(),
                                                  //           ),
                                                  //     ),
                                                  //   ),
                                                  //   child: Padding(
                                                  //     padding:
                                                  //         EdgeInsets.symmetric(
                                                  //           horizontal: 8,
                                                  //           vertical: 4,
                                                  //         ),
                                                  //     child: Text(
                                                  //       booking.bStatus
                                                  //           .toString(),
                                                  //       style: TextStyle(
                                                  //         fontSize: 10,
                                                  //         fontWeight:
                                                  //             FontWeight.w500,
                                                  //         color:
                                                  //             _getStatusColor(
                                                  //               booking
                                                  //                   .bStatus
                                                  //                   .toString(),
                                                  //             ),
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  // SizedBox(width: 8),
                                                  // Container(
                                                  //   decoration: BoxDecoration(
                                                  //     color: primaryColor,
                                                  //     borderRadius:
                                                  //         BorderRadius.circular(
                                                  //           100,
                                                  //         ),
                                                  //   ),
                                                  //   padding:
                                                  //       EdgeInsets.symmetric(
                                                  //         horizontal: 8,
                                                  //         vertical: 4,
                                                  //       ),
                                                  //   child: Text(
                                                  //     "₹${booking.bPrice}",
                                                  //     style: TextStyle(
                                                  //       fontWeight:
                                                  //           FontWeight.w500,
                                                  //       color: Colors.white,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${formatDateTimeToDisplay(booking.bPickupDate)} | ${formatTimeToDisplay(booking.bPicupTime)}",
                                                  style: smalltextblk,
                                                ),
                                                Text("-", style: smalltextblk),
                                                Text(
                                                  "${formatDateTimeToDisplay(booking.bDropDate)} | ${formatTimeToDisplay(booking.bDropTime)}",
                                                  style: smalltextblk,
                                                ),
                                              ],
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              Text(
                                                'Status: ',
                                                style: normalblack,
                                              ),
                                              Text(
                                                booking.bStatus.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: _getStatusColor(
                                                    booking.bStatus.toString(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: primaryColor,
                                        ),
                                        Dash(
                                          direction: Axis.vertical,
                                          length: 20,
                                          dashLength: 2,
                                          dashColor: primaryColor,
                                        ),
                                        Icon(
                                          Icons.location_on,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Pickup: ",
                                                  style: smalltextblk,
                                                ),
                                                TextSpan(
                                                  text: booking.bPickupLocation,
                                                  style: smalltextgrey,
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 35),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Dropoff: ",
                                                  style: smalltextblk,
                                                ),
                                                TextSpan(
                                                  text: booking.bDropLocation,
                                                  style: smalltextgrey,
                                                ),
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                if (booking.bStatus == "completed")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: _buttonLoading
                                                ? null
                                                : () {
                                                    PostFunctions()
                                                        .downloadreceipt(
                                                          context,
                                                          booking.bId
                                                              .toString(),
                                                          () => setState(
                                                            () =>
                                                                _buttonLoading =
                                                                    true,
                                                          ),
                                                          () => setState(
                                                            () =>
                                                                _buttonLoading =
                                                                    false,
                                                          ),
                                                        );
                                                  },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                                border: Border.all(
                                                  color: bordercolorgrey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: _buttonLoading
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                        )
                                                      : Text(
                                                          "Download Reciept",
                                                          style: normalgrey,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigations.push(RatingPage(bookingModel: booking,), context);
                                              // _openFeedbackSheet(
                                              //   context,
                                              //   booking,
                                              // );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Rate Now",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (booking.bStatus == "extendedreq")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showContactSupportBottomSheet(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: secondprimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Contact Support",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (booking.bStatus == "onride")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showContactSupportBottomSheet(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: secondprimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Contact Support",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (booking.bStatus == "pending")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showCancelBottomSheet(
                                                context,
                                                booking,
                                                "cancelled",
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: primaryColor,

                                                border: Border.all(
                                                  color: bordercolorgrey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "cancel booking",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showContactSupportBottomSheet(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: secondprimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Contact Support",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (booking.bStatus == "cancelled" ||
                                    booking.bStatus == "cancelreq")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              print(
                                                '-------------------------------------------  ${booking.viewReason} -----------------------------',
                                              );
                                              showreasonBottomSheet(
                                                context,
                                                booking.viewReason,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  254,
                                                  254,
                                                ),
                                                border: Border.all(
                                                  color: bordercolorgrey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "View Reason",
                                                    style: normalgrey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showContactSupportBottomSheet(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: secondprimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Contact Support",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (booking.bStatus == "approved")
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 4),
                                        //   child: Container(
                                        //     height: 50,
                                        //     decoration: BoxDecoration(
                                        //       color: const Color.fromARGB(
                                        //           255, 255, 254, 254),
                                        //       border: Border.all(
                                        //           color: bordercolorgrey),
                                        //       borderRadius: BorderRadius.circular(
                                        //           borderradius),
                                        //     ),
                                        //     child: Center(
                                        //       child: Padding(
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //                 horizontal: 12.0,
                                        //                 vertical: 8),
                                        //         child: Text("View Invoice",
                                        //             style: normalgrey),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showCancelBottomSheet(
                                                context,
                                                booking,
                                                "cancelreq",
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                border: Border.all(
                                                  color: bordercolorgrey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Cancel Booking",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              showContactSupportBottomSheet(
                                                context,
                                              );
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: secondprimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      borderradius,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8,
                                                      ),
                                                  child: Text(
                                                    "Contact Support",
                                                    style: normalwhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // onride
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  void _openFeedbackSheet(BuildContext context, BookingModel bookingmodel) {
    int _rating = 0; // keep outside builder so it doesn't reset
    final TextEditingController _feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          left: false,
          right: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How was your experience?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ⭐ Rating Row
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // 📝 Feedback
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Write your feedback...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Submit Button
                    Center(
                      child: GlobalButton(
                        context: context,
                        ontap: _buttonLoading
                            ? null
                            : () {
                                PostFunctions().addRating(
                                  context,
                                  bookingmodel.bUId.toString(),
                                  _rating.toString(),
                                  _feedbackController.text,
                                  bookingmodel.bId.toString(),
                                  bookingmodel.bBkId.toString(),
                                  () => setState(
                                    () => _buttonLoading = true,
                                  ), // disable button
                                  () => setState(
                                    () => _buttonLoading = false,
                                  ), // enable button
                                );
                              },
                        text: "Submit",
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showCancelBottomSheet(
    BuildContext context,
    BookingModel booking,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ← Add this line
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          left: false,
          right: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // ← Add this
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title
                Center(
                  child: Container(
                    height: 4,
                    width: 50,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Text(
                  "Cancel Your Booking",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 🔹 Body
                const Text(
                  "After this request, our team will contact you or "
                  "you can check in the app whether your request is approved or not.\n\n"
                  "⚠️ Cancellations before 7 days are only eligible for a 100% refund.",
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 10),
                TextFormField(
                  maxLines: 3,
                  controller: _reasoncontrller,
                  decoration: InputDecoration(
                    hintText: "Please provide a reason for cancellation",
                    hintStyle: normalgrey,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: bordercolorgrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: bordercolorgrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: bordercolorgrey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: bordercolorgrey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: bordercolorgrey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a cancellation reason';
                    }
                    if (value.length < 10) {
                      return 'Please provide a more detailed reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🔹 Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _reasoncontrller.clear();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderradius),
                          ),
                        ),
                        child: Text("Close", style: normalblack),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _buttonLoading
                            ? null
                            : () {
                                // PostFunctions().updatebookingstatus(
                                //   context,
                                //   booking.bUId.toString(),
                                //   status,
                                //   booking.bId.toString(),
                                //   () => setState(
                                //     () => _buttonLoading = true,
                                //   ), // disable button
                                //   () => setState(
                                //     () => _buttonLoading = false,
                                //   ), // enable button
                                // );

                                PostFunctions().cancelBooking(
                                  context,
                                  booking.bId.toString(),
                                  _reasoncontrller.text,
                                  () => setState(
                                    () => _buttonLoading = true,
                                  ), // disable button
                                  () => setState(
                                    () => _buttonLoading = false,
                                  ), // enable button
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderradius),
                          ),
                        ),
                        child: Text("Confirm Cancel", style: normalwhite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Clear the text field when the sheet is dismissed by any method
      _reasoncontrller.clear();
    });
    ;
  }

  void showContactSupportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          left: false,
          right: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📌 Title
                Center(
                  child: Text(
                    "Contact Support",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // 📌 Body
                const Text(
                  "Need help? You can contact our EasyGo customer care team directly for assistance.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // 📞 Call Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // open dialer
                      // launchUrl(Uri.parse("tel:+917306581900"));
                      _makePhoneCall(customercontact);
                    },
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: Text("Call Customer Care", style: normalwhite),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderradius),
                      ),
                    ),
                  ),
                ),

                Center(child: Text(customercontact, style: smalltextblk)),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // setState(() {

    // });

    print("1");

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        print("object");
        await launchUrl(phoneUri);
      } else {
        // Show error if unable to launch
        if (mounted) {
          Navigations.pop(context);
        }
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          // _isLoading = false;
        });
      }
    }
  }

  void showreasonBottomSheet(BuildContext context, String reason) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          left: false,
          right: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📌 Title
                Center(
                  child: Text(
                    "Cancellation Reason",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // 📌 Body
                Center(
                  child: Text(
                    reason,
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 16),

                // 📞 Call Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // open dialer
                      // launchUrl(Uri.parse("tel:+917306581900"));
                      // _makePhoneCall(customercontact);
                      Navigations.pop(context);
                    },
                    // icon: const Icon(Icons.call, color: Colors.white),
                    label: Text("Close", style: normalwhite),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderradius),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Center(
                  child: Text(
                    '* A cancellation request has been submitted for this booking. Please wait for admin approval or contact support for assistance.',
                    style: smalltextgrey,
                    textAlign: TextAlign.justify,
                  ),
                ),
                // Center(child: Text(customercontact, style: smalltextblk,)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
