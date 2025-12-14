import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/core/constants/app_constants.dart';
import 'package:flutter_application_6/features/settings/adhan_selector_page.dart';
import 'package:flutter_application_6/features/settings/font_customization_page.dart';
import 'package:flutter_application_6/providers/settings_provider.dart';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final selectedAdhan = ref.watch(selectedAdhanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notifications Section
            _buildSectionHeader('الإشعارات'),
            _buildCard([
              SwitchListTile(
                title: const Text(
                  'تفعيل الإشعارات',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                ),
                subtitle: const Text(
                  'إشعارات مواقيت الصلاة',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                ),
                value: settings.notificationsEnabled,
                activeColor: Colors.teal,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .toggleNotifications(value);
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Adhan Sound Section
            _buildSectionHeader('صوت الأذان'),
            _buildCard([
              ListTile(
                title: const Text(
                  'اختر صوت الأذان',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                ),
                subtitle: Text(
                  selectedAdhan.nameAr,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: Colors.teal.shade700,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdhanSelectorPage(),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Font Customization Section
            _buildSectionHeader('تخصيص الخط'),
            _buildCard([
              ListTile(
                leading: const Icon(Icons.font_download, color: Colors.teal),
                title: const Text(
                  'تخصيص خط الأذكار',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                ),
                subtitle: const Text(
                  'اختر نوع الخط وحجمه',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FontCustomizationPage(),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Prayer Notifications Section
            _buildSectionHeader('إشعارات الصلوات'),
            _buildCard([
              ...AppConstants.prayerNames.entries.map((entry) {
                if (entry.key == 'Sunrise') return const SizedBox.shrink();
                return SwitchListTile(
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                  ),
                  value: settings.prayerNotifications[entry.key] ?? true,
                  activeColor: Colors.teal,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .togglePrayerNotification(entry.key, value);
                        }
                      : null,
                );
              }),
            ]),

            const SizedBox(height: 16),

            // Azkar Reminders Section
            _buildSectionHeader('تذكير الأذكار'),
            _buildCard([
              SwitchListTile(
                title: const Text(
                  'أذكار الصباح',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                ),
                subtitle: const Text(
                  'بعد صلاة الفجر',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                ),
                value: settings.morningAzkarReminder,
                activeColor: Colors.teal,
                onChanged: settings.notificationsEnabled
                    ? (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleMorningAzkarReminder(value);
                      }
                    : null,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(
                  'أذكار المساء',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
                ),
                subtitle: const Text(
                  'بعد صلاة العصر',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                ),
                value: settings.eveningAzkarReminder,
                activeColor: Colors.teal,
                onChanged: settings.notificationsEnabled
                    ? (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleEveningAzkarReminder(value);
                      }
                    : null,
              ),
            ]),

            const SizedBox(height: 24),

            // App Info
            Center(
              child: Text(
                'أذكاري - الإصدار ${AppConstants.appVersion}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children
            .where((w) => w is! SizedBox || (w as SizedBox).height != 0)
            .toList(),
      ),
    );
  }
}
