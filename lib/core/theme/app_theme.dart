import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        primary: Colors.teal,
        secondary: Colors.orange.shade700,
      ),
      // إذا كنت تستخدم مكتبة Google Fonts يمكنك استخدام: GoogleFonts.cairoTextTheme()
      fontFamily: 'Cairo', // تأكد من إضافة خط Cairo في pubspec.yaml أو سيتم استخدام خط النظام الافتراضي
      
      // 🚀 [UX Fix]: تكبير الخطوط لتناسب شاشات الكاشير وسرعة القراءة
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // خطوط الأزرار
      ),
      
      // 🚀 [UX Fix]: مساحات لمس واسعة (Touch Targets) لمنع أخطاء الكاشير
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 56), // ارتفاع لا يقل عن 56px
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      
      // توحيد تصميم حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // مساحة داخلية واسعة
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
      ),
    );
  }
}