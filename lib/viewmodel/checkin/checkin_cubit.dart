import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/usecases/create_checkin_usecase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_state.dart';

class CheckInCubit extends Cubit<CheckInFormState> {
  final CreateCheckInUseCase createCheckInUseCase;
  final String taskId;
  final String userId;
  final ImagePicker _picker;
  final Uuid _uuid;

  CheckInCubit({
    required this.createCheckInUseCase,
    required this.taskId,
    required this.userId,
    ImagePicker? picker,
    Uuid? uuid,
  })  : _picker = picker ?? ImagePicker(),
        _uuid = uuid ?? const Uuid(),
        super(const CheckInFormState());

  void updateNotes(String value) {
    emit(state.copyWith(notes: value, success: false, error: null));
  }

  void updateCategory(CheckInCategory category) {
    emit(state.copyWith(category: category, success: false, error: null));
  }

  void removePhoto() => emit(state.copyWith(photoPath: null));

  Future<void> pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      emit(state.copyWith(photoPath: picked.path));
    }
  }

  Future<void> loadLocation() async {
    emit(state.copyWith(locationLoading: true, error: null));
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(state.copyWith(
          locationLoading: false,
          error: 'Enable location services to continue.',
        ));
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          emit(state.copyWith(
            locationLoading: false,
            error: 'Location permission denied',
          ));
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      emit(
        state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          locationLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        locationLoading: false,
        error: 'Failed to read location',
      ));
    }
  }

  void setLocation(double lat, double lng) {
    emit(
      state.copyWith(
        latitude: lat,
        longitude: lng,
        locationLoading: false,
      ),
    );
  }

  Future<CheckIn?> submit() async {
    final validationError = _validate();
    if (validationError != null) {
      emit(state.copyWith(error: validationError));
      return null;
    }

    emit(state.copyWith(submitting: true, error: null, success: false));
    final checkIn = CheckIn(
      id: _uuid.v4(),
      taskId: taskId,
      notes: state.notes.trim(),
      category: state.category!,
      photoPath: state.photoPath != null ? File(state.photoPath!).path : null,
      latitude: state.latitude!,
      longitude: state.longitude!,
      createdAt: DateTime.now(),
      createdBy: userId,
    );

    final result = await createCheckInUseCase(checkIn);
    return result.fold(
      (failure) {
        emit(state.copyWith(
          submitting: false,
          error: _friendlyMessage(failure),
        ));
        return null;
      },
      (saved) {
        emit(
          state.copyWith(
            submitting: false,
            success: true,
            notes: '',
            category: null,
            photoPath: null,
          ),
        );
        return saved;
      },
    );
  }

  String? _validate() {
    if (state.notes.trim().length < 10) {
      return 'Notes must be at least 10 characters.';
    }
    if (state.category == null) {
      return 'Choose a category.';
    }
    if (state.latitude == null || state.longitude == null) {
      return 'Location is required.';
    }
    return null;
  }

  String _friendlyMessage(AppFailure failure) {
    switch (failure.type) {
      case FailureType.network:
        return 'Network unavailable, saved locally.';
      default:
        return failure.message;
    }
  }
}
