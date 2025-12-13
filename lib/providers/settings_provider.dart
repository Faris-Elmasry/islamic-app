import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/core/constants/adhan_options.dart';
import 'package:flutter_application_6/core/services/audio_service.dart';
import 'package:flutter_application_6/core/services/notification_service.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';
import 'package:flutter_application_6/data/models/settings_model.dart';

/// Settings state notifier
class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel()) {
    _loadSettings();
  }

  /// Load settings from storage
  void _loadSettings() {
    state = SettingsModel(
      notificationsEnabled: StorageService.isNotificationEnabled(),
      selectedAdhanId: StorageService.getSelectedAdhan(),
      prayerNotifications: StorageService.getPrayerNotificationSettings(),
      tasbihCount: StorageService.getTasbihCounter(),
      morningAzkarReminder: StorageService.getMorningAzkarReminder(),
      eveningAzkarReminder: StorageService.getEveningAzkarReminder(),
    );
  }

  /// Toggle notifications enabled
  Future<void> toggleNotifications(bool enabled) async {
    await StorageService.setNotificationEnabled(enabled);
    state = state.copyWith(notificationsEnabled: enabled);

    if (!enabled) {
      await NotificationService.cancelAllPrayerNotifications();
    }
  }

  /// Set selected adhan
  Future<void> setSelectedAdhan(String adhanId) async {
    await StorageService.setSelectedAdhan(adhanId);
    state = state.copyWith(selectedAdhanId: adhanId);
  }

  /// Toggle prayer notification
  Future<void> togglePrayerNotification(String prayer, bool enabled) async {
    await StorageService.setPrayerNotificationSetting(prayer, enabled);
    final newSettings = Map<String, bool>.from(state.prayerNotifications);
    newSettings[prayer] = enabled;
    state = state.copyWith(prayerNotifications: newSettings);
  }

  /// Update tasbih counter
  Future<void> setTasbihCount(int count) async {
    await StorageService.setTasbihCounter(count);
    state = state.copyWith(tasbihCount: count);
  }

  /// Increment tasbih counter
  Future<void> incrementTasbih() async {
    final newCount = state.tasbihCount + 1;
    await setTasbihCount(newCount);
  }

  /// Reset tasbih counter
  Future<void> resetTasbih() async {
    await setTasbihCount(0);
  }

  /// Preview adhan sound
  Future<bool> previewAdhan(String adhanId) async {
    return await AudioService.previewAdhan(adhanId);
  }

  /// Stop adhan preview
  Future<void> stopAdhanPreview() async {
    await AudioService.stop();
  }

  /// Toggle morning azkar reminder
  Future<void> toggleMorningAzkarReminder(bool enabled) async {
    await StorageService.setMorningAzkarReminder(enabled);
    state = state.copyWith(morningAzkarReminder: enabled);
  }

  /// Toggle evening azkar reminder
  Future<void> toggleEveningAzkarReminder(bool enabled) async {
    await StorageService.setEveningAzkarReminder(enabled);
    state = state.copyWith(eveningAzkarReminder: enabled);
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

/// Selected adhan provider (derived)
final selectedAdhanProvider = Provider<AdhanOption>((ref) {
  final settings = ref.watch(settingsProvider);
  return AdhanOptions.getById(settings.selectedAdhanId) ??
      AdhanOptions.defaultAdhan;
});

/// Notifications enabled provider (derived)
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.notificationsEnabled;
});

/// Tasbih count provider (derived)
final tasbihCountProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.tasbihCount;
});

/// Adhan options provider
final adhanOptionsProvider = Provider<List<AdhanOption>>((ref) {
  return AdhanOptions.options;
});
