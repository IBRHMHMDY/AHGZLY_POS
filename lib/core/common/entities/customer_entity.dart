import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String? address;

  const CustomerEntity({
    this.id,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, address];
}