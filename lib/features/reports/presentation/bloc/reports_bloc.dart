import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/reports_local_data_source.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsLocalDataSource dataSource;

  ReportsBloc({required this.dataSource}) : super(ReportsInitial()) {
    on<LoadSalesReportEvent>(_onLoadSales);
    on<LoadInventoryReportEvent>(_onLoadInventory);
    on<LoadSupplierReportEvent>(_onLoadSupplier);
  }

  Future<void> _onLoadSales(LoadSalesReportEvent event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final report = await dataSource.getSalesReport(from: event.from, to: event.to);
      emit(SalesReportLoaded(report));
    } catch (e) {
      emit(ReportsError('فشل في تحميل تقرير المبيعات: $e'));
    }
  }

  Future<void> _onLoadInventory(LoadInventoryReportEvent event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final items = await dataSource.getInventoryReport();
      emit(InventoryReportLoaded(items));
    } catch (e) {
      emit(ReportsError('فشل في تحميل تقرير المخزن: $e'));
    }
  }

  Future<void> _onLoadSupplier(LoadSupplierReportEvent event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final report = await dataSource.getSupplierReport(event.supplierId);
      emit(SupplierReportLoaded(report));
    } catch (e) {
      emit(ReportsError('فشل في تحميل تقرير المورد: $e'));
    }
  }
}
