import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final int? id;
  final String name;
  final bool isActive;

  const PaymentMethodEntity({
    this.id,
    required this.name,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, isActive];
}