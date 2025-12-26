import 'package:bloc_test/bloc_test.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';
import 'package:check_in_app/domain/usecases/fetch_tasks_usecase.dart';
import 'package:check_in_app/domain/usecases/update_task_status_usecase.dart';
import 'package:check_in_app/domain/usecases/upsert_task_usecase.dart';
import 'package:check_in_app/viewmodel/tasks/task_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockTaskRepository repository;
  late TaskListCubit cubit;

  final tasks = [
    Task(
      id: '1',
      title: 'High priority',
      description: 'task',
      status: TaskStatus.open,
      dueDate: DateTime(2024, 10, 10),
      priority: TaskPriority.high,
      location: 'Site A',
      assignedTo: 'u1',
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.synced,
    ),
    Task(
      id: '2',
      title: 'Low priority',
      description: 'task',
      status: TaskStatus.inProgress,
      dueDate: DateTime(2024, 10, 5),
      priority: TaskPriority.low,
      location: 'Site B',
      assignedTo: 'u1',
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.synced,
    ),
    Task(
      id: '3',
      title: 'Medium',
      description: 'task',
      status: TaskStatus.open,
      dueDate: DateTime(2024, 10, 7),
      priority: TaskPriority.medium,
      location: 'Site C',
      assignedTo: 'u1',
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.synced,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const TaskQuery());
  });

  setUp(() {
    repository = MockTaskRepository();
    cubit = TaskListCubit(
      fetchTasksUseCase: FetchTasksUseCase(repository),
      updateTaskStatusUseCase: UpdateTaskStatusUseCase(repository),
      upsertTaskUseCase: UpsertTaskUseCase(repository),
      assignedTo: null,
    );
  });

  blocTest<TaskListCubit, TaskListState>(
    'filters open tasks',
    build: () {
      when(() => repository.fetchTasks(any())).thenAnswer((invocation) async {
        final query = invocation.positionalArguments.first as TaskQuery;
        final filtered = tasks.where((t) => query.status == null || t.status == query.status).toList();
        return Result.success(filtered);
      });
      return cubit;
    },
    act: (c) => c.applyFilter(TaskStatus.open),
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<TaskListState>().having((s) => s.filter, 'filter set', TaskStatus.open),
      isA<TaskListState>().having((s) => s.loading, 'loading', true),
      isA<TaskListState>().having((s) => s.tasks.length, 'open count', 2),
    ],
  );

  blocTest<TaskListCubit, TaskListState>(
    'sorts by priority with high first',
    build: () {
      when(() => repository.fetchTasks(any())).thenAnswer((invocation) async {
        final query = invocation.positionalArguments.first as TaskQuery;
        final list = List<Task>.from(tasks);
        if (query.sort == TaskSort.priority) {
          list.sort((a, b) => b.priority.weight.compareTo(a.priority.weight));
        }
        return Result.success(list);
      });
      return cubit;
    },
    act: (c) => c.applySort(TaskSort.priority),
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<TaskListState>().having((s) => s.sort, 'sort set', TaskSort.priority),
      isA<TaskListState>().having((s) => s.loading, 'loading', true),
      isA<TaskListState>().having(
        (s) => s.tasks.first.priority,
        'top priority',
        TaskPriority.high,
      ),
    ],
  );
}
