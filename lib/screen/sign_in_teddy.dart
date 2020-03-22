import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/rendering.dart';
import 'signin_button.dart';
import 'teddy_controller.dart';
import 'tracking_text_input.dart';

import 'homescreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInTeddyScreen(title: 'Flutter Demo Hobby Base Page'),
//      routes: <String, WidgetBuilder>{
//        '/HomeScreen': (BuildContext context) => new HomeScreen()
//      },
    );
  }
}

class SignInTeddyScreen extends StatefulWidget {
  SignInTeddyScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInTeddyScreenState createState() => _SignInTeddyScreenState();
}

enum WidgetMarker {
  signin_by_email, signup_by_email, signin_by_phone, signup_by_phone, forgot
}

class _SignInTeddyScreenState extends State<SignInTeddyScreen> with SingleTickerProviderStateMixin<SignInTeddyScreen> {
  TeddyController _teddyController;

  AnimationController _controller;
  Animation _animation;

  WidgetMarker selectedWidgetMarker = WidgetMarker.signin_by_email;

  void navigationPage() {
//    Navigator.of(context).pushNamed('/HomeScreen');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen() ));
  }

  Widget _showSelectedContainer() {
    switch(selectedWidgetMarker) {
      case WidgetMarker.signin_by_email:
        return _showSignInByEmailPanel();
      case WidgetMarker.signup_by_email:
        return _showSignUpByEmailPanel();
      case WidgetMarker.signin_by_phone:
        return _showSignInByEmailPanel();
      case WidgetMarker.signup_by_phone:
        return _showSignUpByEmailPanel();
      case WidgetMarker.forgot:
        return _showSignUpByEmailPanel();
    }
    return _showSignInByEmailPanel();
  }

  Widget _showSignInByEmailPanel() {
    return FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.all(Radius.circular(25.0))),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TrackingTextInput(
                      keyboardType: TextInputType.emailAddress,
                      label: "Email",
                      hint: "What's your email address?",
                      onCaretMoved: (Offset caret) {
                        _teddyController.lookAt(caret);
                      },
                      onTextChanged: (String value) {
                        _teddyController.setEmail(value);
                      },
                    ),
                    TrackingTextInput(
                      label: "Password",
                      hint: "Try 'bears'...",
                      isObscured: true,
                      onCaretMoved: (Offset caret) {
                        _teddyController.coverEyes(caret != null);
                        _teddyController.lookAt(null);
                      },
                      onTextChanged: (String value) {
                        _teddyController.setPassword(value);
                      },
                    ),
                    SigninButton(
                        child: Text("Sign In",
                            style: TextStyle(
                                fontFamily: "RobotoMedium",
                                fontSize: 16,
                                color: Colors.white)),
                        onPressed: () {
  //                                              if(_teddyController.submitPassword()) {
                          if(_teddyController.signInWithEmailAndPassword() != null) {
                            navigationPage();
                          }
                        }),
                    GestureDetector(
                      onTap: () {
                        print('tap Sign up with email');
                        setState(() {
                          selectedWidgetMarker = WidgetMarker.signup_by_email;
                        });

                      },
                      child:
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child:
                          Text.rich(TextSpan(
                              text: 'Sign Up',
                              style: TextStyle( fontWeight: FontWeight.normal),
                              children: <TextSpan> [
                                TextSpan(
                                  text: ' with ',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                TextSpan(
                                  text: 'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),

                                ),
                              ]

                          )
                          ),
                        ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('tap Sign up with phone');
                        setState(() {
                          selectedWidgetMarker = WidgetMarker.signup_by_phone;
                        });

                      },
                      child:
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          child:
                          Text.rich(TextSpan(
                              text: 'Sign Up',
                              style: TextStyle( fontWeight: FontWeight.normal),
                              children: <TextSpan> [
                                TextSpan(
                                  text: ' with ',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                TextSpan(
                                  text: 'Phone number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent
                                  ),
                                ),
                              ]

                          )
                          ),
                        ),
                    ),
                  ],
                )),
          ))
    );

  }

  Widget _showSignUpByEmailPanel() {
    return FadeTransition(
        opacity: _animation,
        child:
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.all(Radius.circular(25.0))),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TrackingTextInput(
                        keyboardType: TextInputType.emailAddress,
                        label: "Email",
                        hint: "What's your email address?",
                        onCaretMoved: (Offset caret) {
                          _teddyController.lookAt(caret);
                        },
                        onTextChanged: (String value) {
                          _teddyController.setEmail(value);
                        },
                      ),
                      TrackingTextInput(
                        label: "Password",
                        hint: "Try 'bears'...",
                        isObscured: true,
                        onCaretMoved: (Offset caret) {
                          _teddyController.coverEyes(caret != null);
                          _teddyController.lookAt(null);
                        },
                        onTextChanged: (String value) {
                          _teddyController.setPassword(value);
                        },
                      ),
                      SigninButton(
                          child: Text("Sign Up",
                              style: TextStyle(
                                  fontFamily: "RobotoMedium",
                                  fontSize: 16,
                                  color: Colors.white)),
                          onPressed: () {
                            _teddyController.signUpWithEmailAndPassword(context).then((FirebaseUser user) =>  
                              navigationPage() ).catchError((error) =>
                              {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.ERROR,
                                  animType: AnimType.TOPSLIDE,
                                  tittle: "Sign Up Failed",
                                  desc: "The email address is already in use by another account.",
                                  btnCancelText: 'Close',
                                  btnCancelIcon: Icons.close,
                                ).show()
                              }
                            );
                            
                          }),
                      GestureDetector(
                        onTap: () {
                          print('tap Sign in by email');
                          setState(() {
                            selectedWidgetMarker = WidgetMarker.signin_by_email;
                          });
                        },
                        child:
                          Container(
                              height: 30,
                              alignment: Alignment.center,
                              child:
                              Text.rich(TextSpan(
                                  text: 'Already have an account, ',
                                  style: TextStyle( fontStyle: FontStyle.italic ),
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: ' Sign In',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ]
                              )
                          ),
                        ),
                      ),
                    ],
                  )),
            ))
    );
  }

  @override
  initState() {
    _teddyController = TeddyController();
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(microseconds: 2000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Color.fromRGBO(93, 142, 155, 1.0),
      body: Container(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      // Box decoration takes a gradient
                      gradient: LinearGradient(
                        // Where the linear gradient begins and ends
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        // Add one stop for each color. Stops should increase from 0 to 1
                        stops: [0.0, 1.0],
                        colors: [
                          Color.fromRGBO(170, 207, 211, 1.0),
                          Color.fromRGBO(93, 142, 155, 1.0),
                        ],
                      ),
                    ),
                  )),
              Positioned.fill(
                child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, top: devicePadding.top + 50.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              height: 200,
                              padding: const EdgeInsets.only(left: 30.0, right:30.0),
                              child: FlareActor(
                                "assets/Teddy.flr",
                                shouldClip: false,
                                alignment: Alignment.bottomCenter,
                                fit: BoxFit.contain,
                                controller: _teddyController,
                              )),
                          FutureBuilder(
                            future: _playAnimation(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              return _showSelectedContainer();
                            },
                          ),

                        ])),
              ),
            ],
          )),
    );
  }

  _playAnimation() {
    _controller.reset();
    _controller.forward();
  }
}
