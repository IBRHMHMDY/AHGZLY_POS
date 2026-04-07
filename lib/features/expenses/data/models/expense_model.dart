import 'package:ahgzly_pos/features/expenses/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    super.id,
    required super.shiftId,
    required super.amount,
    required super.reason,
    required super.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int,
      shiftId: map['shift_id'] as int,
      // Refactored: تحويل إلى int 
      amount: (map['amount'] as num).toInt(),
      reason: map['reason'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shift_id': shiftId,
      'amount': amount, // سيتم حفظه كـ Integer
      'reason': reason,
      'created_at': createdAt,
    };
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      shiftId: entity.shiftId,
      amount: entity.amount,
      reason: entity.reason,
      createdAt: entity.createdAt,
    );
  }
}