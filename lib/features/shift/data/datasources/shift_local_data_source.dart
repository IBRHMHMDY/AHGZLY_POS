import 'package:ahgzly_pos/core/database/app_database.dart'; 
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
    final shift = await (appDatabase.select(appDatabase.shifts)
          ..where((t) => t.status.equals('active')))
        .getSingleOrNull();

    if (shift != null) {
      return ShiftModel.fromDrift(shift);
    }
    return null;
  }

  @override
  Future<ShiftModel> openShift({required int startingCash, required int cashierId}) async {
    // 🚀 [FIXED Business Logic]: استخدام Transaction وضمان عدم وجود وردية نشطة مسبقاً
    return await appDatabase.transaction(() async {
      final activeShift = await getActiveShift();
      if (activeShift != null) {
        throw Exception('توجد وردية مفتوحة بالفعل لهذا النظام.');
      }

      final id = await appDatabase.into(appDatabase.shifts).insert(
            ShiftsCompanion.insert(
              cashierId: Value(cashierId),
              startTime: DateTime.now(), 
              startingCash: Value(startingCash),
              expectedCash: Value(startingCash), 
              status: 'active', 
            ),
          );

      final newShift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(id))).getSingle();
      return ShiftModel.fromDrift(newShift);
    });
  }

  @override
  Future<ShiftModel> closeShift({required int shiftId, required int actualCash}) async {
    await (appDatabase.update(appDatabase.shifts)..where((t) => t.id.equals(shiftId)))
        .write(
      ShiftsCompanion(
        endTime: Value(DateTime.now()),
        actualCash: Value(actualCash),
        status: const Value('closed'),
      ),
    );

    final updatedShift = await (appDatabase.select(appDatabase.shifts)..where((t) => t.id.equals(shiftId))).getSingle();
    return ShiftModel.fromDrift(updatedShift);
  }
}