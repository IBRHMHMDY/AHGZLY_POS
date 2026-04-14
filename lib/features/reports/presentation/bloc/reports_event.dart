import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadReportsEvent extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadReportsEvent({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class RefreshReportsEvent extends ReportsEvent {}