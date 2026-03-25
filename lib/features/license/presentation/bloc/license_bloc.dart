import 'package:ahgzly_pos/features/license/domain/usecases/activate_license_usecase.dart';
import 'package:ahgzly_pos/features/license/domain/usecases/check_license_status_usecase.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_event.dart';
import 'package:ahgzly_pos/features/license/presentation/bloc/license_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final CheckLicenseStatusUseCase checkLicenseStatusUseCase;
  final ActivateLicenseUseCase activateLicenseUseCase;

  LicenseBloc({
    required this.checkLicenseStatusUseCase,
    required this.activateLicenseUseCase,
  }) : super(LicenseInitial()) {
    
    on<CheckLicenseEvent>((event, emit) async {
      emit(LicenseLoading());
      
      // نستدعي الدالة كما تم بناؤها في الـ UseCase الجديدة
      final result = await checkLicenseStatusUseCase.execute();
      
      result.fold(
        // في حالة وجود Failure (سواء تلاعب بالوقت، تلاعب بالجهاز، أو انتهاء الترخيص)
        (failure) => emit(LicenseInvalidState(message: failure.message)),
        // في حالة نجاح التحقق
        (isValid) {
          if (isValid) {
            emit(LicenseValidState());
          } else {
            // الترخيص غير موجود من الأساس
            emit(LicenseInvalidState(message: 'No valid license found. Please activate the system.'));
          }
        },
      );
    });

    on<ActivateLicenseSubmitEvent>((event, emit) async {
      emit(LicenseLoading());
      
      // استدعاء دالة التفعيل (نفترض أنها تستخدم call الموروثة من UseCase)
      final result = await activateLicenseUseCase(event.licenseKey);
      
      result.fold(
        (failure) => emit(LicenseErrorState(message: failure.message)),
        (_) => emit(LicenseActivationSuccessState()),
      );
    });
  }
}