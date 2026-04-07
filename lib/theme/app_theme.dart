import 'package:flutter/material.dart';

class AppTheme {
  // Core palette — Aurora Cosmos
  static const Color bg0       = Color(0xFF06050F); // deepest void
  static const Color bg1       = Color(0xFF0D0B1E); // surface
  static const Color bg2       = Color(0xFF131228); // card base
  static const Color bg3       = Color(0xFF1C1A36); // elevated card

  static const Color auroraTeal    = Color(0xFF00E5CC);
  static const Color auroraViolet  = Color(0xFF8B5CF6);
  static const Color auroraPink    = Color(0xFFE879F9);
  static const Color auroraBlue    = Color(0xFF38BDF8);
  static const Color auroraGold    = Color(0xFFF59E0B);

  static const Color textPrimary   = Color(0xFFF0EEFF);
  static const Color textSecondary = Color(0xFF9B8FC8);
  static const Color textMuted     = Color(0xFF5A5275);

  static const Color border        = Color(0xFF2A2550);
  static const Color borderGlow    = Color(0xFF3D3680);

  // Mood system
  static Color moodColor(String mood) {
    switch (mood) {
      case 'Happy':    return const Color(0xFFF59E0B);
      case 'Scary':    return const Color(0xFFEF4444);
      case 'Weird':    return const Color(0xFFA855F7);
      case 'Peaceful': return const Color(0xFF00E5CC);
      case 'Lucid':    return const Color(0xFF38BDF8);
      case 'Neutral':  return const Color(0xFF6B7280);
      default:         return const Color(0xFF6B7280);
    }
  }

  static String moodEmoji(String mood) {
    switch (mood) {
      case 'Happy':    return '✨';
      case 'Scary':    return '🌑';
      case 'Weird':    return '🌀';
      case 'Peaceful': return '🌊';
      case 'Lucid':    return '💎';
      case 'Neutral':  return '🌫️';
      default:         return '🌫️';
    }
  }

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg0,
    fontFamily: 'serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bg2,
      hintStyle: const TextStyle(color: textMuted, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: auroraViolet, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: auroraViolet,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}

