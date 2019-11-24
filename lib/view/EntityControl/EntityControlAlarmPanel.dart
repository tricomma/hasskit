import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';

class EntityControlAlarmPanel extends StatefulWidget {
  final String entityId;

  const EntityControlAlarmPanel({@required this.entityId});
  @override
  _EntityControlAlarmPanelState createState() =>
      _EntityControlAlarmPanelState();
}

class _EntityControlAlarmPanelState extends State<EntityControlAlarmPanel> {

  String output = "";
  String _readableState = "";

  @override
  void initState() {
    super.initState();
    Entity entity = gd.entities[widget.entityId];

    setState(() {});
  }

  _arm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_arm_away",
      "service_data": {
        "entity_id": entity.entityId,
        "code": output
      }
    };
    print("ARM:" + output);
    var outMsgEncoded = json.encode(outMsg);
    webSocket.send(outMsgEncoded);
    HapticFeedback.mediumImpact();
  }

  _disarm(entity) {
    var outMsg = {
      "id": gd.socketId,
      "type": "call_service",
      "domain": entity.entityId.split('.').first,
      "service": "alarm_disarm",
      "service_data": {
        "entity_id": entity.entityId,
        "code": output
      }
    };
    print("DISARM:" + output);
    var outMsgEncoded = json.encode(outMsg);
    webSocket.send(outMsgEncoded);
    HapticFeedback.mediumImpact();
  }

  buttonPressed(String text) {
    output += text;

    if(output.length > 4) {
      output = output.substring(1, 5);
    }

    if(output.length == 4) {
      var entity = gd.entities[widget.entityId];
      if(entity.state == "disarmed") {
        _arm(entity);
      }
      else {
        _disarm(entity);
      }
    }
  }

  String _getStateText(entity) {
    if(entity.state == "disarmed") {
      return "Disarmed";
    }
    else if(entity.state == "pending") {
      return "Pending";
    }
    else if(entity.state == "armed_away") {
      return "Armed away";
    }
    else if(entity.state == "armed_home") {
      return "Armed home";
    }
    else if(entity.state == "armed_night") {
      return "Armed night";
    }
    else {
      return "Armed";
    }
  }

  Widget buildButton(String buttonText) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new OutlineButton(
        padding: new EdgeInsets.all(24.0),
        child: new Text(buttonText,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        onPressed: () => 
          buttonPressed(buttonText)
        ,
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
        return new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                alignment: Alignment.topCenter,
                padding:
                     new EdgeInsets.symmetric(vertical: 36.0, horizontal: 12.0),
                child: new Text(_readableState,
                    style: new TextStyle(
                        fontSize: 36.0, fontWeight: FontWeight.bold))
              ),
              // new Container(
              //   alignment: Alignment.center,
              //   padding:
              //       new EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              //   child: new Text(output,
              //       style: new TextStyle(
              //           fontSize: 36.0, fontWeight: FontWeight.bold)),
              // ),
              new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buildButton("1"),
                      buildButton("2"),
                      buildButton("3")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buildButton("4"),
                      buildButton("5"),
                      buildButton("6")
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buildButton("7"),
                      buildButton("8"),
                      buildButton("9")
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
