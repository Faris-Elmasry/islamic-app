import 'package:flutter_application_6/features/qibla/domain/entities/qibla_direction.dart';
import 'package:flutter_application_6/features/qibla/domain/entities/location_data.dart';

/// Abstract Repository Interface for Qibla Direction
///
/// Follows Interface Segregation Principle (ISP) and Dependency Inversion Principle (DIP).
/// This interface defines the contract for Qibla-related operations.
abstract class IQiblaRepository {
  /// Get stream of Qibla direction updates
  /// Returns a stream that emits QiblaDirection whenever compass heading changes
  Stream<QiblaDirection> getQiblaDirectionStream();

  /// Get current user location
  Future<LocationData> getCurrentLocation();

  /// Calculate Qibla angle from a given location
  double calculateQiblaAngle(double latitude, double longitude);

  /// Check if device has compass sensor
  Future<bool> hasCompassSensor();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Request location permission
  Future<bool> requestLocationPermission();

  /// Get current location permission status
  Future<LocationPermissionStatus> getLocationPermissionStatus();

  /// Dispose resources
  void dispose();
}

/// Location Permission Status Enum
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
  unknown,
}
