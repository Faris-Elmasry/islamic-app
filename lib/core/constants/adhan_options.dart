/// Available Adhan sound options
class AdhanOption {
  final String id;
  final String nameAr;
  final String nameEn;
  final String assetPath;
  final String muezzin;

  const AdhanOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.assetPath,
    required this.muezzin,
  });
}

/// List of available Adhan sounds
class AdhanOptions {
  AdhanOptions._();

  static const List<AdhanOption> options = [
    AdhanOption(
      id: 'adhan_makkah',
      nameAr: 'أذان مكة المكرمة',
      nameEn: 'Makkah Adhan',
      assetPath: 'assets/audio/adhan_makkah.mp3',
      muezzin: 'الحرم المكي',
    ),
    AdhanOption(
      id: 'adhan_madinah',
      nameAr: 'أذان المدينة المنورة',
      nameEn: 'Madinah Adhan',
      assetPath: 'assets/audio/adhan_madinah.mp3',
      muezzin: 'الحرم المدني',
    ),
    AdhanOption(
      id: 'adhan_alaqsa',
      nameAr: 'أذان المسجد الأقصى',
      nameEn: 'Al-Aqsa Adhan',
      assetPath: 'assets/audio/adhan_alaqsa.mp3',
      muezzin: 'المسجد الأقصى',
    ),
    AdhanOption(
      id: 'adhan_mishary',
      nameAr: 'أذان مشاري العفاسي',
      nameEn: 'Mishary Alafasy Adhan',
      assetPath: 'assets/audio/adhan_mishary.mp3',
      muezzin: 'مشاري العفاسي',
    ),
  ];

  /// Get adhan option by ID
  static AdhanOption? getById(String id) {
    try {
      return options.firstWhere((option) => option.id == id);
    } catch (_) {
      return options.first; // Return default if not found
    }
  }

  /// Get default adhan
  static AdhanOption get defaultAdhan => options.first;
}
