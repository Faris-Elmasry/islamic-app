import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Remotejson {
  List listofazkardata = [];
  var mornning;
  var evnning;
  var prayer;
  var sleep;
  var roqia;
  var ad3ia;
  Future readJson() async {
    final String response =
        await rootBundle.loadString('lib/model/azkarsdata.json');
    final data = await json.decode(response) as List<dynamic>;

    return data;
  }
}

void main() {
  Remotejson();
  // print(Remotejson().readJson());
}
