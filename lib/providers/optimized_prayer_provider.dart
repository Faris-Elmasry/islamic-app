import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';
import 'package:flutter_application_6/data/repositories/optimized_prayer_repository.dart';

/// ============================================================================
/// OPTIMIZED PRAYER PROVIDER - STATE MANAGEMENT WITH INSTANT ACCESS
/// ============================================================================
///
/// Key Features:
/// - State persists across navigation (no reload on page return)
/// - Preloading support for instant page display
/// - Background refresh without UI blocking
/// - Countdown timer with efficient updates
///
/// Usage:
/// ```dart
/// // In widget
/// final state = ref.watch(optimizedPrayerProvider);
/// if (state.isReady) {
///   // Display data immediately
/// }
/// ```
///
/// ============================================================================

/// Repository provider (singleton)
final optimizedPrayerRepositoryProvider =
    Provider<OptimizedPrayerRepository>((ref) {
  return OptimizedPrayerRepository();
});

/// ==================== STATE CLASS ====================

class OptimizedPrayerState {
  final PrayerTimesModel? prayerTimes;
  final bool isLoading;
  final bool isRefreshing; // Background refresh indicator
  final String? error;
  final DateTime? lastUpdated;

  const OptimizedPrayerState({
    this.prayerTimes,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  /// Check if data is ready for display
  bool get isReady => prayerTimes != null;

  /// Check if should show loading spinner
  bool get showLoading => isLoading && prayerTimes == null;

  /// Check if should show error
  bool get showError => error != null && prayerTimes == null;

  OptimizedPrayerState copyWith({
    PrayerTimesModel? prayerTimes,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return OptimizedPrayerState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// ==================== NOTIFIER CLASS ====================

class OptimizedPrayerNotifier extends StateNotifier<OptimizedPrayerState> {
  final OptimizedPrayerRepository _repository;
  Timer? _countdownTimer;

  OptimizedPrayerNotifier(this._repository)
      : super(const OptimizedPrayerState()) {
    _initializeData();
  }

  /// Initialize data on creation
  Future<void> _initializeData() async {
    // First try to get cached data instantly
    if (OptimizedPrayerRepository.isDataReady) {
      await _loadFromCache();
    } else {
      await loadPrayerTimes();
    }
  }

  /// Load from cache (instant)
  Future<void> _loadFromCache() async {
    try {
      final prayerTimes = await _repository.getTodayPrayerTimes();
      state = state.copyWith(
        prayerTimes: prayerTimes,
        isLoading: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );
    } catch (e) {
      // Cache load failed, try full load
      await loadPrayerTimes();
    }
  }

  /// Load prayer times (with loading state)
  Future<void> loadPrayerTimes({bool forceRefresh = false}) async {
    // Don't show loading if we have cached data
    if (state.prayerTimes == null) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isRefreshing: true);
    }

    try {
      final prayerTimes = await _repository.getTodayPrayerTimes(
        forceRefresh: forceRefresh,
      );

      state = state.copyWith(
        prayerTimes: prayerTimes,
        isLoading: false,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
        clearError: true,
      );

      // Schedule notifications
      await _repository.scheduleNotifications();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// Manual refresh
  Future<void> refresh() async {
    await loadPrayerTimes(forceRefresh: true);
  }

  /// Get next prayer info
  MapEntry<String, DateTime>? get nextPrayer {
    return state.prayerTimes?.getNextPrayer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

/// ==================== PROVIDERS ====================

/// Main prayer times provider
final optimizedPrayerProvider =
    StateNotifierProvider<OptimizedPrayerNotifier, OptimizedPrayerState>((ref) {
  final repository = ref.watch(optimizedPrayerRepositoryProvider);
  return OptimizedPrayerNotifier(repository);
});

/// Next prayer derived provider
final nextPrayerProvider2 = Provider<MapEntry<String, DateTime>?>((ref) {
  final state = ref.watch(optimizedPrayerProvider);
  return state.prayerTimes?.getNextPrayer();
});

/// Countdown stream provider (efficient 1-second updates)
final countdownStreamProvider = StreamProvider<Duration>((ref) async* {
  while (true) {
    final nextPrayer = ref.read(nextPrayerProvider2);
    if (nextPrayer != null) {
      final now = DateTime.now();
      final diff = nextPrayer.value.difference(now);
      yield diff.isNegative ? Duration.zero : diff;
    } else {
      yield Duration.zero;
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});

/// Cache stats provider (for debugging)
final cacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(optimizedPrayerRepositoryProvider);
  return repository.getCacheStats();
});

/// ==================== PRELOADING HELPER ====================

/// Call this in main.dart to preload prayer data
Future<void> preloadPrayerData() async {
  await OptimizedPrayerRepository.preloadPrayerTimes();
}
