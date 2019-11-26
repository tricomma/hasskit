import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';

class EntityControlMediaPlayer extends StatelessWidget {
  final String entityId;
  const EntityControlMediaPlayer({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) => "${generalData.eventEntity(entityId)} "
          "${generalData.entities[entityId].isStateOn} "
          "${generalData.entities[entityId].state} "
          "${generalData.entities[entityId].volumeLevel} "
          "${generalData.entities[entityId].isVolumeMuted} "
          "${generalData.entities[entityId].mediaContentType} "
          "${generalData.entities[entityId].mediaTitle} "
          "${generalData.entities[entityId].source} "
          "${generalData.entities[entityId].sourceList.length} "
          "${generalData.entities[entityId].soundMode} "
          "${generalData.entities[entityId].soundModeList.length} "
          "${generalData.entities[entityId].soundModeRaw} "
          "",
      builder: (_, generalData, __) {
        Entity entity = gd.entities[entityId];
        return Container(
          child: Column(
            children: <Widget>[
              !entity.isStateOn
                  ? Column(
                      children: <Widget>[
                        Container(
                          child: MediaPlayerButton(
                            entityId: entityId,
                            buttonData: ButtonData(
                              showWhen: entity != null &&
                                  !entity.isStateOn &&
                                  entity.getSupportedFeaturesMediaPlayer
                                      .contains("SUPPORT_TURN_ON"),
                              disableOnPowerOff: false,
                              icon: "mdi:power",
                              iconColor: ThemeInfo.colorIconInActive,
                              iconSize: 200,
                              json: jsonEncode(
                                {
                                  "service": "turn_on",
                                  "service_data": {
                                    "entity_id": entityId,
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        AutoSizeText(
                          "Turn On",
                          style: Theme.of(context).textTheme.display1,
                        )
                      ],
                    )
                  : Container(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Text(entity.mediaTitle),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: MediaPlayerSource(entityId: entityId)),
                  Expanded(child: MediaPlayerSoundMode(entityId: entityId)),
                ],
              ),
              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text(entity.mediaPosition.toString()),
              //     Text("/"),
              //     Text(entity.mediaDuration.toString())
              //   ],
              // ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MpSeekSlider(entityId: entityId),
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          entity.isStateOn &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_TURN_OFF"),
                      icon: "mdi:power",
                      json: jsonEncode(
                        {
                          "service": "turn_off",
                          "service_data": {
                            "entity_id": entityId,
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MpVolumeSlider(entityId: entityId),
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          !entity.isVolumeMuted &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_VOLUME_MUTE"),
                      icon: "mdi:volume-high",
                      json: jsonEncode(
                        {
                          "service": "volume_mute",
                          "service_data": {
                            "entity_id": entityId,
                            "is_volume_muted": true,
                          }
                        },
                      ),
                    ),
                  ),
                  MediaPlayerButton(
                    entityId: entityId,
                    buttonData: ButtonData(
                      showWhen: entity != null &&
                          entity.isVolumeMuted &&
                          entity.getSupportedFeaturesMediaPlayer
                              .contains("SUPPORT_VOLUME_MUTE"),
                      icon: "mdi:volume-off",
                      iconColor: ThemeInfo.colorIconInActive,
                      json: jsonEncode(
                        {
                          "service": "volume_mute",
                          "service_data": {
                            "entity_id": entityId,
                            "is_volume_muted": false,
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
//                          SUPPORT_VOLUME_STEP volume_down
//                        MediaPlayerButton(
//                          entityId: entityId,
//                          buttonData: ButtonData(
//                            showWhen: entity != null &&
//                                entity.isStateOn &&
//                                entity.getSupportedFeaturesMediaPlayer
//                                    .contains("SUPPORT_VOLUME_STEP"),
//                            icon: "mdi:volume-medium",
//                            json: jsonEncode(
//                              {
//                                "service": "volume_down",
//                                "service_data": {
//                                  "entity_id": entityId,
//                                }
//                              },
//                            ),
//                          ),
//                        ),
                        //SUPPORT_PREVIOUS_TRACK
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_PREVIOUS_TRACK"),
                            icon: "mdi:skip-previous-circle",
                            json: jsonEncode(
                              {
                                "service": "media_previous_track",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_STOP
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_STOP"),
                            icon: "mdi:stop-circle",
                            json: jsonEncode(
                              {
                                "service": "media_stop",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_PAUSE
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_PAUSE"),
                            icon: "mdi:pause-circle",
                            json: jsonEncode(
                              {
                                "service": "media_pause",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_PLAY_MEDIA
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                (entity.getSupportedFeaturesMediaPlayer
                                        .contains("SUPPORT_PLAY_MEDIA") ||
                                    entity.getSupportedFeaturesMediaPlayer
                                        .contains("SUPPORT_PLAY")),
                            icon: "mdi:play-circle",
                            json: jsonEncode(
                              {
                                "service": "media_play",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_NEXT_TRACK
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_NEXT_TRACK"),
                            icon: "mdi:skip-next-circle",
                            json: jsonEncode(
                              {
                                "service": "media_next_track",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
                        //SUPPORT_CLEAR_PLAYLIST
                        MediaPlayerButton(
                          entityId: entityId,
                          buttonData: ButtonData(
                            showWhen: entity != null &&
                                entity.isStateOn &&
                                entity.getSupportedFeaturesMediaPlayer
                                    .contains("SUPPORT_CLEAR_PLAYLIST"),
                            icon: "mdi:playlist-remove",
                            json: jsonEncode(
                              {
                                "service": "clear_playlist",
                                "service_data": {
                                  "entity_id": entityId,
                                }
                              },
                            ),
                          ),
                        ),
//                        //SUPPORT_VOLUME_STEP volume_up
//                        MediaPlayerButton(
//                          entityId: entityId,
//                          buttonData: ButtonData(
//                            showWhen: entity != null &&
//                                entity.isStateOn &&
//                                entity.getSupportedFeaturesMediaPlayer
//                                    .contains("SUPPORT_VOLUME_STEP"),
//                            icon: "mdi:volume-high",
//                            json: jsonEncode(
//                              {
//                                "service": "volume_up",
//                                "service_data": {
//                                  "entity_id": entityId,
//                                }
//                              },
//                            ),
//                          ),
//                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ButtonData {
  bool showWhen;
  bool disableOnPowerOff;
  String icon;
  String json;
  double iconSize;
  Color iconColor;

  ButtonData({
    @required this.showWhen,
    @required this.icon,
    @required this.json,
    this.disableOnPowerOff = true,
    this.iconSize = 40,
    this.iconColor = ThemeInfo.colorIconActive,
  });
}

class MediaPlayerButton extends StatelessWidget {
  final String entityId;
  final ButtonData buttonData;

  const MediaPlayerButton({
    @required this.entityId,
    @required this.buttonData,
  });

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];
    if (entity == null) return Container();
    if (!buttonData.showWhen ||
        buttonData.disableOnPowerOff && !entity.isStateOn) return Container();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: buttonData.iconSize,
        icon: Icon(
          MaterialDesignIcons.getIconDataFromIconName(buttonData.icon),
        ),
        color: buttonData.iconColor,
        onPressed: () {
          Map<String, dynamic> jsonCombined = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
          };
          Map<String, dynamic> buttonDataJson = jsonDecode(buttonData.json);
          jsonCombined.addAll(buttonDataJson);
//              log.d("jsonCombined $jsonCombined");
          var message = jsonEncode(jsonCombined);
          gd.sendSocketMessage(message);
          if (jsonCombined.toString().contains("turn_on"))
            entity.state = "turning on...";
          if (jsonCombined.toString().contains("turn_off"))
            entity.state = "turning off...";
        },
      ),
    );
  }
}

class MpSeekSlider extends StatefulWidget {
  final String entityId;

  const MpSeekSlider({@required this.entityId});

  @override
  _MpSeekSliderState createState() => _MpSeekSliderState();
}


class _MpSeekSliderState extends State<MpSeekSlider> {
  double media_position;
  double media_duration;
  Entity entity;
  double media_positionLast;
  bool supportSeekSet;
  DateTime isChanging;

  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    media_position = entity.mediaPosition;
    media_duration = entity.mediaDuration;    
    isChanging = DateTime.now();
  }

  String getSeekPosition(double pos) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int totalSeconds = (pos).floor();

    if(totalSeconds > 59) {
      minutes = (totalSeconds / 60).floor();

      if(minutes > 59) {
        hours = (minutes / 60).floor();

        minutes = minutes - (hours * 60);
      }

      seconds = totalSeconds - ((hours * 60 * 60) + (minutes * 60));
    }

    return "${hours}.${minutes}.${seconds}";
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    supportSeekSet =
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_SEEK");
    if (!entity.isStateOn || !supportSeekSet) return Container();

    if (isChanging.isBefore(DateTime.now())) {
      media_position = entity.mediaPosition;
    }
    return Expanded(
      child: Slider(
        value: media_position,
        min: 0.0,
        max: media_duration,
        divisions: media_duration.floor(),
        label: getSeekPosition(media_position),
        onChangeStart: (val) {
          isChanging = DateTime.now().add(Duration(days: 1));
        },
        onChangeEnd: (val) {
          if (val == media_positionLast) return;
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
            "service": "media_seek",
            "service_data": {"entity_id": widget.entityId, "seek_position": val}
          };
          entity.mediaPosition = val;
          media_positionLast = val;
          gd.sendSocketMessage(jsonEncode(outMsg));
          isChanging = DateTime.now().add(Duration(seconds: 1));
        },
        onChanged: !entity.isStateOn
            ? null
            : (val) {
                setState(() {
                  media_position = val;
                  isChanging = DateTime.now().add(Duration(days: 1));
                });
              },
      ),
    );
  }
}

class MpVolumeSlider extends StatefulWidget {
  final String entityId;

  const MpVolumeSlider({@required this.entityId});

  @override
  _MpVolumeSliderState createState() => _MpVolumeSliderState();
}

class _MpVolumeSliderState extends State<MpVolumeSlider> {
  double volume;
  Entity entity;
  double volumeLast;
  bool supportVolumeSet;
  DateTime isChanging;

  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    volume = entity.volumeLevel;
    isChanging = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    entity = gd.entities[widget.entityId];
    supportVolumeSet =
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_VOLUME_SET");
    if (!entity.isStateOn || !supportVolumeSet) return Container();

    if (isChanging.isBefore(DateTime.now())) {
      volume = entity.volumeLevel;
    }
    return Expanded(
      child: Slider(
        value: volume,
        min: 0.0,
        max: 1.0,
        divisions: 50,
        label: "${(volume * 100).toInt()}",
        onChangeStart: (val) {
          isChanging = DateTime.now().add(Duration(days: 1));
        },
        onChangeEnd: (val) {
          if (val == volumeLast) return;
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
            "service": "volume_set",
            "service_data": {"entity_id": widget.entityId, "volume_level": val}
          };
          entity.volumeLevel = val;
          volumeLast = val;
          gd.sendSocketMessage(jsonEncode(outMsg));
          isChanging = DateTime.now().add(Duration(seconds: 1));
        },
        onChanged: !entity.isStateOn
            ? null
            : (val) {
                setState(() {
                  volume = val;
                  isChanging = DateTime.now().add(Duration(days: 1));
                });
              },
      ),
    );
  }
}

class MediaPlayerSource extends StatelessWidget {
  final String entityId;
  const MediaPlayerSource({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];

    if (entity == null || entity.sourceList.length <= 0) return Container();

    log.d("entity.sourceList ${entity.sourceList}");
    log.d("entity.source ${entity.source}");
    var index = entity.sourceList.indexOf(entity.source);
    log.d("index ${index}");

    var sourceModeController = FixedExtentScrollController(initialItem: index);

    List<Widget> sourceList = [];

    for (String source in entity.sourceList) {
      var container = Container(
        alignment: entity.soundModeList.length > 0
            ? Alignment.center
            : Alignment.center,
        child: (AutoSizeText(
          source,
          style: Theme.of(context).textTheme.body1,
        )),
      );
      sourceList.add(container);
    }
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeInfo.pickerActivateStyle.color,
          width: 1.0,
        ),
      ),
      child: Column(
        children: <Widget>[
//          Container(
//            width: double.infinity,
//            alignment: Alignment.center,
//            decoration: BoxDecoration(
//                color: ThemeInfo.colorIconActive.withOpacity(1),
//                borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(8),
//                  topRight: entity.soundModeList.length > 0
//                      ? Radius.circular(0)
//                      : Radius.circular(8),
//                )),
//            padding: EdgeInsets.all(4),
//            child: AutoSizeText(
//              "Source",
//              style: Theme.of(context).textTheme.body1,
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
          Container(
            height: 128,
            margin: EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ThemeInfo.colorIconInActive.withOpacity(0),
                    ThemeInfo.colorIconInActive.withOpacity(0.5),
                    ThemeInfo.colorIconInActive.withOpacity(0),
                  ]),
            ),
            child: CupertinoPicker(
              squeeze: 1.45,
              diameterRatio: 1.1,
              offAxisFraction: 0,
              scrollController: sourceModeController,
              magnification: 0.7,
              backgroundColor: Colors.transparent,
              children: sourceList,
              itemExtent: 32, //height of each item
              looping: true,
              onSelectedItemChanged: (covariant) {
                log.d("onSelectedItemChanged $covariant");
                var outMsg = {
                  "id": gd.socketId,
                  "type": "call_service",
                  "domain": "media_player",
                  "service": "select_source",
                  "service_data": {
                    "entity_id": entityId,
                    "source": entity.sourceList[covariant]
                  }
                };
                var message = jsonEncode(outMsg);
                gd.sendSocketMessageDelay(message, 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MediaPlayerSoundMode extends StatelessWidget {
  final String entityId;
  const MediaPlayerSoundMode({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];
    if (entity == null || entity.soundModeList.length <= 0) return Container();

    log.d("entity.soundModeList ${entity.soundModeList}");
    log.d("entity.soundMode ${entity.soundMode}");
    var index = entity.soundModeList.indexOf(entity.soundMode);
    log.d("index ${index}");

    var soundModeController = FixedExtentScrollController(initialItem: index);

    List<Widget> sourceList = [];

    for (String source in entity.soundModeList) {
      var container = Container(
        alignment:
            entity.sourceList.length > 0 ? Alignment.center : Alignment.center,
        child: (AutoSizeText(
          source,
          style: Theme.of(context).textTheme.body1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
      );
      sourceList.add(container);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeInfo.pickerActivateStyle.color,
          width: 1.0,
        ),
      ),
      margin: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
//          Container(
//            width: double.infinity,
//            alignment: Alignment.center,
//            decoration: BoxDecoration(
//                color: ThemeInfo.colorIconActive.withOpacity(1),
//                borderRadius: BorderRadius.only(
//                  topLeft: entity.sourceList.length > 0
//                      ? Radius.circular(0)
//                      : Radius.circular(8),
//                  topRight: Radius.circular(8),
//                )),
//            padding: EdgeInsets.all(4),
//            child: AutoSizeText(
//              "Sound Modes",
//              style: Theme.of(context).textTheme.body1,
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
          Container(
            height: 128,
            margin: EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ThemeInfo.colorIconInActive.withOpacity(0),
                    ThemeInfo.colorIconInActive.withOpacity(0.5),
                    ThemeInfo.colorIconInActive.withOpacity(0),
                  ]),
            ),
            child: CupertinoPicker(
              squeeze: 1.45,
              diameterRatio: 1.1,
              offAxisFraction: 0,
              scrollController: soundModeController,
              magnification: 0.7,
              backgroundColor: Colors.transparent,
              children: sourceList,
              itemExtent: 32, //height of each item
              looping: true,

              onSelectedItemChanged: (covariant) {
                log.d("onSelectedItemChanged $covariant");
                var outMsg = {
                  "id": gd.socketId,
                  "type": "call_service",
                  "domain": "media_player",
                  "service": "select_sound_mode",
                  "service_data": {
                    "entity_id": entityId,
                    "sound_mode": entity.soundModeList[covariant]
                  }
                };
                var message = jsonEncode(outMsg);
                gd.sendSocketMessageDelay(message, 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
