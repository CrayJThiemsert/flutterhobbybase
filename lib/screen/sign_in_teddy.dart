import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/rendering.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/widget/masked_text.dart';
import 'signin_button.dart';
import 'teddy_controller.dart';
import 'tracking_text_input.dart';

import 'homescreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

enum AuthStatus { SOCIAL_AUTH, PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 16.0);
final hintStyle = TextStyle(color: Colors.white24);

// Keys
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<MaskedTextFieldState> _maskedPhoneKey = GlobalKey<MaskedTextFieldState>();



// Firebase
final FirebaseAuth _auth = FirebaseAuth.instance;

class _SignInTeddyScreenState extends State<SignInTeddyScreen> with SingleTickerProviderStateMixin<SignInTeddyScreen> {
  static const String TAG = "_SignInTeddyScreenState";
  AuthStatus status = AuthStatus.SOCIAL_AUTH;

  TeddyController _teddyController;

  AnimationController _controller;
  Animation _animation;

  WidgetMarker selectedWidgetMarker = WidgetMarker.signin_by_email;

  // Controllers
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool _isRefreshing = false;
  bool _codeTimedOut = false;
  bool _codeVerified = false;
  Duration _timeOut = const Duration(minutes: 1);

  FirebaseUser _firebaseUser;

  // Variables
  String _phoneNumber;
  String _errorMessage;
  String _verificationId;
  Timer _codeTimer;

  void navigationPage(User user) {
//    Navigator.of(context).pushNamed('/HomeScreen');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(user) ));
  }

  Widget _showSelectedContainer() {
    switch(selectedWidgetMarker) {
      case WidgetMarker.signin_by_email:
        return _buildSignInByEmailBody();
      case WidgetMarker.signup_by_email:
        return _buildSignUpByEmailBody();
      case WidgetMarker.signin_by_phone:
        return _buildSignInByPhoneAuthBody();
      case WidgetMarker.signup_by_phone:
        return _buildSignInByPhoneAuthBody();
      case WidgetMarker.forgot:
        return _buildSignUpByEmailBody();
    }
    return _buildSignInByEmailBody();
  }

