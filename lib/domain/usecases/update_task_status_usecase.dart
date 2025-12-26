import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class UpdateTaskStatusUseCase {
  final TaskRepository repository;

  UpdateTaskStatusUseCase(this.repository);

  Future<Result<Task>> call(String id, TaskStatus status) {
    return repository.updateStatus(id, status);
  }
}
