import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoService {
  // في بيئة الإنتاج الحقيقية، يفضل استخدام RSA Public Key للتحقق
  // للاستخدام المباشر والفعال أوفلاين، سنستخدم HMAC مع Secret Key قوي ومخفي عبر Obfuscation
  static const String _appSecret = "YOUR_SUPER_SECURE_OBFUSCATED_SECRET_KEY_2026";

  /// Verify if the provided license payload matches its signature
  bool verifyLicenseSignature(String payload, String signature) {
    try {
      final key = utf8.encode(_appSecret);
      final bytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);
      
      final expectedSignature = base64Url.encode(digest.bytes);
      return expectedSignature == signature;
    } catch (e) {
      return false;
    }
  }

  /// Extracts payload from a JWT-like structure (Payload.Signature)
  Map<String, dynamic>? decodeAndVerifyLicense(String secureLicenseKey) {
    try {
      final parts = secureLicenseKey.split('.');
      if (parts.length != 2) return null;

      final payloadStr = utf8.decode(base64Url.decode(parts[0]));
      final signature = parts[1];

      if (!verifyLicenseSignature(parts[0], signature)) {
        return null; // التوقيع غير متطابق - تم التلاعب بالترخيص
      }

      return json.decode(payloadStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}