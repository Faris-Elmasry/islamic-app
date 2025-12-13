import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workmanager/workmanager.dart';
import 'package:flutter_application_6/core/constants/app_constants.dart';

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case AppConstants.prayerTimesTaskName:
        // Fetch and cache prayer times
        await _fetchAndCachePrayerTimes();
        break;
      case AppConstants.prayerNotificationTaskName:
        // Schedule notifications for the day
        await _scheduleNotifications();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _fetchAndCachePrayerTimes() async {
  // This will be implemented in the repository
  // Called from background to refresh prayer times
}

Future<void> _scheduleNotifications() async {
  // Schedule notifications based on cached prayer times
}

/// Service for handling background tasks
class BackgroundService {
  // WorkManager is only supported on Android and iOS (not web or desktop)
  static bool get _isSupported => !kIsWeb;

  /// Initialize workmanager (only on supported platforms)
  static Future<void> init() async {
    if (!_isSupported) {
      print('WorkManager not supported on this platform');
      return;
    }

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Register daily prayer times sync task
  static Future<void> registerPrayerTimesSync() async {
    if (!_isSupported) return;

    await Workmanager().registerPeriodicTask(
      AppConstants.prayerTimesTaskName,
      AppConstants.prayerTimesTaskName,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Register prayer notification task
  static Future<void> registerPrayerNotificationTask() async {
    if (!_isSupported) return;

    await Workmanager().registerPeriodicTask(
      AppConstants.prayerNotificationTaskName,
      AppConstants.prayerNotificationTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    if (!_isSupported) return;
    await Workmanager().cancelAll();
  }

  /// Cancel specific task
  static Future<void> cancelTask(String taskName) async {
    if (!_isSupported) return;
    await Workmanager().cancelByUniqueName(taskName);
  }
}
