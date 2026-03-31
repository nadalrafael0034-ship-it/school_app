import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor   = Color(0xFF4F46E5);
  static const Color primaryLight   = Color(0xFF818CF8);
  static const Color primaryDark    = Color(0xFF3730A3);
  static const Color secondaryColor = Color(0xFF06B6D4);
  static const Color accentColor    = Color(0xFFF59E0B);
  static const Color successColor   = Color(0xFF10B981);
  static const Color dangerColor    = Color(0xFFEF4444);
  static const Color warningColor   = Color(0xFFF97316);

  static const Color surfaceColor   = Color(0xFF1E1E2E);
  static const Color cardColor      = Color(0xFF2A2A3E);
  static const Color dividerColor   = Color(0xFF3A3A52);

  static const Color adminColor     = Color(0xFF4F46E5);
  static const Color teacherColor   = Color(0xFF059669);
  static const Color studentColor   = Color(0xFFDB2777);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: dangerColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      cardColor: cardColor,
      dividerColor: dividerColor,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.poppins(color: Colors.white54),
        hintStyle: GoogleFonts.poppins(color: Colors.white38),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':   return adminColor;
      case 'teacher': return teacherColor;
      case 'student': return studentColor;
      default:        return primaryColor;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'present': return successColor;
      case 'absent':  return dangerColor;
      case 'late':    return warningColor;
      default:        return Colors.grey;
    }
  }
}
