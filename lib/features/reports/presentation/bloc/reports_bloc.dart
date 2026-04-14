import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/error/failures.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/item_sales_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/entities/report_summary_entity.dart';
import 'package:ahgzly_pos/features/reports/domain/usecases/get_reports_usecases.dart';
import 'reports_event.dart';
import 'reports_state.dart';
import 'package:dartz/dartz.dart' as dartz;

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetSummaryReportUseCase getSummaryReportUseCase;
  final GetItemSalesReportUseCase getItemSalesReportUseCase;

  // 🪄 [Refactored]: حفظ التواريخ محلياً لإعادة استخدامها عند التحديث
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  ReportsBloc({
    required this.getSummaryReportUseCase,
    required this.getItemSalesReportUseCase,
  }) : super(ReportsInitial()) {
    
    on<LoadReportsEvent>((event, emit) async {
      emit(ReportsLoading());
      
      _lastStartDate = event.startDate;
      _lastEndDate = event.endDate;

      final params = ReportDateParams(startDate: event.startDate, endDate: event.endDate);

      final results = await Future.wait([
        getSummaryReportUseCase(params),
        getItemSalesReportUseCase(params),
      ]);

      final summaryResult = results[0] as dartz.Either<Failure, ReportSummaryEntity>;
      final itemSalesResult = results[1] as dartz.Either<Failure, List<ItemSalesEntity>>;

      if (summaryResult.isLeft()) {
        emit(ReportsError(message: summaryResult.fold((l) => l.message, (r) => '')));
        return;
      }
      
      if (itemSalesResult.isLeft()) {
        emit(ReportsError(message: itemSalesResult.fold((l) => l.message, (r) => '')));
        return;
      }

      emit(ReportsLoaded(
        summary: summaryResult.getOrElse(() => const ReportSummaryEntity(totalSales: 0, totalExpenses: 0, ordersCount: 0)),
        itemSales: itemSalesResult.getOrElse(() => []),
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    });

    // 🪄 [Refactored]: التعامل مع حدث التحديث بذكاء
    on<RefreshReportsEvent>((event, emit) {
      if (_lastStartDate != null && _lastEndDate != null) {
        add(LoadReportsEvent(startDate: _lastStartDate!, endDate: _lastEndDate!));
      }
    });
  }
}