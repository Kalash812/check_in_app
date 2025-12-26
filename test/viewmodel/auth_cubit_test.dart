import 'package:bloc_test/bloc_test.dart';
import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/usecases/login_usecase.dart';
import 'package:check_in_app/domain/usecases/logout_usecase.dart';
import 'package:check_in_app/domain/usecases/restore_session_usecase.dart';
import 'package:check_in_app/viewmodel/auth/auth_cubit.dart';
import 'package:check_in_app/viewmodel/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late AuthCubit cubit;
  final session = Session(
    user: const AppUser(
      id: '1',
      email: 'admin@test.com',
      name: 'Admin',
      role: UserRole.admin,
    ),
    token: 'token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  setUp(() {
    repository = MockAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repository),
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );
  });

  blocTest<AuthCubit, AuthState>(
    'emits loading then authenticated on login success',
    build: () {
      when(
        () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => Result.success(session));
      return cubit;
    },
    act: (c) => c.login('admin@test.com', 'secret'),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      AuthState(status: AuthStatus.authenticated, session: session),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'emits error on login failure',
    build: () {
      when(
        () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer(
        (_) async => Result.failure(
          const AppFailure(type: FailureType.auth, message: 'Invalid'),
        ),
      );
      return cubit;
    },
    act: (c) => c.login('bad@test.com', 'wrong'),
    expect: () => [
      cubit.state.copyWith(status: AuthStatus.loading, message: null),
      const AuthState(status: AuthStatus.error, message: 'Invalid'),
    ],
  );
}
