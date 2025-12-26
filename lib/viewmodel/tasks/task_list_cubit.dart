import 'package:bloc/bloc.dart';
import 'package:check_in_app/core/config/app_config.dart';
import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';
import 'package:check_in_app/domain/usecases/fetch_tasks_usecase.dart';
import 'package:check_in_app/domain/usecases/update_task_status_usecase.dart';
import 'package:check_in_app/domain/usecases/upsert_task_usecase.dart';
import 'package:equatable/equatable.dart';

class TaskListState extends Equatable {
  final List<Task> tasks;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final TaskStatus? filter;
  final TaskSort sort;
  final bool hasMore;
  final int offset;

  const TaskListState({
    this.tasks = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.filter,
    this.sort = TaskSort.dueDate,
    this.hasMore = true,
    this.offset = 0,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? loading,
    bool? loadingMore,
    String? error,
    TaskStatus? filter,
    TaskSort? sort,
    bool? hasMore,
    int? offset,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        tasks,
        loading,
        loadingMore,
        error,
        filter,
        sort,
        hasMore,
        offset,
      ];
}

class TaskListCubit extends Cubit<TaskListState> {
  final FetchTasksUseCase fetchTasksUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;
  final UpsertTaskUseCase upsertTaskUseCase;
  final String? assignedTo; // null => show all (admins)

  TaskListCubit({
    required this.fetchTasksUseCase,
    required this.updateTaskStatusUseCase,
    required this.upsertTaskUseCase,
    required this.assignedTo,
  }) : super(const TaskListState());

  Future<void> loadInitial() async {
    emit(state.copyWith(loading: true, error: null, tasks: [], offset: 0));
    final result = await fetchTasksUseCase(
      TaskQuery(
        offset: 0,
        limit: AppConfig.pageSize,
        status: state.filter,
        sort: state.sort,
        assignedTo: assignedTo,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          loading: false,
          error: _friendlyMessage(failure),
          hasMore: false,
        ),
      ),
      (tasks) => emit(
        state.copyWith(
          loading: false,
          tasks: tasks,
          hasMore: tasks.length == AppConfig.pageSize,
          offset: tasks.length,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    emit(state.copyWith(loadingMore: true));
    final result = await fetchTasksUseCase(
      TaskQuery(
        offset: state.offset,
        limit: AppConfig.pageSize,
        status: state.filter,
        sort: state.sort,
        assignedTo: assignedTo,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadingMore: false,
          error: _friendlyMessage(failure),
        ),
      ),
      (tasks) {
        final combined = [...state.tasks, ...tasks];
        emit(
          state.copyWith(
            loadingMore: false,
            tasks: combined,
            hasMore: tasks.length == AppConfig.pageSize,
            offset: combined.length,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> applyFilter(TaskStatus? status) async {
    emit(state.copyWith(filter: status));
    await loadInitial();
  }

  Future<void> applySort(TaskSort sort) async {
    emit(state.copyWith(sort: sort));
    await loadInitial();
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final result = await updateTaskStatusUseCase(taskId, status);
    result.fold(
      (_) => null,
      (task) {
        final updatedList = state.tasks.map((t) => t.id == task.id ? task : t).toList();
        emit(state.copyWith(tasks: updatedList));
      },
    );
  }

  Future<void> upsertTask(Task task) async {
    final result = await upsertTaskUseCase(task);
    result.fold(
      (_) => null,
      (saved) {
        final updated = List<Task>.from(state.tasks);
        final index = updated.indexWhere((t) => t.id == saved.id);
        if (index >= 0) {
          updated[index] = saved;
        } else {
          updated.insert(0, saved);
        }
        emit(state.copyWith(tasks: updated));
      },
    );
  }

  String _friendlyMessage(AppFailure failure) {
    switch (failure.type) {
      case FailureType.network:
        return 'Network unavailable.';
      default:
        return failure.message;
    }
  }
}
