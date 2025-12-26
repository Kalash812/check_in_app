import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<Session>> call(String email, String password) {
    return repository.login(email: email, password: password);
  }
}
