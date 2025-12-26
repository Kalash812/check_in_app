import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/check_in.dart';

abstract class CheckInRepository {
  Future<Result<List<CheckIn>>> forTask(String taskId);

  Future<Result<CheckIn>> create(CheckIn checkIn);

  Future<Result<void>> markSynced(String id);

  Future<Result<void>> markFailed(String id);

  Future<Result<List<CheckIn>>> pending();

  Future<Result<void>> syncPending();
}
