import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart'; // أضفنا هذا السطر لاستيراد NoParams
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    
    on<LoginSubmittedEvent>((event, emit) async {
      emit(AuthLoading());
      
      final result = await loginUseCase(event.pin);
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      
      // تم الإصلاح هنا بتمرير NoParams()
      final result = await logoutUseCase(NoParams()); 
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
    });
  }
}