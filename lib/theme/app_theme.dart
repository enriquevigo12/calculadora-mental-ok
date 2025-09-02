import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Fondos
  static const Color backgroundLight = Color(0xFFF4F6F8);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF2A2A2A);
  
  // Textos
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFB0B7C3);
  static const Color textMutedDark = Color(0xFF6C757D);
  
  // Modos de juego
  static const Color easyPrimary = Color(0xFF00C896);
  static const Color easySecondary = Color(0xFF06D6A0);
  static const Color hardPrimary = Color(0xFF7C3AED);
  static const Color hardSecondary = Color(0xFF9333EA);
  
  // Acentos y estados
  static const Color accentWarm = Color(0xFFFFB02E);
  static const Color coinColor = Color(0xFFFFB02E); // Mismo que accentWarm
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB02E);
  
  // Glassmorphism
  static const Color glassLight = Color(0xB3FFFFFF); // 70% opacity
  static const Color glassDark = Color(0xB32A2A2A); // 70% opacity
  static const Color glassDarkSubtle = Color(0x801A1A1A); // 50% opacity
}

class AppGradients {
  // Gradientes de modos de juego
  static const LinearGradient easy = LinearGradient(
    colors: [AppColors.easyPrimary, AppColors.easySecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient hard = LinearGradient(
    colors: [AppColors.hardPrimary, AppColors.hardSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradientes neutros
  static const LinearGradient neutralLight = LinearGradient(
    colors: [AppColors.backgroundLight, Color(0xFFE5E7EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient neutralDark = LinearGradient(
    colors: [AppColors.backgroundDark, AppColors.surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardDark = LinearGradient(
    colors: [AppColors.cardDark, Color(0xFF3A3A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradientes adicionales
  static const LinearGradient accentWarmGradient = LinearGradient(
    colors: [AppColors.accentWarm, Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static const _colorSchemeSeed = AppColors.easyPrimary;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorSchemeSeed,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: AppColors.glassLight,
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.easyPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.easyPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.glassLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorSchemeSeed,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondaryDark,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textMutedDark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: AppColors.glassDark,
        margin: const EdgeInsets.all(8),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.easyPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shadowColor: AppColors.easyPrimary.withOpacity(0.3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textMutedDark.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textMutedDark.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.easyPrimary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.glassDarkSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.textMutedDark,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassDarkSubtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        side: BorderSide(
          color: AppColors.textMutedDark.withOpacity(0.2),
          width: 1,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimaryDark,
          size: 24,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
    );
  }

  // Colores específicos del juego (usando nueva paleta)
  static const Color easyModeColor = AppColors.easyPrimary;
  static const Color hardModeColor = AppColors.hardPrimary;
  static const Color successColor = AppColors.success;
  static const Color errorColor = AppColors.error;
  static const Color warningColor = AppColors.warning;
  static const Color coinColor = AppColors.accentWarm;
  
  // Gradientes (usando AppGradients)
  static const LinearGradient easyGradient = AppGradients.easy;
  static const LinearGradient hardGradient = AppGradients.hard;
  static const LinearGradient backgroundGradient = AppGradients.neutralLight;
  static const LinearGradient primaryGradient = AppGradients.easy;
  static const LinearGradient secondaryGradient = AppGradients.accentWarmGradient;
}
