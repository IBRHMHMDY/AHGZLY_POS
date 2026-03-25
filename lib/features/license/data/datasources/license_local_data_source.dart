import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LicenseLocalDataSource {
  Future<String?> getSavedLicense();
  Future<void> saveLicense(String secureLicenseKey);
  Future<void> clearLicense();
}

class LicenseLocalDataSourceImpl implements LicenseLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _licenseKeyName = 'app_secure_license_token';

  LicenseLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<String?> getSavedLicense() async {
    return await secureStorage.read(key: _licenseKeyName);
  }

  @override
  Future<void> saveLicense(String secureLicenseKey) async {
    await secureStorage.write(key: _licenseKeyName, value: secureLicenseKey);
  }

  @override
  Future<void> clearLicense() async {
    await secureStorage.delete(key: _licenseKeyName);
  }
}