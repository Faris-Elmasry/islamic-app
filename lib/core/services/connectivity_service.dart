import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for handling network connectivity
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? _subscription;

  /// Check if device has internet connection
  static Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  /// Check connectivity result
  static bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  /// Listen to connectivity changes
  static Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  /// Start listening to connectivity changes
  static void startListening(Function(bool hasConnection) onConnectionChange) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      onConnectionChange(_isConnected(result));
    });
  }

  /// Stop listening to connectivity changes
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
