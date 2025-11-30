// To parse this JSON data, do
//
//     final azkarClass = azkarClassFromJson(jsonString);

import 'dart:convert';

List<AzkarClass> azkarClassFromJson(String str) =>
    List<AzkarClass>.from(json.decode(str).map((x) => AzkarClass.fromJson(x)));

String azkarClassToJson(List<AzkarClass> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AzkarClass {
  int id;
  String category;
  String audio;
  String filename;
  List<Array> array;

  AzkarClass({
    required this.id,
    required this.category,
    required this.audio,
    required this.filename,
    required this.array,
  });

  factory AzkarClass.fromJson(Map<String, dynamic> json) => AzkarClass(
        id: json["id"],
        category: json["category"],
        audio: json["audio"],
        filename: json["filename"],
        array: List<Array>.from(json["array"].map((x) => Array.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "audio": audio,
        "filename": filename,
        "array": List<dynamic>.from(array.map((x) => x.toJson())),
      };
}

class Array {
  int id;
  String text;
  int count;
  String audio;
  String filename;

  Array({
    required this.id,
    required this.text,
    required this.count,
    required this.audio,
    required this.filename,
  });

  factory Array.fromJson(Map<String, dynamic> json) => Array(
        id: json["id"],
        text: json["text"],
        count: json["count"],
        audio: json["audio"],
        filename: json["filename"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "count": count,
        "audio": audio,
        "filename": filename,
      };
}
