import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/suppliers/domain/entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id,
    required super.name,
    super.phone,
    super.address,
    super.notes,
    required super.createdAt,
  });

  factory SupplierModel.fromDrift(SupplierData data) {
    return SupplierModel(
      id: data.id,
      name: data.name,
      phone: data.phone,
      address: data.address,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
