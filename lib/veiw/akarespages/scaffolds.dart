import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  final morningZkr;
  final String? appBarTitle;

  const MyWidget({
    required this.morningZkr,
    this.appBarTitle,
    Key? key,
  }) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Map<int, int> counts = {};
  Map<int, bool> disabledItems = {};
  Map<int, Color> itemColors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text(
          widget.appBarTitle ?? "أذكار الصباح",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: widget.morningZkr == null
          ? CircularProgressIndicator() // Show loading indicator
          : Container(
              color: Colors.black38,
              child: ListView.builder(
                itemCount: widget.morningZkr.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = widget.morningZkr[index];
                  var zkrnum = item["count"];
                  var count = counts[index] ?? 0;
                  var isDisabled = disabledItems[index] ?? false;
                  var itemColor = itemColors[index] ?? Colors.black;

                  return ListTile(
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(() {
                              count++;
                              counts[index] = count;

                              if (count == zkrnum) {
                                itemColor = Colors.green;
                                disabledItems[index] = true;
                              }
                              itemColors[index] = itemColor;
                            });
                          },
                    title: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green, // Use the stored color
                        border: Border.all(color: Colors.black26, width: 4),
                      ),
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "${item?["id"].toString()}- ${item["text"].toString()}",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          height: 1.8,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: item["count"] == 0
                        ? Container()
                        : Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: itemColor, // Use the global checkcolor
                            ),
                            child: Center(
                              child: Text(
                                "   ${count}  من    ${item["count"].toString()}  ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
    );
  }
}
