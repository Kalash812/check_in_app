import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:check_in_app/viewmodel/connectivity/connectivity_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityState(isOnline: true)) {
    _listen();
  }

  Future<void> _listen() async {
    final initial = await _connectivity.checkConnectivity();
    emit(ConnectivityState(isOnline: initial != ConnectivityResult.none));
    _subscription = _connectivity.onConnectivityChanged.listen((status) {
      emit(ConnectivityState(isOnline: status != ConnectivityResult.none));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
