import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define a modern color palette
  static const Color primaryColor = Color(0xFF1A73E8); // A bright blue
  static const Color secondaryColor = Color(0xFF34A853); // Green
  static const Color backgroundColor = Color(0xFFF1F3F4); // Light gray
  static const Color cardColor = Color(0xFFFFFFFF); // White for card backgrounds
  static const Color textColor = Color(0xFF333333); // Dark gray for text
  static const Color accentColor = Color(0xFFEA4335); // Red

  // Define text themes with Google Fonts
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
    displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, color: textColor),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, color: textColor),
    bodySmall: GoogleFonts.roboto(fontSize: 12, color: textColor),
  );

  // Define AppBar theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primaryColor,
    elevation: 6,
    titleTextStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
    ),
  );

  // Define Bottom Navigation Bar theme
  static BottomNavigationBarThemeData bottomNavBarTheme = BottomNavigationBarThemeData(
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.black54,
    backgroundColor: Colors.white,
    elevation: 10,
    showSelectedLabels: true,
    showUnselectedLabels: false,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    type: BottomNavigationBarType.fixed,
    selectedIconTheme: IconThemeData(
      size: 28
    ),
  );

  // Define global ThemeData
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: appBarTheme,
    textTheme: textTheme,
    bottomNavigationBarTheme: bottomNavBarTheme,
    cardColor: cardColor,
    visualDensity: VisualDensity.adaptivePlatformDensity, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
  );
}
