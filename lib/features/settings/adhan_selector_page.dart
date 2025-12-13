import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/core/constants/adhan_options.dart';
import 'package:flutter_application_6/providers/settings_provider.dart';

/// Adhan sound selector page
class AdhanSelectorPage extends ConsumerStatefulWidget {
  const AdhanSelectorPage({super.key});

  @override
  ConsumerState<AdhanSelectorPage> createState() => _AdhanSelectorPageState();
}

class _AdhanSelectorPageState extends ConsumerState<AdhanSelectorPage> {
  String? _playingId;

  @override
  void dispose() {
    // Stop any playing audio when leaving the page
    ref.read(settingsProvider.notifier).stopAdhanPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final adhanOptions = ref.watch(adhanOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختر صوت الأذان',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adhanOptions.length,
          itemBuilder: (context, index) {
            final adhan = adhanOptions[index];
            final isSelected = settings.selectedAdhanId == adhan.id;
            final isPlaying = _playingId == adhan.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isSelected ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.teal : Colors.transparent,
                  width: 2,
                ),
              ),
              child: InkWell(
                onTap: () => _selectAdhan(adhan.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Radio indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.teal,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Adhan info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adhan.nameAr,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.teal.shade800
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adhan.muezzin,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play/Stop button
                      IconButton(
                        onPressed: () => _togglePlayback(adhan.id),
                        icon: Icon(
                          isPlaying
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_rounded,
                          size: 40,
                          color: isPlaying ? Colors.red : Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectAdhan(String adhanId) async {
    await ref.read(settingsProvider.notifier).setSelectedAdhan(adhanId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تغيير صوت الأذان',
            style: TextStyle(fontFamily: 'Tajawal'),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future<void> _togglePlayback(String adhanId) async {
    if (_playingId == adhanId) {
      // Stop playing
      await ref.read(settingsProvider.notifier).stopAdhanPreview();
      setState(() => _playingId = null);
    } else {
      // Stop any current playback and play new one
      await ref.read(settingsProvider.notifier).stopAdhanPreview();
      setState(() => _playingId = adhanId);

      final success =
          await ref.read(settingsProvider.notifier).previewAdhan(adhanId);

      if (!success && mounted) {
        // Show error message if audio file not found
        setState(() => _playingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'ملف الصوت غير موجود. يرجى إضافة ملفات MP3 إلى مجلد assets/audio/',
              style: TextStyle(fontFamily: 'Tajawal'),
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: 'حسناً',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }

      // Auto-stop after preview duration
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _playingId == adhanId) {
          setState(() => _playingId = null);
        }
      });
    }
  }
}
