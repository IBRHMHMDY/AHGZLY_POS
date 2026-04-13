// مسار الملف: lib/features/shift/data/datasources/shift_local_data_source.dart

import 'package:ahgzly_pos/core/database/app_database.dart'; 
import 'package:ahgzly_pos/core/error/exceptions.dart';
import 'package:ahgzly_pos/features/shift/data/models/shift_model.dart';
import 'package:drift/drift.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  Future<ShiftModel> openShift({required int startingCash, required int cashierId});
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash});
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  final AppDatabase appDatabase; 

  ShiftLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<ShiftModel?> getActiveShift() async {
    try {
      final shift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.status.equals('active')))
          .getSingleOrNull();

      if (shift != null) {
        // [Refactor]: تمرير الكائن مباشرة للـ Factory
        return ShiftModel.fromDrift(shift);
      }
      return null;
    } catch (e) {
      throw CacheException('فشل في جلب الوردية النشطة: $e'); // توحيد نوع الـ Exception
    }
  }

  @override
  Future<ShiftModel> openShift({required int startingCash, required int cashierId}) async {
    try {
      final id = await appDatabase.into(appDatabase.shifts).insert(
            ShiftsCompanion.insert(
              cashierId: Value(cashierId),
              // [Refactor]: تمرير DateTime مباشرة وليس نص
              startTime: DateTime.now(), 
              startingCash: Value(startingCash),
              expectedCash: Value(startingCash), 
              status: 'active', 
            ),
          );

      final newShift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      return ShiftModel.fromDrift(newShift);
    } catch (e) {
      throw CacheException('فشل في فتح الوردية: $e');
    }
  }

  @override
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash}) async {
    try {
      await (appDatabase.update(appDatabase.shifts)
            ..where((t) => t.id.equals(shiftId)))
          .write(
        ShiftsCompanion(
          // [Refactor]: تمرير DateTime مباشرة وليس نص
          endTime: Value(DateTime.now()),
          actualCash: Value(actualCash),
          status: const Value('closed'),
        ),
      );

      final updatedShift = await (appDatabase.select(appDatabase.shifts)
            ..where((t) => t.id.equals(shiftId)))
          .getSingle();

      return ShiftModel.fromDrift(updatedShift);
    } catch (e) {
      throw CacheException('فشل في إغلاق الوردية: $e');
    }
  }
}