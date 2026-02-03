import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easygonww/controllers_/post_controllers.dart';
import 'package:easygonww/model/models.dart';
import 'package:easygonww/utils/utilities.dart';
import 'package:easygonww/widgets/button.dart';
import 'package:easygonww/utils/navigations.dart';

class CustomerInstructionsPage extends StatefulWidget {
  final BikeModel? bikeModel;
  final String pickuploation;
  final String pickuptime;
  final String pickupdate;
  final String dropoffloation;
  final String dropofftime;
  final String dropoffdate;
  final dynamic totalamount;
  final File selfieImage;
  final String rentID;
  final String rentDurationText;
  final int rentDuration;
  final double locationCharge;
  final double rentamount;
  final double gstamount;
  final double rentdeposite;
  final double totalpayableamount;

  const CustomerInstructionsPage({
    super.key,
    this.bikeModel,
    required this.dropoffdate,
    required this.dropoffloation,
    required this.dropofftime,
    required this.pickupdate,
    required this.pickuploation,
    required this.pickuptime,
    required this.totalamount,
    required this.selfieImage,
    required this.rentID,
    required this.rentDurationText,
    required this.rentDuration,
    required this.locationCharge,
    required this.rentamount,
    required this.gstamount,
    required this.rentdeposite,
    required this.totalpayableamount,
  });

  @override
  State<CustomerInstructionsPage> createState() =>
      _CustomerInstructionsPageState();
}

class _CustomerInstructionsPageState extends State<CustomerInstructionsPage> {
  void _handleConfirmPayment() {
    PostFunctions().addBooking(
      context,
      widget.pickuploation,
      widget.pickupdate,
      widget.pickuptime,
      widget.dropoffloation,
      widget.dropoffdate,
      widget.dropofftime,
      widget.rentID,
      widget.locationCharge,
      widget.selfieImage,
      () => setState(() => _buttonLoading = true),
      () => setState(() => _buttonLoading = false),
    );
  }

  bool _isChecked = false;
  bool _buttonLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () => Navigations.pop(context),
            child: Container(
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
          ),
        ),
        title: Text('Customer Instructions', style: mediumblack),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBullet(
              "Please read these instructions carefully before starting your rental. By proceeding, you agree to follow these guidelines.",
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Before You Start Your Ride"),
            const SizedBox(height: 8),
            _buildBullet(
              "Document Check: Always carry your valid driving license and ID proof while operating the scooter.",
            ),
            _buildBullet(
              "Safety Gear: Always wear the provided helmet (mandatory for both rider and pillion)",
            ),
            _buildBullet(
              "Vehicle Inspection: You are responsible for inspecting the bike before you start. Please check the tyres, brakes, lights, and mirrors.",
            ),
            _buildBullet(
              "Fuel Level: The bike is provided with fuel. You must return it with the same fuel level as provided at pickup",
            ),
            _buildBullet(
              "Personal Record: We highly recommend taking a quick photo or video of the bike's condition for your own record before you ride.",
            ),

            const Divider(
              height: 40,
              color: Color.fromARGB(255, 228, 228, 231),
            ),

            _buildSectionTitle("🔹 During the Ride"),
            const SizedBox(height: 8),
            _buildBullet(
              "Safe Riding: Ride safely and responsibly. Follow all traffic rules, speed limits, and avoid reckless driving (no racing or wheelies).",
            ),
            _buildBullet(
              "Rider Authorization: Only the registered renter is permitted to ride the bike. Allowing unauthorized riders may void your rental agreement.",
            ),
            _buildBullet(
              "Prohibited Use: Riding under the influence of alcohol or drugs is strictly prohibited and will result in immediate termination of the rental.",
            ),
            _buildBullet(
              "Overloading: Avoid overloading. A maximum of two people per bike is permitted",
            ),
            _buildBullet(
              "Fines & Violations: You are solely responsible for all traffic fines, parking violations, or legal issues incurred during the rental period",
            ),
            _buildBullet(
              "Accident/Damage: In case of an accident or damage, stop immediately, inform Easy Go, and file a police report if required",
            ),
            _buildBullet(
              "number: 9847680083 immediately. Do not hand over the bike to any third-party mechanic without prior permission from Easy Go.",
            ),

            const Divider(
              height: 40,
              color: Color.fromARGB(255, 228, 228, 231),
            ),

            _buildSectionTitle("🔹 When Returning the Bike"),
            const SizedBox(height: 8),
            _buildBullet(
              "Timely Return: Return the bike on time to avoid extra charges.",
            ),
            _buildBullet(
              "Vehicle Condition: Return the bike, helmet(s), keys, and documents clean and in the same condition as given. Any missing or damaged items will be charged",
            ),
            _buildBullet(
              "Check-In Responsibility: You are responsible for the bike until it is officially checked back in by Easy Go staff.",
            ),
            _buildBullet(
              "Deposit Refund: Our staff will inspect the bike and process the refund of the security deposit (after any necessary adjustments for damage/fines).",
            ),

            const Divider(
              height: 40,
              color: Color.fromARGB(255, 228, 228, 231),
            ),

            // _buildSectionTitle("🔹 When Returning the Bike"),
            // const SizedBox(height: 8),
            // _buildBullet("Return the bike on time to avoid extra charges."),
            // _buildBullet("Make sure it’s clean and in the same condition as given."),
            // _buildBullet("Return helmet(s), key, and documents."),
            // _buildBullet("Our staff will inspect the bike and refund the security deposit (after any adjustments)."),

            // const Divider(height: 40, color: Color.fromARGB(255, 228, 228, 231)),

            // _buildSectionTitle("🔹 Important Reminders"),
            // const SizedBox(height: 8),
            // _buildBullet("Do not drink and drive."),
            // _buildBullet("Avoid overloading – max 2 people per bike."),
            // _buildBullet("You are responsible for the bike until it’s officially checked back in."),
            // _buildBullet("Keep our contact saved: [Company Name / Helpline Number]."),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: secondprimaryColor,
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                Flexible(
                  child: Text(
                    'I have read, understood, and agree to the Easy Go Ride Instructions.',
                    style: normalblack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 400),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlobalButton(
          text: 'I Understand & Pay',
          ontap: () {
            // Navigate to next page, e.g. Pick-up/drop confirmation or booking summary
            // Navigations.pop(context);

            if (_isChecked == true) {
              _handleConfirmPayment();
            } else {
              Fluttertoast.showToast(msg: 'Please agree to the instructions.');
              return;
            }
          },
          context: context,
          textcolor: Colors.white,
          backgroundcolor: primaryColor,
          isLoading: _buttonLoading,
        ),
      ),
    );
  }

  // Reusable bullet-point widget
  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, height: 1.4)),
          Expanded(
            child: Text(text, style: normalgrey, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }

  // Reusable section title widget
  Widget _buildSectionTitle(String title) {
    return Text(title, style: largelack);
  }
}
