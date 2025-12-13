import 'package:flutter_application_6/core/services/storage_service.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';

/// Local data source for caching prayer times
class PrayerCacheDataSource {
  /// Cache prayer times data
  Future<void> cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    await StorageService.cachePrayerTimes(prayerTimes.toJson());
  }

  /// Get cached prayer times
  PrayerTimesModel? getCachedPrayerTimes() {
    final data = StorageService.getCachedPrayerTimes();
    if (data == null) return null;
    return PrayerTimesModel.fromJson(data);
  }

  /// Check if cache is valid (same day)
  bool isCacheValid() {
    return StorageService.isCacheValid();
  }

  /// Get last cache date
  DateTime? getLastCacheDate() {
    return StorageService.getLastCacheDate();
  }

  /// Clear cached data
  Future<void> clearCache() async {
    await StorageService.clearCache();
  }
}
