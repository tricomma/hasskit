import 'package:flutter/material.dart';

List<Color> baseSettingDefaultColor = [
  Color(0xffEEEEEE), //EEEEEE Gray
  Color(0xffEF5350), //EF5350 Red
  Color(0xffFFCA28), //FFCA28 Amber
  Color(0xff66BB6A), //66BB6A Green
//    Color(0xff26C6DA), //26C6DA Cyan
  Color(0xff42A5F5), //42A5F5 Blue
  Color(0xffAB47BC), //AB47BC Purple
];
BaseSetting baseSetting = BaseSetting(
  itemsPerRow: 3,
  themeIndex: 1,
  notificationDevices: [],
  colorPicker: [
    baseSettingDefaultColor[0],
    baseSettingDefaultColor[1],
    baseSettingDefaultColor[2],
    baseSettingDefaultColor[3],
    baseSettingDefaultColor[4],
    baseSettingDefaultColor[5],
  ],
);

class BaseSetting {
  int itemsPerRow;
  int themeIndex;
  List<String> notificationDevices = [];
  List<Color> colorPicker = [];
  BaseSetting({
    @required this.itemsPerRow,
    @required this.themeIndex,
    this.notificationDevices,
    this.colorPicker,
  });

  Map<String, dynamic> toJson() => {
        'itemsPerRow': itemsPerRow,
        'themeIndex': themeIndex,
        'notificationDevices': notificationDevices,
        'colorPicker': colorPicker,
      };

  factory BaseSetting.fromJson(Map<String, dynamic> json) {
    return BaseSetting(
      itemsPerRow: json['itemsPerRow'] != null ? json['itemsPerRow'] : 3,
      themeIndex: json['themeIndex'] != null ? json['themeIndex'] : 1,
      notificationDevices: json['notificationDevices'] != null
          ? List<String>.from(json['notificationDevices'])
          : [],
      colorPicker: json['themeIndex'] != null
          ? List<String>.from(json['colorPicker'].toList())
          : baseSettingDefaultColor,
    );
  }
}
