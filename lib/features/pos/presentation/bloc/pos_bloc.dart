import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/pos/domain/usecases/save_order_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_event.dart';
import 'package:ahgzly_pos/features/pos/presentation/bloc/pos_state.dart';


class PosBloc extends Bloc<PosEvent, PosState> {
  final SaveOrderUseCase saveOrderUseCase;
  final GetSettingsUseCase getSettingsUseCase; // تمت الإضافة ليتطابق مع ملف الـ DI الخاص بك

  PosBloc({
    required this.saveOrderUseCase,
    required this.getSettingsUseCase,
  }) : super(PosInitial()) {
    on<SaveOrderEvent>(_onSaveOrder);
  }

  Future<void> _onSaveOrder(SaveOrderEvent event, Emitter<PosState> emit) async {
    emit(PosLoading());
    
    final result = await saveOrderUseCase(event.order);
    
    result.fold(
      (failure) {
        // تم التصحيح ليتطابق مع PosError(this.message) الموجودة في pos_state.dart
        emit(PosError(failure.message));
      },
      (orderId) {
        // تم التصحيح ليتطابق مع PosCheckoutSuccess(this.orderId) الموجودة في pos_state.dart
        emit(PosCheckoutSuccess(orderId));
      },
    );
  }
}