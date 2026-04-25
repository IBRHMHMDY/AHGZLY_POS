import 'package:flutter/material.dart';

/// 🎨 الطبقة الأساسية لتصميم النظام (Design System)
/// مخصص ليتوافق مع شاشات اللمس لأجهزة الكاشير ويدعم اللغة العربية.
class AppTheme {
  
  // الألوان الأساسية للنظام (Corporate Colors)
  static const Color primaryColor = Colors.teal;
  static final Color secondaryColor = Colors.orange.shade700;
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Colors.red.shade700,
      ),
      fontFamily: 'Cairo', // تأكد من توفر الخط في pubspec.yaml

      // 🚀 [UX Fix]: Typography مخصصة للقراءة السريعة للكاشير
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87), // لأسماء الأصناف
        bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // نصوص الأزرار
      ),
      
      // 🚀 [UX Fix]: Touch Targets واسعة لمنع أخطاء الضغط
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 56), // ارتفاع ثابت للأزرار الأساسية
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),

      // توحيد تصميم البطاقات (للمنتجات والأقسام)
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // توحيد تصميم النوافذ المنبثقة (Dialogs)
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Cairo'),
      ),
      
      // توحيد تصميم حقول الإدخال
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade700, width: 1.5)),
      ),
      
      // تصميم الـ AppBar
      appBarTheme: const AppBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Cairo'),
      ),
    );
  }
}