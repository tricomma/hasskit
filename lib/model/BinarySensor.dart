import 'package:hasskit/helper/Logger.dart';

class BinarySensor {
  String entityId;
  String lastChanged;
  String lastUpdated;
  String state;

  BinarySensor({this.entityId, this.lastChanged, this.lastUpdated, this.state});
  factory BinarySensor.fromJson(Map<String, dynamic> json) {
    try {
      return BinarySensor(
        lastChanged: json['last_changed'],
        lastUpdated: json['last_updated'],
        state: json['state'],
      );
    } catch (e) {
      log.e("EntityOverride.fromJson $e");
      return null;
    }
  }

  bool get isStateOn {
    return state.toLowerCase().contains('on') ||
        state.toLowerCase().contains('open') ||
        state.toLowerCase().contains('opened');
  }
//  Map<String, dynamic> toJson() => {
//    'friendlyName': friendlyName,
//    'icon': icon,
//    'openRequireAttention': openRequireAttention,
//  };
}
