import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hobbybase/painting/app_logo.dart';
import 'package:hobbybase/screen/homescreen.dart';
import 'package:hobbybase/screen/sign_in_teddy.dart';

import 'app_logo.dart';

void main() => runApp( MaterialApp(
//      initialRoute: '/',
//      routes: {
//        '/': (context) => SplashScreenAnimation(),
//        '/SignInScreen': (context) => SignInTeddyScreen(),
//      },

  home: SplashScreenAnimation(),
    routes: <String, WidgetBuilder>{
      '/SignInScreen': (BuildContext context) =>
        FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
            if(snapshot.hasData) {
              FirebaseUser user = snapshot.data; // This is your user instance
              // is because there is user already logged
              debugPrint("user.displayName=${user.email}");
              return new HomeScreen();
            } else {
              debugPrint("Session timeout!!");
              return new SignInTeddyScreen();
            }
          },
        )
//

  },


//      routes: <String, WidgetBuilder>{
//        '/HomeScreen': (BuildContext context) => new HomeScreen()
//      },
)
);

class SplashScreenImage extends StatefulWidget {
  @override
  _SplashScreenImageState createState() => new _SplashScreenImageState();
}

class _SplashScreenImageState extends State<SplashScreenImage> {
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/SignInScreen');
//    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Image.asset('assets/dq/dq01.png'),
      ),
    );
  }
}

class SplashScreenAnimation extends StatefulWidget {
  @override State<StatefulWidget> createState() =>
      FadeIn();
}

class FadeIn extends State<SplashScreenAnimation> {
  Timer _timer;
  AppLogoStyle _logoStyle = AppLogoStyle.markOnly;
  FadeIn() {
    _timer = new Timer(const Duration(seconds: 1), () {
      setState(() {
        _logoStyle = AppLogoStyle.horizontal;
      });
    });
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/SignInScreen');
//    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            child: new AppLogo(
              size: 200.0, style: _logoStyle, ), ), ), ),

    );
  }
}







