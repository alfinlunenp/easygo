// import 'package:flutter/material.dart';
// import 'package:getbike/model/models.dart';
// import 'package:getbike/utils/navigations.dart';
// import 'package:getbike/utils/utilities.dart';
// import 'package:getbike/widgets/button.dart';

// class RatingPage extends StatefulWidget {
//   BookingModel bookingModel;
//    RatingPage({super.key ,  required this.bookingModel});

//   @override
//   State<RatingPage> createState() => _RatingPageState();
// }

// class _RatingPageState extends State<RatingPage> {
//   int _rating = 0; // stores selected stars
//   final TextEditingController _feedbackController = TextEditingController();

//   void _submitFeedback() {
//     final feedback = _feedbackController.text.trim();
//     if (_rating == 0 || feedback.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please give a rating and feedback")),
//       );
//       return;
//     }

//     // Handle submission logic (API / Database)
//     print("Rating: $_rating, Feedback: $feedback");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Thank you for your feedback!")),
//     );

//     _feedbackController.clear();
//     setState(() {
//       _rating = 0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//       appBar: AppBar(
//         toolbarHeight: 85,
//         backgroundColor: const Color(0xFFF1F2F6),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 16.0),
//           child: GestureDetector(
//             onTap: () {
//               Navigations.pop(context);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.black),
//               ),
//               child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//             ),
//           ),
//         ),
//         centerTitle: false,
//         title: Text("Rate Your", style: largelack),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("How was your experience?",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),

//             // ⭐ Rating row
//             Row(
//               children: List.generate(5, (index) {
//                 return IconButton(
//                   onPressed: () {
//                     setState(() {
//                       _rating = index + 1;
//                     });
//                   },
//                   icon: Icon(
//                     index < _rating ? Icons.star : Icons.star_border,
//                     color: Colors.amber,
//                     size: 32,
//                   ),
//                 );
//               }),
//             ),
//             const SizedBox(height: 16),

//             // 📝 Feedback TextFormField
//             TextFormField(
//               controller: _feedbackController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: "Write your feedback...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ✅ Submit Button
//             Center(
//               child: GlobalButton(
//                  context: context,
//                 ontap: _submitFeedback,
//                 text: "Submit",
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
