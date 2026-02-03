import 'package:flutter/material.dart';
import 'package:easygonww/utils/utilities.dart';

class Privacypolicy extends StatelessWidget {
  const Privacypolicy({super.key});

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
                Text("Privacy policy", style: largelack),

                SizedBox(height: 20),

                Text(
                  "At Get Bike, we are committed to protecting the privacy of our customers (“Users”). By using our services, Users consent to the collection and use of personal information such as name, contact details, government-issued identification, and payment information, solely for the purposes of processing bookings, verifying identity, and ensuring compliance with legal requirements. Get Bike may also collect non-personal information such as device details and usage patterns to improve user experience. All personal information is stored securely and will not be shared, sold, or disclosed to third parties except as required by law, to protect our legal rights, or to facilitate the rental process with trusted service providers. Users acknowledge that while Get Bike employs reasonable security measures, no electronic transmission or storage is completely secure, and therefore Get Bike cannot guarantee absolute data security. By using the platform, Users consent to receive transactional and service-related communications, and may opt out of promotional communications at any time. This Privacy Policy is governed by the laws of India, and any disputes arising from it shall be subject to the exclusive jurisdiction of the courts situated in Kerala.,",
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
