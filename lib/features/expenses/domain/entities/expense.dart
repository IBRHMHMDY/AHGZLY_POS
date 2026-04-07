import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int? id;
  final int shiftId;
  final int amount; // Refactored: تغيير من double إلى int (Cents)
  final String reason;
  final String createdAt;

  const Expense({
    this.id,
    required this.shiftId,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, shiftId, amount, reason, createdAt];
}