import 'package:equatable/equatable.dart';
import 'package:ahgzly_pos/features/shift/domain/entities/shift_report.dart';

abstract class ShiftEvent extends Equatable {
  const ShiftEvent();
  @override
  List<Object> get props => [];
}

class LoadZReportEvent extends ShiftEvent {}

class CloseCurrentShiftEvent extends ShiftEvent {
  final ShiftReport report;
  const CloseCurrentShiftEvent(this.report);
  @override
  List<Object> get props => [report];
}