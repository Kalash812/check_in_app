import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
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
    Object? filter = _noValue,
    TaskSort? sort,
    bool? hasMore,
    int? offset,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      filter: filter == _noValue ? this.filter : filter as TaskStatus?,
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

const _noValue = Object();
