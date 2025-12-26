import 'package:check_in_app/core/errors/failure.dart';

class Result<T> {
  final T? data;
  final AppFailure? error;

  const Result._({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  static Result<T> success<T>(T data) => Result._(data: data);
  static Result<void> successVoid() => const Result._();
  static Result<T> failure<T>(AppFailure error) => Result._(error: error);

  R fold<R>(R Function(AppFailure failure) onFailure, R Function(T data) onSuccess) {
    if (isFailure) return onFailure(error!);
    return onSuccess(data as T);
  }
}
