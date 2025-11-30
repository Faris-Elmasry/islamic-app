import 'package:flutter/material.dart';

import 'package:flutter_application_6/veiw/mainpages/homepage1.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar', 'AE'), // Arabic
      ],
      debugShowCheckedModeBanner: false,
      title: 'Tzirah',
      theme: ThemeData(
        fontFamily: "Tajawal",
        backgroundColor: Colors.blueGrey[900],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // home: MyHomePage(),
      // home: azkarpagen(),
      // home: MornAzkar(),
      home: Directionality(
        // add this
        textDirection: TextDirection.rtl, // set this property
        // child: HomePge(),
        child: HomePge(),
      ),
    );
  }
}
