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

class SliverWebView extends StatefulWidget {
  final String webViewsId;

  const SliverWebView({@required this.webViewsId});
  @override
  _SliverWebViewState createState() => _SliverWebViewState();
}

class _SliverWebViewState extends State<SliverWebView> {
  final Set<Factory> gestureRecognizers = [
    Factory(() => EagerGestureRecognizer()),
  ].toSet();

  InAppWebViewController webController;
  TextEditingController textController = TextEditingController();
  bool showSpin = true;
  bool showAddress = false;
  bool isValidUrl = true;
  bool pinWebView = true;
  double opacity = 0.2;
  double aspect;
  double aspectDisplay;
  String currentUrl;
  @override
  void initState() {
    super.initState();
    aspectDisplay = gd.baseSetting.getWebViewRatio(widget.webViewsId);
    aspect = gd.baseSetting.getWebViewRatio(widget.webViewsId);
    textController.text = gd.baseSetting.getWebViewUrl(widget.webViewsId);
    log.d(
        "widget.webViewsId ${widget.webViewsId} textController.text ${textController.text} ");
    currentUrl = textController.text;
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

  Timer _changeAspectTimer;

  void changeAspect(double val) {
    _changeAspectTimer?.cancel();
    _changeAspectTimer = null;
    _changeAspectTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        aspect = val;
        aspectDisplay = val;

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

  @override
  Widget build(BuildContext context) {
    aspect = gd.baseSetting.getWebViewRatio(widget.webViewsId);

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
              webViewContainer(),
              showSpin
                  ? Container(
                      color: ThemeInfo.colorBackgroundDark.withOpacity(1),
                      child: SpinKitThreeBounce(
                        size: 40,
                        color: ThemeInfo.colorIconActive.withOpacity(0.5),
                      ),
                    )
                  : Container(),
              Opacity(
                opacity: showAddress ? 1 : opacity,
                child: Column(
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
                          webButton(context),
                          SizedBox(width: 4),
                          reloadButton(context),
                          SizedBox(width: 4),
                          pintButton(context),
                          Expanded(child: Container()),
                          presetButons()
                        ],
                      ),
                    ),
                    addressAndAspect(),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ]));
  }

  InkWell webButton(BuildContext context) {
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

  Widget presetButons() {
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
              SizedBox(width: 10),
            ],
          )
        : Container();
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
                    maxLines: 1,
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
                          label: "${aspectDisplay.toStringAsFixed(1)}",
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

  Container webViewContainer() {
    try {
      return Container(
//        child: WebView(
//          initialUrl: currentUrl,
//          gestureRecognizers: !pinWebView ? gestureRecognizers : null,
//          javascriptMode: JavascriptMode.disabled,
//          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
//          onWebViewCreated: (WebViewController webViewController) {
//            webController = webViewController;
//          },
//          debuggingEnabled: true,
//          onPageFinished: (String urlVal) async {
//            log.d("2 onPageFinished $currentUrl");
//            setState(() {
//              showSpin = false;
//            });
//          },
//        ),
        child: InAppWebView(
          initialUrl: currentUrl,
          initialHeaders: {},
          initialOptions: InAppWebViewWidgetOptions(
              inAppWebViewOptions: InAppWebViewOptions(
            debuggingEnabled: true,
          )),
          onWebViewCreated: (InAppWebViewController controller) {
            webController = controller;
          },
          onLoadStart: (InAppWebViewController controller, String url) {
            setState(() {
              log.d("onLoadStart url $url");
//              this.url = url;
            });
          },
          onLoadStop: (InAppWebViewController controller, String url) async {
            setState(() {
              log.d("onLoadStop url $url");
//              showSpin = false;
//              this.url = url;
            });
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              log.d("onProgressChanged progress $progress");
              showSpin = false;
//              this.progress = progress / 100;
            });
          },
        ),
      );
    } catch (e) {
      log.e("webViewContainer $e");
      return Container();
    }
  }
}
