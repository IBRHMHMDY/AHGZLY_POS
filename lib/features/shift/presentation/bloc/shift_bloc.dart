import 'package:ahgzly_pos/core/usecases/usecase.dart'; // ⬅️ إضافة هامة لاستخدام NoParams
import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/open_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/get_shifts_history_usecase.dart'; // 🚀 [Sprint 2]
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final CheckActiveShiftUseCase checkActiveShiftUseCase;
  final OpenShiftUseCase openShiftUseCase;
  final CloseShiftUseCase closeShiftUseCase;
  final GetShiftsHistoryUseCase getShiftsHistoryUseCase; // 🚀 [Sprint 2]

  ShiftBloc({
    required this.checkActiveShiftUseCase,
    required this.openShiftUseCase,
    required this.closeShiftUseCase,
    required this.getShiftsHistoryUseCase, // 🚀 [Sprint 2]
  }) : super(ShiftInitial()) {
    
    on<CheckActiveShiftEvent>((event, emit) async {
      emit(ShiftLoading());
      // Refactored: استدعاء UseCase باستخدام NoParams بدلاً من execute
      final result = await checkActiveShiftUseCase(NoParams());
      
      result.fold(
        (failure) => emit(ShiftError(message: failure.message)),
        (shift) {
          if (shift != null) {
            emit(ActiveShiftLoaded(shift: shift));
          } else {
            emit(NoActiveShiftState());
          }
        },
      );
    });

    on<OpenShiftSubmittedEvent>((event, emit) async {
      emit(ShiftLoading());
      // Refactored: تمرير OpenShiftParams بدلاً من المتغيرات المتناثرة
      final result = await openShiftUseCase(OpenShiftParams(
        startingCash: event.startingCash, 
        userId: event.cashierId, // تم تمرير cashierId إلى userId
      ));
      
      result.fold(
        (failure) => emit(ShiftError(message: failure.message)),
        (shift) => emit(ShiftOpenedSuccess(shift: shift)),
      );
    });

    on<CloseShiftSubmittedEvent>((event, emit) async {
      emit(ShiftLoading());
      // Refactored: تمرير CloseShiftParams
      final result = await closeShiftUseCase(CloseShiftParams(
        shiftId: event.shiftId, 
        actualCash: event.actualCash,
      ));
      
      result.fold(
        (failure) => emit(ShiftError(message: failure.message)),
        (closedShift) => emit(ShiftClosedSuccess(closedShift: closedShift)),
      );
    });

    on<LoadShiftsHistoryEvent>((event, emit) async {
      if (!event.isLoadMore) {
        emit(ShiftLoading());
      }

      final currentState = state;
      int offset = 0;
      List<ShiftEntity> currentShifts = [];

      if (event.isLoadMore && currentState is ShiftsHistoryLoaded) {
        if (currentState.hasReachedMax) return;
        offset = currentState.shifts.length;
        currentShifts = currentState.shifts;
      }

      final result = await getShiftsHistoryUseCase(GetShiftsHistoryParams(limit: 50, offset: offset));
      
      result.fold(
        (failure) {
          if (!event.isLoadMore) emit(ShiftError(message: failure.message));
        },
        (newShifts) {
          if (newShifts.isEmpty) {
            if (event.isLoadMore) {
              emit(ShiftsHistoryLoaded(shifts: currentShifts, hasReachedMax: true));
            } else {
              emit(ShiftsHistoryLoaded(shifts: const [], hasReachedMax: true));
            }
          } else {
            emit(ShiftsHistoryLoaded(
              shifts: currentShifts + newShifts,
              hasReachedMax: newShifts.length < 50,
            ));
          }
        },
      );
    });
  }
}