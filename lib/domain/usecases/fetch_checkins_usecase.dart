import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';

class FetchCheckInsUseCase {
  final CheckInRepository repository;

  FetchCheckInsUseCase(this.repository);

  Future<Result<List<CheckIn>>> call(String taskId) {
    return repository.forTask(taskId);
  }
}
