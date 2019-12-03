import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';
import 'package:hasskit/helper/LocaleHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class EntityGeoLocation extends StatefulWidget {
  final String entityId;

  const EntityGeoLocation({@required this.entityId});
  @override
  _EntityGeoLocationState createState() =>
      _EntityGeoLocationState();
}

class _EntityGeoLocationState extends State<EntityGeoLocation> {

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition getCameraPosition(double lat, double long) {
    return CameraPosition(zoom: 14.4746, target: LatLng(lat, long));
  }

  Set<Marker> _createMarker(var entity) {
    return <Marker>[
      Marker(
        markerId: MarkerId(entity.entityId),
        position: LatLng(entity.latitude, entity.longitude),
        infoWindow: InfoWindow(title: entity.friendlyName)
        //Maybe we should add icon: entityPicture?
      ),
    ].toSet();
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
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

        final GoogleMap googleMap = GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: getCameraPosition(entity.latitude, entity.longitude),
          onMapCreated: (GoogleMapController controller) {
            if(!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          markers: _createMarker(entity),
        );

        return Container(
            child: new Column(
              children: <Widget>[
                Container(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: googleMap,
                  )
                ),
                Container(
                  padding: new EdgeInsets.symmetric(
                    horizontal: 0.0,
                    vertical: 20.0,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: Text("Battery: " + entity.batteryLevel.toString() + "%", textAlign: TextAlign.right),
                  )
                ),
              ],
            )
        );
      },
    );
  }
}
