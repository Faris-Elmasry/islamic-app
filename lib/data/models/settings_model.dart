/// Settings model for app preferences
class SettingsModel {
  final bool notificationsEnabled;
  final String selectedAdhanId;
  final Map<String, bool> prayerNotifications;
  final bool morningAzkarReminder;
  final bool eveningAzkarReminder;
  final int tasbihCount;

  SettingsModel({
    this.notificationsEnabled = true,
    this.selectedAdhanId = 'adhan_makkah',
    Map<String, bool>? prayerNotifications,
    this.morningAzkarReminder = true,
    this.eveningAzkarReminder = true,
    this.tasbihCount = 0,
  }) : prayerNotifications = prayerNotifications ??
            {
              'Fajr': true,
              'Dhuhr': true,
              'Asr': true,
              'Maghrib': true,
              'Isha': true,
            };

  SettingsModel copyWith({
    bool? notificationsEnabled,
    String? selectedAdhanId,
    Map<String, bool>? prayerNotifications,
    bool? morningAzkarReminder,
    bool? eveningAzkarReminder,
    int? tasbihCount,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedAdhanId: selectedAdhanId ?? this.selectedAdhanId,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      morningAzkarReminder: morningAzkarReminder ?? this.morningAzkarReminder,
      eveningAzkarReminder: eveningAzkarReminder ?? this.eveningAzkarReminder,
      tasbihCount: tasbihCount ?? this.tasbihCount,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      selectedAdhanId: json['selectedAdhanId'] ?? 'adhan_makkah',
      prayerNotifications:
          Map<String, bool>.from(json['prayerNotifications'] ?? {}),
      morningAzkarReminder: json['morningAzkarReminder'] ?? true,
      eveningAzkarReminder: json['eveningAzkarReminder'] ?? true,
      tasbihCount: json['tasbihCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'selectedAdhanId': selectedAdhanId,
      'prayerNotifications': prayerNotifications,
      'morningAzkarReminder': morningAzkarReminder,
      'eveningAzkarReminder': eveningAzkarReminder,
      'tasbihCount': tasbihCount,
    };
  }
}
