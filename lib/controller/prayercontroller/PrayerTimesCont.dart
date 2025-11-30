import 'dart:convert';

import 'package:flutter_application_6/model/prayermodel/PrayerTimes.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

class PrayerTimesController {
  static double? pLat;
  static double? pLong;

  Future<AzkarApp> fetchPrayerTimesByLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    pLat = position.latitude;
    pLong = position.longitude;

    String date = DateTime.now().toIso8601String();

    final response = await http.get(
      Uri.parse(
          "http://api.aladhan.com/v1/timings/$date?latitude=$pLat&longitude=$pLong"),
    );

    // print('Response Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return AzkarApp.fromJson(data);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
