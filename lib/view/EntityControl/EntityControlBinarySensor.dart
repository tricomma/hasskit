import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/BinarySensor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    getHistory();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
      height: gd.mediaQueryHeight -
          kBottomNavigationBarHeight -
          kToolbarHeight -
          kToolbarHeight,
      child: Selector<GeneralData, List<BinarySensor>>(
        selector: (_, generalData) => gd.binarySensors,
        builder: (context, data, child) {
          List<BinarySensor> binarySensorsReversed =
              gd.binarySensors.reversed.toList();
          return ListView.builder(
            itemCount: binarySensorsReversed.length,
            itemBuilder: (BuildContext context, int index) {
              var rec = binarySensorsReversed[index];
              var changedTime = DateTime.parse(rec.lastChanged).toLocal();
              var formattedChangedTime =
                  DateFormat('kk:mm:ss').format(changedTime);
              var timeDiff =
                  DateTime.now().difference(DateTime.parse(rec.lastChanged));
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
                height: 50,
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
                              height: 25,
                              color: topColor,
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              width: 2,
                              height: 25,
                              color: bottomColor,
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: binarySensorsReversed[index].isStateOn
                                ? ThemeInfo.colorIconActive
                                : ThemeInfo.colorIconInActive,
                          ),
                          child: Text("${binarySensorsReversed[index].state}"),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
//                      Expanded(
//                        child: Text(
//                            'Entry ${gd.binarySensors[index].lastChanged}'),
//                      ),
                    Text(
                      '$formattedChangedTime',
                      style: Theme.of(context).textTheme.caption,
                      textScaleFactor: gd.textScaleFactor,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: rec.isStateOn
                          ? Text(
                              'Started ${printDuration(timeDiff, abbreviated: true, tersity: DurationTersity.second, delimiter: ', ', conjugation: ' and ')} ago',
                              style: Theme.of(context).textTheme.caption,
                              textScaleFactor: gd.textScaleFactor,
                              overflow: TextOverflow.ellipsis,
                            )
                          : duration != null
                              ? Text(
                                  "Lasted ${printDuration(duration, abbreviated: true, tersity: DurationTersity.second, delimiter: ', ', conjugation: ' and ')}",
                                  style: Theme.of(context).textTheme.caption,
                                  textScaleFactor: gd.textScaleFactor,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(""),
                    ),
//                      Expanded(
//                        child: Text('${DateTime.now()}'),
//                      ),
                  ],
                ),
              );
            },
          );
        },
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

    log.d("url $url headers $headers");
    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        gd.binarySensors = [];
        log.d("\n\njsonResponse");
        int i = 0;
        for (var rec in jsonResponse[0]) {
          var binarySensor = BinarySensor.fromJson(rec);
          gd.binarySensors.add(binarySensor);
//          log.d(
//              "binarySensor ${binarySensor.state} lastUpdated ${binarySensor.lastChanged}");
          i++;
        }

        if (i > 0 && jsonResponse[0][i - 1] != null) {
          batteryLevel = (jsonResponse[0][i - 1]["attributes"]["battery_level"])
              .toString();
          deviceClass =
              (jsonResponse[0][i - 1]["attributes"]["device_class"]).toString();
          log.d("batteryLevel $batteryLevel");
        }
      } else {
        print("Request failed with status: ${response.statusCode}.");
      }
    } finally {
      client.close();
    }
  }

  Future<void> setup() async {
//    final String currentTimeZone =
//        await FlutterNativeTimezone.getLocalTimezone();
//
//    log.d("currentTimeZone $currentTimeZone");

//    await initializeTimeZone();
//    final detroit = getLocation('America/Detroit');
//    final now = new TZDateTime.now(detroit);
//    log.d("now $now");
//    setLocalLocation(detroit);
  }
}
