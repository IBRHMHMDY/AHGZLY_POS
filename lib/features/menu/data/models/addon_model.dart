import 'package:ahgzly_pos/core/database/app_database.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/addon_entity.dart';

class AddonModel extends AddonEntity {
  const AddonModel({
    super.id,
    required super.name,
    required super.price,
    required super.costPrice,
  });

  factory AddonModel.fromDrift(AddonData data) {
    return AddonModel(
      id: data.id,
      name: data.name,
      price: data.price,
      costPrice: data.costPrice,
    );
  }
}