import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/gestures.dart';

class SliverWebView extends StatefulWidget {
  @override
  _SliverWebViewState createState() => _SliverWebViewState();
}

class _SliverWebViewState extends State<SliverWebView> {
  final Set<Factory> gestureRecognizers = [
    Factory(() => EagerGestureRecognizer()),
  ].toSet();
  WebViewController webController;
  TextEditingController textController = TextEditingController();
  bool showSpin = true;
  bool showAddress = false;
  bool isValidUrl = true;
  bool pinWebView = false;
  double aspect = 0.7;
  double aspectDisplay = 0.7;
  String currentUrl;
  @override
  void initState() {
    super.initState();
    textController.text = gd.webViewPresets[0];
    currentUrl = textController.text;
  }

  changeUrl(String url) {
    log.d("changeUrl $url");
    setState(() {
      currentUrl = url;
      webController.loadUrl(currentUrl);
      showSpin = true;
    });
  }

  Timer _changeAspectTimer;

  void changeAspect(double val) {
    _changeAspectTimer?.cancel();
    _changeAspectTimer = null;
    _changeAspectTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        aspect = val;
        aspectDisplay = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        padding: EdgeInsets.all(12),
        width: gd.mediaQueryWidth,
        height: gd.mediaQueryWidth * aspect,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: <Widget>[
              WebView(
                initialUrl: currentUrl,
                gestureRecognizers: !pinWebView ? gestureRecognizers : null,
                javascriptMode: JavascriptMode.unrestricted,
                initialMediaPlaybackPolicy:
                    AutoMediaPlaybackPolicy.always_allow,
                onWebViewCreated: (WebViewController webViewController) {
                  webController = webViewController;
                },
                onPageFinished: (String urlVal) async {
                  log.d("2 onPageFinished $currentUrl");
                  setState(() {
                    showSpin = false;
                  });
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: BoxDecoration(
                      color: showAddress
                          ? ThemeInfo.colorBottomSheet.withOpacity(1)
                          : ThemeInfo.colorBottomSheet.withOpacity(0),
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (showAddress)
                                changeUrl(textController.text.trim());
                              showAddress = !showAddress;
                              Flushbar(
                                message: "Edit webview",
                                duration: Duration(seconds: 3),
                                shouldIconPulse: true,
                                icon: Icon(
                                  Icons.info,
                                  color: ThemeInfo.colorIconActive,
                                ),
                              )..show(context);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeInfo.colorBottomSheet
                                      .withOpacity(0.5),
                                  offset: new Offset(0.0, 0.0),
                                  blurRadius: 3.0,
                                )
                              ],
                            ),
                            child: showAddress
                                ? Icon(
                                    MaterialDesignIcons.getIconDataFromIconName(
                                        "mdi:content-save"))
                                : Icon(
                                    MaterialDesignIcons.getIconDataFromIconName(
                                        "mdi:pencil")),
                          ),
                        ),
                        SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            webController.reload();
                            Flushbar(
                              message: "Reload webview",
                              duration: Duration(seconds: 3),
                              shouldIconPulse: true,
                              icon: Icon(
                                Icons.info,
                                color: ThemeInfo.colorIconActive,
                              ),
                            )..show(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeInfo.colorBottomSheet
                                      .withOpacity(0.5),
                                  offset: new Offset(0.0, 0.0),
                                  blurRadius: 3.0,
                                )
                              ],
                            ),
                            child: Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:refresh")),
                          ),
                        ),
                        SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              pinWebView = !pinWebView;
                              Flushbar(
                                message: pinWebView
                                    ? "Pin webview - Prevent webview scrolling"
                                    : "Unpin webview - Allow webview scrolling",
                                duration: Duration(seconds: 3),
                                shouldIconPulse: true,
                                icon: Icon(
                                  Icons.info,
                                  color: ThemeInfo.colorIconActive,
                                ),
                              )..show(context);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeInfo.colorBottomSheet
                                      .withOpacity(0.5),
                                  offset: new Offset(0.0, 0.0),
                                  blurRadius: 3.0,
                                )
                              ],
                            ),
                            child: pinWebView
                                ? Icon(
                                    MaterialDesignIcons.getIconDataFromIconName(
                                        "mdi:pin"))
                                : Icon(
                                    MaterialDesignIcons.getIconDataFromIconName(
                                        "mdi:pin-off")),
                          ),
                        ),
                        Expanded(child: Container()),
                        showAddress
                            ? Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        textController.text =
                                            gd.webViewPresets[0];
                                        changeUrl(textController.text);
                                        showAddress = false;
                                      });
                                    },
                                    child: Container(
                                      child: Text(
                                        "Windy",
                                        textScaleFactor: gd.textScaleFactor,
                                      ),
                                    ),
                                  ),
                                  Container(child: Text(" | ")),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        textController.text =
                                            gd.webViewPresets[1];
                                        changeUrl(textController.text);
                                        showAddress = false;
                                      });
                                    },
                                    child: Container(
                                      child: Text(
                                        "Y! Weather",
                                        textScaleFactor: gd.textScaleFactor,
                                      ),
                                    ),
                                  ),
                                  Container(child: Text(" | ")),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        textController.text =
                                            gd.webViewPresets[2];
                                        changeUrl(textController.text);
                                        showAddress = false;
                                      });
                                    },
                                    child: Text(
                                      "LiveScore",
                                      textScaleFactor: gd.textScaleFactor,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ),
                  showAddress
                      ? Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: ThemeInfo.colorBottomSheet.withOpacity(1),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: "https://www.siteadress.com",
                                  ),
                                  controller: textController,
                                  autocorrect: false,
                                  autovalidate: true,
                                  autofocus: true,
                                  maxLines: 3,
                                  onEditingComplete: () {
                                    changeUrl(textController.text);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text("Aspect"),
                                    SizedBox(width: 8),
                                    Icon(MaterialDesignIcons
                                        .getIconDataFromIconName(
                                            "mdi:crop-landscape")),
                                    Expanded(
                                      child: Slider(
                                        label:
                                            "${aspectDisplay.toStringAsFixed(1)}",
                                        divisions: 10,
                                        min: 0.5,
                                        value: aspectDisplay,
                                        max: 1.5,
                                        onChanged: (val) {
                                          setState(() {
                                            aspectDisplay = val;
                                            changeAspect(val);
                                          });
                                        },
                                      ),
                                    ),
                                    Icon(MaterialDesignIcons
                                        .getIconDataFromIconName(
                                            "mdi:crop-portrait")),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
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
        ),
      ),
    ]));
  }
}
