import 'package:check_in_app/domain/enums.dart';
import 'package:equatable/equatable.dart';

class CheckInFormState extends Equatable {
  final String notes;
  final CheckInCategory? category;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final bool submitting;
  final bool success;
  final String? error;
  final bool locationLoading;

  const CheckInFormState({
    this.notes = '',
    this.category,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.submitting = false,
    this.success = false,
    this.error,
    this.locationLoading = false,
  });

  CheckInFormState copyWith({
    String? notes,
    CheckInCategory? category,
    String? photoPath,
    double? latitude,
    double? longitude,
    bool? submitting,
    bool? success,
    String? error,
    bool? locationLoading,
  }) {
    return CheckInFormState(
      notes: notes ?? this.notes,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
      locationLoading: locationLoading ?? this.locationLoading,
    );
  }

  @override
  List<Object?> get props => [
        notes,
        category,
        photoPath,
        latitude,
        longitude,
        submitting,
        success,
        error,
        locationLoading,
      ];
}
