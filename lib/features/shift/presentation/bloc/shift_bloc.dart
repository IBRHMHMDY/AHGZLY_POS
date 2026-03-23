import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/get_z_report_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final GetZReportUseCase getZReportUseCase;
  final CloseShiftUseCase closeShiftUseCase;

  ShiftBloc({
    required this.getZReportUseCase,
    required this.closeShiftUseCase,
  }) : super(ShiftInitial()) {
    
    on<LoadZReportEvent>((event, emit) async {
      emit(ShiftLoading());
      final failureOrReport = await getZReportUseCase(NoParams());
      failureOrReport.fold(
        (failure) => emit(ShiftError(failure.message)),
        (report) => emit(ZReportLoaded(report)),
      );
    });

    on<CloseCurrentShiftEvent>((event, emit) async {
      emit(ShiftLoading());
      final failureOrSuccess = await closeShiftUseCase(event.report);
      failureOrSuccess.fold(
        (failure) => emit(ShiftError(failure.message)),
        (shiftId) => emit(const ShiftClosedSuccess('تم إغلاق الوردية وتصفير الصندوق بنجاح')),
      );
    });
  }
}