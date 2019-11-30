import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EntityControlCameraWebView extends StatefulWidget {
  final String entityId;

  const EntityControlCameraWebView({@required this.entityId});

  @override
  _EntityControlCameraWebViewState createState() =>
      _EntityControlCameraWebViewState();
}

class _EntityControlCameraWebViewState
    extends State<EntityControlCameraWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool showSpin = true;
  String url = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          generalData.cameraStreamUrl + url + showSpin.toString(),
      builder: (context, data, child) {
        return RotatedBox(
          quarterTurns: 1,
          child: Stack(
            children: <Widget>[
              Container(
                color: ThemeInfo.colorBackgroundDark,
                child: gd.cameraStreamUrl.length < 10
                    ? Container()
                    : WebView(
                        initialUrl: gd.cameraStreamUrl,
                        javascriptMode: JavascriptMode.disabled,
                        initialMediaPlaybackPolicy:
                            AutoMediaPlaybackPolicy.always_allow,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller.complete(webViewController);
                        },
                        onPageFinished: (String urlVal) async {
                          log.d("1 onPageFinished");
                          await Future.delayed(
                              const Duration(milliseconds: 1500));
                          log.d("2 onPageFinished");
                          setState(() {
                            url = urlVal;
                            showSpin = false;
                          });
                        },
                      ),
              ),
              showSpin
                  ? Container(
                      color: ThemeInfo.colorBackgroundDark.withOpacity(1),
                      child: SpinKitThreeBounce(
                        size: 40,
                        color: ThemeInfo.colorIconActive.withOpacity(0.5),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  void delayedHide() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    showSpin = false;
    setState(() {});
  }
}
