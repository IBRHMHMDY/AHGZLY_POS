import 'package:equatable/equatable.dart';

class AddonEntity extends Equatable {
  final int? id;
  final String name;
  final int price;
  final int costPrice;

  const AddonEntity({
    this.id,
    required this.name,
    required this.price,
    required this.costPrice,
  });

  @override
  List<Object?> get props => [id, name, price, costPrice];
}