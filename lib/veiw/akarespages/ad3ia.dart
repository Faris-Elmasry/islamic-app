import 'package:flutter/material.dart';
import 'package:flutter_application_6/controller/remoteazkar.dart';
import 'package:flutter_application_6/veiw/akarespages/scaffolds.dart';

class Ad3ia extends StatefulWidget {
  const Ad3ia({super.key});

  @override
  State<Ad3ia> createState() => _Ad3iaState();
}

class _Ad3iaState extends State<Ad3ia> {
  Remotejson remoteJson = Remotejson();
  List<dynamic>? items;
  var ad3iazkr;
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
      if (element["id"] == 6) {
        setState(() {
          ad3iazkr = element["array"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyWidget(
      morningZkr: ad3iazkr,
      appBarTitle: 'أدعية',
    );
  }
}
