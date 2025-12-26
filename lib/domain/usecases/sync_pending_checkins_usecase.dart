import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';

class SyncPendingCheckInsUseCase {
  final CheckInRepository repository;

  SyncPendingCheckInsUseCase(this.repository);

  Future<Result<void>> call() => repository.syncPending();
}
