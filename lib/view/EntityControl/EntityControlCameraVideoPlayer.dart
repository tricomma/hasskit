import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class EntityControlCameraVideoPlayer extends StatefulWidget {
  final String entityId;

  const EntityControlCameraVideoPlayer({@required this.entityId});

  @override
  _EntityControlCameraVideoPlayerState createState() =>
      _EntityControlCameraVideoPlayerState();
}

class _EntityControlCameraVideoPlayerState
    extends State<EntityControlCameraVideoPlayer> {
  VideoPlayerController _controller;
  bool initialized = false;
  String streamUrl = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);

//    while (gd.cameraStreamUrl == "") {
//      log.d("WAIT gd.cameraStreamUrl==");
//    }
//
//    log.d("GO gd.cameraStreamUrl==${gd.cameraStreamUrl}");
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) => generalData.cameraStreamUrl,
      builder: (context, data, child) {
        if (gd.cameraStreamUrl.length > 100 &&
            !initialized &&
            streamUrl != gd.cameraStreamUrl) {
          initVideo();
        }

        try {
          return RotatedBox(
            quarterTurns: 1,
            child: ModalProgressHUD(
              inAsyncCall: !_controller.value.initialized,
              opacity: 1,
              progressIndicator: SpinKitThreeBounce(
                size: 40,
                color: ThemeInfo.colorIconActive,
              ),
              color: ThemeInfo.colorBackgroundDark,
              child: Center(
                  child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )),
            ),
          );
        } catch (e) {
          return Container(
            child: Center(child: AutoSizeText("Error: $e")),
          );
        }
      },
    );
  }

  void initVideo() {
    streamUrl = gd.cameraStreamUrl;
    _controller = VideoPlayerController.network(
//        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4'
        gd.cameraStreamUrl)
      ..initialize().then(
        (_) {
          log.w("initVideo ${gd.cameraStreamUrl}");
          initialized = true;
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          _controller.play();
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _controller.dispose();
  }
}
