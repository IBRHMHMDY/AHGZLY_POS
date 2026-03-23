import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
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
      final failureOrSettings = await getSettingsUseCase(NoParams());
      failureOrSettings.fold(
        (failure) => emit(SettingsError(failure.message)),
        (settings) => emit(SettingsLoaded(settings)),
      );
    });

    on<SaveSettingsEvent>((event, emit) async {
      emit(SettingsLoading());
      final failureOrSuccess = await updateSettingsUseCase(event.settings);
      failureOrSuccess.fold(
        (failure) => emit(SettingsError(failure.message)),
        (_) => emit(SettingsSavedSuccess(event.settings)),
      );
    });
  }
}