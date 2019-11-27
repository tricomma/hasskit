import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class EntityControlAlarmPanel extends StatefulWidget {
  final String entityId;

  const EntityControlAlarmPanel({@required this.entityId});
  @override
  _EntityControlAlarmPanelState createState() =>
      _EntityControlAlarmPanelState();
}

class _EntityControlAlarmPanelState extends State<EntityControlAlarmPanel> {
  final int keyCodeLength = 4;
  String output = "";
  String _readableState = "";
  String _armType = "arm_away";

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  _arm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_" + _armType,
      "service_data": {"entity_id": entity.entityId, "code": output}
    };

    var outMsgEncoded = json.encode(outMsg);
    gd.sendSocketMessage(outMsgEncoded);
  }

  _disarm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_disarm",
      "service_data": {"entity_id": entity.entityId, "code": output}
    };

    var outMsgEncoded = json.encode(outMsg);
    gd.sendSocketMessage(outMsgEncoded);
  }

  buttonPressed(String text) {
    if (text != "") {
      output += text;
    }

    if (output.length > keyCodeLength) {
      output = output.substring(1, keyCodeLength + 1);
    }

    if (output.length == keyCodeLength) {
      var entity = gd.entities[widget.entityId];
      if (entity.state == "disarmed") {
        _arm(entity);
      } else {
        _disarm(entity);
      }
    }
  }

  String _getStateText(entity) {
    if (entity.state == "disarmed") {
      return "Disarmed";
    } else if (entity.state == "pending") {
      return "Pending";
    } else if (entity.state == "armed_away") {
      return "Armed away";
    } else if (entity.state == "armed_home") {
      return "Armed home";
    } else if (entity.state == "armed_night") {
      return "Armed night";
    } else {
      return "Armed";
    }
  }

  Widget alarmSelectionButton(String text, String armType) {
    Color getColor() {
      return _armType == armType
          ? Theme.of(context).textTheme.body1.color
          : Theme.of(context).textTheme.body1.color.withOpacity(0.25);
    }

    return Container(
        height: 50,
        width: 80,
        decoration: BoxDecoration(
          color: _armType == armType
              ? Theme.of(context).textTheme.body1.color.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: EdgeInsets.all(8),
        child: new OutlineButton(
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0),
          ),
          child: new Text(text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: getColor(),
              ),
              textAlign: TextAlign.center),
          onPressed: () => {
            setState(() {
              _armType = armType;
            })
          },
        ));
  }

  Widget alarmButton(String buttonText) {
    return Container(
      height: 50,
      width: 80,
      margin: EdgeInsets.all(8),
      child: new OutlineButton(
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(8.0),
        ),
        child: new Text(
          buttonText,
          style: TextStyle(
              fontSize: buttonText.length > 2 ? 15.0 : 20.0,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state}" +
          "${generalData.entities[widget.entityId].getFriendlyName}" +
          "${generalData.entities[widget.entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[widget.entityId];
        _readableState = _getStateText(entity);
        Color alarmColor = Colors.red;
        String alarmIcon = "mdi:shield-lock";
        if (_readableState == "Disarmed") {
          alarmColor = Colors.green;
          alarmIcon = "mdi:shield-check";
        } else if (_readableState == "Pending") {
          alarmColor = ThemeInfo.colorIconActive;
          alarmIcon = "mdi:shield-outline";
        }

        return new Container(
          child: new Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: alarmColor,
                        width: 4.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      MaterialDesignIcons.getIconDataFromIconName(alarmIcon),
                      size: 50,
                      color: alarmColor,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: alarmColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: new Container(
                      padding: new EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 5,
                      ),
                      child: new Text(
                        _readableState.toUpperCase(),
                        style: new TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
//              new Container(
//                alignment: Alignment.center,
//                padding:
//                    new EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
//                child: new Text(output,
//                    style: new TextStyle(
//                        fontSize: 36.0, fontWeight: FontWeight.bold)),
//              ),
              SizedBox(height: 20),

              new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("1"),
                      alarmButton("2"),
                      alarmButton("3")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("4"),
                      alarmButton("5"),
                      alarmButton("6")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmButton("7"),
                      alarmButton("8"),
                      alarmButton("9")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      alarmSelectionButton("Arm Home", "arm_home"),
                      alarmButton("0"),
                      alarmSelectionButton("Arm Away", "arm_away")
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
