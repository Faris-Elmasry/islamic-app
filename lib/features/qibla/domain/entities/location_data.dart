/// Location Data Entity
///
/// Represents user's geographic location with additional metadata.
class LocationData {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
  });

  /// Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Check if location is valid
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Calculate distance to Kaaba in kilometers (Haversine formula)
  double get distanceToKaaba {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(kaabaLatitude - latitude);
    final double dLon = _toRadians(kaabaLongitude - longitude);

    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(kaabaLatitude)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  double _sin(double x) => _sinImpl(x);
  double _cos(double x) => _cosImpl(x);
  double _sqrt(double x) => _sqrtImpl(x);
  double _atan2(double y, double x) => _atan2Impl(y, x);

  // Dart math implementations
  static double _sinImpl(double x) {
    // Using Taylor series approximation
    x = x % (2 * 3.141592653589793);
    double result = 0;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }

  static double _cosImpl(double x) {
    return _sinImpl(x + 3.141592653589793 / 2);
  }

  static double _sqrtImpl(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2Impl(double y, double x) {
    if (x > 0) return _atanImpl(y / x);
    if (x < 0 && y >= 0) return _atanImpl(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atanImpl(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  static double _atanImpl(double x) {
    double result = 0;
    double term = x;
    for (int i = 0; i < 10; i++) {
      result += term / (2 * i + 1) * (i % 2 == 0 ? 1 : -1);
      term *= x * x;
    }
    return result;
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude)';
  }
}
