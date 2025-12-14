import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';

/// Available Arabic fonts for azkar
class ArabicFont {
  final String name;
  final String displayName;
  final String? description;

  const ArabicFont({
    required this.name,
    required this.displayName,
    this.description,
  });
}

/// Available Arabic fonts
class AvailableFonts {
  static const List<ArabicFont> fonts = [
    ArabicFont(
      name: 'Tajawal',
      displayName: 'تجول',
      description: 'خط واضح وسهل القراءة',
    ),
    ArabicFont(
      name: 'Amiri',
      displayName: 'أميري',
      description: 'خط تقليدي أنيق',
    ),
    ArabicFont(
      name: 'Cairo',
      displayName: 'القاهرة',
      description: 'خط عصري ومميز',
    ),
    ArabicFont(
      name: 'Scheherazade',
      displayName: 'شهرزاد',
      description: 'خط نسخ تقليدي',
    ),
    ArabicFont(
      name: 'Lateef',
      displayName: 'لطيف',
      description: 'خط نسخ بسيط',
    ),
    ArabicFont(
      name: 'ReemKufi',
      displayName: 'ريم كوفي',
      description: 'خط كوفي حديث',
    ),
  ];

  static ArabicFont getFontByName(String name) {
    return fonts.firstWhere(
      (font) => font.name == name,
      orElse: () => fonts[0],
    );
  }
}

/// Font settings state
class FontSettings {
  final String fontFamily;
  final double fontSize;

  FontSettings({
    required this.fontFamily,
    required this.fontSize,
  });

  FontSettings copyWith({
    String? fontFamily,
    double? fontSize,
  }) {
    return FontSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

/// Font settings provider
class FontSettingsNotifier extends StateNotifier<FontSettings> {
  FontSettingsNotifier()
      : super(
          FontSettings(
            fontFamily: StorageService.getAzkarFontFamily(),
            fontSize: StorageService.getAzkarFontSize(),
          ),
        );

  /// Update font family
  Future<void> setFontFamily(String fontFamily) async {
    await StorageService.setAzkarFontFamily(fontFamily);
    state = state.copyWith(fontFamily: fontFamily);
  }

  /// Update font size
  Future<void> setFontSize(double fontSize) async {
    await StorageService.setAzkarFontSize(fontSize);
    state = state.copyWith(fontSize: fontSize);
  }

  /// Increase font size
  Future<void> increaseFontSize() async {
    if (state.fontSize < 40) {
      await setFontSize(state.fontSize + 2);
    }
  }

  /// Decrease font size
  Future<void> decreaseFontSize() async {
    if (state.fontSize > 12) {
      await setFontSize(state.fontSize - 2);
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await setFontFamily('Tajawal');
    await setFontSize(18.0);
  }
}

/// Font settings provider instance
final fontSettingsProvider =
    StateNotifierProvider<FontSettingsNotifier, FontSettings>((ref) {
  return FontSettingsNotifier();
});
