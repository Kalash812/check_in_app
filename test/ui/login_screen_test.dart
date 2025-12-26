import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/usecases/login_usecase.dart';
import 'package:check_in_app/domain/usecases/logout_usecase.dart';
import 'package:check_in_app/domain/usecases/restore_session_usecase.dart';
import 'package:check_in_app/ui/screens/login/login_screen.dart';
import 'package:check_in_app/viewmodel/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late AuthCubit cubit;

  setUp(() {
    repository = MockAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repository),
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );
    when(
      () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer(
      (_) async => Result.success(
        Session(
          user: const AppUser(
            id: '1',
            email: 'admin@test.com',
            name: 'Admin',
            role: UserRole.admin,
          ),
          token: 'token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      ),
    );
  });

  testWidgets('shows validation errors for empty credentials', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: repository,
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(home: LoginScreen()),
        ),
      ),
    );

    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(emailField, '');
    await tester.enterText(passwordField, '');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email required'), findsOneWidget);
    expect(find.text('Password must be 6+ chars'), findsOneWidget);
  });
}
