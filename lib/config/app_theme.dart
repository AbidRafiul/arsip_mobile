import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === Palet Warna (sesuai design brief) ===
  static const Color primaryBlue = Color(0xFF1E4FD6); // primary-blue
  static const Color primaryBlueDark = Color(0xFF13358F); // primary-blue-dark
  static const Color primaryBlueLight = Color(0xFFE8EEFC); // primary-blue-light

  // Alias untuk kompatibilitas kode lama
  static const Color primaryColor = primaryBlue;
  static const Color primaryLight = primaryBlueLight;
  static const Color secondaryColor = primaryBlueDark;

  static const Color successColor = Color(0xFF0F9D58); // emerald-success 
  static const Color warningColor = Color(0xFFF5A623); // amber-warning
  static const Color dangerColor = Color(0xFFE53935); // red-danger
  static const Color infoColor = Color(0xFF1E4FD6); // sama dengan primary

  static const Color surfaceWhite = Color(0xFFFFFFFF); // surface-white
  static const Color surfaceSoft = Color(0xFFF5F7FB); // surface-soft
  static const Color borderSubtle = Color(0xFFE2E8F0); // border-subtle

  static const Color textPrimary = Color(0xFF0F172A); // text-primary
  static const Color textSecondary = Color(0xFF64748B); // text-secondary

  // Alias untuk kompatibilitas kode lama
  static const Color backgroundColor = surfaceSoft;
  static const Color surfaceColor = surfaceWhite;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceSoft,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlueDark,
        surface: surfaceWhite,
        error: dangerColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      // === Tipografi (Inter, skala design brief) ===
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // H1 — 24/700
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        // H2 — 20/700
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        // H3 — 16/600
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        // Body — 14/400
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        // Caption — 12/400
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
        // Button — 15/600
        labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        // titleLarge untuk kompatibilitas AppBar
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      ),

      // === AppBar: putih bersih, 1px border bawah, tanpa shadow berat ===
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: borderSubtle, width: 1),
        ),
      ),

      // === Card: radius 16px, shadow halus ===
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shadowColor: const Color(0x0F0F172A), // rgba(15,23,42,0.06)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // === ElevatedButton: radius 12px, height target 52px, font 15/600 ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // === OutlinedButton: border biru 1.5px, teks biru ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          backgroundColor: surfaceWhite,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // === TextButton ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      // === Input Fields: outlined rounded radius 12px ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerColor, width: 2),
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // === Chip ===
      chipTheme: ChipThemeData(
        backgroundColor: surfaceWhite,
        selectedColor: primaryBlue,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // === NavigationBar (Bottom Nav) ===
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 0,
        height: 64,
        indicatorColor: primaryBlueLight,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primaryBlue);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
      ),

      // === Divider ===
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // === RefreshIndicator default colour ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryBlue,
      ),
    );
  }
}
