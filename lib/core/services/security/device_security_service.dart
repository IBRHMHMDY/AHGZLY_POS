import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceSecurityService {
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  DeviceSecurityService(this._secureStorage);

  Future<String> getUniqueDeviceId() async {
    // 1. Check if we already generated and secured a hardware-bound UUID
    String? secureDeviceId = await _secureStorage.read(key: 'secure_device_id');
    if (secureDeviceId != null) {
      return secureDeviceId;
    }

    // 2. Fallback to generating a device-specific ID based on hardware
    String hardwareId = '';
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      hardwareId = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      hardwareId = '${iosInfo.identifierForVendor}';
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfoPlugin.windowsInfo;
      hardwareId = windowsInfo.deviceId;
    } else {
      hardwareId = const Uuid().v4();
    }

    // Hash it for privacy and consistency
    final bytes = utf8.encode(hardwareId);
    final digest = sha256.convert(bytes);
    secureDeviceId = digest.toString();

    // Store it securely so it survives app updates but gets wiped on uninstall (mostly)
    await _secureStorage.write(key: 'secure_device_id', value: secureDeviceId);
    
    return secureDeviceId;
  }
}