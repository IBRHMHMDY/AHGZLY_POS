import 'package:flutter/foundation.dart';
import '../../domain/entities/shift_entity.dart';

@immutable
abstract class ShiftState {}

class ShiftInitial extends ShiftState {}
class ShiftLoading extends ShiftState {}

class ActiveShiftLoaded extends ShiftState {
  final ShiftEntity shift;
  ActiveShiftLoaded({required this.shift});
}

class NoActiveShiftState extends ShiftState {}

class ShiftOpenedSuccess extends ShiftState {
  final ShiftEntity shift;
  ShiftOpenedSuccess({required this.shift});
}

class ShiftClosedSuccess extends ShiftState {
  final ShiftEntity closedShift; // يمكن استخدامها لطباعة الزي ريبورت Z-Report فور الإغلاق
  ShiftClosedSuccess({required this.closedShift});
}

class ShiftError extends ShiftState {
  final String message;
  ShiftError({required this.message});
}

class ShiftsHistoryLoaded extends ShiftState {
  final List<ShiftEntity> shifts;
  final bool hasReachedMax;
  
  ShiftsHistoryLoaded({
    required this.shifts,
    this.hasReachedMax = false,
  });

  ShiftsHistoryLoaded copyWith({
    List<ShiftEntity>? shifts,
    bool? hasReachedMax,
  }) {
    return ShiftsHistoryLoaded(
      shifts: shifts ?? this.shifts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}