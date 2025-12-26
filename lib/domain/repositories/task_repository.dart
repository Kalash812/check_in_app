import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';

class TaskQuery {
  final int offset;
  final int limit;
  final TaskStatus? status;
  final TaskSort sort;
  final String? assignedTo;

  const TaskQuery({
    this.offset = 0,
    this.limit = 20,
    this.status,
    this.sort = TaskSort.dueDate,
    this.assignedTo,
  });
}

abstract class TaskRepository {
  Future<Result<List<Task>>> fetchTasks(TaskQuery query);

  Future<Result<Task>> upsertTask(Task task);

  Future<Result<Task?>> getTask(String id);

  Future<Result<Task>> updateStatus(String id, TaskStatus status);

  Future<Result<void>> seedDefaults(List<Task> tasks);

  Future<Result<void>> syncPending();
}
