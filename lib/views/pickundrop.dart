import 'package:easygonww/controllers_/controllers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/pref/add_pref.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/views/conformbooking.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/widgets/globalcontainer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PickundropPage extends StatefulWidget {
  final double rentamount;
  final double gstamount;
  final double rentdeposite;
  final double totalpayableamount;
  final String rentID;
  final String rentDurationText;
  final int rentDuration;

  PickundropPage({
    super.key,
    required this.rentamount,
    required this.gstamount,
    required this.rentdeposite,
    required this.totalpayableamount,
    required this.rentID,
    required this.rentDurationText,
    required this.rentDuration,
  });

  @override
  State<PickundropPage> createState() => _PickundropPageState();
}

class _PickundropPageState extends State<PickundropPage> {
  String selectedOption = 'Option 1';
  String? location;

  final prefs = GlobalPreference();
  Map<String, dynamic> locationdata = {};
  late SharedPreferences _prefs;

  final TextEditingController _pickupController = TextEditingController();
  BikeCentersLocationController bikeCentersLocationController =
      BikeCentersLocationController();

  DateTime? selectedDate;
  DateTime? selecteddropDate;
  late TimeOfDay selectedTime;
  late TimeOfDay selecteddropTime;
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  void _updateDropOff() {
    final pickupDate = selectedDate ?? DateTime.now();

    DateTime pickupDateTime = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Calculate drop-off date/time based on rentDuration (HOURS)
    DateTime dropoffDateTime = pickupDateTime.add(
      Duration(hours: widget.rentDuration),
    );

    setState(() {
      selecteddropDate = dropoffDateTime;
      selecteddropTime = TimeOfDay.fromDateTime(dropoffDateTime);
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(8000),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _updateDropOff();
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
      _updateDropOff();
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserDetails();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay(hour: DateTime.now().hour, minute: 0);
    _updateDropOff();
    fetchbikelocation();
  }

  Future<void> fetchbikelocation() async {
    print("object");
    await bikeCentersLocationController.fetchBikeCentersLocation();
    setState(() {
      bikeCentersLocationController.bikeCenterLocationList;
      print(bikeCentersLocationController.bikeCenterLocationList);
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
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

  String? selectedpickupCenter;
  String? selectedDropCenter;

  double get locationCharge {
    if (selectedpickupCenter != null &&
        selectedDropCenter != null &&
        selectedpickupCenter != selectedDropCenter) {
      return 149.0;
    }
    return 0.0;
  }

  double get totalAmountWithLocationCharge {
    return widget.totalpayableamount + locationCharge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigations.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          ),
        ),
        centerTitle: false,
        title: Text("Your Ride Plan", style: mediumblack),
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
            children: [
              Padding(
                padding: const EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderradius),
                        color: secondprimaryColor.withOpacity(0.18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(padding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Rent', style: normalgrey),
                                  Text(
                                    '₹${widget.rentamount}',
                                    style: normalblack,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('GST(5%)', style: normalgrey),
                                  Text(
                                    '₹${widget.gstamount}',
                                    style: normalblack,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Rentable Deposit', style: normalgrey),
                                  Text(
                                    '₹${widget.rentdeposite}',
                                    style: normalblack,
                                  ),
                                ],
                              ),
                            ),
                            if (selectedpickupCenter != null &&
                                selectedDropCenter != null &&
                                selectedpickupCenter != selectedDropCenter)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Different location fee',
                                      style: normalgrey,
                                    ),
                                    Text('₹149', style: normalblack),
                                  ],
                                ),
                              ),
                            Divider(color: Colors.grey),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Payable Amount',
                                  style: mediumblack,
                                ),
                                Text(
                                  '₹${totalAmountWithLocationCharge}',
                                  style: mediumblack.copyWith(
                                    color: secondprimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Deposit amount is fully refundable after ride completion',
                              style: smalltextgrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Start Location', style: mediumblack),
                    Text(
                      'Where would you like to pick up the bike?',
                      style: smalltextgrey,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Pickup Station',
                                    style: normalblack,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              hint: Text(
                                "Choose a bike center",
                                style: smalltextgrey,
                              ),
                              value: selectedpickupCenter,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              underline: Divider(color: secondprimaryColor),
                              items: bikeCentersLocationController
                                  .bikeCenterLocationList
                                  .map((center) {
                                    return DropdownMenuItem<String>(
                                      value:
                                          "${center.lLocation} ${center.lDistrict}"
                                              .toString(),
                                      child: Text(
                                        "${center.lLocation} ${center.lDistrict}",
                                        style: normalblack,
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedpickupCenter = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Start Date & Time', style: mediumblack),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickDate(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderradius),
                              color: dividercolor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  formatDateTimeToDisplay(
                                    selectedDate ?? DateTime.now(),
                                  ),
                                  style: normalblack,
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => _pickDate(context),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: secondprimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _pickTime(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderradius),
                              color: dividercolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      (selectedTime.hourOfPeriod == 0
                                              ? 12
                                              : selectedTime.hourOfPeriod)
                                          .toString(),
                                      style: normalblack,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    child: Text(" : ", style: normalblack),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      selectedTime.minute.toString().padLeft(
                                        2,
                                        '0',
                                      ),
                                      style: normalblack,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      selectedTime.period == DayPeriod.am
                                          ? 'AM'
                                          : 'PM',
                                      style: normalblack,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _pickTime(context),
                                    child: Icon(
                                      Icons.access_time_sharp,
                                      color: secondprimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('End Location', style: mediumblack),
                    Text(
                      'Where would you like to drop the bike?',
                      style: smalltextgrey,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Drop Station',
                                    style: normalblack,
                                  ),
                                ),
                              ],
                            ),
                            DropdownButton<String>(
                              hint: Text(
                                "Choose a bike center",
                                style: smalltextgrey,
                              ),
                              value: selectedDropCenter,
                              dropdownColor: Colors.white,
                              isExpanded: true,
                              underline: Divider(color: secondprimaryColor),
                              items: bikeCentersLocationController
                                  .bikeCenterLocationList
                                  .map((center) {
                                    return DropdownMenuItem<String>(
                                      value:
                                          "${center.lLocation} ${center.lDistrict}"
                                              .toString(),
                                      child: Text(
                                        "${center.lLocation} ${center.lDistrict}",
                                        style: normalblack,
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDropCenter = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('End Date & Time', style: mediumblack),
                    Text(
                      'Calculated based on ${widget.rentDuration} hours rental',
                      style: smalltextgrey,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderradius),
                            color: dividercolor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                formatDateTimeToDisplay(
                                  selecteddropDate ?? DateTime.now(),
                                ),
                                style: normalblack,
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.calendar_month,
                                color: secondprimaryColor,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderradius),
                            color: dividercolor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    (selecteddropTime.hourOfPeriod == 0
                                            ? 12
                                            : selecteddropTime.hourOfPeriod)
                                        .toString(),
                                    style: normalblack,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Text(" : ", style: normalblack),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    selecteddropTime.minute.toString().padLeft(
                                      2,
                                      '0',
                                    ),
                                    style: normalblack,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 0.0,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    selecteddropTime.period == DayPeriod.am
                                        ? 'AM'
                                        : 'PM',
                                    style: normalblack,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time_sharp,
                                  color: secondprimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (selectedpickupCenter != null &&
                        selectedDropCenter != null &&
                        selectedpickupCenter != selectedDropCenter)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'A charge of ₹149 applies if the drop-off location differs from the pickup location.',
                          style: smalltextgrey.copyWith(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 240),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlobalButton(
          text: 'Confirm & Continue',
          ontap: () {
            // 🔹 Validate pickup location
            if (selectedOption == 'Option 1' && selectedpickupCenter == null) {
              Fluttertoast.showToast(
                msg: "Please select a pickup bike center",
                textColor: Colors.red,
                backgroundColor: Colors.white,
              );
              return;
            }
            if (selectedOption == 'Option 2' &&
                _pickupController.text.trim().isEmpty) {
              Fluttertoast.showToast(
                msg: "Please enter your pickup location",
                textColor: Colors.red,
                backgroundColor: Colors.white,
              );
              return;
            }

            // 🔹 Validate drop location
            if (selectedDropCenter == null) {
              Fluttertoast.showToast(
                msg: "Please select a drop-off bike center",
                textColor: Colors.red,
                backgroundColor: Colors.white,
              );
              return;
            }

            // ✅ Construct values after validation
            String pickuploation = selectedOption == 'Option 1'
                ? selectedpickupCenter!
                : _pickupController.text;

            String dropoffloation = selectedDropCenter!;

            DateTime pickupDateTime = DateTime(
              selectedDate?.year ?? DateTime.now().year,
              selectedDate?.month ?? DateTime.now().month,
              selectedDate?.day ?? DateTime.now().day,
              selectedTime.hour,
              selectedTime.minute,
            );

            // Calculate drop-off date/time based on rentDuration (hours)
            DateTime dropoffDateTime = pickupDateTime.add(
              Duration(hours: widget.rentDuration),
            );

            String pickupdate = DateFormat('yyyy-MM-dd').format(pickupDateTime);
            String dropoffdate = DateFormat(
              'yyyy-MM-dd',
            ).format(dropoffDateTime);

            String pickuptime = pickupDateTime.toString();
            String dropofftime = dropoffDateTime.toString();

            // ✅ Navigate after all validations
            Navigations.push(
              ConfirmBooking(
                pickupdate: pickupdate,
                pickuploation: pickuploation,
                pickuptime: pickuptime,
                dropoffdate: dropoffdate,
                dropoffloation: dropoffloation,
                dropofftime: dropofftime,
                gstamount: widget.gstamount,
                rentdeposite: widget.rentdeposite,
                totalpayableamount: totalAmountWithLocationCharge,
                rentID: widget.rentID,
                rentDurationText: widget.rentDurationText,
                rentDuration: widget.rentDuration,
                locationCharge:
                    selectedpickupCenter != null &&
                        selectedDropCenter != null &&
                        selectedpickupCenter != selectedDropCenter
                    ? 149
                    : 0,
                rentamount: widget.rentamount,
              ),
              context,
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
