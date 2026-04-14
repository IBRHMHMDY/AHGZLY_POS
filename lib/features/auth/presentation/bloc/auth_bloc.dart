import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart'; 
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/unlock_usecase.dart'; 
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final UnlockUseCase unlockUseCase; 

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.unlockUseCase, 
  }) : super(AuthInitial()) {
    
    on<LoginSubmittedEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase(event.pin);
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    });

    on<UnlockSubmittedEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await unlockUseCase(UnlockParams(pin: event.pin, currentUser: event.currentUser));
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (unlockedByUser) {
          emit(AuthUnlocked(user: unlockedByUser));
          emit(AuthAuthenticated(user: event.currentUser)); 
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