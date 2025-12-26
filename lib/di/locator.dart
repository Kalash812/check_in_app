import 'package:check_in_app/domain/repositories/auth_repository.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required AuthRepository authRepository,
  required TaskRepository taskRepository,
  required CheckInRepository checkInRepository,
}) async {
  await getIt.reset(dispose: true);
  getIt
    ..registerSingleton<AuthRepository>(authRepository)
    ..registerSingleton<TaskRepository>(taskRepository)
    ..registerSingleton<CheckInRepository>(checkInRepository);
}
