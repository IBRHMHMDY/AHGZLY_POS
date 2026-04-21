import 'package:equatable/equatable.dart';

class RestaurantTableEntity extends Equatable {
  final int? id;
  final int zoneId;
  final String tableNumber;
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'

  const RestaurantTableEntity({
    this.id,
    required this.zoneId,
    required this.tableNumber,
    required this.capacity,
    this.status = 'available',
  });

  @override
  List<Object?> get props => [id, zoneId, tableNumber, capacity, status];
}