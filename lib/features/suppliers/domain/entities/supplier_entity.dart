import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, phone, address, notes, createdAt];
}
