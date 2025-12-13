import 'package:flutter_application_6/core/services/connectivity_service.dart';
import 'package:flutter_application_6/core/services/location_service.dart';
import 'package:flutter_application_6/core/services/notification_service.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';
import 'package:flutter_application_6/data/datasources/local/prayer_cache_datasource.dart';
import 'package:flutter_application_6/data/datasources/remote/prayer_api_datasource.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';
import 'package:geolocator/geolocator.dart';

/// Repository for prayer times data with caching strategy
class PrayerRepository {
  final PrayerApiDataSource _remoteDataSource;
  final PrayerCacheDataSource _localDataSource;

  PrayerRepository({
    PrayerApiDataSource? remoteDataSource,
    PrayerCacheDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? PrayerApiDataSource(),
        _localDataSource = localDataSource ?? PrayerCacheDataSource();

  /// Get prayer times with cache-first strategy
  /// 1. Check if cache is valid (same day)
  /// 2. If valid, return cached data
  /// 3. If not valid or no cache, fetch from API
  /// 4. Cache the new data
  Future<PrayerTimesModel> getPrayerTimes({bool forceRefresh = false}) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh && _localDataSource.isCacheValid()) {
      final cached = _localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return cached;
      }
    }

    // Check internet connection
    final hasConnection = await ConnectivityService.hasConnection();

    if (!hasConnection) {
      // Return cached data even if stale
      final cached = _localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return cached;
      }
      throw Exception('No internet connection and no cached data available');
    }

    // Get location
    Position? position = await LocationService.getCurrentPosition();
    position ??= await LocationService.getLastKnownPosition();

    if (position == null) {
      // Try to return cached data
      final cached = _localDataSource.getCachedPrayerTimes();
      if (cached != null) {
        return cached;
      }
      throw Exception('Unable to get location');
    }

    // Fetch from API
    final prayerTimes = await _remoteDataSource.fetchPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // Cache the result
    await _localDataSource.cachePrayerTimes(prayerTimes);

    return prayerTimes;
  }

  /// Fetch and cache prayer times for background sync
  Future<void> syncPrayerTimes() async {
    try {
      await getPrayerTimes(forceRefresh: true);
    } catch (e) {
      print('Background sync failed: $e');
    }
  }

  /// Schedule notifications for all prayers
  Future<void> scheduleNotifications() async {
    try {
      // Get current prayer times (from cache or API)
      final prayerTimes = await getPrayerTimes();

      // Check if notifications are enabled
      if (!StorageService.isNotificationEnabled()) return;

      // Get prayer times as DateTime map
      final prayerDateTimes = prayerTimes.getAllPrayerDateTimes();

      // Schedule notifications
      await NotificationService.scheduleAllPrayerNotifications(prayerDateTimes);
    } catch (e) {
      print('Failed to schedule notifications: $e');
    }
  }

  /// Get next prayer info
  Future<MapEntry<String, DateTime>?> getNextPrayer() async {
    try {
      final prayerTimes = await getPrayerTimes();
      return prayerTimes.getNextPrayer();
    } catch (e) {
      return null;
    }
  }

  /// Check if cache exists
  bool hasCachedData() {
    return _localDataSource.getCachedPrayerTimes() != null;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }
}
