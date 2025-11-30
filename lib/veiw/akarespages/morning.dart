import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_6/controller/fetchazkardata.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/veiw/akarespages/scaffolds.dart';

class MornAzkar extends StatefulWidget {
  @override
  _MornAzkartState createState() => _MornAzkartState();
}

class _MornAzkartState extends State<MornAzkar> {
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  var morningzkr;
  Map<int, int> counts = {}; // Maintain counts for each item
  Map<int, bool> disabledItems = {}; // Maintain whether an item is disabled

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    items = await remoteJson.readJson();

    items!.forEach((element) {
      if (element["id"] == 1) {
        setState(() {
          morningzkr = element["array"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyWidget(
      morningZkr: morningzkr,
      appBarTitle: 'أذكار الصباح',
    );
  }
}
