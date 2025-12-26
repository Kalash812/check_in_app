import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/usecases/fetch_checkins_usecase.dart';
import 'package:check_in_app/domain/usecases/get_task_usecase.dart';
import 'package:check_in_app/viewmodel/tasks/task_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailCubit extends Cubit<TaskDetailState> {
  final GetTaskUseCase getTaskUseCase;
  final FetchCheckInsUseCase fetchCheckInsUseCase;

  TaskDetailCubit({
    required this.getTaskUseCase,
    required this.fetchCheckInsUseCase,
  }) : super(const TaskDetailState());

  Future<void> load(String taskId) async {
    emit(state.copyWith(loading: true, error: null));
    final taskResult = await getTaskUseCase(taskId);
    final checkInsResult = await fetchCheckInsUseCase(taskId);
    final task = taskResult.isSuccess ? taskResult.data : null;
    final checkIns = checkInsResult.isSuccess ? checkInsResult.data ?? [] : <CheckIn>[];

    emit(
      state.copyWith(
        task: task,
        checkIns: checkIns,
        loading: false,
        error: task == null ? 'Task not found' : null,
      ),
    );
  }

  void addCheckIn(CheckIn checkIn) {
    final list = List<CheckIn>.from(state.checkIns);
    list.insert(0, checkIn);
    emit(state.copyWith(checkIns: list));
  }
}
