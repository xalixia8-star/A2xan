import 'package:flutter/material.dart';

/// Satu-satunya tempat warna dasar aplikasi didefinisikan.
/// Widget lain harus memakai Theme.of(context) atau konstanta di sini.
class AppColors {
  AppColors._();

  static const Color burgundy = Color(0xFF710912); // aksen utama
  static const Color burgundyDark = Color(0xFF450409); // ujung gradient
  static const Color midnight = Color(0xFF0D0D0D); // background
  static const Color gold = Color(0xFFC28D39); // ikon, border, highlight
  static const Color espresso = Color(0xFF362822); // card, input, sheet
  static const Color champagne = Color(0xFFEFE5D2); // teks utama

  /// Champagne dengan opasitas rendah untuk teks sekunder (kontras tetap > AA).
  static const Color champagneMuted = Color(0xFFC9BFAE);

  // Warna dasar untuk ikon layanan (logo di atas squircle brand).
  static const Color iconOnDark = Color(0xFFFFFFFF);
  static const Color iconOnLight = Color(0xFF111111);
  static const Color iconNeutralBase = Color(0xFF1C1C1E);

  static const Color danger = Color(0xFFE57373);
  static const Color success = Color(0xFF8DBF8A);

  static Color goldBorder([double opacity = 0.28]) =>
      gold.withValues(alpha: opacity);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [burgundy, burgundyDark],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.45),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}
