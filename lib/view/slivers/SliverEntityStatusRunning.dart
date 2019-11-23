import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class SliverEntityStatusRunning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entitiesStatusShow} " +
          "${generalData.entitiesStatusRunning.length} ",
      builder: (context, data, child) {
        List<Widget> status2ndRowButtons = [];

        for (var entity in gd.entitiesStatusRunning) {
          status2ndRowButtons.add(Status2ndRowItem(entityId: entity.entityId));
        }
        return gd.entitiesStatusShow && gd.entitiesStatusRunning.length > 0
            ? SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      height: 50.0,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: status2ndRowButtons),
                    ),
                  ],
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate(
                  [],
                ),
              );
      },
    );
  }
}

class Status2ndRowItem extends StatelessWidget {
  const Status2ndRowItem({
    @required this.entityId,
  });

  final String entityId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        gd.toggleStatus(gd.entities[entityId]);
        if (gd.entitiesStatusRunning.length <= 0) {
          gd.entitiesStatusShowOffTimer(0);
        } else {
          gd.entitiesStatusShowOffTimer(60);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.all(2),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ThemeInfo.colorBackgroundActive,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              MaterialDesignIcons.getIconDataFromIconName(
                  gd.entities[entityId].getDefaultIcon),
              color: ThemeInfo.colorIconActive,
              size: 28,
            ),
            Text(
              "${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
              style: ThemeInfo.textStatusButtonActive,
              textScaleFactor: gd.textScaleFactor * 0.5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
