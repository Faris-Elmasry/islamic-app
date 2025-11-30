// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_6/model/prayermodel/Prayerapi.dart';

// Future<PrayerApimodel> getprayertimedata() async {
//   final url =
//       'http://api.aladhan.com/v1/calendarByCity/2017/4?city=London&country=United%20Kingdom&method=2';
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.

//     var data = jsonDecode(response.body);
//     print(data);
//     return data;
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     print("error");
//     throw Exception('Failed to load prayer time');
//   }
// }
