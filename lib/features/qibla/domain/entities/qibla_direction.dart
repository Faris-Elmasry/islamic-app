/// Qibla Direction Entity
///
/// Represents the calculated direction to the Kaaba from user's location.
/// This is a domain entity following Clean Architecture principles.
class QiblaDirection {
  /// The bearing angle to Qibla from true north (in degrees, 0-360)
  final double qiblaAngle;

  /// Current device compass heading (in degrees, 0-360)
  final double compassHeading;

  /// The offset between device heading and Qibla direction
  /// Positive = Qibla is to the right, Negative = Qibla is to the left
  final double offset;

  /// User's current latitude
  final double latitude;

  /// User's current longitude
  final double longitude;

  /// Accuracy of the compass reading (in degrees)
  final double accuracy;

  /// Whether the compass is calibrated properly
  final bool isCalibrated;

  const QiblaDirection({
    required this.qiblaAngle,
    required this.compassHeading,
    required this.offset,
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    this.isCalibrated = true,
  });

  /// Check if user is facing Qibla (within acceptable tolerance)
  bool get isFacingQibla => offset.abs() < 5;

  /// Get direction instruction text in Arabic
  String get directionInstruction {
    if (isFacingQibla) {
      return 'أنت تواجه القبلة ✓';
    } else if (offset > 0) {
      return 'أدر إلى اليمين';
    } else {
      return 'أدر إلى اليسار';
    }
  }

  /// Create a copy with updated values
  QiblaDirection copyWith({
    double? qiblaAngle,
    double? compassHeading,
    double? offset,
    double? latitude,
    double? longitude,
    double? accuracy,
    bool? isCalibrated,
  }) {
    return QiblaDirection(
      qiblaAngle: qiblaAngle ?? this.qiblaAngle,
      compassHeading: compassHeading ?? this.compassHeading,
      offset: offset ?? this.offset,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      isCalibrated: isCalibrated ?? this.isCalibrated,
    );
  }

  @override
  String toString() {
    return 'QiblaDirection(qiblaAngle: $qiblaAngle, compassHeading: $compassHeading, offset: $offset)';
  }
}
