import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class GetTaskUseCase {
  final TaskRepository repository;

  GetTaskUseCase(this.repository);

  Future<Result<Task?>> call(String id) => repository.getTask(id);
}
