import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class EntityButton extends StatelessWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;
  final Color borderColor;
  final String indicatorIcon;
  const EntityButton(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback,
      @required this.borderColor,
      @required this.indicatorIcon});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.connectionStatus} " +
          "${generalData.eventEntity(entityId)} " +
          "${generalData.entities[entityId].getStateDisplay} " +
          "${generalData.entities[entityId].getOverrideName} " +
          "${generalData.entities[entityId].getOverrideIcon} ",
      builder: (context, data, child) {
        return Hero(
          tag: entityId,
          child: InkWell(
            onTap: onTapCallback,
            onLongPress: onLongPressCallback,
            child: EntityButtonDisplay(entityId: entityId),
          ),
        );
      },
    );
  }
}

class EntityButtonDisplay extends StatefulWidget {
  const EntityButtonDisplay({@required this.entityId});

  final String entityId;

  @override
  _EntityButtonDisplayState createState() => _EntityButtonDisplayState();
}

class _EntityButtonDisplayState extends State<EntityButtonDisplay> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8 * 3 / gd.itemsPerRow)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          onEnd: () {
            setState(() {
              gd.clickedStatus.remove(widget.entityId);
            });
          },
          margin: gd.getClickedStatus(widget.entityId)
              ? EdgeInsets.fromLTRB(3, 3, 3, 3)
              : EdgeInsets.zero,
          padding: EdgeInsets.all(4 * 3 / gd.itemsPerRow),
          decoration: BoxDecoration(
            color: gd.entities[widget.entityId].isStateOn
                ? ThemeInfo.colorBackgroundActive
                : ThemeInfo.colorEntityBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        "${gd.textToDisplay(gd.entities[widget.entityId].getOverrideName)}",
                        style: gd.entities[widget.entityId].isStateOn
                            ? ThemeInfo.textNameButtonActive
                            : ThemeInfo.textNameButtonInActive,
                        maxLines: 2,
                        textScaleFactor:
                            gd.textScaleFactor * 3 / gd.itemsPerRow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: <Widget>[
                          EntityIcon(entityId: widget.entityId),
                          EntityIconStatus(entityId: widget.entityId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${gd.textToDisplay(gd.entities[widget.entityId].getStateDisplay)}",
                style: gd.entities[widget.entityId].isStateOn
                    ? ThemeInfo.textStatusButtonActive
                    : ThemeInfo.textStatusButtonInActive,
                maxLines: 1,
                textScaleFactor: gd.textScaleFactor * 3 / gd.itemsPerRow,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityIconStatus extends StatelessWidget {
  const EntityIconStatus({
    Key key,
    @required this.entityId,
  }) : super(key: key);

  final String entityId;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        alignment: Alignment.centerRight,
        child: (gd.showSpin || gd.entities[entityId].state.contains("..."))
            ? SpinKitThreeBounce(
                size: 100,
                color: ThemeInfo.colorIconActive,
              )
            : gd.viewMode == ViewMode.sort
//                ? Stack(
//                    children: <Widget>[
//                      Container(
//                        width: 100,
//                        height: 100,
//                        decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.circular(8)),
//                      ),
//                      SpinKitFadingGrid(
//                        size: 100,
//                        color: Colors.black,
//                      ),
//                      Container(),
//                    ],
//                  )
                ? Icon(
                    MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:cursor-move"),
                    size: 100,
                    color: Colors.amber.withOpacity(0.8),
                  )
                : Container(),
      ),
    );
  }
}

class EntityIcon extends StatelessWidget {
  final String entityId;

  const EntityIcon({@required this.entityId});
  @override
  Widget build(BuildContext context) {
//    log.d("Widget build _EntityIcon $entityId");

    var iconWidget;
    var entity = gd.entities[entityId];
    if (entity.entityId.contains("climate.")) {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.brightness_1,
              color: gd.climateModeToColor(entity.state),
            ),
            Column(
              children: <Widget>[
                Text(
                  "${entity.getTemperature.toInt()}",
                  style: ThemeInfo.textNameButtonActive.copyWith(
                    color: ThemeInfo.colorBottomSheet,
                  ),
                  textScaleFactor:
                      gd.textScaleFactor * 0.8 * 3 / gd.itemsPerRow,
                ),
              ],
            ),
          ],
        ),
      );
    } else if (entity.entityId.contains("alarm_control_panel")) {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
                entity.state.contains("disarmed")
                    ? MaterialDesignIcons.getIconDataFromIconName(
                        "mdi:shield-check")
                    : entity.state.contains("pending")
                        ? MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:shield-outline")
                        : MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:shield-lock"),
                color: entity.state.contains("disarmed")
                    ? Colors.green
                    : entity.state.contains("pending")
                        ? ThemeInfo.colorIconActive
                        : Colors.red),
          ],
        ),
      );
    } else {
      iconWidget = FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              entity.mdiIcon,
              color: entity.isStateOn
                  ? ThemeInfo.colorIconActive
                  : ThemeInfo.colorIconInActive,
            ),
          ],
        ),
      );
    }
    return AspectRatio(aspectRatio: 1, child: iconWidget);
  }
}
