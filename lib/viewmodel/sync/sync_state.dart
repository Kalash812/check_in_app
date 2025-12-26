import 'package:equatable/equatable.dart';

class SyncState extends Equatable {
  final bool syncing;
  final String? message;

  const SyncState({
    this.syncing = false,
    this.message,
  });

  SyncState copyWith({
    bool? syncing,
    String? message,
  }) {
    return SyncState(
      syncing: syncing ?? this.syncing,
      message: message,
    );
  }

  @override
  List<Object?> get props => [syncing, message];
}
