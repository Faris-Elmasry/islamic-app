import 'package:flutter_application_6/controller/remoteazkar.dart';

class fetchdata {
  Remotejson remoteJson = Remotejson();

  List<dynamic>? items;

  // @override
  // void initState() {
  //   // super.initState();
  //   fetchItems();
  // }

  void fetchItems() async {
    return items = await remoteJson.readJson();

    // items!.forEach((element) {
    //   print(element);
    // });
    // print(items);
    // setState(() {
    //   // Update the UI with the fetched items
    // });
  }
}

void main() {
  fetchdata();
}
