import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:flutter/gestures.dart';

class SliverWebView extends StatelessWidget {
  final String webViewsId;
  const SliverWebView({@required this.webViewsId});
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          WebView(
            webViewsId: webViewsId,
          ),
        ],
      ),
    );
  }
}

class WebView extends StatefulWidget {
  final String webViewsId;

  const WebView({@required this.webViewsId});

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final TextEditingController textController = TextEditingController();
  final Set<Factory> gestureRecognizers = [
    Factory(() => EagerGestureRecognizer()),
  ].toSet();

  InAppWebViewController webController;
  String currentUrl;
  double ratio;
  double ratioDisplay;
  double opacity = 0.2;
  bool showSpin = true;
  bool showAddress = false;
  bool pinWebView = true;

  @override
  void initState() {
    currentUrl = gd.baseSetting.getWebViewUrl(widget.webViewsId);
    ratio = gd.baseSetting.getWebViewRatio(widget.webViewsId);
    ratioDisplay = ratio;
    textController.text = currentUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      height: ratio * gd.mediaQueryWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            buildInAppWebView(),
            showSpin
                ? Container(
                    color: ThemeInfo.colorBackgroundDark.withOpacity(1),
                    child: SpinKitThreeBounce(
                      size: 40,
                      color: ThemeInfo.colorIconActive.withOpacity(0.5),
                    ),
                  )
                : Container(),
            Column(
              children: <Widget>[
                Container(
                  color: showAddress
                      ? ThemeInfo.colorBottomSheet
                      : Colors.transparent,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      webButton(context),
                      reloadButton(context),
                      pintButton(context),
                      Spacer(),
                      presetButtons(),
                    ],
                  ),
                ),
                addressAndAspect(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InAppWebView buildInAppWebView() {
    return InAppWebView(
      initialUrl: currentUrl,
      gestureRecognizers: pinWebView ? null : gestureRecognizers,
      initialHeaders: {},
      initialOptions: InAppWebViewWidgetOptions(
          inAppWebViewOptions: InAppWebViewOptions(
        debuggingEnabled: true,
      )),
      onWebViewCreated: (InAppWebViewController controller) {
        print("onWebViewCreated currentUrl $currentUrl");
        webController = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          print("onLoadStart url $url");
          showSpin = true;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        setState(() {
          print("onLoadStop url $url");
          showSpin = false;
        });
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          print("onProgressChanged progress $progress currentUrl $currentUrl");
          if (progress > 90) showSpin = false;
        });
      },
    );
  }

  Widget presetButtons() {
    return showAddress
        ? Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    textController.text = gd.webViewPresets[0];
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
                    textController.text = gd.webViewPresets[1];
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
                    textController.text = gd.webViewPresets[2];
                    changeUrl(textController.text);
                    showAddress = false;
                  });
                },
                child: Text(
                  "LiveScore",
                  textScaleFactor: gd.textScaleFactor,
                ),
              ),
            ],
          )
        : Container();
  }

  changeUrl(String url) {
    log.d("changeUrl $url");
    setState(() {
      currentUrl = url;
      webController.loadUrl(url: currentUrl);
      showSpin = true;

      if (widget.webViewsId == "WebView1") {
        gd.baseSetting.webView1Url = url;
        gd.baseSettingSave(true);
      }
      if (widget.webViewsId == "WebView2") {
        gd.baseSetting.webView2Url = url;
        gd.baseSettingSave(true);
      }
      if (widget.webViewsId == "WebView3") {
        gd.baseSetting.webView3Url = url;
        gd.baseSettingSave(true);
      }
    });
  }

  Widget addressAndAspect() {
    return showAddress
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
                      Icon(MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:crop-landscape")),
                      Expanded(
                        child: Slider(
                          label: "${ratioDisplay.toStringAsFixed(1)}",
                          divisions: 10,
                          min: 0.5,
                          value: ratioDisplay,
                          max: 1.5,
                          onChanged: (val) {
                            setState(() {
                              ratioDisplay = val;
                            });
                          },
                          onChangeEnd: (val) {
                            setState(() {
                              ratio = val;
                              ratioDisplay = val;
                              changeAspect(val);
                            });
                          },
                        ),
                      ),
                      Icon(MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:crop-portrait")),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Timer _changeAspectTimer;

  void changeAspect(double val) {
    _changeAspectTimer?.cancel();
    _changeAspectTimer = null;
    _changeAspectTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        ratio = val;

        if (widget.webViewsId == "WebView1") {
          gd.baseSetting.webView1Ratio = val;
          gd.baseSettingSave(true);
        }
        if (widget.webViewsId == "WebView2") {
          gd.baseSetting.webView2Ratio = val;
          gd.baseSettingSave(true);
        }
        if (widget.webViewsId == "WebView3") {
          gd.baseSetting.webView3Ratio = val;
          gd.baseSettingSave(true);
        }
      });
    });
  }

  Widget webButton(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          changeOpacity();
          if (showAddress) changeUrl(textController.text.trim());
          showAddress = !showAddress;
          Flushbar(
            message: showAddress ? "Edit Website" : "Website saved",
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
              color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
              offset: new Offset(0.0, 0.0),
              blurRadius: 1.0,
            )
          ],
        ),
        child: showAddress
            ? Icon(
                MaterialDesignIcons.getIconDataFromIconName("mdi:content-save"))
            : Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:pencil")),
      ),
    );
  }

  Widget reloadButton(BuildContext context) {
    return !showAddress
        ? InkWell(
            onTap: () {
              changeOpacity();
              webController.reload();
              Flushbar(
                message: "Reload Website",
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
                    color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                    offset: new Offset(0.0, 0.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
              child: Icon(
                  MaterialDesignIcons.getIconDataFromIconName("mdi:refresh")),
            ),
          )
        : Container();
  }

  Widget pintButton(BuildContext context) {
    return !showAddress
        ? InkWell(
            onTap: () {
              setState(() {
                changeOpacity();
                pinWebView = !pinWebView;
                Flushbar(
                  message: pinWebView
                      ? "Pin Website - Prevent Website scrolling"
                      : "Unpin Website - Allow Website scrolling",
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
                    color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                    offset: new Offset(0.0, 0.0),
                    blurRadius: 1.0,
                  )
                ],
              ),
              child: pinWebView
                  ? Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:pin"))
                  : Icon(MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:pin-off")),
            ),
          )
        : Container();
  }

  Timer _changeOpacityTimer;

  void changeOpacity() {
    opacity = 1;
    _changeOpacityTimer?.cancel();
    _changeOpacityTimer = null;
    _changeOpacityTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        opacity = 0.2;
      });
    });
  }
}
