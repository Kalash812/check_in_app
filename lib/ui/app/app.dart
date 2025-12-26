
import 'package:check_in_app/core/theme/app_theme.dart';
import 'package:check_in_app/di/locator.dart';
import 'package:check_in_app/domain/usecases/login_usecase.dart';
import 'package:check_in_app/domain/usecases/logout_usecase.dart';
import 'package:check_in_app/domain/usecases/restore_session_usecase.dart';
import 'package:check_in_app/domain/usecases/sync_pending_checkins_usecase.dart';
import 'package:check_in_app/domain/usecases/sync_pending_tasks_usecase.dart';
import 'package:check_in_app/ui/screens/login/login_screen.dart';
import 'package:check_in_app/ui/screens/tasks/task_list_page.dart';
import 'package:check_in_app/viewmodel/auth/auth_cubit.dart';
import 'package:check_in_app/viewmodel/auth/auth_state.dart';
import 'package:check_in_app/viewmodel/connectivity/connectivity_cubit.dart';
import 'package:check_in_app/viewmodel/connectivity/connectivity_state.dart';
import 'package:check_in_app/viewmodel/sync/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckInApp extends StatelessWidget {
  const CheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => AuthCubit(
                loginUseCase: LoginUseCase(getIt()),
                restoreSessionUseCase: RestoreSessionUseCase(getIt()),
                logoutUseCase: LogoutUseCase(getIt()),
              )..restoreSession(),
        ),
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(
          create:
              (context) => SyncCubit(
                syncPendingCheckInsUseCase: SyncPendingCheckInsUseCase(getIt()),
                syncPendingTasksUseCase: SyncPendingTasksUseCase(getIt()),
              ),
        ),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listenWhen: (prev, curr) => prev.isOnline != curr.isOnline,
        listener: (context, state) {
          if (state.isOnline) {
            context.read<SyncCubit>().sync();
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Check-in',
          theme: AppTheme.light(),
          home: const AppEntryPoint(),
        ),
      ),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.loading:
          case AuthStatus.unknown:
            return const _Splash();
          case AuthStatus.authenticated:
            final session = state.session!;
            return TaskListPage(session: session);
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return LoginScreen(error: state.message);
        }
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            const Text('Loading session...'),
          ],
        ),
      ),
    );
  }
}
