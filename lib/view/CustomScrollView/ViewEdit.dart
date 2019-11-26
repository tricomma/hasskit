import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/view/CustomScrollView/DeviceTypeHeader.dart';
import 'package:hasskit/view/CustomScrollView/TemperatureSelector.dart';
import 'package:hasskit/view/slivers/SliverNavigationBar.dart';

import 'BackgroundImageSelector.dart';

class ViewEdit extends StatefulWidget {
  final int roomIndex;
  const ViewEdit({@required this.roomIndex});

  @override
  _ViewEditState createState() => _ViewEditState();
}

class _ViewEditState extends State<ViewEdit> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerSearch = TextEditingController();
  FocusNode addressFocusNode = new FocusNode();
  FocusNode addressFocusNodeSearch = new FocusNode();
  bool keyboardVisible = false;
  void dispose() {
    _controller.removeListener(addressFocusNodeListener);
    _controllerSearch.removeListener(addressFocusNodeListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = "${gd.getRoomName(widget.roomIndex)}";
    _controller.addListener(addressFocusNodeListener);
  }

  addressFocusNodeListener() {
    if (addressFocusNode.hasFocus) {
      keyboardVisible = true;
      gd.delayCancelEditModeTimer(300);
      log.w(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    } else {
      keyboardVisible = false;
      log.w(
          "addressFocusNode.hasFocus ${addressFocusNode.hasFocus} $keyboardVisible");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverNavigationBar(roomIndex: widget.roomIndex),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: EdgeInsets.all(8),
                color: ThemeInfo.colorBottomSheet.withOpacity(0.8),
                child: TextFormField(
                  decoration: InputDecoration(prefixIcon: Icon(Icons.edit)),
                  focusNode: addressFocusNode,
                  controller: _controller,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.title,
                  maxLines: 1,
                  onChanged: (val) {
                    setState(() {
                      log.w("onChanged ${_controller.text}");
                      gd.setRoomName(gd.roomList[widget.roomIndex],
                          _controller.text.trim());
                      gd.delayCancelEditModeTimer(300);
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      log.w("onEditingComplete ${_controller.text}");
                      gd.setRoomName(gd.roomList[widget.roomIndex],
                          _controller.text.trim());
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
            ],
          ),
        ),
        BackgroundImageSelector(roomIndex: widget.roomIndex),
        TemperatureSelector(roomIndex: widget.roomIndex),
//        HumiditySelector(roomIndex: widget.roomIndex),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(
                padding: EdgeInsets.all(8),
                color: ThemeInfo.colorBottomSheet.withOpacity(0.8),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Search devices...",
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    suffixIcon: Opacity(
                      opacity: _controllerSearch.text.trim().length > 0 ? 1 : 0,
                      child: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          _controllerSearch.clear();
                          gd.delayCancelEditModeTimer(300);
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  focusNode: addressFocusNodeSearch,
                  controller: _controllerSearch,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.title,
                  maxLines: 1,
                  onChanged: (val) {
                    setState(() {});
                    gd.delayCancelEditModeTimer(300);
                  },
                  onEditingComplete: () {
                    setState(() {
                      log.w("onEditingComplete ${_controllerSearch.text}");
                      gd.delayCancelEditModeTimer(300);
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
            ],
          ),
        ),
        DeviceTypeHeaderEdit(
          title: "Selected devices...",
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
              "mdi:checkbox-marked")),
        ),
        _EditItems(
          selectedItem: true,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.lightSwitches],
        ),
        DeviceTypeHeaderEdit(
          title: "Lights, Switches...",
          icon: Icon(
              MaterialDesignIcons.getIconDataFromIconName("mdi:toggle-switch")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.lightSwitches],
        ),
        DeviceTypeHeaderEdit(
          title: "Climate, Fans...",
          icon: Icon(
              MaterialDesignIcons.getIconDataFromIconName("mdi:thermometer")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.climateFans],
        ),
        DeviceTypeHeaderEdit(
          title: "Cameras...",
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:webcam")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.cameras],
        ),
        DeviceTypeHeaderEdit(
          title: "Media Players...",
          icon:
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:theater")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.mediaPlayers],
        ),
        DeviceTypeHeaderEdit(
          title: "Groups...",
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:blur")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.group],
        ),
        DeviceTypeHeaderEdit(
          title: "Accessories...",
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:ballot")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.accessories],
        ),
        DeviceTypeHeaderEdit(
          title: "Script, Automation...",
          icon: Icon(MaterialDesignIcons.getIconDataFromIconName(
              "mdi:home-automation")),
        ),
        _EditItems(
          selectedItem: false,
          roomIndex: widget.roomIndex,
          keyword: _controllerSearch.text.trim(),
          types: [EntityType.scriptAutomation],
        ),
        SliverSafeArea(sliver: gd.emptySliver),
      ],
    );
  }
}

