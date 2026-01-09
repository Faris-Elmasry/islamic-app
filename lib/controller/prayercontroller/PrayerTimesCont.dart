import 'package:dio/dio.dart';
import 'package:flutter_application_6/model/prayermodel/PrayerTimes.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';
import 'package:flutter_application_6/core/services/connectivity_service.dart';
import 'package:geolocator/geolocator.dart';

/// Prayer Times Controller with Cache-First Strategy
///
/// Strategy:
/// 1. Return cached data immediately if available (instant UI)
/// 2. Fetch fresh data in background if internet available
/// 3. Update cache with fresh data
/// 4. Only hit API if cache is stale (different day) or empty
class PrayerTimesController {
  static double? pLat;
  static double? pLong;
  static AzkarApp? _cachedPrayerTimes;
  static DateTime? _lastFetchDate;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Get prayer times with cache-first strategy
  /// Returns cached data instantly, refreshes in background
  Future<AzkarApp> fetchPrayerTimesByLocation(
      {bool forceRefresh = false}) async {
    // 1. Check memory cache first (fastest)
    if (!forceRefresh &&
        _cachedPrayerTimes != null &&
        _isSameDay(_lastFetchDate)) {
      return _cachedPrayerTimes!;
    }

    // 2. Check disk cache (fast)
    if (!forceRefresh) {
      final diskCache = await _loadFromDiskCache();
      if (diskCache != null && _isSameDay(_getLastCacheDate())) {
        _cachedPrayerTimes = diskCache;
        _lastFetchDate = DateTime.now();
        return diskCache;
      }
    }

    // 3. If we have old cache, return it and refresh in background
    if (_cachedPrayerTimes != null) {
      _refreshInBackground();
      return _cachedPrayerTimes!;
    }

    // 4. No cache - must fetch from API
    return await _fetchFromApi();
  }

  /// Check if date is same day as today
  bool _isSameDay(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get last cache date from storage
  DateTime? _getLastCacheDate() {
    return StorageService.getLastCacheDate();
  }

  /// Load from disk cache
  Future<AzkarApp?> _loadFromDiskCache() async {
    try {
      final data = StorageService.getCachedPrayerTimes();
      if (data != null) {
        return AzkarApp.fromJson({'data': data});
      }
    } catch (e) {
      // Cache corrupted, will fetch fresh
    }
    return null;
  }

  /// Save to disk cache
  Future<void> _saveToDiskCache(AzkarApp prayerTimes) async {
    try {
      final data = {
        'timings': {
          'Fajr': prayerTimes.data.timings.fajr,
          'Dhuhr': prayerTimes.data.timings.dhuhr,
          'Asr': prayerTimes.data.timings.asr,
          'Maghrib': prayerTimes.data.timings.maghrib,
          'Isha': prayerTimes.data.timings.isha,
          'Sunrise': prayerTimes.data.timings.sunrise,
        },
        'date': {
          'hijri': {
            'date': prayerTimes.data.date.hijri.date,
            'day': prayerTimes.data.date.hijri.day,
            'month': {
              'number': prayerTimes.data.date.hijri.month.number,
              'en': prayerTimes.data.date.hijri.month.en,
              'ar': prayerTimes.data.date.hijri.month.ar,
            },
            'year': prayerTimes.data.date.hijri.year,
            'weekday': {
              'en': prayerTimes.data.date.hijri.weekday.en,
              'ar': prayerTimes.data.date.hijri.weekday.ar,
            },
          },
          'gregorian': {
            'date': prayerTimes.data.date.gregorian.date,
            'day': prayerTimes.data.date.gregorian.day,
            'month': {
              'number': prayerTimes.data.date.gregorian.month.number,
              'en': prayerTimes.data.date.gregorian.month.en,
            },
            'year': prayerTimes.data.date.gregorian.year,
            'weekday': {
              'en': prayerTimes.data.date.gregorian.weekday.en,
            },
          },
        },
        'meta': {
          'timezone': prayerTimes.data.meta.timezone,
        },
      };
      await StorageService.cachePrayerTimes(data);
    } catch (e) {
      // Silently fail cache save
    }
  }

  /// Refresh data in background without blocking UI
  void _refreshInBackground() async {
    try {
      final hasConnection = await ConnectivityService.hasConnection();
      if (hasConnection) {
        final fresh = await _fetchFromApi(updateCache: true);
        _cachedPrayerTimes = fresh;
      }
    } catch (e) {
      // Background refresh failed, keep using cached data
    }
  }

  /// Fetch fresh data from API
  Future<AzkarApp> _fetchFromApi({bool updateCache = true}) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );

    pLat = position.latitude;
    pLong = position.longitude;

    // Format date as DD-MM-YYYY (required by Aladhan API)
    final now = DateTime.now();
    String date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final response = await _dio.get(
      "https://api.aladhan.com/v1/timings/$date",
      queryParameters: {
        'latitude': pLat,
        'longitude': pLong,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      final prayerTimes = AzkarApp.fromJson(data);

      // Update caches
      _cachedPrayerTimes = prayerTimes;
      _lastFetchDate = DateTime.now();

      if (updateCache) {
        await _saveToDiskCache(prayerTimes);
      }

      return prayerTimes;
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  /// Clear all caches
  static void clearCache() {
    _cachedPrayerTimes = null;
    _lastFetchDate = null;
  }

  /// Check if we have cached data
  static bool hasCachedData() {
    return _cachedPrayerTimes != null;
  }
}
