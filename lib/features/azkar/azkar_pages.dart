import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/providers/azkar_provider.dart';
import 'package:flutter_application_6/shared/widgets/azkar_list_widget.dart';

/// Morning Azkar Page using Riverpod
class MorningAzkarPage extends ConsumerWidget {
  const MorningAzkarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(morningAzkarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكار الصباح',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(morningAzkarProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage:
                'lib/assets/pngtree-early-morning-sun-background-template-image_161619.jpg',
          );
        },
      ),
    );
  }
}

/// Evening Azkar Page using Riverpod
class EveningAzkarPage extends ConsumerWidget {
  const EveningAzkarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(eveningAzkarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكار المساء',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(eveningAzkarProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage: 'lib/assets/evining.jpg',
          );
        },
      ),
    );
  }
}

/// Prayer Azkar Page using Riverpod
class PrayerAzkarPage extends ConsumerWidget {
  const PrayerAzkarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(prayerAzkarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكار الصلاة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(prayerAzkarProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage: 'lib/assets/mosque.jpg',
          );
        },
      ),
    );
  }
}

/// Sleep Azkar Page using Riverpod
class SleepAzkarPage extends ConsumerWidget {
  const SleepAzkarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(sleepAzkarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكار النوم',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(sleepAzkarProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage: 'lib/assets/sleep.jpg',
          );
        },
      ),
    );
  }
}

/// Ruqyah Page using Riverpod
class RuqyahPage extends ConsumerWidget {
  const RuqyahPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(ruqyahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الرقية الشرعية',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(ruqyahProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage: 'lib/assets/roqia.jpg',
          );
        },
      ),
    );
  }
}

/// Dua Page using Riverpod
class DuaPage extends ConsumerWidget {
  const DuaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final azkarAsync = ref.watch(duaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أدعية متنوعة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: azkarAsync.when(
        loading: () => const AzkarLoadingWidget(),
        error: (error, stack) => AzkarErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(duaProvider),
        ),
        data: (category) {
          if (category == null) {
            return const AzkarErrorWidget(error: 'لا توجد بيانات');
          }
          return AzkarListWidget(
            category: category,
            backgroundImage: 'lib/assets/do3aa.jpg',
          );
        },
      ),
    );
  }
}
