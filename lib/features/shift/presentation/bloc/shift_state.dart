import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';

abstract class ShiftState extends Equatable {
  const ShiftState();
  @override
  List<Object> get props => [];
}

class ShiftInitial extends ShiftState {}

class ShiftLoading extends ShiftState {}

class ZReportLoaded extends ShiftState {
  final ShiftReport report;
  const ZReportLoaded(this.report);
  @override
  List<Object> get props => [report];
}

class ShiftClosedSuccess extends ShiftState {
  final String message;
  const ShiftClosedSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ShiftError extends ShiftState {
  final String message;
  const ShiftError(this.message);
  @override
  List<Object> get props => [message];
}