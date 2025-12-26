import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/session.dart';

abstract class AuthRepository {
  Future<Result<Session>> login({
    required String email,
    required String password,
  });

  Future<Result<Session?>> restoreSession();

  Future<void> logout();
}
