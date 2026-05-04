import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class HardwareService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getHardwareId() async {
    try {
      if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.deviceId; // This is a unique identifier for Windows
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      }
      return 'UNKNOWN_DEVICE';
    } catch (e) {
      return 'FALLBACK_DEVICE_ID';
    }
  }
}
