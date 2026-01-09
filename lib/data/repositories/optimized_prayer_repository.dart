import 'package:flutter_application_6/core/services/connectivity_service.dart';
import 'package:flutter_application_6/core/services/location_service.dart';
import 'package:flutter_application_6/core/services/notification_service.dart';
import 'package:flutter_application_6/core/services/prayer_cache_service.dart';
import 'package:flutter_application_6/data/datasources/remote/prayer_api_datasource.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';
import 'package:geolocator/geolocator.dart';

/// ============================================================================
/// OPTIMIZED PRAYER REPOSITORY - MONTHLY CACHING STRATEGY
/// ============================================================================
///
/// Performance Goals:
/// - Page load < 100ms when returning from other pages
/// - First meaningful paint < 1 second
/// - Zero API calls on page revisits
/// - Smooth transitions with no flickering
///
/// Cache-First Strategy:
/// 1. INSTANT: Return from memory cache if available
/// 2. FAST: Load from disk cache if memory empty
/// 3. BACKGROUND: Refresh silently if cache stale
/// 4. API CALL: Only when no cache exists
///
/// API Call Triggers:
/// - First time opening app (no cache)
/// - User changes location (> 5km)
/// - New month begins
/// - Cache expired (> 30 days)
/// - User manually refreshes
///
/// ============================================================================

class OptimizedPrayerRepository {
  final PrayerApiDataSource _remoteDataSource;

  /// Static flag to track if initial load is done
  static bool _isPreloaded = false;
  static PrayerTimesModel? _todayCache;

  OptimizedPrayerRepository({
    PrayerApiDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PrayerApiDataSource();

  /// ==================== MAIN ACCESS METHOD ====================

  /// Get today's prayer times - INSTANT if cached
  /// This is the primary method for UI access
  Future<PrayerTimesModel> getTodayPrayerTimes({
    bool forceRefresh = false,
  }) async {
    // 1. INSTANT: Return static memory cache
    if (!forceRefresh && _todayCache != null) {
      _backgroundRefreshIfNeeded();
      return _todayCache!;
    }

    // 2. FAST: Check service memory cache
    if (!forceRefresh) {
      final cached = PrayerCacheService.getTodayPrayerTimes();
      if (cached != null) {
        _todayCache = cached;
        _backgroundRefreshIfNeeded();
        return cached;
      }
    }

    // 3. Check if we should fetch from API
    final shouldFetch = forceRefresh ||
        PrayerCacheService.shouldRefreshCache() ||
        !PrayerCacheService.hasValidCacheForToday();

    if (shouldFetch) {
      // Try to fetch, but return cached if fails
      try {
        await _fetchAndCacheMonthlyData();
        final result = PrayerCacheService.getTodayPrayerTimes();
        if (result != null) {
          _todayCache = result;
          return result;
        }
      } catch (e) {
        // API failed, try to return any cached data
        final fallback = PrayerCacheService.getTodayPrayerTimes();
        if (fallback != null) {
          _todayCache = fallback;
          return fallback;
        }
        rethrow;
      }
    }

    // 4. No data available
    throw Exception('No prayer times available');
  }

  /// ==================== PRELOADING ====================

  /// Preload data on app startup (call from main.dart)
  /// This ensures data is ready before user navigates to prayer page
  static Future<void> preloadPrayerTimes() async {
    if (_isPreloaded) return;

    try {
      // PrayerCacheService should already be initialized in main.dart
      // Load from disk to memory
      final cached = PrayerCacheService.getTodayPrayerTimes();
      if (cached != null) {
        _todayCache = cached;
        _isPreloaded = true;
      }

      // Background refresh if needed (non-blocking)
      if (PrayerCacheService.shouldRefreshCache()) {
        _backgroundFetchMonthlyData();
      }
    } catch (e) {
      // Preload failed, will try again when page opens
    }
  }

  /// Check if data is preloaded and ready
  static bool get isDataReady =>
      _todayCache != null || PrayerCacheService.hasValidCacheForToday();

  /// ==================== MONTHLY DATA FETCH ====================

  /// Fetch entire month's data in single API call
  Future<void> _fetchAndCacheMonthlyData() async {
    // Check connectivity
    final hasConnection = await ConnectivityService.hasConnection();
    if (!hasConnection) {
      throw Exception('No internet connection');
    }

    // Get location
    Position? position = await LocationService.getCurrentPosition();
    position ??= await LocationService.getLastKnownPosition();

    if (position == null) {
      throw Exception('Unable to get location');
    }

    // Check if location changed significantly
    final locationChanged = PrayerCacheService.locationChanged(
      position.latitude,
      position.longitude,
    );

    // If location didn't change and cache is still valid, skip API call
    if (!locationChanged && !PrayerCacheService.shouldRefreshCache()) {
      return;
    }

    final now = DateTime.now();

    // Fetch entire month's data
    final monthlyData = await _remoteDataSource.fetchMonthlyPrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      month: now.month,
      year: now.year,
    );

    // Cache all data
    await PrayerCacheService.cacheMonthlyPrayerTimes(
      prayerTimesList: monthlyData,
      latitude: position.latitude,
      longitude: position.longitude,
      month: now.month,
      year: now.year,
    );

    // Update static cache
    _todayCache = PrayerCacheService.getTodayPrayerTimes();
  }

  /// Background fetch without blocking
  static void _backgroundFetchMonthlyData() async {
    try {
      final repo = OptimizedPrayerRepository();
      await repo._fetchAndCacheMonthlyData();
    } catch (e) {
      // Background fetch failed silently
    }
  }

  /// Check if background refresh is needed
  void _backgroundRefreshIfNeeded() async {
    if (PrayerCacheService.shouldRefreshCache()) {
      // Don't await - run in background
      _fetchAndCacheMonthlyData().catchError((_) {});
    }
  }

  /// ==================== NOTIFICATIONS ====================

  /// Schedule notifications for all prayers
  Future<void> scheduleNotifications() async {
    try {
      final prayerTimes = await getTodayPrayerTimes();
      final prayerDateTimes = prayerTimes.getAllPrayerDateTimes();
      await NotificationService.scheduleAllPrayerNotifications(prayerDateTimes);
    } catch (e) {
      // Silent fail for notifications
    }
  }

  /// ==================== UTILITIES ====================

  /// Get next prayer info
  Future<MapEntry<String, DateTime>?> getNextPrayer() async {
    try {
      final prayerTimes = await getTodayPrayerTimes();
      return prayerTimes.getNextPrayer();
    } catch (e) {
      return null;
    }
  }

  /// Get prayer times for a specific date
  Future<PrayerTimesModel?> getPrayerTimesForDate(DateTime date) async {
    // Try cache first
    final cached = PrayerCacheService.getPrayerTimesForDate(date);
    if (cached != null) return cached;

    // Need to fetch that month's data
    final now = DateTime.now();
    if (date.month == now.month && date.year == now.year) {
      // Same month, fetch if not cached
      await _fetchAndCacheMonthlyData();
      return PrayerCacheService.getPrayerTimesForDate(date);
    }

    // Different month - would need separate API call
    return null;
  }

  /// Force refresh all data
  Future<void> forceRefresh() async {
    _todayCache = null;
    await PrayerCacheService.clearCache();
    await _fetchAndCacheMonthlyData();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    _todayCache = null;
    _isPreloaded = false;
    await PrayerCacheService.clearCache();
  }

  /// Get cache statistics (for debugging)
  Map<String, dynamic> getCacheStats() {
    return {
      ...PrayerCacheService.getCacheStats(),
      'hasStaticCache': _todayCache != null,
      'isPreloaded': _isPreloaded,
    };
  }
}