class _EditItems extends StatefulWidget {
  final bool selectedItem;
  final int roomIndex;
  final String keyword;
  final List<EntityType> types;
  const _EditItems(
      {@required this.selectedItem,
      this.roomIndex,
      @required this.keyword,
      @required this.types});

  @override
  __EditItemsState createState() => __EditItemsState();
}

class __EditItemsState extends State<_EditItems> {
  @override
  Widget build(BuildContext context) {
    List<Entity> entities = [];

    if (!widget.selectedItem) {
      entities = gd.entities.values
          .where((e) =>
              !gd.roomList[widget.roomIndex].favorites.contains(e.entityId) &&
              !gd.roomList[widget.roomIndex].entities.contains(e.entityId) &&
              !gd.roomList[widget.roomIndex].row3.contains(e.entityId) &&
              !gd.roomList[widget.roomIndex].row4.contains(e.entityId) &&
              widget.types.contains(e.entityType) &&
              (widget.keyword.length < 1 ||
                  e.getOverrideName
                      .toLowerCase()
                      .contains(widget.keyword.toLowerCase()) ||
                  e.entityId
                      .toLowerCase()
                      .contains(widget.keyword.toLowerCase())))
          .toList();
    } else {
      entities = gd.entities.values
          .where((e) =>
              (gd.roomList[widget.roomIndex].favorites.contains(e.entityId) ||
                  gd.roomList[widget.roomIndex].entities.contains(e.entityId) ||
                  gd.roomList[widget.roomIndex].row3.contains(e.entityId) ||
                  gd.roomList[widget.roomIndex].row4.contains(e.entityId)) &&
              (widget.keyword.length < 1 ||
                  e.getOverrideName
                      .toLowerCase()
                      .contains(widget.keyword.toLowerCase()) ||
                  e.entityId
                      .toLowerCase()
                      .contains(widget.keyword.toLowerCase())))
          .toList();
    }

    if (entities.length < 1) {
      return gd.emptySliver;
    }

    if (!widget.selectedItem)
      entities.sort((a, b) => a.getOverrideName.compareTo(b.getOverrideName));

    void removeItemFromGroup(String entityId, String except) {
      if (except != "favorites" &&
          gd.roomList[widget.roomIndex].favorites.contains(entityId))
        gd.roomList[widget.roomIndex].favorites.remove(entityId);
      if (except != "entities" &&
          gd.roomList[widget.roomIndex].entities.contains(entityId))
        gd.roomList[widget.roomIndex].entities.remove(entityId);
      if (except != "row3" &&
          gd.roomList[widget.roomIndex].row3.contains(entityId))
        gd.roomList[widget.roomIndex].row3.remove(entityId);
      if (except != "row4" &&
          gd.roomList[widget.roomIndex].row4.contains(entityId))
        gd.roomList[widget.roomIndex].row4.remove(entityId);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            gd.delayCancelEditModeTimer(300);
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
            margin: EdgeInsets.zero,
            child: Row(
              children: <Widget>[
                Opacity(
                  opacity: (gd.roomList[widget.roomIndex].favorites
                              .contains(entities[index].entityId) ||
                          gd.roomList[widget.roomIndex].entities
                              .contains(entities[index].entityId) ||
                          gd.roomList[widget.roomIndex].row3
                              .contains(entities[index].entityId) ||
                          gd.roomList[widget.roomIndex].row4
                              .contains(entities[index].entityId))
                      ? 1
                      : 0.5,
                  child: Icon(
                    entities[index].mdiIcon,
                    size: 28,
                    color: Theme.of(context).textTheme.title.color,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Opacity(
                    opacity: (gd.roomList[widget.roomIndex].favorites
                                .contains(entities[index].entityId) ||
                            gd.roomList[widget.roomIndex].entities
                                .contains(entities[index].entityId) ||
                            gd.roomList[widget.roomIndex].row3
                                .contains(entities[index].entityId) ||
                            gd.roomList[widget.roomIndex].row4
                                .contains(entities[index].entityId))
                        ? 1
                        : 0.5,
                    child: AutoSizeText(
                      "${gd.textToDisplay(entities[index].getOverrideName)}",
                      style: Theme.of(context).textTheme.subhead,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: gd.textScaleFactor,
                      maxLines: 1,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (gd.roomList[widget.roomIndex].favorites
                        .contains(entities[index].entityId)) {
                      gd.roomList[widget.roomIndex].favorites
                          .remove(entities[index].entityId);
                    } else {
                      gd.roomList[widget.roomIndex].favorites
                          .add(entities[index].entityId);
                      removeItemFromGroup(
                          entities[index].entityId, "favorites");
                    }

                    gd.roomListSave(true);
                    gd.delayCancelEditModeTimer(300);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.looks_one,
                    size: 28,
                    color: gd.roomList[widget.roomIndex].favorites
                            .contains(entities[index].entityId)
                        ? Theme.of(context).textTheme.title.color
                        : Theme.of(context)
                            .textTheme
                            .title
                            .color
                            .withOpacity(0.25),
                  ),
                ),
                SizedBox(width: 0),
                InkWell(
                  onTap: () {
                    if (gd.roomList[widget.roomIndex].entities
                        .contains(entities[index].entityId)) {
                      gd.roomList[widget.roomIndex].entities
                          .remove(entities[index].entityId);
                    } else {
                      gd.roomList[widget.roomIndex].entities
                          .add(entities[index].entityId);
                      removeItemFromGroup(entities[index].entityId, "entities");
                    }
                    gd.roomListSave(true);
                    gd.delayCancelEditModeTimer(300);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.looks_two,
                    size: 28,
                    color: gd.roomList[widget.roomIndex].entities
                            .contains(entities[index].entityId)
                        ? Theme.of(context).textTheme.title.color
                        : Theme.of(context)
                            .textTheme
                            .title
                            .color
                            .withOpacity(0.25),
                  ),
                ),
                SizedBox(width: 0),
                InkWell(
                  onTap: () {
                    if (gd.roomList[widget.roomIndex].row3
                        .contains(entities[index].entityId)) {
                      gd.roomList[widget.roomIndex].row3
                          .remove(entities[index].entityId);
                    } else {
                      gd.roomList[widget.roomIndex].row3
                          .add(entities[index].entityId);
                      removeItemFromGroup(entities[index].entityId, "row3");
                    }
                    gd.roomListSave(true);
                    gd.delayCancelEditModeTimer(300);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.looks_3,
                    size: 28,
                    color: gd.roomList[widget.roomIndex].row3
                            .contains(entities[index].entityId)
                        ? Theme.of(context).textTheme.title.color
                        : Theme.of(context)
                            .textTheme
                            .title
                            .color
                            .withOpacity(0.25),
                  ),
                ),
                SizedBox(width: 0),
                InkWell(
                  onTap: () {
                    if (gd.roomList[widget.roomIndex].row4
                        .contains(entities[index].entityId)) {
                      gd.roomList[widget.roomIndex].row4
                          .remove(entities[index].entityId);
                    } else {
                      gd.roomList[widget.roomIndex].row4
                          .add(entities[index].entityId);
                      removeItemFromGroup(entities[index].entityId, "row4");
                    }
                    gd.roomListSave(true);
                    gd.delayCancelEditModeTimer(300);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.looks_4,
                    size: 28,
                    color: gd.roomList[widget.roomIndex].row4
                            .contains(entities[index].entityId)
                        ? Theme.of(context).textTheme.title.color
                        : Theme.of(context)
                            .textTheme
                            .title
                            .color
                            .withOpacity(0.25),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (gd.activeDevices.contains(entities[index].entityId)) {
                      gd.activeDevices.remove(entities[index].entityId);
                      gd.baseSettingSave(true);
                      setState(() {});
                    } else if (gd
                        .activeDevicesSupportedType(entities[index].entityId)) {
                      gd.activeDevices.add(entities[index].entityId);
                      gd.baseSettingSave(true);
                      setState(() {});
                    }
                    gd.delayCancelEditModeTimer(300);
                  },
                  child: Icon(
                    gd.activeDevices.contains(entities[index].entityId)
                        ? Icons.notifications
                        : Icons.notifications_off,
                    size: 28,
                    color: gd.activeDevices.contains(entities[index].entityId)
                        ? Theme.of(context).textTheme.title.color
                        : (gd.activeDevicesSupportedType(
                                entities[index].entityId))
                            ? Theme.of(context)
                                .textTheme
                                .title
                                .color
                                .withOpacity(0.25)
                            : Theme.of(context)
                                .textTheme
                                .title
                                .color
                                .withOpacity(0.0),
                  ),
                ),
                SizedBox(
                  width: 4,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
        childCount: entities.length,
      ),
    );
  }
}
