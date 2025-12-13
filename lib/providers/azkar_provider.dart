import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_6/data/models/azkar_model.dart';
import 'package:flutter_application_6/data/repositories/azkar_repository.dart';

/// Azkar repository provider
final azkarRepositoryProvider = Provider<AzkarRepository>((ref) {
  return AzkarRepository();
});

/// All azkar data provider
final allAzkarProvider = FutureProvider<AzkarData>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getAllAzkar();
});

/// Morning azkar provider
final morningAzkarProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getMorningAzkar();
});

/// Evening azkar provider
final eveningAzkarProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getEveningAzkar();
});

/// Prayer azkar provider
final prayerAzkarProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getPrayerAzkar();
});

/// Sleep azkar provider
final sleepAzkarProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getSleepAzkar();
});

/// Ruqyah provider
final ruqyahProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getRuqyah();
});

/// Dua provider
final duaProvider = FutureProvider<AzkarCategory?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getDua();
});

/// Random dua provider
final randomDuaProvider = FutureProvider<AzkarItem?>((ref) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getRandomDua();
});

/// Generic azkar by ID provider
final azkarByIdProvider =
    FutureProvider.family<AzkarCategory?, int>((ref, id) async {
  final repository = ref.watch(azkarRepositoryProvider);
  return await repository.getAzkarById(id);
});
