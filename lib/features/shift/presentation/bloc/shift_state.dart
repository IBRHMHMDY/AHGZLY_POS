import 'package:flutter/foundation.dart';
import '../../domain/entities/shift.dart';

@immutable
abstract class ShiftState {}

class ShiftInitial extends ShiftState {}
class ShiftLoading extends ShiftState {}

class ActiveShiftLoaded extends ShiftState {
  final Shift shift;
  ActiveShiftLoaded({required this.shift});
}

class NoActiveShiftState extends ShiftState {}

class ShiftOpenedSuccess extends ShiftState {
  final Shift shift;
  ShiftOpenedSuccess({required this.shift});
}

class ShiftClosedSuccess extends ShiftState {
  final Shift closedShift; // يمكن استخدامها لطباعة الزي ريبورت Z-Report فور الإغلاق
  ShiftClosedSuccess({required this.closedShift});
}

class ShiftError extends ShiftState {
  final String message;
  ShiftError({required this.message});
}