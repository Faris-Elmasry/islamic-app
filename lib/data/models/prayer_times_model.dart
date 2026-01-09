/// Prayer times model with all prayer data
class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String midnight;
  final HijriDate hijri;
  final GregorianDate gregorian;
  final Meta meta;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.hijri,
    required this.gregorian,
    required this.meta,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    return PrayerTimesModel(
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      midnight: _cleanTime(timings['Midnight']),
      hijri: HijriDate.fromJson(date['hijri']),
      gregorian: GregorianDate.fromJson(date['gregorian']),
      meta: Meta.fromJson(meta),
    );
  }

  /// Remove timezone info from time string (e.g., "05:30 (EET)" -> "05:30")
  static String _cleanTime(String? time) {
    if (time == null) return '00:00';
    return time.split(' ').first;
  }

  Map<String, dynamic> toJson() {
    return {
      'timings': {
        'Fajr': fajr,
        'Sunrise': sunrise,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
        'Midnight': midnight,
      },
      'date': {
        'hijri': hijri.toJson(),
        'gregorian': gregorian.toJson(),
      },
      'meta': meta.toJson(),
    };
  }

  /// Get prayer time as DateTime for today
  DateTime getPrayerDateTime(String prayer) {
    final now = DateTime.now();
    String timeStr;

    switch (prayer.toLowerCase()) {
      case 'fajr':
        timeStr = fajr;
        break;
      case 'sunrise':
        timeStr = sunrise;
        break;
      case 'dhuhr':
        timeStr = dhuhr;
        break;
      case 'asr':
        timeStr = asr;
        break;
      case 'maghrib':
        timeStr = maghrib;
        break;
      case 'isha':
        timeStr = isha;
        break;
      default:
        return now;
    }

    final parts = timeStr.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Get all prayer times as Map<String, DateTime>
  Map<String, DateTime> getAllPrayerDateTimes() {
    return {
      'Fajr': getPrayerDateTime('fajr'),
      'Dhuhr': getPrayerDateTime('dhuhr'),
      'Asr': getPrayerDateTime('asr'),
      'Maghrib': getPrayerDateTime('maghrib'),
      'Isha': getPrayerDateTime('isha'),
    };
  }

  /// Get next prayer name and time
  MapEntry<String, DateTime>? getNextPrayer() {
    final now = DateTime.now();
    final prayers = getAllPrayerDateTimes();

    for (final entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return entry;
      }
    }

    // If all prayers passed, return tomorrow's Fajr
    final tomorrowFajr = getPrayerDateTime('fajr').add(const Duration(days: 1));
    return MapEntry('Fajr', tomorrowFajr);
  }
}

/// Hijri date model
class HijriDate {
  final String date;
  final String day;
  final String month;
  final String year;
  final HijriMonth monthInfo;
  final String weekday;
  final String format;

  HijriDate({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.monthInfo,
    required this.weekday,
    required this.format,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      month: json['month']?['number']?.toString() ?? '',
      year: json['year'] ?? '',
      monthInfo: HijriMonth.fromJson(json['month'] ?? {}),
      weekday: json['weekday']?['ar'] ??
          _getArabicWeekday(json['weekday']?['en'] ?? ''),
      format: json['format'] ?? '',
    );
  }

  static String _getArabicWeekday(String en) {
    const weekdays = {
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
    };
    return weekdays[en] ?? en;
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'month': monthInfo.toJson(),
      'year': year,
      'weekday': {'ar': weekday},
      'format': format,
    };
  }

  String get formattedDate => '$day ${monthInfo.ar} $year هـ';
}

/// Hijri month info
class HijriMonth {
  final int number;
  final String en;
  final String ar;

  HijriMonth({
    required this.number,
    required this.en,
    required this.ar,
  });

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'] ?? 1,
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'en': en,
      'ar': ar,
    };
  }
}

/// Gregorian date model
class GregorianDate {
  final String date;
  final String day;
  final String month; // Month name (e.g., "January")
  final String year;
  final GregorianWeekday weekday;
  final String format;

  GregorianDate({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.weekday,
    required this.format,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      month: json['month']?['en'] ?? json['month']?['number']?.toString() ?? '',
      year: json['year'] ?? '',
      weekday: GregorianWeekday.fromJson(json['weekday'] ?? {}),
      format: json['format'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'month': {'en': month},
      'year': year,
      'weekday': weekday.toJson(),
      'format': format,
    };
  }
}

/// Gregorian weekday info
class GregorianWeekday {
  final String en;
  final String ar;

  GregorianWeekday({required this.en, required this.ar});

  factory GregorianWeekday.fromJson(Map<String, dynamic> json) {
    return GregorianWeekday(
      en: json['en'] ?? '',
      ar: _getArabicWeekday(json['en'] ?? ''),
    );
  }

  static String _getArabicWeekday(String en) {
    const weekdays = {
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
    };
    return weekdays[en] ?? en;
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'ar': ar};
  }
}

/// Meta information
class Meta {
  final double latitude;
  final double longitude;
  final String timezone;
  final String method;

  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.method,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timezone: json['timezone'] ?? '',
      method: json['method']?['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'method': {'name': method},
    };
  }
}
