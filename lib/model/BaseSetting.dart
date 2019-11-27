import 'package:flutter/material.dart';

const List<String> baseSettingDefaultColor = [
  "0xffEEEEEE",
  "0xffEF5350",
  "0xffFFCA28",
  "0xff66BB6A",
  "0xff42A5F5",
  "0xffAB47BC",
//  Color(0xffEEEEEE), //EEEEEE Gray
//  Color(0xffEF5350), //EF5350 Red
//  Color(0xffFFCA28), //FFCA28 Amber
//  Color(0xff66BB6A), //66BB6A Green
////    Color(0xff26C6DA), //26C6DA Cyan
//  Color(0xff42A5F5), //42A5F5 Blue
//  Color(0xffAB47BC), //AB47BC Purple
];

class BaseSetting {
  int itemsPerRow;
  int themeIndex;
  String lastArmType;
  List<String> notificationDevices;
  List<String> colorPicker;

  BaseSetting({
    @required this.itemsPerRow,
    @required this.themeIndex,
    @required this.lastArmType,
    @required this.notificationDevices,
    @required this.colorPicker,
  });

  Map<String, dynamic> toJson() => {
        'itemsPerRow': itemsPerRow,
        'themeIndex': themeIndex,
        'lastArmType': lastArmType,
        'notificationDevices': notificationDevices,
        'colorPicker': colorPicker,
      };

  factory BaseSetting.fromJson(Map<String, dynamic> json) {
    return BaseSetting(
      itemsPerRow: json['itemsPerRow'] != null ? json['itemsPerRow'] : 3,
      themeIndex: json['themeIndex'] != null ? json['themeIndex'] : 1,
      lastArmType:
          json['lastArmType'] != null ? json['lastArmType'] : "arm_away",
      notificationDevices: json['notificationDevices'] != null
          ? List<String>.from(json['notificationDevices'])
          : [],
      colorPicker: json['colorPicker'] != null
          ? List<String>.from(json['colorPicker'])
          : [
              "0xffEEEEEE",
              "0xffEF5350",
              "0xffFFCA28",
              "0xff66BB6A",
              "0xff42A5F5",
              "0xffAB47BC",
            ],
    );
  }
}
