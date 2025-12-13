import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_6/features/azkar/azkar_pages.dart';

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
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Customlessons(
                      AzkarName: "أذكار الصباح",
                      imgpath:
                          "lib/assets/pngtree-early-morning-sun-background-template-image_161619.jpg",
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: MorningAzkarPage(),
                      )),
                  Customlessons(
                      AzkarName: "أذكار المساء",
                      imgpath: 'lib/assets/evining.jpg',
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: EveningAzkarPage(),
                      )),
                  Customlessons(
                      AzkarName: "أذكار الصلاة",
                      imgpath: 'lib/assets/mosque.jpg',
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: PrayerAzkarPage(),
                      )),
                  Customlessons(
                      AzkarName: "أذكار النوم",
                      imgpath: 'lib/assets/sleep.jpg',
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: SleepAzkarPage(),
                      )),
                  Customlessons(
                      AzkarName: "الرقية",
                      imgpath: 'lib/assets/roqia.jpg',
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: RuqyahPage(),
                      )),
                  Customlessons(
                      AzkarName: "أدعية متنوعة",
                      imgpath: 'lib/assets/do3aa.jpg',
                      nextpagename: const Directionality(
                        textDirection: TextDirection.rtl,
                        child: DuaPage(),
                      )),
                ],
              ),
            ),
          ),
        ));
  }

  Widget Customlessons(
      {required String AzkarName,
      required String imgpath,
      var nextpage,
      required var nextpagename}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => nextpagename),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              child: Ink.image(
                width: double.infinity,
                height: double.infinity,
                image: AssetImage(imgpath),
                fit: BoxFit.cover,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      AzkarName,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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