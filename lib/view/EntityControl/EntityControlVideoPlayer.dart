import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class EntityControlVideoPlayer extends StatefulWidget {
  final String entityId;

  const EntityControlVideoPlayer({@required this.entityId});

  @override
  _EntityControlVideoPlayerState createState() =>
      _EntityControlVideoPlayerState();
}

class _EntityControlVideoPlayerState extends State<EntityControlVideoPlayer> {
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
        return RotatedBox(
          quarterTurns: 1,
          child: ModalProgressHUD(
            inAsyncCall: !_controller.value.initialized,
            opacity: 1,
            progressIndicator: SpinKitThreeBounce(
              size: 40,
//              color: Colors.white.withOpacity(0.5),
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
      },
    );
  }

  void initVideo() {
    streamUrl = gd.cameraStreamUrl;
    _controller = VideoPlayerController.network(
//        'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4'
//        "http://hasskitdemo.duckdns.org:8123/api/hls/0a7b88af7fbb840192e94c8b1e2831b61dd75768af08c03b53f5c8cfc510abaa/playlist.m3u8")
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
