import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/controller/prayercontroller/PrayerTimesCont.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/model/prayermodel/PrayerTimes.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesController _controller = PrayerTimesController();
  AzkarApp? _prayerTimes;
  StreamController<Duration>? _remainingTimeStreamController;
  Timer? _timer;
  String nextPrayerName = '';
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  var randomDoaa;
  int selectedDoaaIndex = 0;
  bool isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _remainingTimeStreamController = StreamController<Duration>.broadcast();
    _loadPrayerTimes();
    _loadDoaa();
  }

  /// Load prayer times with cache-first strategy
  Future<void> _loadPrayerTimes() async {
    try {
      // This returns cached data instantly if available
      final prayerTimes = await _controller.fetchPrayerTimesByLocation();

      if (mounted && !_isDisposed) {
        setState(() {
          _prayerTimes = prayerTimes;
          isLoading = false;
          _errorMessage = null;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Load doaa in background (non-blocking)
  Future<void> _loadDoaa() async {
    try {
      items = await remoteJson.readJson();
      if (items != null) {
        for (var element in items!) {
          if (element["id"] == 6) {
            if (mounted && !_isDisposed) {
              setState(() {
                randomDoaa = element["array"];
                selectedDoaaIndex = Random().nextInt(randomDoaa.length);
              });
            }
            break;
          }
        }
      }
    } catch (e) {
      // Silently fail - doaa is optional
    }
  }

  void _startCountdown() {
    _timer?.cancel();

    if (_prayerTimes == null) return;

    // Calculate immediately first
    _calculateRemainingTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || !mounted || _prayerTimes == null) {
        _timer?.cancel();
        return;
      }
      _calculateRemainingTime();
    });
  }

  void _calculateRemainingTime() {
    if (_prayerTimes == null) return;

    final prayerTimesDuration = [
      _parseTime(_prayerTimes!.data.timings.fajr),
      _parseTime(_prayerTimes!.data.timings.dhuhr),
      _parseTime(_prayerTimes!.data.timings.asr),
      _parseTime(_prayerTimes!.data.timings.maghrib),
      _parseTime(_prayerTimes!.data.timings.isha),
    ];

    final prayerNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];

    final now = DateTime.now();
    final nowDuration = Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
    );

    Duration nextPrayerTimeDuration = Duration.zero;
    String nextPrayer = '';

    for (int i = 0; i < prayerTimesDuration.length; i++) {
      if (prayerTimesDuration[i].compareTo(nowDuration) > 0) {
        nextPrayerTimeDuration = prayerTimesDuration[i];
        nextPrayer = prayerNames[i];
        break;
      }
    }

    if (nextPrayerTimeDuration == Duration.zero) {
      nextPrayerTimeDuration = prayerTimesDuration[0] + const Duration(days: 1);
      nextPrayer = 'الفجر';
    }

    final remainingTime = nextPrayerTimeDuration - nowDuration;

    if (mounted && !_isDisposed) {
      setState(() {
        nextPrayerName = nextPrayer;
      });
      _remainingTimeStreamController?.sink.add(remainingTime);
    }
  }

  Duration _parseTime(String time) {
    final parts = time.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    );
  }

  Future<void> _refresh() async {
    setState(() => isLoading = true);
    try {
      final prayerTimes =
          await _controller.fetchPrayerTimesByLocation(forceRefresh: true);
      if (mounted && !_isDisposed) {
        setState(() {
          _prayerTimes = prayerTimes;
          isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
    _remainingTimeStreamController?.close();
    _remainingTimeStreamController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: _buildContent(screenHeight, screenWidth),
        ),
      ),
    );
  }

  Widget _buildContent(double screenHeight, double screenWidth) {
    // Show loading only on first load
    if (isLoading && _prayerTimes == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    // Show error only if no cached data
    if (_errorMessage != null && _prayerTimes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ: $_errorMessage',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Show data (from cache or fresh)
    if (_prayerTimes == null) {
      return const Center(
        child: Text('لا توجد بيانات', style: TextStyle(color: Colors.white)),
      );
    }

    final prayerTimes = _prayerTimes!;
    final prayerNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];

    final apiMonthName = prayerTimes.data.date.gregorian.month.en;
    final monthNameMapping = {
      'January': 'يناير',
      'February': 'فبراير',
      'March': 'مارس',
      'April': 'إبريل',
      'May': 'مايو',
      'June': 'يونيو',
      'July': 'يوليو',
      'August': 'أغسطس',
      'September': 'سبتمبر',
      'October': 'أكتوبر',
      'November': 'نوفمبر',
      'December': 'ديسمبر',
    };
    final arabicMonthName = monthNameMapping[apiMonthName] ?? apiMonthName;

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateInfo(prayerTimes, arabicMonthName, screenWidth),
            _buildCountdownSection(prayerTimes, screenHeight),
            _buildPrayerList(prayerTimes, prayerNames, screenHeight),
            if (randomDoaa != null) _buildDuaSection(screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    AzkarApp prayerTimes,
    String arabicMonthName,
    double screenWidth,
  ) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${prayerTimes.data.date.hijri.weekday.ar} ${prayerTimes.data.date.gregorian.day} $arabicMonthName',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.033,
            ),
          ),
          Text(
            '${prayerTimes.data.date.hijri.day} ${prayerTimes.data.date.hijri.month.ar} ${prayerTimes.data.date.hijri.year} هـ',
            style: TextStyle(
              color: Colors.green,
              fontSize: screenWidth * 0.033,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(AzkarApp prayerTimes, double screenHeight) {
    return SizedBox(
      child: Card(
        color: Colors.green,
        child: Container(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: StreamBuilder<Duration>(
            stream: _remainingTimeStreamController?.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error.toString()}');
              } else if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else {
                final remainingTime = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          prayerTimes.data.meta.timezone,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const Text(
                      "متبقي علي ",
                      style: TextStyle(color: Colors.white),
                    ),
                    ListTile(
                      title: Text(
                        'صلاة $nextPrayerName',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        formatDuration(remainingTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.03,
                        ),
                      ),
                    )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerList(
    AzkarApp prayerTimes,
    List<String> prayerNames,
    double screenHeight,
  ) {
    return Column(
      children: List.generate(prayerNames.length, (index) {
        final List<Duration> prayerTimings = [
          _parseTime(prayerTimes.data.timings.fajr),
          _parseTime(prayerTimes.data.timings.dhuhr),
          _parseTime(prayerTimes.data.timings.asr),
          _parseTime(prayerTimes.data.timings.maghrib),
          _parseTime(prayerTimes.data.timings.isha),
        ];
        bool isCurrentPrayer = false;
        final prayerName = prayerNames[index];
        final prayerTiming = prayerTimings[index];
        final DateTime now = DateTime.now();
        final Duration nowDuration =
            Duration(hours: now.hour, minutes: now.minute, seconds: now.second);
        String prayerTime =
            "${prayerTiming.inHours.toString().padLeft(2, '0')}:${prayerTiming.inMinutes.remainder(60).toString().padLeft(2, '0')}";

        if (index > 0) {
          final previousPrayerTime = prayerTimings[index - 1];
          final currentPrayerTime = prayerTiming;

          if (nowDuration > previousPrayerTime &&
              nowDuration < currentPrayerTime) {
            isCurrentPrayer = true;
          }
        } else {
          final currentPrayerTime = prayerTimings[0];

          if (nowDuration < currentPrayerTime) {
            isCurrentPrayer = true;
          }
        }

        if (prayerName == 'الفجر' &&
            nowDuration > prayerTimings[prayerTimings.length - 1]) {
          final nextDayFajr = prayerTimings[0] + const Duration(days: 1);
          if (nowDuration < nextDayFajr) {
            isCurrentPrayer = true;
          }
        }

        return Card(
          color: isCurrentPrayer ? Colors.green : Colors.transparent,
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isCurrentPrayer ? Colors.green : Colors.white,
              ),
              borderRadius: BorderRadius.circular(screenHeight * 0.0115),
            ),
            title: Text(
              prayerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.015,
              ),
            ),
            trailing: Text(
              prayerTime,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.015,
              ),
            ),
            textColor: Colors.white,
          ),
        );
      }),
    );
  }

  Widget _buildDuaSection(double screenHeight) {
    if (randomDoaa == null || randomDoaa.isEmpty) return const SizedBox();

    final selectedDoaaText = randomDoaa[selectedDoaaIndex]['text'];
    return Card(
      color: const Color.fromARGB(103, 62, 145, 64),
      child: Padding(
        padding: EdgeInsets.all(screenHeight * 0.015),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "تَذكِرة",
              style: TextStyle(
                color: Colors.green,
                fontSize: screenHeight * 0.015,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              width: double.infinity,
              child: Text(
                selectedDoaaText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.015,
                  fontWeight: FontWeight.bold,
                  height: screenHeight * 0.0015,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String convertDateFormat(
      String dateTimeString, String oldFormat, String newFormat) {
    DateFormat newDateFormat = DateFormat(newFormat);
    DateTime dateTime = DateFormat(oldFormat).parse(dateTimeString);
    String selectedDate = newDateFormat.format(dateTime);
    return selectedDate;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
