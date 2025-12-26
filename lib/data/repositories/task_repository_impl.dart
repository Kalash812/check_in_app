import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/data/local/task_local_data_source.dart';
import 'package:check_in_app/data/remote/task_remote_data_source.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource local;
  final TaskRemoteDataSource remote;
  final bool remoteEnabled;

  TaskRepositoryImpl({
    required this.local,
    required this.remote,
    required this.remoteEnabled,
  });

  @override
  Future<Result<List<Task>>> fetchTasks(TaskQuery query) async {
    try {
      List<Task> tasks = local.getTasks();

      if (remoteEnabled) {
        try {
          final remoteTasks = await remote.fetchTasks();
          if (remoteTasks.isNotEmpty) {
            await local.saveTasks(remoteTasks
                .map((t) => t.copyWith(syncStatus: SyncStatus.synced))
                .toList());
            tasks = remoteTasks;
          }
        } catch (_) {
          // Keep working with cache if remote fetch fails.
        }
      }

      tasks = _applyFilterAndSort(tasks, query);
      final paged = tasks.skip(query.offset).take(query.limit).toList();
      return Result.success(paged);
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.unknown,
          message: 'Failed to load tasks',
          cause: e,
        ),
      );
    }
  }

  List<Task> _applyFilterAndSort(List<Task> tasks, TaskQuery query) {
    var filtered = tasks;
    if (query.assignedTo != null) {
      filtered = filtered.where((t) => t.assignedTo == query.assignedTo).toList();
    }
    if (query.status != null) {
      filtered = filtered.where((t) => t.status == query.status).toList();
    }
    switch (query.sort) {
      case TaskSort.dueDate:
        filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSort.priority:
        filtered.sort((a, b) => b.priority.weight.compareTo(a.priority.weight));
        break;
    }
    return filtered;
  }

  @override
  Future<Result<Task>> upsertTask(Task task) async {
    try {
      final toSave = task.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: remoteEnabled ? SyncStatus.pending : SyncStatus.localOnly,
      );
      await local.upsertTask(toSave);
      return Result.success(toSave);
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Unable to save task',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<Task?>> getTask(String id) async {
    try {
      return Result.success(local.getById(id));
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Failed to read task',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<Task>> updateStatus(String id, TaskStatus status) async {
    final existing = local.getById(id);
    if (existing == null) {
      return Result.failure(
        const AppFailure(
          type: FailureType.notFound,
          message: 'Task not found',
        ),
      );
    }
    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      syncStatus: remoteEnabled ? SyncStatus.pending : existing.syncStatus,
    );
    try {
      await local.upsertTask(updated);
      return Result.success(updated);
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Unable to update task',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> seedDefaults(List<Task> tasks) async {
    try {
      await local.saveTasks(tasks);
      return Result.successVoid();
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Failed to seed tasks',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> syncPending() async {
    if (!remoteEnabled) return Result.successVoid();
    final pending = local
        .getTasks()
        .where((t) => t.syncStatus == SyncStatus.pending || t.syncStatus == SyncStatus.failed)
        .toList();
    if (pending.isEmpty) return Result.successVoid();

    try {
      for (final task in pending) {
        final synced = await remote.upsert(task);
        await local.upsertTask(synced.copyWith(syncStatus: SyncStatus.synced));
      }
      return Result.successVoid();
    } catch (e) {
      for (final task in pending) {
        await local.upsertTask(task.copyWith(syncStatus: SyncStatus.failed));
      }
      return Result.failure(
        AppFailure(
          type: FailureType.network,
          message: 'Task sync failed. Will retry.',
          cause: e,
        ),
      );
    }
  }
}
