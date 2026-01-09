import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';
import 'package:flutter_application_6/core/services/notification_service.dart';
import 'package:flutter_application_6/core/services/audio_service.dart';
import 'package:flutter_application_6/core/services/background_service.dart';
import 'package:flutter_application_6/core/services/prayer_cache_service.dart';
import 'package:flutter_application_6/veiw/mainpages/homepage1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services in parallel for faster startup
  await Future.wait([
    StorageService.init(),
    NotificationService.init(),
    AudioService.init(),
  ]);

  // Initialize prayer cache (non-blocking)
  PrayerCacheService.init();

  // Request permissions (non-blocking)
  NotificationService.requestPermissions();

  // Background service can be deferred
  BackgroundService.init().then((_) {
    BackgroundService.registerPrayerTimesSync();
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'أذكاري',
      theme: ThemeData(
        fontFamily: "Tajawal",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePge(),
      ),
    );
  }
}
