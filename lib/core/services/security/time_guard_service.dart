import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimeGuardService {
  final FlutterSecureStorage _secureStorage;
  static const String _lastRecordedTimeKey = 'last_recorded_secure_time';

  TimeGuardService(this._secureStorage);

  Future<bool> isTimeTampered() async {
    final now = DateTime.now();
    final lastRecordedStr = await _secureStorage.read(key: _lastRecordedTimeKey);

    if (lastRecordedStr != null) {
      final lastRecordedTime = DateTime.tryParse(lastRecordedStr);
      
      // إذا كان الوقت الحالي أقدم من آخر وقت محفوظ، إذن المستخدم أرجع الساعة للوراء!
      if (lastRecordedTime != null && now.isBefore(lastRecordedTime)) {
        return true; 
      }
    }

    // تحديث الوقت المحفوظ
    await updateLastRecordedTime();
    return false;
  }

  Future<void> updateLastRecordedTime() async {
    await _secureStorage.write(
      key: _lastRecordedTimeKey,
      value: DateTime.now().toIso8601String(),
    );
  }
}