import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/data/local/task_local_data_source.dart';
import 'package:check_in_app/data/remote/task_remote_data_source.dart';
import 'package:check_in_app/data/repositories/task_repository_impl.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  late HiveStorage storage;
  late TaskLocalDataSource local;
  late TaskRepository repository;
  late Box tasks;
  late Box checkIns;
  late Box session;
  late Box meta;

  final task = Task(
    id: 'task-1',
    title: 'Demo',
    description: 'desc',
    status: TaskStatus.open,
    dueDate: DateTime(2024, 10, 1),
    priority: TaskPriority.high,
    location: 'Site',
    assignedTo: 'u1',
    updatedAt: DateTime.now(),
    syncStatus: SyncStatus.pending,
  );

  setUp(() async {
    await setUpTestHive();
    tasks = await Hive.openBox('tasks_box');
    checkIns = await Hive.openBox('checkins_box');
    session = await Hive.openBox('session_box');
    meta = await Hive.openBox('meta_box');
    storage = HiveStorage.test(
      tasks: tasks,
      checkIns: checkIns,
      session: session,
      meta: meta,
    );
    local = TaskLocalDataSource(storage);
    repository = TaskRepositoryImpl(
      local: local,
      remote: MockTaskRemoteDataSource(),
      remoteEnabled: false,
    );
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('upsertTask persists and fetchTasks returns item', () async {
    await repository.upsertTask(task);
    final result = await repository.fetchTasks(const TaskQuery());
    expect(result.isSuccess, true);
    expect(result.data?.length, 1);
    expect(result.data?.first.syncStatus, SyncStatus.localOnly);
  });

  test('updateStatus changes status locally', () async {
    await repository.upsertTask(task);
    final updated = await repository.updateStatus(task.id, TaskStatus.done);
    expect(updated.isSuccess, true);
    expect(updated.data?.status, TaskStatus.done);
  });

  test('syncPending marks task as synced when remote enabled', () async {
    final remoteRepo = TaskRepositoryImpl(
      local: local,
      remote: MockTaskRemoteDataSource(),
      remoteEnabled: true,
    );
    await remoteRepo.upsertTask(task);
    final result = await remoteRepo.syncPending();
    expect(result.isSuccess, true);
    final fetched = await remoteRepo.fetchTasks(const TaskQuery());
    expect(fetched.data?.first.syncStatus, SyncStatus.synced);
  });
}
