/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'أذكاري';
  static const String appVersion = '1.0.0';

  // Prayer Names in Arabic
  static const Map<String, String> prayerNames = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  // Azkar Categories
  static const int morningAzkarId = 1;
  static const int eveningAzkarId = 2;
  static const int prayerAzkarId = 3;
  static const int sleepAzkarId = 4;
  static const int ruqyahId = 5;
  static const int duaId = 6;

  // Cache Keys
  static const String prayerTimesCacheKey = 'prayer_times_cache';
  static const String lastCacheDateKey = 'last_cache_date';
  static const String selectedAdhanKey = 'selected_adhan';
  static const String notificationEnabledKey = 'notification_enabled';
  static const String tasbihCounterKey = 'tasbih_counter';

  // Background Task
  static const String prayerTimesTaskName = 'prayerTimesSync';
  static const String prayerNotificationTaskName = 'prayerNotification';

  // Default Values
  static const int defaultNotificationMinutesBefore = 0;
  static const String defaultAdhan = 'adhan_makkah';
}

/// API related constants
class ApiConstants {
  ApiConstants._();

  // Aladhan API
  static const String baseUrl = 'https://api.aladhan.com/v1';
  static const String prayerTimingsEndpoint = '/timings';
  static const String calendarEndpoint = '/calendar';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Notification IDs
class NotificationIds {
  NotificationIds._();

  static const int fajrId = 1;
  static const int sunriseId = 2;
  static const int dhuhrId = 3;
  static const int asrId = 4;
  static const int maghribId = 5;
  static const int ishaId = 6;
  static const int morningAzkarId = 7;
  static const int eveningAzkarId = 8;
}