  Widget _buildSignInByEmailBody() {
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
                            getUserDB(_teddyController.getEmail());
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

  Widget _buildSignUpByEmailBody() {
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
                              createNewUserDB(_teddyController.getEmail()) ).catchError((error) =>
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

  Widget _buildSignInByPhoneAuthBody() {
    return _PhoneSignInSection(); // Scaffold.of(context));
  }

  Widget _buildSignInByPhoneAuthBody_NotUsed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            "We'll send an SMS message to verify your identity, please enter your number right below!",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 5, child: _buildPhoneNumberInput()),
              Flexible(flex: 1, child: _buildConfirmInputButton())
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmInputButton() {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.check),
      color: theme.accentColor,
      disabledColor: theme.buttonColor,
      onPressed: (this.status == AuthStatus.PROFILE_AUTH)
          ? null
          : () => _updateRefreshing(true),
    );
  }

  String get phoneNumber {
    try {
      String unmaskedText = _maskedPhoneKey.currentState?.unmaskedText;
      if (unmaskedText != null) _phoneNumber = "+66$unmaskedText".trim();
    } catch (error) {
      print("${TAG} - Couldn't access state from _maskedPhoneKey: ${error}");
    }
    return _phoneNumber;
  }

  // async

  Future<Null> _updateRefreshing(bool isRefreshing) async {
    print("${TAG} Setting _isRefreshing ($_isRefreshing) to $isRefreshing");
    if (_isRefreshing) {
      setState(() {
        this._isRefreshing = false;
      });
    }
    setState(() {
      this._isRefreshing = isRefreshing;
    });
  }

  String _phoneInputValidator() {
    if (phoneNumberController.text.isEmpty) {
      return "Your phone number can't be empty!";
    } else if (phoneNumberController.text.length < 15) {
      return "This phone number is invalid!";
    }
    return null;
  }

  Future<Null> _submitPhoneNumber() async {
    final error = _phoneInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = error;
      });
      return null;
    } else {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = null;
      });
      final result = await _verifyPhoneNumber();
      print("${TAG} - Returning $result from _submitPhoneNumber");
      return result;
    }
  }

  Future<Null> _verifyPhoneNumber() async {
    print("${TAG} - Got phone number as: ${this.phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: _linkWithPhoneNumber,
        verificationFailed: verificationFailed);
    print("${TAG} - Returning null from _verifyPhoneNumber");
    return null;
  }

  // PhoneVerificationFailed
  verificationFailed(AuthException authException) {

    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.TOPSLIDE,
      tittle: "Verify Code Failed",
      desc: "We couldn't verify your code for now, please try again!",
      btnCancelText: 'Close',
      btnCancelIcon: Icons.close,
    ).show();
    print("${TAG} - onVerificationFailed, code: ${authException.code}, message: ${authException.message}");
  }

  Future<void> _linkWithPhoneNumber(AuthCredential credential) async {
    final errorMessage = "We couldn't verify your code, please try again!";

    final result =
    await _firebaseUser.linkWithCredential(credential).catchError((error) {
      print("Failed to verify SMS code: $error");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.TOPSLIDE,
        tittle: "Verify Code Failed",
        desc: errorMessage,
        btnCancelText: 'Close',
        btnCancelIcon: Icons.close,
      ).show();

    });
    _firebaseUser = result.user;

    await _onCodeVerified(_firebaseUser).then((codeVerified) async {
      this._codeVerified = codeVerified;
      print("${TAG} - Returning ${this._codeVerified} from _onCodeVerified",
      );
      if (this._codeVerified) {
        await _finishSignIn(_firebaseUser);
      } else {

        AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.TOPSLIDE,
          tittle: "Verify Code Failed",
          desc: errorMessage,
          btnCancelText: 'Close',
          btnCancelIcon: Icons.close,
        ).show();
      }
    });
  }

  _finishSignIn(FirebaseUser user) async {
    await _onCodeVerified(user).then((result) {
      if (result) {
        // Here, instead of navigating to another screen, you should do whatever you want
        // as the user is already verified with Firebase from both
        // Google and phone number methods
        // Example: authenticate with your own API, use the data gathered
        // to post your profile/user, etc.

        getUserDB(_teddyController.getEmail());
//        Navigator.of(context).pushReplacement(CupertinoPageRoute(
//          builder: (context) => MainScreen(
//            googleUser: _googleUser,
//            firebaseUser: user,
//          ),
//        ));
      } else {
        setState(() {
          this.status = AuthStatus.SMS_AUTH;
        });

        AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.TOPSLIDE,
          tittle: "Verify Code Failed",
          desc: "We couldn't create your profile for now, please try again later",
          btnCancelText: 'Close',
          btnCancelIcon: Icons.close,
        ).show();
      }
    });
  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      setState(() {
        // Here we change the status once more to guarantee that the SMS's
        // text input isn't available while you do any other request
        // with the gathered data
        this.status = AuthStatus.PROFILE_AUTH;
        print("${TAG} - Changed status to $status");
      });
    } else {

      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.TOPSLIDE,
        tittle: "Verify Code Failed",
        desc: "We couldn't verify your code, please try again!",
        btnCancelText: 'Close',
        btnCancelIcon: Icons.close,
      ).show();
    }
    return isUserValid;
  }

  // PhoneCodeAutoRetrievalTimeout
  codeAutoRetrievalTimeout(String verificationId) {
    print("${TAG} - onCodeTimeout");
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  // PhoneCodeSent
  codeSent(String verificationId, [int forceResendingToken]) async {
    print("${TAG} - Verification code sent to number ${phoneNumberController.text}");
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this.status = AuthStatus.SMS_AUTH;
      print("${TAG} - Changed status to $status");
    });
  }

  Widget _buildPhoneNumberInput() {
    return MaskedTextField(
      key: _maskedPhoneKey,
      mask: "xxx xxx-xxxx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: phoneNumberController,
      maxLength: 15,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme.of(context)
          .textTheme
          .subhead
          .copyWith(fontSize: 18.0, color: Colors.white),
      inputDecoration: InputDecoration(
        isDense: false,
        enabled: true, //this.status == AuthStatus.PHONE_AUTH,
        counterText: "",
        icon: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        labelText: "Phone",
        labelStyle: decorationStyle,
        hintText: "(99) 99999-9999",
        hintStyle: hintStyle,
        errorText: _errorMessage,
      ),
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

  Future<User> createNewUserDB(String email) async {
//    String email = _teddyController.getEmail();
    try {
      String username = email.substring(0, email.indexOf('@'));
      User user = new User(
        email: email,
        name: username,
      );
      var db = Firestore.instance;

      await db.collection("users")
          .document(email)
          .setData({
        'email': user.email,
        'username': user.name,

        'role': 'user',
        'sent_notification': true,
        'uid': user.email,
        'username': user.name,
        'created_when': Timestamp.now(),
        'created_by': user.email,
        'updated_when': Timestamp.now(),
        'updated_by': user.email,
        'active': true,
      });

      navigationPage(user);
      return user;
    } on Exception catch(err) {
      print('Add new user error: $err');
      return User();
    } finally {

      print('End of createNewUserDB()');
    }
  }

  Future<User> getUserDB(String email) async {
    try {
//      String username = email.substring(0, email.indexOf('@'));
//      User user = new User(
//        email: email,
//        name: username,
//      );
      var db = Firestore.instance;

      var snap = await db.collection("users")
          .document(email)
          .get();
      User user = User.fromMap(snap.data);
      navigationPage(user);
      return user;
    } on Exception catch(err) {
      print('Add new user error: $err');
      return User();
    } finally {

      print('End of getUserDB()');
    }
  }
}

class _PhoneSignInSection extends StatefulWidget {
//  _PhoneSignInSection(this._scaffold);
//
//  final ScaffoldState _scaffold;
  @override
  State<StatefulWidget> createState() => _PhoneSignInSectionState();
}

class _PhoneSignInSectionState extends State<_PhoneSignInSection> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _message = '';
  String _verificationId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: const Text('Test sign in with phone number'),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),
        TextFormField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
              labelText: 'Phone number (+x xxx-xxx-xxxx)'),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Phone number (+x xxx-xxx-xxxx)';
            }
            return null;
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _verifyPhoneNumber();
            },
            child: const Text('Verify phone number'),
          ),
        ),
        TextField(
          controller: _smsController,
          decoration: const InputDecoration(labelText: 'Verification code'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _signInWithPhoneNumber();
            },
            child: const Text('Sign in with phone number'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _message,
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  // Example code of how to verify phone number
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
        'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
//      widget._scaffold.showSnackBar(const SnackBar(
//        content: Text('Please check your phone for the verification code.'),
//      ));
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.TOPSLIDE,
            tittle: "Verify Code Failed",
            desc: "Please check your phone for the verification code.",
            btnCancelText: 'Close',
            btnCancelIcon: Icons.close,
          ).show();
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };
    print("_phoneNumberController.text=${_phoneNumberController.text}");

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _message = 'Successfully signed in, uid: ' + user.uid;
      } else {
        _message = 'Sign in failed';
      }
    });
  }
}