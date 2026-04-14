import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seedColor = Colors.indigo;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seedColor,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
