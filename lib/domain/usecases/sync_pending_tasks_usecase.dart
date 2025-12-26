import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class SyncPendingTasksUseCase {
  final TaskRepository repository;

  SyncPendingTasksUseCase(this.repository);

  Future<Result<void>> call() => repository.syncPending();
}
