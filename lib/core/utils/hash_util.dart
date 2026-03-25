import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class HashUtil {
  /// توليد Salt عشوائي قوي للمستخدمين الجدد
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// تشفير الـ PIN مع الـ Salt
  /// تُرجع (String) يمثل التشفير
  static String generatePinHash(String pin, String salt) {
    // دمج الـ PIN مع الـ Salt قبل التشفير لضمان أقصى حماية
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// التحقق من صحة الـ PIN المدخل مقارنة بالـ Hash المحفوظ 
  /// تُرجع (bool) - هذه الدالة هي التي تُستخدم في شروط الـ if
  static bool verifyPin(String inputPin, String salt, String expectedHash) {
    final inputHash = generatePinHash(inputPin, salt);
    return inputHash == expectedHash;
  }
}