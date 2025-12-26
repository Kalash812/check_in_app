import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;

  RestoreSessionUseCase(this.repository);

  Future<Result<Session?>> call() {
    return repository.restoreSession();
  }
}
