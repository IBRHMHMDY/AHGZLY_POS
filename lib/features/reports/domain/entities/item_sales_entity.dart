import 'package:equatable/equatable.dart';

class ItemSalesEntity extends Equatable {
  final String itemName;
  final int quantitySold;
  final double totalRevenue;

  const ItemSalesEntity({
    required this.itemName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  @override
  List<Object> get props => [itemName, quantitySold, totalRevenue];
}