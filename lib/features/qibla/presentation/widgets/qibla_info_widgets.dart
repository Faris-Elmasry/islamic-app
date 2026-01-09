import 'package:flutter/material.dart';
import 'package:flutter_application_6/features/qibla/presentation/theme/qibla_theme.dart';

/// Qibla Info Card Widget
///
/// Displays information about the current Qibla direction.
/// Reusable component following Open-Closed Principle.
class QiblaInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final bool highlighted;

  const QiblaInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? QiblaTheme.successColor.withOpacity(0.2)
            : QiblaTheme.primaryMedium.withOpacity(0.5),
        borderRadius: QiblaTheme.cardRadius,
        border: Border.all(
          color: highlighted
              ? QiblaTheme.successColor
              : QiblaTheme.primaryLight.withOpacity(0.3),
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? QiblaTheme.accentColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? QiblaTheme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: QiblaTheme.labelStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: QiblaTheme.subheadingStyle.copyWith(
                    color: highlighted
                        ? QiblaTheme.successColor
                        : QiblaTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Direction Status Card
///
/// Shows the current direction status with animation.
class DirectionStatusCard extends StatelessWidget {
  final String instruction;
  final bool isFacingQibla;
  final double offset;

  const DirectionStatusCard({
    super.key,
    required this.instruction,
    required this.isFacingQibla,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFacingQibla
              ? [QiblaTheme.successColor, QiblaTheme.successLight]
              : [QiblaTheme.accentDark, QiblaTheme.accentColor],
        ),
        borderRadius: QiblaTheme.cardRadius,
        boxShadow: isFacingQibla
            ? QiblaTheme.glowShadow(QiblaTheme.successColor)
            : QiblaTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFacingQibla
                ? Icons.check_circle_outline
                : (offset > 0 ? Icons.turn_right : Icons.turn_left),
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            instruction,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Degree Display Widget
///
/// Shows the offset angle with styling.
class DegreeDisplay extends StatelessWidget {
  final double degrees;
  final String label;

  const DegreeDisplay({
    super.key,
    required this.degrees,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${degrees.abs().toStringAsFixed(1)}°',
          style: QiblaTheme.degreeStyle,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: QiblaTheme.labelStyle,
        ),
      ],
    );
  }
}

/// Error State Widget
///
/// Displays error messages with retry option.
class QiblaErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onRetry;

  const QiblaErrorWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.buttonText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: QiblaTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: QiblaTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: QiblaTheme.headingStyle.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: QiblaTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null && buttonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  buttonText!,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: QiblaTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: QiblaTheme.buttonRadius,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading Widget
///
/// Shows loading state with animation.
class QiblaLoadingWidget extends StatelessWidget {
  final String message;

  const QiblaLoadingWidget({
    super.key,
    this.message = 'جاري تحديد اتجاه القبلة...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    QiblaTheme.accentColor,
                  ),
                ),
              ),
              const Icon(
                Icons.explore,
                size: 40,
                color: QiblaTheme.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: QiblaTheme.bodyStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
