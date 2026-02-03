import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:easygonww/controllers/bookinglist.dart';
import 'package:easygonww/controllers_/controllers.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/bookings.dart';
import 'package:easygonww/views/extendbooking.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class OnrideWidget extends StatefulWidget {
  OnrideWidget({super.key});

  @override
  State<OnrideWidget> createState() => _OnrideWidgetState();
}

class _OnrideWidgetState extends State<OnrideWidget> {
  MyBookingController _myBookingController = MyBookingController();
  UserController _userController = UserController();

  String? customercontact;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
  }

  Future<void> fetchdata() async {
    await _myBookingController.fetchBikes();
    await _userController.fetchUser("admin");
    setState(() {
      if (_userController.userList.isNotEmpty) {
        final user = _userController.userList.first;
        customercontact = user.uMobile.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _myBookingController.mybookingList
        .where(
          (booking) =>
              booking.bStatus == 'onride' ||
              booking.bStatus == 'extendedreq' ||
              booking.bStatus == 'extended',
        )
        .toList();

    return Column(
      children: filteredBookings
          .map(
            (booking) => Container(
              color: primaryColor.withOpacity(0.12),
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
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
                            border: Border.all(color: containerColor),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/home/bikeimg.png",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.network(fit: BoxFit.cover, '$Noimage'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.bBikeName,
                                      style: mediumblack,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: const Color(0xFF24B300),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 1,
                                    ),
                                    child: Text(
                                      booking.bStatus.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF24B300),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 1,
                                    ),
                                    child: Text(
                                      "₹ ${booking.bTotalAmount}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Text(
                                      "${formatDateTimeToDisplay(booking.bPickupDate)} | ${formatTimeToDisplay(booking.bPicupTime)}",
                                      style: smalltextblk,
                                    ),

                                    Icon(
                                      Icons.arrow_right_alt_outlined,
                                      color: primaryColor,
                                    ),
                                    Text(
                                      "${formatDateTimeToDisplay(booking.bDropDate)} | ${formatTimeToDisplay(booking.bDropTime)}",
                                      style: smalltextblk,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
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
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text.rich(
                                          TextSpan(
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
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        SizedBox(height: 30),
                                        Text.rich(
                                          TextSpan(
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
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigations.push(
                                          ExtendBookingPage(
                                            bookingmodel: booking,
                                          ),
                                          context,
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: bordercolorgrey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            borderradius,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          "Extend Booking",
                                          style: normalgrey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showContactSupportBottomSheet(context);
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            borderradius,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          "Contact Support",
                                          style: normalwhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
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
                  "Need help? You can contact our GetBike customer care team directly for assistance.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // 📞 Call Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // open dialer
                      // launchUrl(Uri.parse("tel:+917306581900"));
                      _makePhoneCall(customercontact.toString());
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

                Center(
                  child: Text(customercontact.toString(), style: smalltextblk),
                ),

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
}
