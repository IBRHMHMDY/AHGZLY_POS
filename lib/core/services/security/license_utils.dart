import 'dart:convert';
import 'package:crypto/crypto.dart';

class LicenseUtils {
  static const String _secretSalt = "AHGZLY_SECURE_SALT_2026";

  /// Generates the expected license key for a given hardware ID.
  /// This should be the same logic used by the external Keygen tool.
  static String generateExpectedKey(String hardwareId) {
    var bytes = utf8.encode(hardwareId + _secretSalt);
    var digest = sha256.convert(bytes);
    // Convert to a shorter, user-friendly format, e.g. uppercase hex grouped by dashes
    String hexString = digest.toString().toUpperCase();
    return '${hexString.substring(0, 4)}-${hexString.substring(4, 8)}-${hexString.substring(8, 12)}-${hexString.substring(12, 16)}';
  }

  /// Verifies if the provided license key matches the hardware ID.
  static bool verifyLicenseKey(String hardwareId, String providedKey) {
    if (providedKey.isEmpty) return false;
    String expectedKey = generateExpectedKey(hardwareId);
    return expectedKey == providedKey.trim().toUpperCase();
  }
}
