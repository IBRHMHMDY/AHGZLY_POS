import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/core/usecases/usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/check_license_status_usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/activate_license_usecase.dart';
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
      final result = await checkLicenseStatusUseCase(NoParams());
      
      result.fold(
        (failure) => emit(LicenseErrorState(message: failure.message)),
        (license) {
          if (license.isActivated || !license.isTrialExpired) {
            emit(LicenseValidState(license: license));
          } else {
            emit(LicenseExpiredState(license: license));
          }
        },
      );
    });

    on<ActivateLicenseSubmitEvent>((event, emit) async {
      emit(LicenseLoading());
      final result = await activateLicenseUseCase(event.licenseKey);
      
      result.fold(
        (failure) => emit(LicenseErrorState(message: failure.message)),
        (_) => emit(LicenseActivationSuccessState()),
      );
    });
  }
}