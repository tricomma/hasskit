import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/model/Sensor.dart';
import 'package:http/http.dart' as http;

/// Timeseries chart example
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EntityControlSensor extends StatefulWidget {
  final String entityId;

  const EntityControlSensor({@required this.entityId});

  @override
  _EntityControlSensorState createState() => _EntityControlSensorState();
}

class _EntityControlSensorState extends State<EntityControlSensor> {
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
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: gd.mediaQueryHeight - kBottomNavigationBarHeight - kToolbarHeight,
      width: gd.mediaQueryWidth,
      child: ModalProgressHUD(
        inAsyncCall: inAsyncCall,
        opacity: 0,
        progressIndicator: SpinKitThreeBounce(
          size: 40,
          color: Colors.grey.withOpacity(0.5),
        ),
        child: Container(
          height: gd.mediaQueryWidth * 5 / 8,
          child: TimeSeriesRangeAnnotationChart.withSampleData(),
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

    log.d("url $url");

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
//        log.w("response.statusCode ${response.statusCode}");
        var jsonResponse = jsonDecode(response.body);
//        log.d("jsonResponse $jsonResponse");
        gd.sensors = [];
        int i = 0;
        for (var rec in jsonResponse[0]) {
          var sensor = Sensor.fromJson(rec);
          gd.sensors.add(sensor);
          i++;
        }

        if (i > 0 && jsonResponse[0][i - 1] != null) {
          batteryLevel = (jsonResponse[0][i - 1]["attributes"]["battery_level"])
              .toString();
          deviceClass =
              (jsonResponse[0][i - 1]["attributes"]["device_class"]).toString();
//          log.d(
//              "gd.sensors.length ${gd.sensors.length} batteryLevel $batteryLevel deviceClass $deviceClass");
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
    } finally {
//      setState(() {
      inAsyncCall = false;
//      });
      client.close();
    }
  }
}

// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class TimeSeriesRangeAnnotationChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  TimeSeriesRangeAnnotationChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory TimeSeriesRangeAnnotationChart.withSampleData() {
    return new TimeSeriesRangeAnnotationChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Sensor, DateTime>> _createSampleData() {
//    final data = [
//      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
//      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
//      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
//      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
//    ];
//    return [
//      new charts.Series<TimeSeriesSales, DateTime>(
//        id: 'Sales',
//        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//        domainFn: (TimeSeriesSales sales, _) => sales.time,
//        measureFn: (TimeSeriesSales sales, _) => sales.sales,
//        data: data,
//      )
//    ];

//    final data = [];
//
//    for (var sensor in gd.sensors) {
//      var dateParse = DateTime.tryParse(sensor.lastChanged).toLocal();
//      var state = double.tryParse(sensor.state);
//
//      if (dateParse != null && state != null) {
//        var timeSeriesSales = TimeSeriesSales(
//          dateParse,
//          state,
//        );
////        log.d(
////            "timeSeriesSales ${timeSeriesSales.time} ${timeSeriesSales.sales}");
//        data.add(timeSeriesSales);
//      }
//    }

    return [
      new charts.Series<Sensor, DateTime>(
        id: 'Chart',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (Sensor sensor, _) =>
            DateTime.tryParse(sensor.lastChanged).toLocal(),
        measureFn: (Sensor sensor, _) => double.tryParse(sensor.state),
        data: gd.sensors,
      )
    ];
  }
}
