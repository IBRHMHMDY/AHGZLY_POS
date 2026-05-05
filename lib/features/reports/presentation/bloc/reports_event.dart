import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesReportEvent extends ReportsEvent {
  final DateTime from;
  final DateTime to;
  const LoadSalesReportEvent({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

class LoadInventoryReportEvent extends ReportsEvent {}

class LoadSupplierReportEvent extends ReportsEvent {
  final int supplierId;
  const LoadSupplierReportEvent(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}
