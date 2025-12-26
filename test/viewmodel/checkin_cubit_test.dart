import 'package:bloc_test/bloc_test.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/usecases/create_checkin_usecase.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_cubit.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockCheckInRepository repository;
  late CheckInCubit cubit;

  final sampleCheckIn = CheckIn(
    id: '1',
    taskId: 'task1',
    notes: 'Valid notes text',
    category: CheckInCategory.progress,
    latitude: 1,
    longitude: 1,
    createdAt: DateTime.now(),
    createdBy: 'u1',
  );

  setUpAll(() {
    registerFallbackValue(sampleCheckIn);
  });

  setUp(() {
    repository = MockCheckInRepository();
    cubit = CheckInCubit(
      createCheckInUseCase: CreateCheckInUseCase(repository),
      taskId: 'task1',
      userId: 'u1',
    );
  });

  blocTest<CheckInCubit, CheckInFormState>(
    'fails validation for short notes',
    build: () {
      when(() => repository.create(any())).thenAnswer((_) async => Result.success(sampleCheckIn));
      return cubit;
    },
    act: (c) async {
      c.updateNotes('short');
      c.updateCategory(CheckInCategory.progress);
      c.setLocation(0.1, 0.2);
      await c.submit();
    },
    expect: () => [
      isA<CheckInFormState>(), // notes updated
      isA<CheckInFormState>(), // category updated
      isA<CheckInFormState>(), // location updated
      isA<CheckInFormState>().having((s) => s.error, 'error', isNotNull),
    ],
  );

  blocTest<CheckInCubit, CheckInFormState>(
    'emits success on valid submit',
    build: () {
      when(() => repository.create(any())).thenAnswer((_) async => Result.success(sampleCheckIn));
      return cubit;
    },
    act: (c) async {
      c.updateNotes('Valid long notes');
      c.updateCategory(CheckInCategory.progress);
      c.setLocation(1.1, -1.2);
      await c.submit();
    },
    expect: () => [
      isA<CheckInFormState>(),
      isA<CheckInFormState>(),
      isA<CheckInFormState>(),
      isA<CheckInFormState>().having((s) => s.submitting, 'submitting', true),
      isA<CheckInFormState>().having((s) => s.success, 'success', true),
    ],
  );
}
