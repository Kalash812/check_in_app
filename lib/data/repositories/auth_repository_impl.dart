import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/data/local/auth_local_data_source.dart';
import 'package:check_in_app/data/remote/auth_remote_data_source.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<Result<Session>> login({
    required String email,
    required String password,
  }) async {
    try {
      final remoteResult = await remote.signIn(email, password);
      final session = Session(
        user: remoteResult.user,
        token: remoteResult.token,
        expiresAt: remoteResult.expiresAt,
      );
      await local.cacheSession(session);
      return Result.success(session);
    } on AppFailure catch (failure) {
      return Result.failure(failure);
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.unknown,
          message: 'Login failed',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<Session?>> restoreSession() async {
    final session = local.readSession();
    if (session == null) return Result.success<Session?>(null);
    if (session.isExpired) {
      await local.clear();
      return Result.failure(
        const AppFailure(
          type: FailureType.auth,
          message: 'Session expired, please login again.',
        ),
      );
    }
    return Result.success(session);
  }

  @override
  Future<void> logout() async {
    await remote.signOut();
    await local.clear();
  }
}
