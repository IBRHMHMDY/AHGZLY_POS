import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; // ضروري لـ NoParams
import 'package:ahgzly_pos/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:ahgzly_pos/features/settings/domain/usecases/update_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  SettingsBloc({
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(SettingsInitial()) {
    
    on<LoadSettingsEvent>((event, emit) async {
      emit(SettingsLoading());
      // Refactored: Use call(NoParams())
      final result = await getSettingsUseCase(NoParams());
      
      result.fold(
        (failure) => emit(SettingsError(message: failure.message)),
        (settings) => emit(SettingsLoaded(settings: settings)),
      );
    });

    on<SaveSettingsEvent>((event, emit) async {
      emit(SettingsLoading());
      // Refactored: Use Params object
      final result = await updateSettingsUseCase(UpdateSettingsParams(settings: event.settings));
      
      result.fold(
        (failure) => emit(SettingsError(message: failure.message)),
        (_) {
          emit(const SettingsSavedSuccess(message: 'تم حفظ الإعدادات بنجاح'));
          add(LoadSettingsEvent()); // إعادة التحميل لضمان تحديث الواجهة
        },
      );
    });
  }
}