import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtil {
  /// يقوم بتحويل النص الصريح للرقم السري إلى تشفير SHA-256
  static String generatePinHash(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}