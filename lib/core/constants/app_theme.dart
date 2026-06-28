import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      // Mengunci Font Utama Aplikasi secara Global ke Plus Jakarta Sans
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.textDark),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
      ),
    );
  }
}