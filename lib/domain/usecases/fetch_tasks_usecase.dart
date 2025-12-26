import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class FetchTasksUseCase {
  final TaskRepository repository;

  FetchTasksUseCase(this.repository);

  Future<Result<List<Task>>> call(TaskQuery query) => repository.fetchTasks(query);
}
