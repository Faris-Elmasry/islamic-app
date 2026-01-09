import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/features/qibla/domain/entities/qibla_direction.dart';
import 'package:flutter_application_6/features/qibla/domain/repositories/i_qibla_repository.dart';
import 'package:flutter_application_6/features/qibla/data/repositories/qibla_repository.dart';

/// Qibla Repository Provider
///
/// Provides singleton instance of QiblaRepository
final qiblaRepositoryProvider = Provider<IQiblaRepository>((ref) {
  final repository = QiblaRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// Qibla Direction Stream Provider
///
/// Streams real-time Qibla direction updates
final qiblaDirectionStreamProvider = StreamProvider<QiblaDirection>((ref) {
  final repository = ref.watch(qiblaRepositoryProvider);
  return repository.getQiblaDirectionStream();
});

/// Location Permission Status Provider
final locationPermissionProvider =
    FutureProvider<LocationPermissionStatus>((ref) async {
  final repository = ref.watch(qiblaRepositoryProvider);
  return repository.getLocationPermissionStatus();
});

/// Compass Support Provider
final compassSupportProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(qiblaRepositoryProvider);
  return repository.hasCompassSensor();
});

/// Location Service Status Provider
final locationServiceProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(qiblaRepositoryProvider);
  return repository.isLocationServiceEnabled();
});

/// Qibla State for managing UI state
enum QiblaState {
  initial,
  loading,
  success,
  permissionDenied,
  locationDisabled,
  compassUnavailable,
  error,
}

/// Qibla State Notifier
///
/// Manages the overall state of the Qibla feature
class QiblaStateNotifier extends StateNotifier<QiblaState> {
  final IQiblaRepository _repository;

  QiblaStateNotifier(this._repository) : super(QiblaState.initial);

  Future<void> initialize() async {
    state = QiblaState.loading;

    try {
      // Check location service
      final locationEnabled = await _repository.isLocationServiceEnabled();
      if (!locationEnabled) {
        state = QiblaState.locationDisabled;
        return;
      }

      // Check permission
      final permission = await _repository.getLocationPermissionStatus();
      if (permission == LocationPermissionStatus.denied ||
          permission == LocationPermissionStatus.deniedForever) {
        // Try to request permission
        final granted = await _repository.requestLocationPermission();
        if (!granted) {
          state = QiblaState.permissionDenied;
          return;
        }
      }

      // Check compass
      final hasCompass = await _repository.hasCompassSensor();
      if (!hasCompass) {
        state = QiblaState.compassUnavailable;
        return;
      }

      state = QiblaState.success;
    } catch (e) {
      state = QiblaState.error;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final granted = await _repository.requestLocationPermission();
      if (granted) {
        await initialize();
      }
      return granted;
    } catch (e) {
      return false;
    }
  }
}

/// Qibla State Provider
final qiblaStateProvider =
    StateNotifierProvider<QiblaStateNotifier, QiblaState>((ref) {
  final repository = ref.watch(qiblaRepositoryProvider);
  return QiblaStateNotifier(repository);
});
