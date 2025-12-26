import 'package:bloc/bloc.dart';
import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/domain/usecases/login_usecase.dart';
import 'package:check_in_app/domain/usecases/logout_usecase.dart';
import 'package:check_in_app/domain/usecases/restore_session_usecase.dart';
import 'package:check_in_app/viewmodel/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.restoreSessionUseCase,
    required this.logoutUseCase,
  }) : super(AuthState.unknown());

  Future<void> restoreSession() async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    final result = await restoreSessionUseCase();
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.unauthenticated, message: failure.message),
      ),
      (session) {
        if (session == null) {
          emit(AuthState.unauthenticated());
        } else {
          emit(AuthState(status: AuthStatus.authenticated, session: session));
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    final result = await loginUseCase(email, password);
    result.fold(
      (failure) => emit(
        AuthState(status: AuthStatus.error, message: _friendlyMessage(failure)),
      ),
      (session) =>
          emit(AuthState(status: AuthStatus.authenticated, session: session)),
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    emit(AuthState.unauthenticated());
  }

  String _friendlyMessage(AppFailure failure) {
    switch (failure.type) {
      case FailureType.auth:
        return failure.message;
      case FailureType.network:
        return 'Network error. Try again.';
      default:
        return 'Something went wrong. Please retry.';
    }
  }
}
