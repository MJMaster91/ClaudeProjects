import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFFDF6EC);
  static const Color primary = Color(0xFF4A9B8E);
  static const Color accent = Color(0xFFE8A838);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: background,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          bodyMedium: GoogleFonts.nunito(fontSize: 20, color: textPrimary),
          titleLarge: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(64, 64),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
