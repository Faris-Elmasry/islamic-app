import 'package:flutter/material.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/veiw/akarespages/scaffolds.dart';

class sleepAzkar extends StatefulWidget {
  const sleepAzkar({super.key});

  @override
  State<sleepAzkar> createState() => _sleepAzkarState();
}

class _sleepAzkarState extends State<sleepAzkar> {
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  Map<int, int> counts = {}; // Maintain counts for each item
  Map<int, bool> disabledItems = {}; // Maintain whether an item is disabled
  var sleepzkr;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    items = await remoteJson.readJson();

    items!.forEach((element) {
      if (element["id"] == 4) {
        setState(() {
          sleepzkr = element["array"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyWidget(
      morningZkr: sleepzkr,
      appBarTitle: 'أذكار النوم',
    );
  }
}
