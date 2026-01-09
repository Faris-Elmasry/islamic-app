import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';

/// ============================================================================
/// MONTHLY PRAYER TIMES CACHE SERVICE
/// ============================================================================
///
/// Aggressive Caching Strategy:
///
/// 1. MEMORY CACHE (L1) - Instant access (~0ms)
///    - Stores current month's prayer times in RAM
///    - Survives page navigation
///    - Lost on app restart
///
/// 2. DISK CACHE (L2) - Fast access (~10-50ms)
///    - Stores entire month's prayer times in Hive
///    - Survives app restart
///    - Expires after 30 days or location change
///
/// Cache Invalidation Rules:
/// - Location changes (distance > 5km)
/// - New month begins
/// - Cache older than 30 days
/// - User manually refreshes
///
/// API Call Strategy:
/// - Fetch ENTIRE MONTH in single API call
/// - Only call API when cache invalid
/// - Background refresh doesn't block UI
///
/// ============================================================================

class PrayerCacheService {
  static const String _boxName = 'prayer_cache_v2';
  static const String _monthlyDataKey = 'monthly_prayer_data';
  static const String _cacheMetaKey = 'cache_metadata';
  static const int _cacheExpirationDays = 30;
  static const double _locationThresholdKm = 5.0;

  static Box? _box;

  /// L1 Memory Cache - Survives page navigation
  static Map<String, PrayerTimesModel>? _memoryCache;
  static CacheMetadata? _memoryCacheMeta;
  static bool _isInitialized = false;

  /// ==================== INITIALIZATION ====================

