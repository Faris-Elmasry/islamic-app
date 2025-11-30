// import 'dart:async';
// import 'dart:math';
// import 'package:flutter_application_6/controller/remoteazkar.dart';

// class GetRandomDo3aa {
//   Remotejson remoteJson = Remotejson();
//   List<dynamic>? items;
//   var ad3iazkr;
//   Map<int, int> counts = {}; // Maintain counts for each item
//   Map<int, bool> disabledItems = {}; // Maintain whether an item is disabled

//   // Create a StreamController to broadcast random text updates
//   final _randomTextStreamController = StreamController<String>.broadcast();

//   Stream<String> get randomTextStream => _randomTextStreamController.stream;

//   GetRandomDo3aa() {
//     // Fetch initial data when the class is instantiated
//     fetchItems();

//     // Start a timer to fetch random text every 24 hours
//     Timer.periodic(Duration(hours: 24), (timer) {
//       fetchItems();
//     });
//   }

// Future<void> fetchItems() async {
//   items = await remoteJson.readJson();

//   items!.forEach((element) {
//     if (element["id"] == 6) {
//       final array = element["array"];
//       if (array is List<dynamic> && array.isNotEmpty) {
//         // Assuming you want to get the first item as a string
//         ad3iazkr = array[0]["text"].toString();
//       } else {
//         // Handle the case where 'array' is empty or not a list
//         ad3iazkr = ''; // Or assign a default value
//       }

//       // Generate a random index within the range of the ad3iazkr list
//       final randomIndex = _getRandomIndex(ad3iazkr);

//       // Retrieve the random text from the ad3iazkr list
//       final randomText = ad3iazkr[randomIndex];

//       // Broadcast the random text to listeners
//       _randomTextStreamController.add(randomText);
//     }
//   });
// }

//   int _getRandomIndex(List<dynamic> list) {
//     if (list != null && list.isNotEmpty) {
//       return Random().nextInt(list.length);
//     }
//     return 0;
//   }

//   void dispose() {
//     _randomTextStreamController.close();
//   }
// }
