import 'package:bloc/bloc.dart';
import 'package:check_in_app/domain/usecases/sync_pending_checkins_usecase.dart';
import 'package:check_in_app/domain/usecases/sync_pending_tasks_usecase.dart';
import 'package:check_in_app/viewmodel/sync/sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncPendingCheckInsUseCase syncPendingCheckInsUseCase;
  final SyncPendingTasksUseCase syncPendingTasksUseCase;

  SyncCubit({
    required this.syncPendingCheckInsUseCase,
    required this.syncPendingTasksUseCase,
  }) : super(const SyncState());

  Future<void> sync() async {
    emit(state.copyWith(syncing: true, message: 'Syncing...'));
    await syncPendingTasksUseCase();
    await syncPendingCheckInsUseCase();
    emit(state.copyWith(syncing: false, message: 'Sync complete'));
  }
}
