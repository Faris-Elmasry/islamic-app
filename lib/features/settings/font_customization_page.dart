import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/providers/font_settings_provider.dart';

/// Font customization page for azkar
class FontCustomizationPage extends ConsumerWidget {
  const FontCustomizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSettings = ref.watch(fontSettingsProvider);
    final fontNotifier = ref.read(fontSettingsProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          title: const Text(
            'تخصيص الخط',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة الضبط',
              onPressed: () async {
                await fontNotifier.resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم إعادة الضبط إلى الإعدادات الافتراضية',
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview card
            _buildPreviewCard(fontSettings),
            const SizedBox(height: 24),

            // Font family selector
            _buildFontFamilySection(fontSettings, fontNotifier, context),
            const SizedBox(height: 24),

            // Font size slider
            _buildFontSizeSection(fontSettings, fontNotifier),
          ],
        ),
      ),
    );
  }

  /// Build preview card
  Widget _buildPreviewCard(FontSettings fontSettings) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'معاينة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n'
                'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: fontSettings.fontFamily,
                  fontSize: fontSettings.fontSize,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'الخط: ${AvailableFonts.getFontByName(fontSettings.fontFamily).displayName} • الحجم: ${fontSettings.fontSize.toInt()}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build font family section
  Widget _buildFontFamilySection(
    FontSettings fontSettings,
    FontSettingsNotifier fontNotifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.font_download, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'نوع الخط',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...AvailableFonts.fonts.map((font) {
          final isSelected = fontSettings.fontFamily == font.name;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () async {
                await fontNotifier.setFontFamily(font.name);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.teal.withOpacity(0.9)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.teal : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.white : Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            font.displayName,
                            style: TextStyle(
                              fontFamily: font.name,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (font.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              font.description!,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      'الله أكبر',
                      style: TextStyle(
                        fontFamily: font.name,
                        fontSize: 18,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build font size section
  Widget _buildFontSizeSection(
    FontSettings fontSettings,
    FontSettingsNotifier fontNotifier,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_size, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'حجم الخط',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fontSettings.fontSize.toInt()}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: fontNotifier.decreaseFontSize,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.teal,
                  iconSize: 32,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.teal,
                      inactiveTrackColor: Colors.teal.withOpacity(0.2),
                      thumbColor: Colors.teal,
                      overlayColor: Colors.teal.withOpacity(0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: fontSettings.fontSize,
                      min: 12,
                      max: 40,
                      divisions: 14,
                      label: '${fontSettings.fontSize.toInt()}',
                      onChanged: (value) {
                        fontNotifier.setFontSize(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: fontNotifier.increaseFontSize,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.teal,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'صغير (12)',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'كبير (40)',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
