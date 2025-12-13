import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_application_6/data/models/azkar_model.dart';

/// Local data source for azkar data
class AzkarLocalDataSource {
  static AzkarData? _cachedData;

  /// Load azkar data from local JSON asset
  Future<AzkarData> loadAzkarData() async {
    // Return cached data if available
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('lib/model/azkarsdata.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;
      _cachedData = AzkarData.fromJsonList(jsonList);
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load azkar data: $e');
    }
  }

  /// Get specific category by ID
  Future<AzkarCategory?> getCategoryById(int id) async {
    final data = await loadAzkarData();
    return data.getCategoryById(id);
  }

  /// Get morning azkar
  Future<AzkarCategory?> getMorningAzkar() async {
    final data = await loadAzkarData();
    return data.morningAzkar;
  }

  /// Get evening azkar
  Future<AzkarCategory?> getEveningAzkar() async {
    final data = await loadAzkarData();
    return data.eveningAzkar;
  }

  /// Get prayer azkar
  Future<AzkarCategory?> getPrayerAzkar() async {
    final data = await loadAzkarData();
    return data.prayerAzkar;
  }

  /// Get sleep azkar
  Future<AzkarCategory?> getSleepAzkar() async {
    final data = await loadAzkarData();
    return data.sleepAzkar;
  }

  /// Get ruqyah
  Future<AzkarCategory?> getRuqyah() async {
    final data = await loadAzkarData();
    return data.ruqyah;
  }

  /// Get dua
  Future<AzkarCategory?> getDua() async {
    final data = await loadAzkarData();
    return data.dua;
  }

  /// Get random dua for display
  Future<AzkarItem?> getRandomDua() async {
    final dua = await getDua();
    if (dua == null || dua.items.isEmpty) return null;

    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % dua.items.length;
    return dua.items[randomIndex];
  }

  /// Clear cached data (if needed to reload)
  void clearCache() {
    _cachedData = null;
  }
}
