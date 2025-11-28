import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// App theme configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryGold,
      scaffoldBackgroundColor: AppConstants.shadowBlack,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryGold,
        secondary: AppConstants.secondaryOrange,
        tertiary: AppConstants.electricBlue,
        surface: AppConstants.darkPurple.withOpacity(0.3),
        background: AppConstants.shadowBlack,
      ),
      textTheme: GoogleFonts.cinzelTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: AppConstants.marbleWhite,
          displayColor: AppConstants.primaryGold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGold,
          foregroundColor: AppConstants.shadowBlack,
          textStyle: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: AppConstants.secondaryOrange, width: 2),
          ),
        ),
      ),
      // cardTheme: CardTheme(
      //   color: AppConstants.darkPurple.withOpacity(0.5),
      //   elevation: 8,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(20),
      //     side: BorderSide(color: AppConstants.primaryGold.withOpacity(0.3), width: 2),
      //   ),
      // ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryGold,
        ),
      ),
    );
  }
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryGold,
      scaffoldBackgroundColor: AppConstants.marbleWhite,
      colorScheme: ColorScheme.light(
        primary: AppConstants.primaryGold,
        secondary: AppConstants.secondaryOrange,
        tertiary: AppConstants.electricBlue,
        surface: Colors.white.withOpacity(0.9),
        background: AppConstants.marbleWhite,
      ),
      textTheme: GoogleFonts.cinzelTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: AppConstants.shadowBlack,
          displayColor: AppConstants.darkPurple,
        ),
      ),
    );
  }
  
  // Custom decorations
  static BoxDecoration goldenBorder = BoxDecoration(
    border: Border.all(color: AppConstants.primaryGold, width: 3),
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      colors: [
        AppConstants.primaryGold.withOpacity(0.3),
        AppConstants.secondaryOrange.withOpacity(0.3),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: AppConstants.primaryGold.withOpacity(0.5),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );
  
  static BoxDecoration marblePanel = BoxDecoration(
    color: AppConstants.marbleWhite.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppConstants.primaryGold.withOpacity(0.5), width: 2),
  );
}
