import 'package:dio/dio.dart';
import 'package:flutter_application_6/model/prayermodel/PrayerTimes.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesController {
  static double? pLat;
  static double? pLong;
  final Dio _dio = Dio();

  Future<AzkarApp> fetchPrayerTimesByLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    pLat = position.latitude;
    pLong = position.longitude;

    String date = DateTime.now().toIso8601String();

    final response = await _dio.get(
      "https://api.aladhan.com/v1/timings/$date",
      queryParameters: {
        'latitude': pLat,
        'longitude': pLong,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return AzkarApp.fromJson(data);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
