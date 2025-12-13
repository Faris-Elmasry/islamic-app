import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';
import 'package:flutter_application_6/data/repositories/prayer_repository.dart';

/// Prayer repository provider
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository();
});

/// Prayer times state
class PrayerTimesState {
  final PrayerTimesModel? prayerTimes;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const PrayerTimesState({
    this.prayerTimes,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  PrayerTimesState copyWith({
    PrayerTimesModel? prayerTimes,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return PrayerTimesState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Prayer times notifier
class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final PrayerRepository _repository;

  PrayerTimesNotifier(this._repository) : super(const PrayerTimesState()) {
    loadPrayerTimes();
  }

  /// Load prayer times (cache-first)
  Future<void> loadPrayerTimes({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prayerTimes =
          await _repository.getPrayerTimes(forceRefresh: forceRefresh);
      state = state.copyWith(
        prayerTimes: prayerTimes,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      // Schedule notifications after loading
      await _repository.scheduleNotifications();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh prayer times
  Future<void> refresh() async {
    await loadPrayerTimes(forceRefresh: true);
  }

  /// Get next prayer
  MapEntry<String, DateTime>? get nextPrayer {
    return state.prayerTimes?.getNextPrayer();
  }
}

/// Prayer times provider
final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  final repository = ref.watch(prayerRepositoryProvider);
  return PrayerTimesNotifier(repository);
});

/// Next prayer provider (derived from prayer times)
final nextPrayerProvider = Provider<MapEntry<String, DateTime>?>((ref) {
  final state = ref.watch(prayerTimesProvider);
  return state.prayerTimes?.getNextPrayer();
});

/// Countdown provider for next prayer
final countdownProvider = StreamProvider<Duration>((ref) async* {
  while (true) {
    final nextPrayer = ref.read(nextPrayerProvider);
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
