import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Compass Service
///
/// Handles device compass sensor and provides heading stream.
/// Uses flutter_compass package for real compass data on mobile devices.
/// Falls back to simulation on unsupported platforms.
/// Follows Single Responsibility Principle - only handles compass functionality.
class CompassService {
  StreamController<double>? _compassController;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Simulated compass for platforms without sensor
  Timer? _simulationTimer;
  double _simulatedHeading = 0;
  bool _useSimulation = false;

  /// Stream of compass heading values (0-360 degrees from true north)
  Stream<double> get compassStream {
    _compassController ??= StreamController<double>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _compassController!.stream;
  }

  void _startListening() {
    if (kIsWeb) {
      // Web platform doesn't support compass - use simulation
      _startSimulatedCompass();
      return;
    }

    // Try to use real compass on native platforms
    _startRealCompass();
  }

  void _startRealCompass() async {
    try {
      // Check if compass events are available
      final events = FlutterCompass.events;
      if (events == null) {
        debugPrint('Compass not available, falling back to simulation');
        _startSimulatedCompass();
        return;
      }

      _useSimulation = false;
      _compassSubscription = events.listen(
        (event) {
          final heading = event.heading;
          if (heading != null &&
              _compassController != null &&
              !_compassController!.isClosed) {
            // Normalize heading to 0-360 range
            double normalizedHeading = heading;
            if (normalizedHeading < 0) normalizedHeading += 360;
            _compassController!.add(normalizedHeading);
          }
        },
        onError: (error) {
          debugPrint('Compass error: $error, falling back to simulation');
          _startSimulatedCompass();
        },
      );
    } catch (e) {
      debugPrint(
          'Failed to initialize compass: $e, falling back to simulation');
      _startSimulatedCompass();
    }
  }

  void _startSimulatedCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _useSimulation = true;
    _simulationTimer?.cancel();

    // Start with a random heading
    _simulatedHeading = math.Random().nextDouble() * 360;

    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        // Simulate realistic compass movement with slight drift
        _simulatedHeading += (math.Random().nextDouble() - 0.5) * 1.5;
        _simulatedHeading = _simulatedHeading % 360;
        if (_simulatedHeading < 0) _simulatedHeading += 360;

        if (_compassController != null && !_compassController!.isClosed) {
          _compassController!.add(_simulatedHeading);
        }
      },
    );
  }

  void _stopListening() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Check if compass is supported on this device
  Future<bool> isSupported() async {
    if (kIsWeb) return true; // We'll simulate

    try {
      final events = FlutterCompass.events;
      return events != null ||
          true; // Always return true since we have fallback
    } catch (e) {
      return true; // We have simulation fallback
    }
  }

  /// Check if we're using simulated compass
  bool get isSimulated => _useSimulation;

  /// Set a fixed heading (useful for testing or manual input)
  void setFixedHeading(double heading) {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    if (_compassController != null && !_compassController!.isClosed) {
      _compassController!.add(heading % 360);
    }
  }

  /// Dispose resources
  void dispose() {
    _stopListening();
    _compassController?.close();
    _compassController = null;
  }
}
