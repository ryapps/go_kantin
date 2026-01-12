import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Service to monitor network connectivity
abstract class ConnectivityService {
  /// Check if device is currently connected
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Dispose resources
  void dispose();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final InternetConnectionChecker _connectionChecker;

  StreamController<bool>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ConnectivityServiceImpl({
    Connectivity? connectivity,
    InternetConnectionChecker? connectionChecker,
  })  : _connectivity = connectivity ?? Connectivity(),
        _connectionChecker = connectionChecker ?? InternetConnectionChecker();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();

      // Check if connection type is none
      if (result == ConnectivityResult.none) {
        return false;
      }

      // Verify actual internet connectivity
      return await _connectionChecker.hasConnection;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    _connectivityController ??= StreamController<bool>.broadcast();

    _connectivitySubscription ??= _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _connectivityController?.add(false);
      } else {
        // Verify actual internet connection
        final hasConnection = await _connectionChecker.hasConnection;
        _connectivityController?.add(hasConnection);
      }
    });

    return _connectivityController!.stream;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}