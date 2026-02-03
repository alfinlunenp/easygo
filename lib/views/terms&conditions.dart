import 'package:flutter/material.dart';
import 'package:easygonww/utils/navigations.dart';
import 'package:easygonww/utils/utilities.dart';

class Termsconditions extends StatelessWidget {
  const Termsconditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        title: Text("Terms & Conditions", style: mediumblack),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigations.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: padding,
          vertical: padding / 2,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Easy Go Terms & Conditions",
                    style: mediumblack.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Introduction
              Text(
                "By accessing or using the services of Easy Go, the customer (Renter) agrees to the following Terms and Conditions.",
                style: normalgrey.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 28),

              // Terms Sections
              _buildTermSection(
                number: "1",
                title: "Booking, Payment, and Cancellation",
                children: [
                  _buildTermBullet(
                    "Full Advance Payment: All bookings require 100% of the rental amount to be paid in full at the time of booking.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Rental Calculation: All rental charges are calculated on a per-day basis.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Cancellation Policy:",
                    children: [
                      _buildNestedBullet(
                        "7+ Days Notice: 30% deduction (70% refunded)",
                      ),
                      _buildNestedBullet(
                        "2 Days Notice: 50% deduction (50% refunded)",
                      ),
                      _buildNestedBullet(
                        "1 Day Notice: 70% deduction (30% refunded)",
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "The remaining balance, if any, will be refunded to the Renter.",
                        style: normalgrey,
                      ),
                    ],
                  ),
                ],
              ),

              _buildTermSection(
                number: "2",
                title: "Vehicle Pickup and Operation",
                children: [
                  _buildTermBullet(
                    "Mandatory ID: The Renter must present valid government-issued photo identification at the time of pickup.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Inspection is Required: The Renter is responsible for inspecting the vehicle before starting the ride (including tyres, brakes, lights, and mirrors). Any pre-existing issues must be reported to Easy Go staff immediately.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Vehicle Condition: The Renter must return the vehicle in the same condition as provided. Any damage or loss will be charged (See Section 3).",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Fuel Policy: The Renter must return the vehicle with the same fuel level as provided at the time of pickup.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Safety Gear: Helmets are mandatory for both the rider and the pillion. Failure to comply may result in penalties.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Rider Authorization: Only the registered Renter is permitted to ride the vehicle. Allowing unauthorized riders may result in additional charges or termination of the rental agreement.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Overloading: Overloading is not allowed. A maximum of two persons per bike is permitted.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Prohibited Use: Riding under the influence of alcohol or drugs is strictly prohibited and will result in the immediate termination of the rental agreement.",
                  ),
                ],
              ),

              _buildTermSection(
                number: "3",
                title: "Liability, Damage, and Fines",
                children: [
                  _buildTermBullet(
                    "Renter Responsibility: The Renter is solely responsible for any damage, loss, penalties, or liabilities arising during the rental period.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Damage Charges: Any damage caused to the vehicle (including missing/damaged keys or accessories) during the rental period will be fully chargeable to the Renter.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Traffic Fines: All traffic fines, penalties, parking violations, or legal issues arising during the rental period will be the sole responsibility of the Renter.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Accidents: In the event of an accident, the Renter must stop immediately, inform Easy Go, and file a police report if required.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Breakdowns: In case of a breakdown or puncture, the Renter must contact Easy Go immediately and must not approach any third-party mechanic without prior permission.",
                  ),
                ],
              ),

              _buildTermSection(
                number: "4",
                title: "Vehicle Return and Overstay",
                children: [
                  _buildTermBullet(
                    "Timely Return: Vehicles must be returned on or before the agreed return time.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Late Return Charges: Failing to return the vehicle on time may result in additional charges at the discretion of Easy Go.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Check-In: The Renter is responsible for the vehicle until it is officially checked back in by Easy Go staff.",
                  ),
                ],
              ),

              _buildTermSection(
                number: "5",
                title: "Legal Disclaimer",
                children: [
                  _buildTermBullet(
                    "Liability Limitation: Easy Go shall not be liable for any indirect, incidental, or consequential damages. Liability for direct damages, if any, shall be limited strictly to the rental amount paid.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Governing Law: These Terms and Conditions are governed by the laws of India. Any disputes shall fall under the exclusive jurisdiction of the courts situated in Varkala.",
                  ),
                  const SizedBox(height: 8),
                  _buildTermBullet(
                    "Updates: Easy Go reserves the right to modify or update these Terms and Conditions at any time without prior notice.",
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection({
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(number, style: normalblack)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: normalblack)),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildTermBullet(String text, {List<Widget>? children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                style: normalgrey,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
        if (children != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNestedBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Text(text, style: normalgrey)),
        ],
      ),
    );
  }
}
