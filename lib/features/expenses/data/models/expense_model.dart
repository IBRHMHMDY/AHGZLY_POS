import 'package:ahgzly_pos/core/database/app_database.dart'; // [Added]
import 'package:ahgzly_pos/features/expenses/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    super.id,
    required super.shiftId,
    required super.amount,
    required super.reason,
    required super.createdAt, // الآن هي DateTime
  });

  // [Refactored]: قراءة مباشرة من قاعدة بيانات Drift
  factory ExpenseModel.fromDrift(ExpenseData data) {
    return ExpenseModel(
      id: data.id,
      shiftId: data.shiftId,
      amount: data.amount,
      reason: data.reason,
      createdAt: data.createdAt, // يمرر كـ DateTime تلقائياً
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity expense) {
    return ExpenseModel(
      id: expense.id,
      shiftId: expense.shiftId,
      amount: expense.amount,
      reason: expense.reason,
      createdAt: expense.createdAt,
    );
  }
}