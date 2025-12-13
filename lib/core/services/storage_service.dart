import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_6/core/constants/app_constants.dart';

/// Service for local storage using Hive
class StorageService {
  static const String _settingsBox = 'settings';
  static const String _cacheBox = 'cache';

  static late Box _settings;
  static late Box _cache;

  /// Initialize Hive storage
  static Future<void> init() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(_settingsBox);
    _cache = await Hive.openBox(_cacheBox);
  }

  // ==================== Settings ====================

  /// Get selected adhan ID
  static String getSelectedAdhan() {
    return _settings.get(
      AppConstants.selectedAdhanKey,
      defaultValue: AppConstants.defaultAdhan,
    );
  }

  /// Set selected adhan ID
  static Future<void> setSelectedAdhan(String adhanId) async {
    await _settings.put(AppConstants.selectedAdhanKey, adhanId);
  }

  /// Check if notifications are enabled
  static bool isNotificationEnabled() {
    return _settings.get(AppConstants.notificationEnabledKey,
        defaultValue: true);
  }

  /// Set notification enabled state
  static Future<void> setNotificationEnabled(bool enabled) async {
    await _settings.put(AppConstants.notificationEnabledKey, enabled);
  }

  /// Get notification settings for each prayer
  static Map<String, bool> getPrayerNotificationSettings() {
    final Map<String, bool> defaults = {
      'Fajr': true,
      'Dhuhr': true,
      'Asr': true,
      'Maghrib': true,
      'Isha': true,
    };

    return Map<String, bool>.from(
      _settings.get('prayer_notifications', defaultValue: defaults),
    );
  }

  /// Set notification setting for a specific prayer
  static Future<void> setPrayerNotificationSetting(
      String prayer, bool enabled) async {
    final settings = getPrayerNotificationSettings();
    settings[prayer] = enabled;
    await _settings.put('prayer_notifications', settings);
  }

  /// Get tasbih counter
  static int getTasbihCounter() {
    return _settings.get(AppConstants.tasbihCounterKey, defaultValue: 0);
  }

  /// Set tasbih counter
  static Future<void> setTasbihCounter(int count) async {
    await _settings.put(AppConstants.tasbihCounterKey, count);
  }

  /// Get morning azkar reminder setting
  static bool getMorningAzkarReminder() {
    return _settings.get('morning_azkar_reminder', defaultValue: true);
  }

  /// Set morning azkar reminder
  static Future<void> setMorningAzkarReminder(bool enabled) async {
    await _settings.put('morning_azkar_reminder', enabled);
  }

  /// Get evening azkar reminder setting
  static bool getEveningAzkarReminder() {
    return _settings.get('evening_azkar_reminder', defaultValue: true);
  }

  /// Set evening azkar reminder
  static Future<void> setEveningAzkarReminder(bool enabled) async {
    await _settings.put('evening_azkar_reminder', enabled);
  }

  // ==================== Cache ====================

  /// Cache prayer times data
  static Future<void> cachePrayerTimes(Map<String, dynamic> data) async {
    await _cache.put(AppConstants.prayerTimesCacheKey, data);
    await _cache.put(
        AppConstants.lastCacheDateKey, DateTime.now().toIso8601String());
  }

  /// Get cached prayer times
  static Map<String, dynamic>? getCachedPrayerTimes() {
    final data = _cache.get(AppConstants.prayerTimesCacheKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get last cache date
  static DateTime? getLastCacheDate() {
    final dateStr = _cache.get(AppConstants.lastCacheDateKey);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  /// Check if cache is valid (same day)
  static bool isCacheValid() {
    final lastCache = getLastCacheDate();
    if (lastCache == null) return false;

    final now = DateTime.now();
    return lastCache.year == now.year &&
        lastCache.month == now.month &&
        lastCache.day == now.day;
  }

  /// Clear all cache
  static Future<void> clearCache() async {
    await _cache.clear();
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await _settings.clear();
    await _cache.clear();
  }
}
