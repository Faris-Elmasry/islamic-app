import 'dart:async';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_6/controller/prayercontroller/PrayerTimesCont.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/model/prayermodel/PrayerTimes.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesController _controller = PrayerTimesController();
  late Future<AzkarApp> _prayerTimes;
  StreamController<Duration> _remainingTimeStreamController =
      StreamController<Duration>();
  Timer? _timer;
  late String nextPrayerName = '';
  late String nextPrayerTime = '';
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  var randomDoaa;
  Map<int, int> counts = {};
  Map<int, bool> disabledItems = {};
  int selectedDoaaIndex = 0;

  bool isLoading = true; // Added to track loading state

  @override
  void initState() {
    super.initState();
    _prayerTimes = _controller.fetchPrayerTimesByLocation();
    startCountdown();
    checkInternetConnectivity();
    fetchItems();
  }

  void generateRandomDoaaIndex() {
    if (randomDoaa != null) {
      setState(() {
        selectedDoaaIndex = Random().nextInt(randomDoaa.length);
      });
    }
  }

  Future<void> fetchItems() async {
    items = await remoteJson.readJson();
    items!.forEach((element) {
      if (element["id"] == 6) {
        setState(() {
          randomDoaa = element["array"];
        });
        generateRandomDoaaIndex();
      }
    });
  }

  Future<void> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, show a dialog
      showNoInternetDialog();
    }
  }

  void retryOperation() async {
    checkInternetConnectivity();
    _prayerTimes = _controller.fetchPrayerTimesByLocation();
  }

  void startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      // Get prayer times
      final AzkarApp prayerTimes = await _prayerTimes;

      // Convert timings to Duration from midnight
      final List<Duration> prayerTimesDuration = [
        parseTimeToDuration(prayerTimes.data.timings.fajr),
        parseTimeToDuration(prayerTimes.data.timings.dhuhr),
        parseTimeToDuration(prayerTimes.data.timings.asr),
        parseTimeToDuration(prayerTimes.data.timings.maghrib),
        parseTimeToDuration(prayerTimes.data.timings.isha)
      ];

      // Get current time as Duration from midnight
      final DateTime now = DateTime.now();
      final Duration nowDuration =
          Duration(hours: now.hour, minutes: now.minute, seconds: now.second);

      // Find closest prayer time
      Duration nextPrayerTimeDuration = Duration.zero;
      String nextPrayer = '';

      for (int i = 0; i < prayerTimesDuration.length; i++) {
        if (prayerTimesDuration[i].compareTo(nowDuration) > 0) {
          nextPrayerTimeDuration = prayerTimesDuration[i];
          nextPrayer = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'][i];
          break;
        }
      }

      // Check if Fajr time for the next day
      if (nextPrayerTimeDuration == Duration.zero) {
        // Set next prayer to Fajr of the next day
        nextPrayerTimeDuration = prayerTimesDuration[0];
        nextPrayer = 'الفجر';
        // Add one day to the remaining time
        nextPrayerTimeDuration += Duration(days: 1);
      }

      // Calculate remaining time
      final Duration remainingTime = nextPrayerTimeDuration - nowDuration;

      // Set states
      setState(() {
        nextPrayerName = nextPrayer;
        isLoading = false; // Mark loading as complete
      });
      _remainingTimeStreamController.sink.add(remainingTime);
    });
  }

  Duration parseTimeToDuration(String time) {
    final List<String> timeParts = time.split(':');

    return Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
        seconds: int.parse(timeParts[0]));
  }

  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                retryOperation();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingTimeStreamController.close();
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
          padding: EdgeInsets.all(
              screenWidth * 0.02), // Adjust outer padding based on screen width
          child: isLoading // Display the circular indicator while loading
              ? Center(
                  child: SpinKitFoldingCube(
                    color: Colors.green,
                    size: 50.0,
                  ),
                )
              : FutureBuilder<AzkarApp>(
                  future: _prayerTimes,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error.toString()}'),
                      );
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: Text(''),
                      );
                    } else {
                      final prayerTimes = snapshot.data!;
                      final prayerNames = [
                        'الفجر',
                        'الظهر',
                        'العصر',
                        'المغرب',
                        'العشاء',
                      ];
                      final prayerTimings = [
                        prayerTimes.data.timings.fajr,
                        prayerTimes.data.timings.dhuhr,
                        prayerTimes.data.timings.asr,
                        prayerTimes.data.timings.maghrib,
                        prayerTimes.data.timings.isha,
                      ];

                      final apiMonthName =
                          prayerTimes.data.date.gregorian.month.en;

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
                      final arabicMonthName =
                          monthNameMapping[apiMonthName] ?? apiMonthName;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildDateInfo(
                              prayerTimes, arabicMonthName, screenWidth),
                          _buildCountdownSection(prayerTimes, screenHeight),
                          _buildPrayerList(
                              prayerTimes, prayerNames, screenHeight),
                          _buildDuaSection(screenHeight),
                        ],
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    AzkarApp prayerTimes,
    String arabicMonthName,
    double screenWidth,
  ) {
    return Container(
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${prayerTimes.data.date.hijri.weekday.ar} ${prayerTimes.data.date.gregorian.day},$arabicMonthName',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth *
                      0.033, // Adjust font size based on screen width
                ),
              ),
              Text(
                '${prayerTimes.data.date.hijri.day} ${prayerTimes.data.date.hijri.month.ar},${prayerTimes.data.date.hijri.year}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: screenWidth *
                      0.033, // Adjust font size based on screen width
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownSection(AzkarApp prayerTimes, double screenHeight) {
    return SizedBox(
      //height: screenHeight * 0.175,
      child: Card(
        color: Colors.green,
        child: Container(
          padding: EdgeInsets.all(
              screenHeight * 0.02), // Adjust padding based on screen height
          child: StreamBuilder<Duration>(
            stream: _remainingTimeStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error.toString()}');
              } else if (!snapshot.hasData) {
                return Text('');
              } else {
                final remainingTime = snapshot.data;
                final remainingHours = remainingTime!.inHours;
                final remainingMinutes = remainingTime.inMinutes.remainder(60);
                final remainingSeconds = remainingTime.inSeconds.remainder(60);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${prayerTimes.data.meta.timezone}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Text(
                      "متبقي علي ",
                      style: TextStyle(color: Colors.white),
                    ),
                    ListTile(
                      title: Text(
                        'صلاة $nextPrayerName',
                        style: TextStyle(
                          fontSize: screenHeight *
                              0.025, // Adjust font size based on screen height
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '${formatDuration(remainingTime)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight *
                              0.03, // Adjust font size based on screen height
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
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            itemCount: prayerNames.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final List<Duration> prayerTimings = [
                parseTimeToDuration(prayerTimes.data.timings.fajr),
                parseTimeToDuration(prayerTimes.data.timings.dhuhr),
                parseTimeToDuration(prayerTimes.data.timings.asr),
                parseTimeToDuration(prayerTimes.data.timings.maghrib),
                parseTimeToDuration(prayerTimes.data.timings.isha),
              ];
              bool isCurrentPrayer = false;
              final prayerName = prayerNames[index];
              final prayerTiming = prayerTimings[index];
              final DateTime now = DateTime.now();
              final Duration nowDuration = Duration(
                  hours: now.hour, minutes: now.minute, seconds: now.second);
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

              // Handle Fajr for the next day
              if (prayerName == 'الفجر' &&
                  nowDuration > prayerTimings[prayerTimings.length - 1]) {
                // Calculate Fajr for the next day
                final nextDayFajr = prayerTimings[0] + Duration(days: 1);
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDuaSection(double screenHeight) {
    final selectedDoaaText = randomDoaa[selectedDoaaIndex]['text'];
    return SingleChildScrollView(
      child: Card(
        color: Color.fromARGB(103, 62, 145, 64),
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
              IntrinsicHeight(
                child: Container(
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
              ),
            ],
          ),
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
