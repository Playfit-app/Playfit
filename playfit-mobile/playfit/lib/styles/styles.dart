import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Colors
  static const Color grey = Color.fromARGB(255, 78, 74, 89);
  static const Color red = Color.fromARGB(255, 231, 29, 54);
  static const Color brown = Color.fromARGB(255, 169, 153, 133);
  static const Color beige = Color.fromARGB(255, 218, 210, 188);
  static const Color primaryColor = Color.fromARGB(255, 129, 0, 0);
  static const Color backgroundColor = Color.fromARGB(255, 238, 235, 221);

  // Text styles
  static TextStyle bodyRegular = GoogleFonts.amaranth(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: grey,
  );
  static TextStyle bodyBold = GoogleFonts.amaranth(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: grey,
  );
  static TextStyle titleRegular = GoogleFonts.amaranth(
    fontSize: 32,
    fontWeight: FontWeight.normal,
    color: grey,
  );
  static TextStyle titleBold = GoogleFonts.amaranth(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: grey,
  );
  static TextStyle usernameRegular = GoogleFonts.amaranth(
    fontSize: 40,
    fontWeight: FontWeight.normal,
    color: beige,
  );

  static TextStyle displaySmall = GoogleFonts.amaranth(
    fontSize: 36,
    height: 44,
    letterSpacing: 0,
    fontWeight: FontWeight.normal,
    color: grey,
  );
}
