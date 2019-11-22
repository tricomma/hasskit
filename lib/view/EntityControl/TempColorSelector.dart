import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'EntityControlLightDimmer.dart';

class TempColorSelector extends StatefulWidget {
  final String entityId;

  const TempColorSelector({@required this.entityId});
  @override
  _TempColorSelectorState createState() => _TempColorSelectorState();
}

class _TempColorSelectorState extends State<TempColorSelector> {
  int selectedIndex = 0;
  List<Widget> widgets = [];
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < colorTemps.length; i++) {
      var widget = InkWell(
        onTap: () {
          selectedIndex = i;
          sendColor();
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
            backgroundColor: colorTemps[i],
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

  void sendColor() {
    setState(() {
      var outMsg = {
        "id": gd.socketId,
        "type": "call_service",
        "domain": gd.entities[widget.entityId].entityId.split('.').first,
        "service": "turn_on",
        "service_data": {
          "entity_id": widget.entityId,
          "color_temp": gd
              .mapNumber(
                  selectedIndex.toDouble(),
                  0,
                  colorTemps.length.toDouble() - 1,
                  gd.entities[widget.entityId].minMireds.toDouble(),
                  gd.entities[widget.entityId].maxMireds.toDouble() - 1)
              .toInt()
        },
      };

      var outMsgEncoded = json.encode(outMsg);
      webSocket.send(outMsgEncoded);
      HapticFeedback.mediumImpact();

      log.d("minMireds ${gd.entities[widget.entityId].minMireds} "
          "maxMireds ${gd.entities[widget.entityId].maxMireds} "
          "selectedIndex $selectedIndex");
    });
  }
}
