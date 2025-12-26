import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  final bool isOnline;

  const ConnectivityState({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}
