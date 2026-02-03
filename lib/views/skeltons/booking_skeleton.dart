import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:easygonww/controllers/bookinglist.dart';
import 'package:easygonww/controllers/notificationslist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MybookingsSkeleton extends StatefulWidget {
  const MybookingsSkeleton({super.key});

  @override
  State<MybookingsSkeleton> createState() => _MybookingsSkeletonState();
}

class _MybookingsSkeletonState extends State<MybookingsSkeleton> {
  String selectedStatus = 'All';
  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};
  String? location;
  String? user_id;

  bool isLoading = true; // <-- added

  MyBookingController _bookingController = MyBookingController();

  @override
  void initState() {
    super.initState();
    getpref();
    loadUserDetails();
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
    setState(() {});
  }

  Future<void> loadUserDetails() async {
    Map<String, dynamic> data = await prefs.readlocation();
    setState(() {
      locationdata = data;
      location = data['location'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = selectedStatus == 'All'
        ? _bookingController.mybookingList
        : _bookingController.mybookingList
              .where(
                (booking) =>
                    booking.bStatus.toString().toLowerCase() ==
                    selectedStatus.toLowerCase(),
              )
              .toList();

    // Helper function
    Color _getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'upcoming':
          return Color(0xFFB3009F);
        case 'completed':
          return Color(0xFF24B300);
        case 'cancelled':
          return Colors.red;
        default:
          return secondaryColor;
      }
    }

    NotificationController _notificationController = NotificationController();

    int unreadCount = _notificationController.notificationList
        .where((notification) => notification.status == 'unread')
        .length;

    // Show loader while fetching
    // if (isLoading) {
    //   return Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }

    return Skeletonizer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 26),
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
                        Icon(Icons.location_on, color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text('Current location',

                        //           style: normalblack, maxLines: 1),
                        //       Text(
                        //         location ?? 'Fetching...',
                        //         style: mediumblack,
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
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: ['All', 'Upcoming', 'Completed', 'Cancelled'].map((
                    status,
                  ) {
                    final isSelected =
                        selectedStatus.toLowerCase() == status.toLowerCase();
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : bordercolorgrey,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? primaryColor : cardcolor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSelected ? Colors.white : secondaryColor,
                          fontWeight: FontWeight.w500,
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
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 4,
                  ),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 200),
                    color: booking.bStatus == "upcoming"
                        ? primaryColor.withOpacity(0.12)
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: containerColor ?? Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    booking.bId.toString(),
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,

                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.network(
                                              fit: BoxFit.cover,
                                              '$Noimage',
                                            ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height:
                                          40, // Set a fixed height for the row
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize
                                              .min, // Important to prevent conflicts
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
                                                "bike name",
                                                style: mediumblack,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: _getStatusColor(
                                                    booking.bStatus.toString(),
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                child: Text(
                                                  booking.bStatus.toString(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: _getStatusColor(
                                                      booking.bStatus
                                                          .toString(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          // Text(
                                          //   "${booking.bPickupDate} | ${booking.bPickupTime.toString()}",
                                          //   style: smalltextblk,
                                          // ),
                                          Icon(
                                            Icons.arrow_right_alt_outlined,
                                            color: primaryColor,
                                          ),
                                          Text(
                                            "${booking.bDropDate} | ${booking.bDropTime}",
                                            style: smalltextblk,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      text: booking
                                                          .bPickupLocation,
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
                                                      text:
                                                          booking.bDropLocation,
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
                                    child: Container(
                                      height: 40,
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
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Download Reciept",
                                            style: normalgrey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
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
                                ],
                              ),
                            )
                          else if (booking.bStatus == "cancelled")
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
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
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Rebook",
                                            style: normalwhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (booking.bStatus == "upcoming")
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
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
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "View Invoice",
                                            style: normalgrey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
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
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Cancel Booking",
                                            style: normalgrey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          borderradius,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Modify Booking",
                                            style: normalwhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
