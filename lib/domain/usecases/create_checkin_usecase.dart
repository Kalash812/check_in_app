import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';

class CreateCheckInUseCase {
  final CheckInRepository repository;

  CreateCheckInUseCase(this.repository);

  Future<Result<CheckIn>> call(CheckIn checkIn) {
    return repository.create(checkIn);
  }
}
