import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_application_6/core/constants/app_constants.dart';
import 'package:flutter_application_6/core/services/audio_service.dart';

/// Service for handling local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
    final payload = response.payload;
    if (payload != null) {
      // Play adhan if it's a prayer notification
      if (payload.startsWith('prayer_')) {
        AudioService.playAdhan();
      }
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule prayer notification
  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required String prayerNameAr,
    required DateTime scheduledTime,
    bool playAdhan = true,
  }) async {
    // Don't schedule if time has passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'حان وقت صلاة $prayerNameAr',
      'حي على الصلاة، حي على الفلاح',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_$prayerName',
    );
  }

  /// Schedule all prayer notifications for a day
  static Future<void> scheduleAllPrayerNotifications(
    Map<String, DateTime> prayerTimes,
  ) async {
    // Cancel existing notifications first
    await cancelAllPrayerNotifications();

    final prayerIds = {
      'Fajr': NotificationIds.fajrId,
      'Dhuhr': NotificationIds.dhuhrId,
      'Asr': NotificationIds.asrId,
      'Maghrib': NotificationIds.maghribId,
      'Isha': NotificationIds.ishaId,
    };

    for (final entry in prayerTimes.entries) {
      final prayerName = entry.key;
      final time = entry.value;
      final id = prayerIds[prayerName];

      if (id != null && time.isAfter(DateTime.now())) {
        await schedulePrayerNotification(
          id: id,
          prayerName: prayerName,
          prayerNameAr: AppConstants.prayerNames[prayerName] ?? prayerName,
          scheduledTime: time,
        );
      }
    }
  }

  /// Schedule azkar reminder
  static Future<void> scheduleAzkarReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'azkar_channel',
      'تذكير الأذكار',
      channelDescription: 'تذكير بأذكار الصباح والمساء',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'azkar',
    );
  }

  /// Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'general_channel',
      'إشعارات عامة',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all prayer notifications
  static Future<void> cancelAllPrayerNotifications() async {
    await _notifications.cancel(NotificationIds.fajrId);
    await _notifications.cancel(NotificationIds.dhuhrId);
    await _notifications.cancel(NotificationIds.asrId);
    await _notifications.cancel(NotificationIds.maghribId);
    await _notifications.cancel(NotificationIds.ishaId);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
