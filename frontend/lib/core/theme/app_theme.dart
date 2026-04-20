import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color primaryDark = Color(0xFF1A237E);    // Azul oscuro (header)
  static const Color primaryPurple = Color(0xFF4A148C);  // Morado (degradado)
  static const Color accentPurple = Color(0xFF7C3AED);   // Morado botones
  static const Color accentGreen = Color(0xFF22C55E);    // Verde (botón login)
  static const Color accentCyan = Color(0xFF06B6D4);     // Cyan (botón subir calif.)
  static const Color accentRed = Color(0xFFEF4444);      // Rojo (suspender)
  static const Color accentOrange = Color(0xFFF59E0B);   // Naranja (regular)
  static const Color backgroundGray = Color(0xFF374151); // Gris oscuro (menu inferior)
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color backgroundLight = Color(0xFFF3F4F6);

  static const Color colorAlumno = Color(0xFF22C55E);    // Verde
  static const Color colorMaestro = Color(0xFFEF4444);   // Rojo
  static const Color colorAdmin = Color(0xFFF59E0B);     // Amarillo

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentPurple,
        primary: accentPurple,
        secondary: accentGreen,
        background: backgroundLight,
        surface: cardWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPurple,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: accentPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
    );
  }
}

const LinearGradient headerGradient = LinearGradient(
  colors: [AppTheme.primaryDark, AppTheme.primaryPurple],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
