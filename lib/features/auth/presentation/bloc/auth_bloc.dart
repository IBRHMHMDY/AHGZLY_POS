import 'package:ahgzly_pos/core/extensions/user_role.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart'; 
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

    // Refactored: Business logic for unlocking moved here (Clean Architecture)
    on<UnlockSubmittedEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase(event.pin);
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) {
          // Check if the user is the current cashier OR an admin
          if (user.id == event.currentUser.id || user.role == UserRole.admin) {
            emit(AuthUnlocked(user: user));
          } else {
            emit(AuthError(message: 'يجب إدخال الرمز الخاص بك (${event.currentUser.name}) أو رمز المدير'));
          }
        },
      );
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await logoutUseCase(NoParams()); 
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
    });
  }
}