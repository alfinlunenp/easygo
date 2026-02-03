import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const double padding = 16.0;
double heightgapnormal = 10.0;
double borderradius = 12.0;

Color primaryColor = Color.fromARGB(255, 5, 40, 56);
Color secondprimaryColor = Color(0xFF53AC42);
Color secondaryColor = Color.fromARGB(255, 135, 135, 135);
Color bordercolorgrey = Color.fromARGB(255, 215, 215, 215);
Color containerColor = Color.fromRGBO(241, 242, 246, 1);
const cardcolor = Color(0xFFF3F4F6);

const Color dividercolor = Color.fromARGB(255, 228, 228, 231);

TextStyle poppinscaps = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

TextStyle poppinscapswhite = GoogleFonts.poppins(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

TextStyle normalgrey = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color(0xFF878787),
);

TextStyle normalwhite = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color.fromARGB(255, 255, 255, 255),
);

TextStyle mediumwhite = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 255, 255, 255),
);

TextStyle normalblack = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color.fromARGB(255, 0, 0, 0),
);

TextStyle smalltextblk = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color.fromARGB(255, 0, 0, 0),
);

TextStyle smalltextwhite = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color.fromARGB(255, 255, 255, 255),
);

TextStyle smalltextgrey = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0xFF878787),
);

TextStyle mediumblack = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 0, 0, 0),
);

TextStyle mediumgrey = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF878787),
);

TextStyle largelack = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 0, 0, 0),
);

TextStyle hintgrey = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFF878787),
);

TextStyle colortext = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: secondprimaryColor,
);

TextStyle colortextmall = GoogleFonts.poppins(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  color: primaryColor,
);

TextStyle colortextlarge = GoogleFonts.poppins(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: primaryColor,
);

TextStyle buttontext = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 255, 255, 255),
);

TextStyle readtitle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Color.fromARGB(255, 0, 0, 0),
);
TextStyle readsubtitle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color.fromARGB(255, 0, 0, 0),
);

TextStyle unreadtitle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Color(0xFF878787),
);
TextStyle unreadsubtitle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0xFF878787),
);

// deetailed page

TextStyle detailedname = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: Colors.black,
);

String Noimage =
    "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";

//
String formatDateTimeToDisplay(DateTime date) {
  return DateFormat('dd - MM - yyyy').format(date);
}

String formatTimeToDisplay(DateTime dateTime) {
  return DateFormat('hh : mm a').format(dateTime);
}

String formatStringTimeToDisplay(String dateTimeString) {
  try {
    final dt = DateTime.parse(dateTimeString);
    return DateFormat('hh : mm a').format(dt);
  } catch (e) {
    return dateTimeString;
  }
}