  /// Initialize the cache service
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Hive should already be initialized by StorageService
      _box = await Hive.openBox(_boxName);
      await _loadFromDiskToMemory();
      _isInitialized = true;
    } catch (e) {
      // If box fails to open, continue without disk cache
      _isInitialized = true;
    }
  }

  /// Ensure service is initialized
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) await init();
  }

  /// Load disk cache to memory on startup
  static Future<void> _loadFromDiskToMemory() async {
    if (_box == null) return;

    try {
      final metaJson = _box?.get(_cacheMetaKey);
      if (metaJson != null) {
        _memoryCacheMeta = CacheMetadata.fromJson(
          Map<String, dynamic>.from(metaJson),
        );
      }

      final dataJson = _box?.get(_monthlyDataKey);
      if (dataJson != null) {
        _memoryCache = {};
        final Map<dynamic, dynamic> data = dataJson;
        data.forEach((key, value) {
          try {
            _memoryCache![key.toString()] = PrayerTimesModel.fromJson(
              _deepConvertMap(value),
            );
          } catch (e) {
            // Skip corrupted entry
          }
        });
      }
    } catch (e) {
      // Cache corrupted, will be refreshed
      await clearCache();
    }
  }

  /// ==================== CACHE ACCESS ====================

  /// Get prayer times for a specific date (INSTANT if cached)
  /// Returns null if not cached - caller should fetch from API
  static PrayerTimesModel? getPrayerTimesForDate(DateTime date) {
    if (_memoryCache == null) return null;

    final key = _dateToKey(date);
    return _memoryCache![key];
  }

  /// Get today's prayer times (INSTANT)
  static PrayerTimesModel? getTodayPrayerTimes() {
    return getPrayerTimesForDate(DateTime.now());
  }

  /// Get prayer times for date range (for UI preview)
  static List<PrayerTimesModel> getPrayerTimesForRange(
    DateTime start,
    DateTime end,
  ) {
    final result = <PrayerTimesModel>[];
    var current = start;

    while (!current.isAfter(end)) {
      final data = getPrayerTimesForDate(current);
      if (data != null) result.add(data);
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  /// Check if we have valid cache for today
  static bool hasValidCacheForToday() {
    if (_memoryCache == null || _memoryCacheMeta == null) return false;

    final today = DateTime.now();
    final key = _dateToKey(today);

    return _memoryCache!.containsKey(key) && !isCacheExpired();
  }

  /// Check if cache should be refreshed
  static bool shouldRefreshCache() {
    if (_memoryCacheMeta == null) return true;
    return isCacheExpired() || isNewMonth();
  }

  /// ==================== CACHE VALIDATION ====================

  /// Check if cache is expired (older than 30 days)
  static bool isCacheExpired() {
    if (_memoryCacheMeta == null) return true;

    final daysSinceCache =
        DateTime.now().difference(_memoryCacheMeta!.lastFetchTime).inDays;

    return daysSinceCache > _cacheExpirationDays;
  }

  /// Check if it's a new month (cache might be stale)
  static bool isNewMonth() {
    if (_memoryCacheMeta == null) return true;

    final now = DateTime.now();
    return now.year != _memoryCacheMeta!.cachedYear ||
        now.month != _memoryCacheMeta!.cachedMonth;
  }

  /// Check if location changed significantly
  static bool locationChanged(double newLat, double newLong) {
    if (_memoryCacheMeta == null) return true;

    final distance = _calculateDistanceKm(
      _memoryCacheMeta!.latitude,
      _memoryCacheMeta!.longitude,
      newLat,
      newLong,
    );

    return distance > _locationThresholdKm;
  }

  /// ==================== CACHE STORAGE ====================

  /// Store entire month's prayer times (batch save)
  static Future<void> cacheMonthlyPrayerTimes({
    required List<PrayerTimesModel> prayerTimesList,
    required double latitude,
    required double longitude,
    required int month,
    required int year,
  }) async {
    await _ensureInitialized();

    // Update memory cache
    _memoryCache ??= {};

    final dataToStore = <String, dynamic>{};

    for (final prayerTimes in prayerTimesList) {
      // Parse the date from gregorian data
      final day = int.tryParse(prayerTimes.gregorian.day) ?? 1;
      final key =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      _memoryCache![key] = prayerTimes;
      dataToStore[key] = prayerTimes.toJson();
    }

    // Update metadata
    _memoryCacheMeta = CacheMetadata(
      lastFetchTime: DateTime.now(),
      cachedMonth: month,
      cachedYear: year,
      latitude: latitude,
      longitude: longitude,
      version: 2,
    );

    // Persist to disk (non-blocking)
    _saveToDisk(dataToStore);
  }

  /// Save to disk in background
  static Future<void> _saveToDisk(Map<String, dynamic> data) async {
    try {
      await _box?.put(_monthlyDataKey, data);
      await _box?.put(_cacheMetaKey, _memoryCacheMeta?.toJson());
    } catch (e) {
      // Disk save failed, memory cache still works
    }
  }

  /// ==================== CACHE MANAGEMENT ====================

  /// Clear all cache
  static Future<void> clearCache() async {
    _memoryCache = null;
    _memoryCacheMeta = null;
    await _box?.clear();
  }

  /// Get cache metadata (for debugging/UI)
  static CacheMetadata? getCacheMetadata() => _memoryCacheMeta;

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'hasCachedData': _memoryCache != null,
      'cachedDays': _memoryCache?.length ?? 0,
      'cacheMonth': _memoryCacheMeta?.cachedMonth,
      'cacheYear': _memoryCacheMeta?.cachedYear,
      'lastFetch': _memoryCacheMeta?.lastFetchTime.toIso8601String(),
      'isExpired': isCacheExpired(),
      'isNewMonth': isNewMonth(),
    };
  }

  /// ==================== UTILITIES ====================

  /// Convert date to cache key
  static String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate distance between two coordinates (Haversine formula)
  static double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorSin(x + 1.5707963267948966);
  static double _sqrt(double x) => x <= 0 ? 0 : _newtonSqrt(x);
  static double _atan2(double y, double x) {
    if (x > 0) return _taylorAtan(y / x);
    if (x < 0 && y >= 0) return _taylorAtan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _taylorAtan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 1.5707963267948966;
    if (x == 0 && y < 0) return -1.5707963267948966;
    return 0;
  }

  static double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    double result = 0;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }

  static double _newtonSqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _taylorAtan(double x) {
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * 1.5707963267948966 - _taylorAtan(1 / x);
    }
    double result = 0;
    double term = x;
    for (int i = 0; i < 15; i++) {
      result += term / (2 * i + 1) * (i % 2 == 0 ? 1 : -1);
      term *= x * x;
    }
    return result;
  }

  /// Deep convert Map<dynamic, dynamic> to Map<String, dynamic>
  static Map<String, dynamic> _deepConvertMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepConvertMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), _deepConvertList(value));
        }
        return MapEntry(key.toString(), value);
      });
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _deepConvertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) return _deepConvertMap(item);
      if (item is List) return _deepConvertList(item);
      return item;
    }).toList();
  }
}

/// ==================== CACHE METADATA ====================

class CacheMetadata {
  final DateTime lastFetchTime;
  final int cachedMonth;
  final int cachedYear;
  final double latitude;
  final double longitude;
  final int version;

  CacheMetadata({
    required this.lastFetchTime,
    required this.cachedMonth,
    required this.cachedYear,
    required this.latitude,
    required this.longitude,
    this.version = 2,
  });

  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      lastFetchTime: DateTime.parse(json['lastFetchTime']),
      cachedMonth: json['cachedMonth'],
      cachedYear: json['cachedYear'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      version: json['version'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastFetchTime': lastFetchTime.toIso8601String(),
      'cachedMonth': cachedMonth,
      'cachedYear': cachedYear,
      'latitude': latitude,
      'longitude': longitude,
      'version': version,
    };
  }
}
