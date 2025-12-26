import 'package:check_in_app/domain/repositories/auth_repository.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';
import 'package:check_in_app/domain/repositories/task_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockCheckInRepository extends Mock implements CheckInRepository {}
