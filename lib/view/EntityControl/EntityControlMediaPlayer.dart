import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class EntityControlMediaPlayer extends StatelessWidget {
  final String entityId;

  const EntityControlMediaPlayer({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          MpPowerButton(entityId: entityId),
          MpVolumeSlider(entityId: entityId),
        ],
      ),
    );
  }
}

class MpPowerButton extends StatelessWidget {
  final String entityId;

  const MpPowerButton({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];

    return IconButton(
      iconSize: 60,
      icon: Icon(
        MaterialDesignIcons.getIconDataFromIconName("mdi:power"),
      ),
      color: entity.isStateOn
          ? ThemeInfo.colorIconActive
          : ThemeInfo.colorIconInActive,
      onPressed: () {
        if (entity.isStateOn &&
            entity.getSupportedFeaturesMediaPlayer
                .contains("SUPPORT_TURN_OFF")) {
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
            "service": "turn_off",
            "service_data": {"entity_id": entityId}
          };
          gd.sendSocketMessage(jsonEncode(outMsg));
          entity.state = "turning off...";
        } else if (!entity.isStateOn &&
            entity.getSupportedFeaturesMediaPlayer
                .contains("SUPPORT_TURN_ON")) {
          var outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": "media_player",
            "service": "turn_on",
            "service_data": {"entity_id": entityId}
          };
          gd.sendSocketMessage(jsonEncode(outMsg));
          entity.state = "turning on...";
        }
      },
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
  Entity entity;
  double volume;
  bool supportedVolume;

  @override
  void initState() {
    super.initState();
    entity = gd.entities[widget.entityId];
    supportedVolume =
        entity.getSupportedFeaturesMediaPlayer.contains("SUPPORT_VOLUME_SET");
    volume = entity.volumeLevel;
    if (volume == null || !entity.isStateOn) volume = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: volume,
      min: 0.0,
      max: 1.0,
      divisions: 50,
      label: "${(volume * 100).toInt()}",
      onChangeEnd: supportedVolume
          ? (val) {
              var outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "media_player",
                "service": "turn_on",
                "service_data": {
                  "entity_id": widget.entityId,
                  "volume_level": val
                }
              };
              gd.sendSocketMessage(jsonEncode(outMsg));
            }
          : null,
      onChanged: supportedVolume
          ? (val) {
              setState(() {
                volume = val;
              });
            }
          : null,
    );
  }
}

class MediaPlayerButton {
  String supportedFeature;
  String serviceName;
  String iconOn;
  String iconOff;
  Color iconOnColor;
  Color iconOffColor;
  Color iconNotSupportedColor;
}

class MpTurnOn extends StatelessWidget {
  final String entityId;
  final MediaPlayerButton mediaPlayerButton;

  const MpTurnOn({
    @required this.entityId,
    @required this.mediaPlayerButton,
  });

  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];
    return IconButton(
      iconSize: 60,
      icon: Icon(
        entity != null && entity.isStateOn
            ? MaterialDesignIcons.getIconDataFromIconName(
                mediaPlayerButton.iconOn)
            : MaterialDesignIcons.getIconDataFromIconName(
                mediaPlayerButton.iconOff),
      ),
      color: entity != null &&
              entity.getSupportedFeaturesMediaPlayer
                  .contains(mediaPlayerButton.supportedFeature)
          ? entity.isStateOn
              ? mediaPlayerButton.iconOnColor
              : mediaPlayerButton.iconOnColor
          : mediaPlayerButton.iconNotSupportedColor,
      onPressed: entity != null &&
              entity.isStateOn &&
              entity.getSupportedFeaturesMediaPlayer
                  .contains(mediaPlayerButton.supportedFeature)
          ? () {
              var outMsg = {
                "id": gd.socketId,
                "type": "call_service",
                "domain": "media_player",
                "service": mediaPlayerButton.serviceName,
                "service_data": {"entity_id": entityId}
              };
              gd.sendSocketMessage(jsonEncode(outMsg));
              entity.state = "turning off...";
            }
          : null,
    );
  }
}
