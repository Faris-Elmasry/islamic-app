import 'package:flutter/material.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/veiw/akarespages/scaffolds.dart';

class EviningAkar extends StatefulWidget {
  @override
  _EviningAkarState createState() => _EviningAkarState();
}

class _EviningAkarState extends State<EviningAkar> {
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  var evinningzkr;
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
      if (element["id"] == 2) {
        setState(() {
          evinningzkr = element["array"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyWidget(
      morningZkr: evinningzkr,
      appBarTitle: "أذكار المساء",
    );
  }
}
