import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_6/features/azkar/azkar_pages.dart';
import 'package:flutter_application_6/features/qibla/qibla.dart';

class azkarpagen extends StatefulWidget {
  const azkarpagen({Key? key});

  @override
  State<azkarpagen> createState() => _azkarpagenState();
}

class _azkarpagenState extends State<azkarpagen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          title: const Text(
            'الأذكار',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Qibla Compass Button
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.explore, color: Colors.teal),
                tooltip: 'بوصلة القبلة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QiblaCompassPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Qibla Quick Access Card
                  _buildQiblaQuickAccessCard(),

                  const SizedBox(height: 20),

                  // Section Header
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'الأذكار اليومية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),

                  // Azkar Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildAzkarCard(
                        name: "أذكار الصباح",
                        icon: Icons.wb_sunny,
                        color: Colors.orange,
                        imgpath:
                            "lib/assets/pngtree-early-morning-sun-background-template-image_161619.jpg",
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: MorningAzkarPage(),
                        ),
                      ),
                      _buildAzkarCard(
                        name: "أذكار المساء",
                        icon: Icons.nightlight_round,
                        color: Colors.indigo,
                        imgpath: 'lib/assets/evining.jpg',
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: EveningAzkarPage(),
                        ),
                      ),
                      _buildAzkarCard(
                        name: "أذكار الصلاة",
                        icon: Icons.mosque,
                        color: Colors.teal,
                        imgpath: 'lib/assets/mosque.jpg',
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: PrayerAzkarPage(),
                        ),
                      ),
                      _buildAzkarCard(
                        name: "أذكار النوم",
                        icon: Icons.bedtime,
                        color: Colors.purple,
                        imgpath: 'lib/assets/sleep.jpg',
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: SleepAzkarPage(),
                        ),
                      ),
                      _buildAzkarCard(
                        name: "الرقية الشرعية",
                        icon: Icons.healing,
                        color: Colors.green,
                        imgpath: 'lib/assets/roqia.jpg',
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: RuqyahPage(),
                        ),
                      ),
                      _buildAzkarCard(
                        name: "أدعية متنوعة",
                        icon: Icons.menu_book,
                        color: Colors.blue,
                        imgpath: 'lib/assets/do3aa.jpg',
                        nextPage: const Directionality(
                          textDirection: TextDirection.rtl,
                          child: DuaPage(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  /// Build Qibla Quick Access Card
  Widget _buildQiblaQuickAccessCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QiblaCompassPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00796B), Color(0xFF009688)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.explore,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بوصلة القبلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'حدد اتجاه القبلة بدقة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Modern Azkar Card
  Widget _buildAzkarCard({
    required String name,
    required IconData icon,
    required Color color,
    required String imgpath,
    required Widget nextPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                imgpath,
                fit: BoxFit.cover,
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      color.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 


















/*
 ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MornAzkar()),
                  );
                },
                child: Text("morining azkarpage")),

*/




    //   child: Container(
    //     padding: EdgeInsets.all(10),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(15),
    //     ),
    //     child: Stack(
    //       alignment: Alignment.center,
    //       children: [
    //         // Image widget
    //         Container(
    //           // height: 100,
    //           child: ClipRRect(
    //               borderRadius: BorderRadius.circular(15),
    //               child: ImageFiltered(
    //                 imageFilter: ImageFilter.blur(
    //                   sigmaX: 2,
    //                   sigmaY: 2,
    //                 ),
    //                 child: Image.asset(
    //                   imgpath,
    //                   // height: 200, // Adjust the height as needed
    //                   width: double.infinity, // Adjust the width as needed
    //                   fit: BoxFit.cover, // Adjust the image fit as needed
    //                 ),
    //               )),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             print("faris");

    //             /*
    //               Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => const SecondRoute()),
    //             */
    //           },
    //           child: Container(
    //             // color: Colors.black,
    //             child: Text(
    //               AzkarName,
    //               style: TextStyle(
    //                 color: Colors.black54, // Adjust the text color as needed
    //                 fontSize: 25, // Adjust the font size as needed
    //                 fontWeight:
    //                     FontWeight.bold, // Adjust the font weight as needed
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),