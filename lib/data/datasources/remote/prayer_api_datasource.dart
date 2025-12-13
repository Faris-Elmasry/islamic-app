import 'package:dio/dio.dart';
import 'package:flutter_application_6/core/constants/app_constants.dart';
import 'package:flutter_application_6/data/models/prayer_times_model.dart';

/// Remote data source for prayer times API
class PrayerApiDataSource {
  late final Dio _dio;

  PrayerApiDataSource() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ));
  }

  /// Fetch prayer times for a specific date and location
  Future<PrayerTimesModel> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr =
          '${targetDate.day}-${targetDate.month}-${targetDate.year}';

      final response = await _dio.get(
        '${ApiConstants.prayerTimingsEndpoint}/$dateStr',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 5, // Egyptian General Authority of Survey
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return PrayerTimesModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch prayer times: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch prayer times for a month (for caching)
  Future<List<PrayerTimesModel>> fetchMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    int? month,
    int? year,
  }) async {
    try {
      final now = DateTime.now();
      final targetMonth = month ?? now.month;
      final targetYear = year ?? now.year;

      final response = await _dio.get(
        '${ApiConstants.calendarEndpoint}/$targetYear/$targetMonth',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 5,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final dataList = response.data['data'] as List<dynamic>;
        return dataList.map((day) => PrayerTimesModel.fromJson(day)).toList();
      } else {
        throw Exception('Failed to fetch monthly prayer times');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${error.response?.statusCode}');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
