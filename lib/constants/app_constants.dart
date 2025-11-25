import 'package:flutter/material.dart';

class AppConstants {
  // Kendi API Key'ini buraya yapıştır
  static const String apiKey = 'Api Key Buraya Gelecek.....'; 

 // --- MODERN RENK PALETİ ---
// Ana Geçiş Rengi (Maviden Mora - Dribbble tarzı)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.fromARGB(255, 62, 74, 126), Color.fromARGB(209, 4, 161, 176)], 
  );

  // Kartlar için Yumuşak Geçiş (Beyazdan çok açık griye)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF9FAFB)], 
  );

  static const Color backgroundColor = Color.fromARGB(255, 232, 233, 234); // Yumuşak Gri Zemin
  static const Color primaryColor = Color.fromARGB(255, 64, 129, 158);    // Ana Mavi
  static const Color secondaryColor = Color(0xFF764BA2);  // Ana Mor
  
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF9CA3AF);

  // Durum Renkleri
  static const Color safeGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
}
