import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/get_users_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/add_user_usecase.dart';
import 'package:ahgzly_pos/features/users/domain/usecases/toggle_user_status_usecase.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;
  final AddUserUseCase addUserUseCase;
  final ToggleUserStatusUseCase toggleUserStatusUseCase;

  UsersBloc({
    required this.getUsersUseCase,
    required this.addUserUseCase,
    required this.toggleUserStatusUseCase,
  }) : super(UsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<AddUserEvent>(_onAddUser);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
  }

  Future<void> _onLoadUsers(LoadUsersEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await getUsersUseCase();
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onAddUser(AddUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await addUserUseCase(name: event.name, role: event.role, pin: event.pin);
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (_) {
        emit(const UserOperationSuccess('تمت إضافة المستخدم بنجاح'));
        add(LoadUsersEvent()); // إعادة تحميل القائمة تلقائياً
      },
    );
  }

  Future<void> _onToggleUserStatus(ToggleUserStatusEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await toggleUserStatusUseCase(event.id, event.isActive);
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (_) {
        final status = event.isActive ? 'تفعيل' : 'إيقاف';
        emit(UserOperationSuccess('تم $status المستخدم بنجاح'));
        add(LoadUsersEvent()); // إعادة تحميل القائمة تلقائياً
      },
    );
  }
}