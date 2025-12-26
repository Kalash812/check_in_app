import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:equatable/equatable.dart';

class TaskDetailState extends Equatable {
  final Task? task;
  final List<CheckIn> checkIns;
  final bool loading;
  final String? error;

  const TaskDetailState({
    this.task,
    this.checkIns = const [],
    this.loading = false,
    this.error,
  });

  TaskDetailState copyWith({
    Task? task,
    List<CheckIn>? checkIns,
    bool? loading,
    String? error,
  }) {
    return TaskDetailState(
      task: task ?? this.task,
      checkIns: checkIns ?? this.checkIns,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [task, checkIns, loading, error];
}
