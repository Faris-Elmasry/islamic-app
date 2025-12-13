import 'package:flutter_application_6/data/datasources/local/azkar_local_datasource.dart';
import 'package:flutter_application_6/data/models/azkar_model.dart';

/// Repository for azkar data
class AzkarRepository {
  final AzkarLocalDataSource _localDataSource;

  AzkarRepository({
    AzkarLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? AzkarLocalDataSource();

  /// Get all azkar data
  Future<AzkarData> getAllAzkar() async {
    return await _localDataSource.loadAzkarData();
  }

  /// Get azkar category by ID
  Future<AzkarCategory?> getAzkarById(int id) async {
    return await _localDataSource.getCategoryById(id);
  }

  /// Get morning azkar
  Future<AzkarCategory?> getMorningAzkar() async {
    return await _localDataSource.getMorningAzkar();
  }

  /// Get evening azkar
  Future<AzkarCategory?> getEveningAzkar() async {
    return await _localDataSource.getEveningAzkar();
  }

  /// Get prayer azkar
  Future<AzkarCategory?> getPrayerAzkar() async {
    return await _localDataSource.getPrayerAzkar();
  }

  /// Get sleep azkar
  Future<AzkarCategory?> getSleepAzkar() async {
    return await _localDataSource.getSleepAzkar();
  }

  /// Get ruqyah
  Future<AzkarCategory?> getRuqyah() async {
    return await _localDataSource.getRuqyah();
  }

  /// Get dua
  Future<AzkarCategory?> getDua() async {
    return await _localDataSource.getDua();
  }

  /// Get random dua for display
  Future<AzkarItem?> getRandomDua() async {
    return await _localDataSource.getRandomDua();
  }
}
