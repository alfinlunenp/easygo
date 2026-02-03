import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/conformbooking.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExtendBookingPage extends StatefulWidget {
  final BookingModel bookingmodel;

  ExtendBookingPage({super.key, required this.bookingmodel});

  @override
  State<ExtendBookingPage> createState() => _ExtendBookingPageState();
}

class _ExtendBookingPageState extends State<ExtendBookingPage> {
  String selectedOption = 'Option 1';
  String selectedDropOption = 'Option 3';
  String? location;
  bool _buttonLoading = false; // only for button

  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};
  late SharedPreferences _prefs;

  final TextEditingController _pickupController = TextEditingController();
  late TextEditingController _dropController;

  DateTime? selectedDate;
  late DateTime selecteddropDate;
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  late TimeOfDay selectedTime;
  late TimeOfDay selecteddropTime;

  // Move initialization to initState
  String? selectedpickupCenter;
  late String? selecteddropoffCenter;

  @override
  void initState() {
    super.initState();
    _dropController = TextEditingController(
      text: widget.bookingmodel.bDropLocation,
    );
    // Initialize fields that depend on widget.bookingmodel here
    selecteddropDate = widget.bookingmodel.bDropDate;

    // Convert string time to TimeOfDay if needed
    // Assuming bDropTime is a string like "10:30 AM"
    selecteddropTime = _parseTimeString(
      widget.bookingmodel.bDropTime.toString(),
    );

    selecteddropoffCenter = widget.bookingmodel.bDropLocation;
    // Initialize other fields
    selectedTime = TimeOfDay(hour: DateTime.now().hour, minute: 0);

    loadUserDetails();
  }

  // Helper method to parse time string to TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final format = DateFormat.jm(); // Parses "10:30 AM" format
      final dateTime = format.parse(timeString);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      // Fallback to current time if parsing fails
      return TimeOfDay.fromDateTime(DateTime.now());
    }
  }

  // Helper method to format TimeOfDay to string like "3.00 AM" or "2.30 PM"
  String _formatTimeOfDay(TimeOfDay time) {
    // Get hour in 12-hour format
    int hour = time.hourOfPeriod;
    if (hour == 0) hour = 12; // Convert 0 to 12 for 12-hour format

    // Get minutes with leading zero if needed
    String minute = time.minute.toString().padLeft(2, '0');

    // Get AM/PM
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour.$minute $period';
  }

  // Alternative format with colon: "3:00 AM"
  String _formatTimeOfDayWithColon(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    if (hour == 0) hour = 12;

    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  // Compact format without space: "3.00AM"
  String _formatTimeOfDayCompact(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    if (hour == 0) hour = 12;

    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour.$minute$period';
  }

  Future<void> _pickDropDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(8000),
    );
    if (picked != null) {
      setState(() {
        selecteddropDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _pickDropTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selecteddropTime = picked;
      });
    }
  }

  String calculateNoOfDays() {
    print("dayss");
    final pickupDate = selectedDate ?? DateTime.now();
    final dropoffDate = selecteddropDate;

    // Remove time portion — consider only year, month, and day
    final pickup = DateTime(pickupDate.year, pickupDate.month, pickupDate.day);
    final dropoff = DateTime(
      dropoffDate.year,
      dropoffDate.month,
      dropoffDate.day,
    );

    // Calculate the difference in days
    int days = dropoff.difference(pickup).inDays;

    print("days : $days");

    // Minimum 1 day rent if same date or next date
    if (days < 1) {
      days = 1;
    }

    return days.toString();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  Future<void> loadUserDetails() async {
    Map<String, dynamic> data = await prefs.readlocation();
    setState(() {
      locationdata = data;
      location = data['location'];
      _pickupController.text = location ?? '';
    });
  }

  final List<String> bikeCenters = [
    "City Bike Hub - Downtown",
    "Speed Wheels - North Side",
    "Eco Ride Center - East Zone",
    "Urban Pedal Hub - West End",
    "High Gear Rentals - Central Plaza",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: const Color(0xFFF1F2F6),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigations.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Text("Extend Drop-off Details", style: largelack),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pickup Location', style: mediumblack),
                    SizedBox(height: 5),
                    Text(
                      widget.bookingmodel.bPickupLocation,
                      style: normalblack,
                    ),
                    SizedBox(height: 16),
                    Text('Pickup Date & Time', style: mediumblack),
                    SizedBox(height: 5),
                    Text(
                      "${formatDateTimeToDisplay(widget.bookingmodel.bPickupDate)} | ${formatTimeToDisplay(widget.bookingmodel.bPicupTime)}",
                      style: normalblack,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current selected Dropoff Location',
                      style: mediumblack,
                    ),
                    SizedBox(height: 5),
                    Text(widget.bookingmodel.bDropLocation, style: normalblack),
                    SizedBox(height: 16),
                    Text(
                      'Current selected Dropoff Date & Time',
                      style: mediumblack,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${formatDateTimeToDisplay(widget.bookingmodel.bDropDate)} | ${formatTimeToDisplay(widget.bookingmodel.bDropTime)}",
                      style: normalblack,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              Divider(color: dividercolor),
              Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drop-off Location', style: mediumblack),
                    Text('Where will you return the bike?', style: normalgrey),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'change your drop location here',
                            style: normalblack,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8,
                      ),
                      child: Globalcontainer(
                        height: 50,
                        child: Center(
                          child: TextFormField(
                            controller: _dropController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                left: 16,
                                top: 12,
                              ),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.location_on,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Dropoff Date & Time', style: mediumblack),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickDropDate(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: bordercolorgrey,
                                width: 1,
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10,
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  formatDateTimeToDisplay(selecteddropDate),
                                  style: normalblack,
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _pickDropDate(context),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),

                        GestureDetector(
                          onTap: () {
                            _pickDropTime(context);
                          },
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                  color: bordercolorgrey,
                                ),
                                child: Text(
                                  (selecteddropTime.hourOfPeriod == 0
                                          ? 12
                                          : selecteddropTime.hourOfPeriod)
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  " : ",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                  color: bordercolorgrey,
                                ),
                                child: Text(
                                  selecteddropTime.minute.toString().padLeft(
                                    2,
                                    '0',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                  color: primaryColor,
                                ),
                                child: Text(
                                  selecteddropTime.period == DayPeriod.am
                                      ? 'AM'
                                      : 'PM',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _pickDropTime(context),
                                child: Icon(
                                  Icons.access_time_sharp,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Display formatted time for preview
                  ],
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlobalButton(
          text: 'Sumbmit Modification',
          ontap: _buttonLoading
              ? null
              : () {
                  // Format date and time before sending
                  String formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(selecteddropDate);
                  String formattedTime = _formatTimeOfDay(
                    selecteddropTime,
                  ); // Use dot format: "3.00 AM"

                  print('Sending date: $formattedDate');
                  print('Sending time: $formattedTime');
                  print('Sending location: ${_dropController.text}');

                  PostFunctions().extendBooking(
                    context,
                    widget.bookingmodel.bId.toString(),
                    selecteddropDate.toString(), // Formatted date
                    formattedTime, // Formatted time in "3.00 AM" format
                    _dropController.text,
                    "extention request for booking",
                    () => setState(() => _buttonLoading = true),
                    () => setState(() => _buttonLoading = false),
                  );
                },
          context: context,
          textcolor: Colors.white,
          backgroundcolor: primaryColor,
        ),
      ),
    );
  }
}
