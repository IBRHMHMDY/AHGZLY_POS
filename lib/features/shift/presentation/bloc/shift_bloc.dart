import 'package:ahgzly_pos/features/shift/domain/usecases/check_active_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/domain/usecases/open_shift_usecase.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final CheckActiveShiftUseCase checkActiveShiftUseCase;
  final OpenShiftUseCase openShiftUseCase;
  final CloseShiftUseCase closeShiftUseCase;

  ShiftBloc({
    required this.checkActiveShiftUseCase,
    required this.openShiftUseCase,
    required this.closeShiftUseCase,
  }) : super(ShiftInitial()) {
    
    on<CheckActiveShiftEvent>((event, emit) async {
      emit(ShiftLoading());
      final result = await checkActiveShiftUseCase.execute();
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
      final result = await openShiftUseCase.execute(
        startingCash: event.startingCash, 
        cashierId: event.cashierId
      );
      result.fold(
        (failure) => emit(ShiftError(message: failure.message)),
        (shift) => emit(ShiftOpenedSuccess(shift: shift)),
      );
    });

    on<CloseShiftSubmittedEvent>((event, emit) async {
      emit(ShiftLoading());
      final result = await closeShiftUseCase.execute(
        shiftId: event.shiftId, 
        actualCash: event.actualCash
      );
      result.fold(
        (failure) => emit(ShiftError(message: failure.message)),
        (closedShift) => emit(ShiftClosedSuccess(closedShift: closedShift)),
      );
    });
  }
}