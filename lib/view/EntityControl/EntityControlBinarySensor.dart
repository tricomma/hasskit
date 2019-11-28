import 'package:auto_size_text/auto_size_text.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Sensor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EntityControlBinarySensor extends StatefulWidget {
  final String entityId;
  final bool horizontalMode;
  const EntityControlBinarySensor({
    @required this.entityId,
    this.horizontalMode = false,
  });

  @override
  _EntityControlBinarySensorState createState() =>
      _EntityControlBinarySensorState();
}

class _EntityControlBinarySensorState extends State<EntityControlBinarySensor> {
  String batteryLevel;
  String deviceClass;
  bool inAsyncCall = true;
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  @override
  Widget build(BuildContext context) {
//    List<Sensor> binarySensorsReversed = gd.sensors.reversed.toList();
    List<Sensor> binarySensorsReversed = [];
    for (int i = gd.sensors.length - 1; i > 0; i--) {
      if (gd.sensors[i - 1] == null ||
          gd.sensors[i - 1].isStateOn == null ||
          gd.sensors[i - 1].isStateOn != gd.sensors[i].isStateOn) {
        binarySensorsReversed.add(gd.sensors[i]);
      }
    }

    return Container(
      padding: EdgeInsets.all(8),
      height: gd.mediaQueryHeight - kBottomNavigationBarHeight - kToolbarHeight,
      child: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        opacity: 0,
        progressIndicator: SpinKitThreeBounce(
          size: 40,
          color: Colors.grey.withOpacity(0.025),
        ),
        child: inAsyncCall
            ? Container()
            : !widget.horizontalMode
                ? ListView.builder(
                    itemCount: binarySensorsReversed.length,
                    itemBuilder: (BuildContext context, int index) {
                      var rec = binarySensorsReversed[index];
                      var changedTime =
                          DateTime.parse(rec.lastChanged).toLocal();
                      var formattedChangedTime =
                          DateFormat('kk:mm:ss').format(changedTime);
                      var timeDiff = DateTime.now()
                          .difference(DateTime.parse(rec.lastChanged));
                      Duration duration;

                      if (!rec.isStateOn &&
                          index + 1 < binarySensorsReversed.length &&
                          binarySensorsReversed[index + 1] != null &&
                          binarySensorsReversed[index + 1].isStateOn) {
                        var date1 = DateTime.parse(rec.lastChanged);
                        var date2 = DateTime.parse(
                            binarySensorsReversed[index + 1].lastChanged);
                        duration = date1.difference(date2);
                      }

                      return Stack(
                        alignment: rec.isStateOn
                            ? Alignment.topLeft
                            : Alignment.bottomLeft,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 25),
                            color: ThemeInfo.colorIconActive,
                            width: 2,
                            height: 5,
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 6),
                                Container(
                                  padding: EdgeInsets.all(2),
                                  alignment: Alignment.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: rec.isStateOn
                                        ? ThemeInfo.colorIconActive
                                            .withOpacity(0.25)
                                        : ThemeInfo.colorIconInActive
                                            .withOpacity(0),
                                    border: Border.all(
                                      color: ThemeInfo.colorIconActive,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: FittedBox(
                                    child: Text(
                                        "${stateString(deviceClass, binarySensorsReversed[index].isStateOn)}"),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$formattedChangedTime',
                                  style: Theme.of(context).textTheme.subtitle,
                                  textScaleFactor: gd.textScaleFactor,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: rec.isStateOn
                                      ? Text(
                                          '${printDuration(timeDiff, abbreviated: false, tersity: DurationTersity.minute, spacer: ' ', delimiter: ' ', conjugation: ' and ')} ago',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle,
                                          textScaleFactor: gd.textScaleFactor,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : duration != null
                                          ? Text(
                                              "Duration: ${printDuration(duration, abbreviated: true, tersity: DurationTersity.second, spacer: '', delimiter: ' ', conjugation: ' and ')}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle,
                                              textScaleFactor:
                                                  gd.textScaleFactor,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(""),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: binarySensorsReversed.length,
                    itemBuilder: (BuildContext context, int index) {
                      var rec = binarySensorsReversed[index];
                      var changedTime =
                          DateTime.parse(rec.lastChanged).toLocal();
                      var formattedChangedTime =
                          DateFormat('kk:mm').format(changedTime);

                      if (!rec.isStateOn &&
                          index + 1 < binarySensorsReversed.length &&
                          binarySensorsReversed[index + 1] != null &&
                          binarySensorsReversed[index + 1].isStateOn) {}

                      return Stack(
                        alignment: rec.isStateOn
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        children: <Widget>[
                          Container(
                            width: 5,
                            height: 2,
                            color: ThemeInfo.colorIconActive,
                          ),
                          Container(
                            alignment: rec.isStateOn
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            width: 52,
                            margin: rec.isStateOn
                                ? EdgeInsets.only(left: 2)
                                : EdgeInsets.only(right: 8),
                            padding: rec.isStateOn
                                ? EdgeInsets.all(8)
                                : EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rec.isStateOn
                                  ? ThemeInfo.colorIconActive.withOpacity(0.25)
                                  : ThemeInfo.colorIconInActive.withOpacity(0),
                              border: Border.all(
                                color: ThemeInfo.colorIconActive,
                                width: 2.0,
                              ),
                            ),
                            child: AutoSizeText(
                              "$formattedChangedTime",
                              maxLines: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }

  void getHistory() async {
    var client = new http.Client();
    var url = gd.currentUrl +
        "/api/history/period?filter_entity_id=${widget.entityId}";
    Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${gd.loginDataCurrent.longToken}',
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        log.w("response.statusCode ${response.statusCode}");
        var jsonResponse = jsonDecode(response.body);
        gd.sensors = [];

        int i = 0;
        for (var rec in jsonResponse[0]) {
          var binarySensor = Sensor.fromJson(rec);
          gd.sensors.add(binarySensor);
          i++;
        }

        if (i > 0 && jsonResponse[0][i - 1] != null) {
//          log.d(
//              "Total record: ${i} lenght: ${jsonResponse[0].toString().length}");
          batteryLevel = (jsonResponse[0][i - 1]["attributes"]["battery_level"])
              .toString();
          deviceClass =
              (jsonResponse[0][i - 1]["attributes"]["device_class"]).toString();
          log.d(
              "gd.sensors.length ${gd.sensors.length} batteryLevel $batteryLevel deviceClass $deviceClass");
        }
        setState(() {
          inAsyncCall = false;
        });
      } else {
        setState(() {
          inAsyncCall = false;
        });
        print("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      inAsyncCall = false;
      log.e("getHistory $e");
    } finally {
//      setState(() {
      inAsyncCall = false;
//      });
      client.close();
    }
  }
}

String stateString(String deviceClass, bool isStateOn) {
//  log.d("stateString deviceClass $deviceClass");
  if (deviceClass.contains("garage_door") ||
      deviceClass.contains("door") ||
      deviceClass.contains("lock") ||
      deviceClass.contains("opening") ||
      deviceClass.contains("window")) {
    if (isStateOn) {
      return "open";
    }
    return "closed";
  }

  if (isStateOn) {
    return "on";
  }
  return "off";
}
