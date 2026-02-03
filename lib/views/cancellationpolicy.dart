import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class Cancellationpolicy extends StatelessWidget {
  const Cancellationpolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Cancellation policy", style: largelack),

                SizedBox(height: 20),

                Text(
                  'The cancellation of bookings made through Get Bike is subject to the following terms: cancellations made seven (7) days prior to the scheduled booking date will result in a deduction of thirty percent (30%) of the total rental amount; cancellations made two (2) days prior will result in a deduction of fifty percent (50%); and cancellations made one (1) day prior will result in a deduction of seventy percent (70%). The remaining balance, if any, will be refunded to the customer. All refunds will be processed to the original mode of payment within a reasonable time frame.',
                  textAlign: TextAlign.justify,
                  style: normalgrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
