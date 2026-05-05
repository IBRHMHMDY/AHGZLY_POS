import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/core/error/exceptions.dart';
import '../models/supplier_model.dart';

abstract class SuppliersLocalDataSource {
  Future<List<SupplierModel>> getSuppliers();
  Future<SupplierModel> addSupplier(SuppliersCompanion supplier);
  Future<SupplierModel> updateSupplier(SuppliersCompanion supplier);
  Future<void> deleteSupplier(int id);
}

class SuppliersLocalDataSourceImpl implements SuppliersLocalDataSource {
  final AppDatabase appDatabase;

  SuppliersLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final suppliers = await appDatabase.select(appDatabase.suppliers).get();
      return suppliers.map((s) => SupplierModel.fromDrift(s)).toList();
    } catch (e) {
      throw CacheException('فشل في جلب الموردين: $e');
    }
  }

  @override
  Future<SupplierModel> addSupplier(SuppliersCompanion supplier) async {
    try {
      final id = await appDatabase.into(appDatabase.suppliers).insert(supplier);
      final data = await (appDatabase.select(appDatabase.suppliers)..where((t) => t.id.equals(id))).getSingle();
      return SupplierModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في إضافة المورد: $e');
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SuppliersCompanion supplier) async {
    try {
      await appDatabase.update(appDatabase.suppliers).replace(supplier);
      final data = await (appDatabase.select(appDatabase.suppliers)..where((t) => t.id.equals(supplier.id.value))).getSingle();
      return SupplierModel.fromDrift(data);
    } catch (e) {
      throw CacheException('فشل في تحديث المورد: $e');
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    try {
      await (appDatabase.delete(appDatabase.suppliers)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw CacheException('فشل في حذف المورد. قد يكون مرتبطاً بفواتير سابقة.');
    }
  }
}
