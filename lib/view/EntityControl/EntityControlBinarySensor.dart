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

  const EntityControlBinarySensor({@required this.entityId});

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
    List<Sensor> binarySensorsReversed = gd.sensors.reversed.toList();
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      height: gd.mediaQueryHeight - kBottomNavigationBarHeight - kToolbarHeight,
      child: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        opacity: 0,
        progressIndicator: SpinKitThreeBounce(
          size: 40,
          color: Colors.grey.withOpacity(0.5),
        ),
        child: inAsyncCall
            ? Container()
            : ListView.builder(
                itemCount: binarySensorsReversed.length,
                itemBuilder: (BuildContext context, int index) {
                  var rec = binarySensorsReversed[index];
                  var changedTime = DateTime.parse(rec.lastChanged).toLocal();
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
//                var topColor = ThemeInfo.colorIconInActive.withOpacity(0.5);
                  var topColor = Colors.transparent;
                  if (index == 0)
                    topColor = Colors.transparent;
                  else if (rec.isStateOn) {
                    topColor = ThemeInfo.colorIconActive.withOpacity(1);
                  }
//                var bottomColor = ThemeInfo.colorIconInActive.withOpacity(0.5);
                  var bottomColor = Colors.transparent;
                  if (index >= binarySensorsReversed.length - 1)
                    bottomColor = Colors.transparent;
                  else if (binarySensorsReversed[index + 1].isStateOn) {
                    bottomColor = ThemeInfo.colorIconActive.withOpacity(1);
                  }

                  return Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  width: 2,
                                  height: 30,
                                  color: topColor,
                                ),
                                Container(
                                  alignment: Alignment.topCenter,
                                  width: 2,
                                  height: 30,
                                  color: bottomColor,
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: binarySensorsReversed[index].isStateOn
                                    ? ThemeInfo.colorIconActive
                                    : ThemeInfo.colorIconInActive,
                              ),
                              child: FittedBox(
                                child: Text(
                                    "${stateString(deviceClass, binarySensorsReversed[index].isStateOn)}"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Text(
                          '$formattedChangedTime',
                          style: Theme.of(context).textTheme.subtitle,
                          textScaleFactor: gd.textScaleFactor,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: rec.isStateOn
                              ? Text(
                                  '${printDuration(timeDiff, abbreviated: true, tersity: DurationTersity.second, delimiter: ', ', conjugation: ' and ')} ago',
                                  style: Theme.of(context).textTheme.subtitle,
                                  textScaleFactor: gd.textScaleFactor,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : duration != null
                                  ? Text(
                                      "${printDuration(duration, abbreviated: true, tersity: DurationTersity.second, delimiter: ', ', conjugation: ' and ')} duration",
                                      style:
                                          Theme.of(context).textTheme.subtitle,
                                      textScaleFactor: gd.textScaleFactor,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(""),
                        ),
                      ],
                    ),
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
