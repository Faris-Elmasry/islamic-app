import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_6/features/qibla/presentation/theme/qibla_theme.dart';

/// Animated Compass Widget
///
/// A beautiful, animated compass that shows Qibla direction.
/// Follows Single Responsibility Principle - only handles compass visualization.
class AnimatedCompass extends StatelessWidget {
  final double compassHeading;
  final double qiblaAngle;
  final bool isFacingQibla;
  final double size;

  const AnimatedCompass({
    super.key,
    required this.compassHeading,
    required this.qiblaAngle,
    required this.isFacingQibla,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          _buildGlowRing(),

          // Compass background
          _buildCompassBackground(),

          // Compass dial (rotates with device)
          _buildCompassDial(),

          // Qibla indicator (fixed relative to compass)
          _buildQiblaIndicator(),

          // Center decoration
          _buildCenterDecoration(),
        ],
      ),
    );
  }

  Widget _buildGlowRing() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isFacingQibla
            ? QiblaTheme.glowShadow(QiblaTheme.successColor)
            : QiblaTheme.glowShadow(QiblaTheme.accentColor),
      ),
    );
  }

  Widget _buildCompassBackground() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: QiblaTheme.compassGradient,
        border: Border.all(
          color:
              isFacingQibla ? QiblaTheme.successColor : QiblaTheme.accentColor,
          width: 3,
        ),
        boxShadow: QiblaTheme.cardShadow,
      ),
    );
  }

  Widget _buildCompassDial() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: -compassHeading),
      duration: const Duration(milliseconds: 200),
      builder: (context, rotation, child) {
        return Transform.rotate(
          angle: rotation * math.pi / 180,
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(size - 40, size - 40),
        painter: CompassDialPainter(),
      ),
    );
  }

  Widget _buildQiblaIndicator() {
    // Calculate the angle where Qibla indicator should appear
    final qiblaOffset = qiblaAngle - compassHeading;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: qiblaOffset),
      duration: const Duration(milliseconds: 200),
      builder: (context, rotation, child) {
        return Transform.rotate(
          angle: rotation * math.pi / 180,
          child: child,
        );
      },
      child: SizedBox(
        width: size - 20,
        height: size - 20,
        child: Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, 15),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isFacingQibla
                    ? QiblaTheme.successColor
                    : QiblaTheme.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isFacingQibla
                            ? QiblaTheme.successColor
                            : QiblaTheme.accentColor)
                        .withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mosque,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDecoration() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: QiblaTheme.primaryDark,
        border: Border.all(
          color:
              isFacingQibla ? QiblaTheme.successColor : QiblaTheme.accentColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isFacingQibla ? Icons.check_circle : Icons.navigation,
          color:
              isFacingQibla ? QiblaTheme.successColor : QiblaTheme.accentColor,
          size: 30,
        ),
      ),
    );
  }
}

/// Custom Painter for Compass Dial
///
/// Draws the compass directions and tick marks.
class CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw tick marks
    _drawTickMarks(canvas, center, radius);

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = QiblaTheme.textMuted
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = QiblaTheme.textSecondary
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 15 : 8;

      final start = Offset(
        center.dx + (radius - tickLength) * math.sin(angle),
        center.dy - (radius - tickLength) * math.cos(angle),
      );
      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    const directions = [
      {'angle': 0, 'text': 'N', 'arabic': 'ش'},
      {'angle': 90, 'text': 'E', 'arabic': 'شر'},
      {'angle': 180, 'text': 'S', 'arabic': 'ج'},
      {'angle': 270, 'text': 'W', 'arabic': 'غ'},
    ];

    for (final dir in directions) {
      final angle = (dir['angle'] as int) * math.pi / 180;
      final textRadius = radius - 35;

      final position = Offset(
        center.dx + textRadius * math.sin(angle),
        center.dy - textRadius * math.cos(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: dir['arabic'] as String,
          style: TextStyle(
            color: dir['angle'] == 0
                ? QiblaTheme.errorColor
                : QiblaTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
