import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/BaseSetting.dart';

class RgbColorSelector extends StatefulWidget {
  final String entityId;

  const RgbColorSelector({@required this.entityId});
  @override
  _RgbColorSelectorState createState() => _RgbColorSelectorState();
}

class _RgbColorSelectorState extends State<RgbColorSelector> {
  Color pickerColor = Color(0xff443a49);

  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < baseSetting.colorPicker.length; i++) {
      var widget = InkWell(
        onTap: () {
          selectedIndex = i;
          pickerColor = baseSetting.colorPicker[selectedIndex];
          //really don't know why index 0 cant change color, maybe addon bug?
          if (i != 0) {
            Flushbar(
              backgroundColor: ThemeInfo.colorBottomSheet,
              icon: Icon(Icons.info),
              overlayColor: Colors.red,
              messageText: Text("Long Press To Edit Color"),
              duration: Duration(seconds: 3),
            )..show(context);
          }
          sendColor();
        },
        onLongPress: () {
          selectedIndex = i;
          if (i != 0) {
//          log.d("onLongPress pickerColor $pickerColor");
//          log.d("selectedIndex selectedIndex $selectedIndex");
            pickerColor = baseSetting.colorPicker[selectedIndex];
            openColorPicker();
          }
        },
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeInfo.colorBottomSheetReverse,
//                            border: Border.all(width: 0, color: Colors.white),
          ),
          child: CircleAvatar(
            backgroundColor: baseSetting.colorPicker[i],
          ),
        ),
      );
      widgets.add(widget);
    }

    return Column(
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          widgets[0],
          widgets[1],
          widgets[2],
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          widgets[3],
          widgets[4],
          widgets[5],
        ]),
      ],
    );
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void openColorPicker() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        backgroundColor: ThemeInfo.colorBottomSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: SingleChildScrollView(
          child: ColorPicker(
            enableAlpha: false,
            displayThumbColor: true,
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            enableLabel: true,
            pickerAreaHeightPercent: 5 / 8,
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            child: const Text('Reset'),
            onPressed: () {
              setState(
                () {
                  baseSetting.colorPicker[selectedIndex] =
                      baseSettingDefaultColor[selectedIndex];
                  pickerColor = baseSetting.colorPicker[selectedIndex];
                },
              );
              sendColor();
              Navigator.of(context).pop();
            },
          ),
          RaisedButton(
            child: const Text('OK'),
            onPressed: () {
              setState(
                () {
                  log.d(
                      "RaisedButton selectedIndex $selectedIndex pickerColor $pickerColor");
                  baseSetting.colorPicker[selectedIndex] = pickerColor;
                },
              );
              sendColor();
              gd.baseSettingSave();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void sendColor() {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": widget.entityId.split('.').first,
      "service": "turn_on",
      "service_data": {
        "entity_id": widget.entityId,
        "rgb_color": [pickerColor.red, pickerColor.green, pickerColor.blue]
      },
    };

    var outMsgEncoded = json.encode(outMsg);
    webSocket.send(outMsgEncoded);
    HapticFeedback.mediumImpact();

    log.d(
        "sendColor ${[pickerColor.red, pickerColor.green, pickerColor.blue]}");
  }
}
