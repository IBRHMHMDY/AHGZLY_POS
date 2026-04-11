import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart'; // ⬅️ ضروري لـ NoParams
import 'package:ahgzly_pos/features/license/domain/usecases/activate_license_usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/check_license_status_usecase.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_event.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_state.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final CheckLicenseStatusUseCase checkLicenseStatusUseCase;
  final ActivateLicenseUseCase activateLicenseUseCase;

  LicenseBloc({
    required this.checkLicenseStatusUseCase,
    required this.activateLicenseUseCase,
  }) : super(LicenseInitial()) {
    
    on<CheckLicenseEvent>((event, emit) async {
      emit(LicenseLoading());
      
      // Refactored: Use call(NoParams) instead of execute()
      final result = await checkLicenseStatusUseCase(NoParams());
      
      result.fold(
        (failure) => emit(LicenseInvalidState(message: failure.message)),
        (isValid) {
          if (isValid) {
            emit(LicenseValidState());
          } else {
            // Refactored: Translated to Arabic
            emit(const LicenseInvalidState(message: 'لم يتم العثور على ترخيص صالح. يرجى تفعيل النظام.'));
          }
        },
      );
    });

    on<ActivateLicenseSubmitEvent>((event, emit) async {
      emit(LicenseLoading());
      
      // Refactored: Pass ActivateLicenseParams
      final result = await activateLicenseUseCase(ActivateLicenseParams(licenseKey: event.licenseKey));
      
      result.fold(
        (failure) => emit(LicenseErrorState(message: failure.message)),
        (_) => emit(LicenseActivationSuccessState()),
      );
    });
  }
}