import 'package:check_in_app/core/config/app_config.dart';
import 'package:check_in_app/core/config/firebase_options.dart';
import 'package:check_in_app/data/local/auth_local_data_source.dart';
import 'package:check_in_app/data/local/checkin_local_data_source.dart';
import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/data/local/task_local_data_source.dart';
import 'package:check_in_app/data/remote/auth_remote_data_source.dart';
import 'package:check_in_app/data/remote/checkin_remote_data_source.dart';
import 'package:check_in_app/data/remote/task_remote_data_source.dart';
import 'package:check_in_app/data/repositories/auth_repository_impl.dart';
import 'package:check_in_app/data/repositories/checkin_repository_impl.dart';
import 'package:check_in_app/data/repositories/task_repository_impl.dart';
import 'package:check_in_app/data/seed/seed_data.dart';
import 'package:check_in_app/di/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HiveStorage.init();

  if (!storage.isSeeded) {
    final taskLocal = TaskLocalDataSource(storage);
    await taskLocal.saveTasks(SeedData.tasks());
    await storage.markSeeded();
  }

  final shouldInitFirebase = AppConfig.enableFirebaseAuth || AppConfig.enableFirebaseRemote;
  if (shouldInitFirebase) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // Ensure default app is ready without reinitializing.
        Firebase.app();
      }
    } catch (e) {
      // Keep running in offline mode when Firebase is not configured or already initialized.
    }
  }

  final authLocal = AuthLocalDataSource(storage);
  final taskLocal = TaskLocalDataSource(storage);
  final checkInLocal = CheckInLocalDataSource(storage);

  final authRemote =
      AppConfig.enableFirebaseAuth
          ? FirebaseAuthRemoteDataSource(
            roleOverrides: {
              for (final user in SeedData.users) user.email: user,
            },
          )
          : MockAuthRemoteDataSource();

  final taskRemote =
      AppConfig.enableFirebaseRemote
          ? FirestoreTaskRemoteDataSource()
          : MockTaskRemoteDataSource();

  final checkInRemote =
      AppConfig.enableFirebaseRemote
          ? FirestoreCheckInRemoteDataSource()
          : MockCheckInRemoteDataSource();

  final authRepository = AuthRepositoryImpl(
    local: authLocal,
    remote: authRemote,
  );

  final taskRepository = TaskRepositoryImpl(
    local: taskLocal,
    remote: taskRemote,
    remoteEnabled: AppConfig.enableFirebaseRemote,
  );

  final checkInRepository = CheckInRepositoryImpl(
    local: checkInLocal,
    remote: checkInRemote,
    remoteEnabled: AppConfig.enableFirebaseRemote,
  );

  await configureDependencies(
    authRepository: authRepository,
    taskRepository: taskRepository,
    checkInRepository: checkInRepository,
  );

  // All dependencies are registered in get_it; no return object needed.
}
