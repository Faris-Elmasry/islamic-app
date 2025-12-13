import 'package:flutter/material.dart';
import 'package:flutter_application_6/veiw/mainpages/Azkarpage.dart';
import 'package:flutter_application_6/veiw/mainpages/tasbih.dart';
import 'package:flutter_application_6/veiw/prayertime/PrayerTimesView.dart';
import 'package:flutter_application_6/features/settings/settings_page.dart';

import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class HomePge extends StatefulWidget {
  const HomePge({Key? key}) : super(key: key);

  @override
  State<HomePge> createState() => _HomePgeState();
}

class _HomePgeState extends State<HomePge> {
  int currentpage = 0;
  String appBarTitle = 'مواقيت الصلاة';

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(initialPage: currentpage);

    void onTapIcon(int index) {
      _controller.animateToPage(index,
          duration: Duration(microseconds: 300), curve: Curves.easeIn);
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Directionality(
                    textDirection: TextDirection.rtl,
                    child: SettingsPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (value) {
          setState(() {
            currentpage = value;
          });
        },
        children: [
          PrayerTimesScreen(),
          azkarpagen(),
          Tasbih(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 10,
        selectedIconTheme: IconThemeData(color: Colors.amberAccent, size: 20),
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        elevation: 0,
        backgroundColor: Colors.blueGrey[800],
        currentIndex: currentpage,
        onTap: onTapIcon,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              FlutterIslamicIcons.mosque,
              color: Colors.green,
              size: 30,
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FlutterIslamicIcons.quran2,
              color: Colors.green,
              size: 30,
            ),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                color: Colors.green, FlutterIslamicIcons.tasbihHand, size: 30),
            label: 'تسبيح',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentpage) {
      case 0:
        return 'مواقيت الصلاة';
      case 1:
        return 'الأذكار';
      case 2:
        return 'التسبيح';
      default:
        return 'أذكاري';
    }
  }
}
