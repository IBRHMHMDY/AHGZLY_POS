import 'package:equatable/equatable.dart';
import '../../data/models/sales_report_model.dart';
import '../../data/models/inventory_report_model.dart';
import '../../data/models/supplier_report_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SalesReportLoaded extends ReportsState {
  final SalesReportModel report;
  const SalesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class InventoryReportLoaded extends ReportsState {
  final List<InventoryReportItemModel> items;
  const InventoryReportLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class SupplierReportLoaded extends ReportsState {
  final SupplierReportModel report;
  const SupplierReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
