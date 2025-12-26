import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class UpsertTaskUseCase {
  final TaskRepository repository;

  UpsertTaskUseCase(this.repository);

  Future<Result<Task>> call(Task task) => repository.upsertTask(task);
}
