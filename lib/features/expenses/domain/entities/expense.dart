import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int? id;
  final double amount;
  final String reason;
  final String createdAt;

  const Expense({
    this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, reason, createdAt];
}