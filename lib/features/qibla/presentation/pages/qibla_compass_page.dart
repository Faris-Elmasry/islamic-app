import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/features/qibla/domain/entities/qibla_direction.dart';
import 'package:flutter_application_6/features/qibla/presentation/providers/qibla_provider.dart';
import 'package:flutter_application_6/features/qibla/presentation/theme/qibla_theme.dart';
import 'package:flutter_application_6/features/qibla/presentation/widgets/animated_compass.dart';
import 'package:flutter_application_6/features/qibla/presentation/widgets/qibla_info_widgets.dart';

/// Qibla Compass Page
///
/// Main page for displaying Qibla direction.
/// Follows SOLID principles with proper separation of concerns.
class QiblaCompassPage extends ConsumerStatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  ConsumerState<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends ConsumerState<QiblaCompassPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeQibla();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _initializeQibla() {
    // Initialize Qibla state after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qiblaStateProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaState = ref.watch(qiblaStateProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: QiblaTheme.primaryDark,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Container(
          decoration: const BoxDecoration(
            gradient: QiblaTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: _buildBody(qiblaState),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'بوصلة القبلة',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showInfoDialog,
          tooltip: 'معلومات',
        ),
      ],
    );
  }

  Widget _buildBody(QiblaState state) {
    switch (state) {
      case QiblaState.initial:
      case QiblaState.loading:
        return const QiblaLoadingWidget();

      case QiblaState.permissionDenied:
        return QiblaErrorWidget(
          title: 'صلاحية الموقع مطلوبة',
          message: 'يرجى السماح للتطبيق بالوصول إلى موقعك لتحديد اتجاه القبلة',
          icon: Icons.location_off,
          buttonText: 'السماح بالوصول',
          onRetry: _requestPermission,
        );

      case QiblaState.locationDisabled:
        return QiblaErrorWidget(
          title: 'خدمة الموقع معطلة',
          message: 'يرجى تفعيل خدمة الموقع في إعدادات الجهاز',
          icon: Icons.location_disabled,
          buttonText: 'إعادة المحاولة',
          onRetry: _retryInitialization,
        );

      case QiblaState.compassUnavailable:
        return QiblaErrorWidget(
          title: 'البوصلة غير متوفرة',
          message: 'جهازك لا يدعم مستشعر البوصلة',
          icon: Icons.explore_off,
        );

      case QiblaState.error:
        return QiblaErrorWidget(
          title: 'حدث خطأ',
          message: 'حدث خطأ أثناء تحديد اتجاه القبلة',
          icon: Icons.error_outline,
          buttonText: 'إعادة المحاولة',
          onRetry: _retryInitialization,
        );

      case QiblaState.success:
        return _buildCompassView();
    }
  }

  Widget _buildCompassView() {
    final qiblaStream = ref.watch(qiblaDirectionStreamProvider);

    return qiblaStream.when(
      loading: () => const QiblaLoadingWidget(),
      error: (error, stack) => QiblaErrorWidget(
        title: 'حدث خطأ',
        message: error.toString(),
        icon: Icons.error_outline,
        buttonText: 'إعادة المحاولة',
        onRetry: _retryInitialization,
      ),
      data: (direction) => _buildCompassContent(direction),
    );
  }

  Widget _buildCompassContent(QiblaDirection direction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Main compass
          AnimatedCompass(
            compassHeading: direction.compassHeading,
            qiblaAngle: direction.qiblaAngle,
            isFacingQibla: direction.isFacingQibla,
            size: MediaQuery.of(context).size.width * 0.8,
          ),

          const SizedBox(height: 32),

          // Direction status
          DirectionStatusCard(
            instruction: direction.directionInstruction,
            isFacingQibla: direction.isFacingQibla,
            offset: direction.offset,
          ),

          const SizedBox(height: 24),

          // Degree display
          DegreeDisplay(
            degrees: direction.offset,
            label: direction.offset > 0 ? 'درجة إلى اليمين' : 'درجة إلى اليسار',
          ),

          const SizedBox(height: 32),

          // Info cards
          _buildInfoCards(direction),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCards(QiblaDirection direction) {
    return Column(
      children: [
        QiblaInfoCard(
          title: 'زاوية القبلة',
          value: '${direction.qiblaAngle.toStringAsFixed(1)}°',
          icon: Icons.explore,
          highlighted: direction.isFacingQibla,
        ),
        const SizedBox(height: 12),
        QiblaInfoCard(
          title: 'اتجاه البوصلة',
          value: '${direction.compassHeading.toStringAsFixed(1)}°',
          icon: Icons.compass_calibration,
        ),
        const SizedBox(height: 12),
        QiblaInfoCard(
          title: 'الموقع',
          value:
              '${direction.latitude.toStringAsFixed(4)}, ${direction.longitude.toStringAsFixed(4)}',
          icon: Icons.location_on,
          iconColor: QiblaTheme.warningColor,
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: QiblaTheme.primaryMedium,
        shape: RoundedRectangleBorder(
          borderRadius: QiblaTheme.cardRadius,
        ),
        title: const Text(
          'كيفية الاستخدام',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
          ),
          textAlign: TextAlign.right,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _InfoItem(
              icon: Icons.phone_android,
              text: 'أمسك الجهاز بشكل أفقي',
            ),
            SizedBox(height: 12),
            _InfoItem(
              icon: Icons.rotate_right,
              text: 'قم بتدوير جسمك ببطء',
            ),
            SizedBox(height: 12),
            _InfoItem(
              icon: Icons.mosque,
              text: 'اتبع أيقونة المسجد',
            ),
            SizedBox(height: 12),
            _InfoItem(
              icon: Icons.check_circle,
              text: 'البوصلة تتحول للأخضر عند مواجهة القبلة',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: QiblaTheme.accentColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestPermission() {
    ref.read(qiblaStateProvider.notifier).requestPermission();
  }

  void _retryInitialization() {
    ref.read(qiblaStateProvider.notifier).initialize();
  }
}

/// Info Item for Dialog
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          icon,
          color: QiblaTheme.accentColor,
          size: 20,
        ),
      ],
    );
  }
}
