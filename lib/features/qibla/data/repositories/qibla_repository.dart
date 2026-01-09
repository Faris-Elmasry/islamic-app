import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_6/features/qibla/domain/entities/qibla_direction.dart';
import 'package:flutter_application_6/features/qibla/domain/entities/location_data.dart';
import 'package:flutter_application_6/features/qibla/domain/repositories/i_qibla_repository.dart';
import 'package:flutter_application_6/features/qibla/data/services/compass_service.dart';

/// Qibla Repository Implementation
///
/// Concrete implementation of IQiblaRepository following Single Responsibility Principle.
/// Handles all Qibla direction calculations and location services.
class QiblaRepository implements IQiblaRepository {
  final CompassService _compassService;

  // Kaaba coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;

  StreamController<QiblaDirection>? _qiblaStreamController;
  StreamSubscription? _compassSubscription;

  QiblaRepository({CompassService? compassService})
      : _compassService = compassService ?? CompassService();

  @override
  Stream<QiblaDirection> getQiblaDirectionStream() {
    _qiblaStreamController ??= StreamController<QiblaDirection>.broadcast();

    _initQiblaStream();
    return _qiblaStreamController!.stream;
  }

  Future<void> _initQiblaStream() async {
    try {
      // Get current location first
      final location = await getCurrentLocation();

      // Calculate Qibla angle
      final qiblaAngle =
          calculateQiblaAngle(location.latitude, location.longitude);

      // Listen to compass updates
      _compassSubscription?.cancel();
      _compassSubscription = _compassService.compassStream.listen(
        (compassHeading) {
          if (_qiblaStreamController != null &&
              !_qiblaStreamController!.isClosed) {
            final offset = _calculateOffset(qiblaAngle, compassHeading);

            _qiblaStreamController!.add(QiblaDirection(
              qiblaAngle: qiblaAngle,
              compassHeading: compassHeading,
              offset: offset,
              latitude: location.latitude,
              longitude: location.longitude,
              isCalibrated: true,
            ));
          }
        },
        onError: (error) {
          if (_qiblaStreamController != null &&
              !_qiblaStreamController!.isClosed) {
            _qiblaStreamController!.addError(error);
          }
        },
      );
    } catch (e) {
      if (_qiblaStreamController != null && !_qiblaStreamController!.isClosed) {
        _qiblaStreamController!.addError(e);
      }
    }
  }

  double _calculateOffset(double qiblaAngle, double compassHeading) {
    double offset = qiblaAngle - compassHeading;

    // Normalize to -180 to 180 range
    if (offset > 180) {
      offset -= 360;
    } else if (offset < -180) {
      offset += 360;
    }

    return offset;
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // Check permission
    final permissionStatus = await getLocationPermissionStatus();
    if (permissionStatus != LocationPermissionStatus.granted) {
      final granted = await requestLocationPermission();
      if (!granted) {
        throw LocationPermissionDeniedException();
      }
    }

    // Get position with timeout (10 seconds)
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } on TimeoutException {
      // Try to get last known position as fallback
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return LocationData(
          latitude: lastPosition.latitude,
          longitude: lastPosition.longitude,
          altitude: lastPosition.altitude,
          accuracy: lastPosition.accuracy,
          timestamp: lastPosition.timestamp,
        );
      }
      throw LocationTimeoutException();
    }
  }

  @override
  double calculateQiblaAngle(double latitude, double longitude) {
    // Convert to radians
    final latRad = _toRadians(latitude);
    final lonRad = _toRadians(longitude);
    final kaabaLatRad = _toRadians(_kaabaLat);
    final kaabaLonRad = _toRadians(_kaabaLon);

    // Calculate Qibla direction using spherical trigonometry
    final deltaLon = kaabaLonRad - lonRad;

    final y = math.sin(deltaLon);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(deltaLon);

    double qiblaAngle = math.atan2(y, x);
    qiblaAngle = _toDegrees(qiblaAngle);

    // Normalize to 0-360 range
    if (qiblaAngle < 0) {
      qiblaAngle += 360;
    }

    return qiblaAngle;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  @override
  Future<bool> hasCompassSensor() async {
    return _compassService.isSupported();
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    final permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unknown;
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _qiblaStreamController?.close();
  }
}

/// Custom Exceptions for better error handling
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(
      [this.message = 'Location services are disabled']);

  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(
      [this.message = 'Location permission denied']);

  @override
  String toString() => message;
}

class LocationTimeoutException implements Exception {
  final String message;
  LocationTimeoutException([this.message = 'Location request timed out']);

  @override
  String toString() => message;
}
