import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'GeneralData.dart';
import 'ThemeInfo.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
//    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class GoogleSign extends StatefulWidget {
  @override
  _GoogleSignState createState() => _GoogleSignState();
}

class _GoogleSignState extends State<GoogleSign> {
  @override
  void initState() {
    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        gd.firebaseCurrentUser = account;
//      });
//    });
//    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  gd.googleSignInAccount != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(gd.googleSignInAccount.photoUrl),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/google_cloud.png"),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        ),
                  gd.googleSignInAccount != null
                      ? Text(gd.googleSignInAccount.displayName ?? '')
                      : Text('Use Cloud Data Sync'),
//                  Text(_currentUser.email ?? ''),
//                  Text('Using Cloud Sync Data'),
                  gd.googleSignInAccount != null
                      ? GoogleLoggedIn()
                      : GoogleLoggedOut(),
                  Text(
                    "Keep your rooms layout and device customization synchronized accross devices. HassKit won't upload your login data online...",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
//          RaisedButton(
//            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
//            child: Row(
//              children: <Widget>[
//                Icon(MaterialDesignIcons.getIconDataFromIconName(
//                    "mdi:cloud-download")),
//                SizedBox(width: 4),
//                Text("Download"),
//              ],
//            ),
//            onPressed: () {
//              Flushbar(
//                title: "Force downloading data from cloud",
//                message: "Use when auto sync not working",
//                duration: Duration(seconds: 3),
//              )..show(context);
//              gd.downloadCloudData();
//            },
//          ),
//          SizedBox(width: 4),
//          RaisedButton(
//            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
//            child: Row(
//              children: <Widget>[
//                Icon(MaterialDesignIcons.getIconDataFromIconName(
//                    "mdi:cloud-upload")),
//                SizedBox(width: 4),
//                Text("Upload"),
//              ],
//            ),
//            onPressed: () {
//              Flushbar(
//                title: "Force downloading data from cloud",
//                message: "Use when auto sync not working",
//                duration: Duration(seconds: 3),
//              )..show(context);
//              gd.uploadCloudData();
//            },
//          ),
//          SizedBox(width: 4),
        RaisedButton(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Row(
            children: <Widget>[
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:logout")),
              SizedBox(width: 4),
              Text("Sign Out"),
            ],
          ),
          onPressed: _handleSignOut,
        )
      ],
    );
  }

  Future<void> _handleSignOut() async {
    googleSignIn.disconnect();
  }
}

class GoogleLoggedOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: _handleSignIn,
          child: Row(
            children: <Widget>[
              Icon(MaterialDesignIcons.getIconDataFromIconName("mdi:login")),
              SizedBox(width: 4),
              Text("Sign In"),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    try {
      log.d("googleSignIn.signIn()");
      await googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
}
