import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'placeholder_widget.dart';
import 'package:hobbybase/transition/scale_transition.dart';
import 'package:hobbybase/transition/slide_right_transition.dart';
import 'package:hobbybase/screen/secondroute.dart';

class HomeScreen extends StatefulWidget {
  @override
//  _SafeAreaState createState() => _SafeAreaState();
  _HomeScreenState createState() => _HomeScreenState();
}
    // TODO: implement createState
//    return null;
//  }

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FixedExtentScrollController _controller = FixedExtentScrollController();

  //Uses a Ticker Mixin for Animations
  Animation<double> _animation;
  AnimationController _animationController;
  // Bool value to control the behaviour of SafeArea widget
  bool _isEnabled = true;

  AssetImage _imageToShow;
  String _imagePathToShow = "assets/dq/dq01.png";
  String _imageToShowTag = "demoTag";

  int _currentIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.amberAccent),
    PlaceholderWidget(Colors.lime),
    PlaceholderWidget(Colors.brown),
//    PlaceholderWidget(Colors.greenAccent)
  ];

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () => exit(0),
            /*Navigator.of(context).pop(true)*/
            child: Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      debugPrint("_currentIndex[${_currentIndex}]");
      if(_currentIndex == 2) {
        debugPrint("Do logoff");
        signOut();
      }
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pushNamedAndRemoveUntil("/SignInScreen", ModalRoute.withName("/HomeScreen"));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageToShow = AssetImage("assets/dq/dq01.png");
    _imagePathToShow = "assets/dq/dq01.png";
    _imageToShowTag = "dq01";
//    _animationController = AnimationController(
//        vsync: this,
//        duration: Duration(
//            seconds:
//            2)); //specify the duration for the animation & include `this` for the vsyc
//    _animation = Tween<double>(begin: 1.0, end: 3.5).animate(
//        _animationController); //use Tween animation here, to animate between the values of 1.0 & 2.5.
//
//    _animation.addListener(() {
//      //here, a listener that rebuilds our widget tree when animation.value chnages
//      setState(() {});
//    });
//
//    _animation.addStatusListener((status) {
//      //AnimationStatus gives the current status of our animation, we want to go back to its previous state after completing its animation
//      if (status == AnimationStatus.completed) {
//        _animationController
//            .reverse(); //reverse the animation back here if its completed
//      }
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(

//      appBar: AppBar(
//        title: Text('First Routex'),
//      ),
        body: LayoutBuilder(

          builder: (context, constraints) {
            if(constraints.maxWidth < 600) {
              // Mobile/Vertical
              return _homePhoneView();

            } else {
              // Tablet/Horizontal
              return _homeTabletView();
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              title: Text('Messages'),
            ),
//            new BottomNavigationBarItem(
//                icon: Icon(Icons.person),
//                title: Text('Profile')
//            ),
            new BottomNavigationBarItem(
                icon: Icon(Icons.settings_power),
                title: Text('Logoff')
            )
          ],
        ),
      ),
    );

  }

  /**
   * create Mobile/Vertical View
   */
  Widget _homePhoneView() {
    print('call _homePhoneView');
    return SafeArea(
      top: _isEnabled,
      bottom: _isEnabled,
      left: _isEnabled,
      right: _isEnabled,
      minimum: const EdgeInsets.all(2.0),


      child: Column(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(

            decoration: new BoxDecoration(
//              color: Colors.cyan,
              gradient: new RadialGradient(
                colors: [Colors.blueGrey, Colors.white],
                center: Alignment(-1.5, -0.2),
                radius: 3.3,
                stops: [0.0, 0.2]
              ),
              boxShadow: [new BoxShadow(
                  color: Colors.black54,
                  offset: new Offset(4.0, 4.0),
                  blurRadius: 4.0
              )],
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 6.0),
              child: Stack(
                alignment: AlignmentDirectional.centerStart,

                children: <Widget>[

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: <Widget>[

                      Container(
                        decoration: new BoxDecoration(
                          color: Colors.indigo,
                          gradient: new LinearGradient(
                            colors: [Colors.white, Colors.cyan],
                          ),
                          boxShadow: [new BoxShadow(
                              color: Colors.black54,
                              offset: new Offset(4.0, 4.0),
                              blurRadius: 4.0
                          )],
                        ),

                        //            alignment: Alignment.center,
                        //            color: Colors.amber,
                        height: MediaQuery.of(context).size.height / 2,
                        width: 225, //MediaQuery.of(context).size.width - 120,
                        child: ListWheelScrollView(
                          onSelectedItemChanged: (index) {
                            print('hello monster ${(index+1).toString().padLeft(2, '0')}');
                            setState(() {
                              _imageToShow = new AssetImage("assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png");
                              _imagePathToShow = "assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png";
                              _imageToShowTag = "dq${(index+1).toString().padLeft(2, '0')}";
                              //                      _animationController
                              //                          .forward(); // tapping the button, starts the animation.
                            });
                          },
                          controller: _controller,
                          diameterRatio: 2.5,
                          offAxisFraction: -1.5,
                          itemExtent: 80,
                          //              magnification: 1.0,
                          squeeze: 1.0,
                          //              useMagnifier: true,
                          physics:  FixedExtentScrollPhysics(), // BouncingScrollPhysics()
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: _homeListWheel(context), //List of widgets,
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    //            alignment: Alignment.centerLeft,
                    //            height: MediaQuery.of(context).size.height / 2,
                    //            width: MediaQuery.of(context).size.width,

                    child: SizedBox(
                      child: GestureDetector(
                        child: Hero(
                          tag: _imageToShowTag,
                          child: Image.asset(
                            _imagePathToShow,
                            scale: 0.6,
                          ),
                          transitionOnUserGestures: true,
                        ),

                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) {
                            return DetailScreen(
                              imageToShowHero: _imageToShowTag,
                              imageToShowPath: _imagePathToShow,
                            );
                          }));
                        },
                      ),
                    ),

                  ),

                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
//            height: 200,
              color: Colors.amberAccent,
              child:  _children[_currentIndex],
            ),
          )
        ],
      ),
    );
  }


  /**
   * create Mobile/Vertical View
   */
  Widget _safeAreaPhoneView() {
    return SafeArea(
      top: _isEnabled,
      bottom: _isEnabled,
      left: _isEnabled,
      right: _isEnabled,
      minimum: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.orange,
            child: Text(
              "Phone View!! This widget is below safe area. If you remove the SafeArea "
                  "widget then this text will be behind the notch.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),

          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.deepOrange,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              _isEnabled == true ? _isEnabled = false : _isEnabled = true;
            }),
            child: Text(_isEnabled ? "Disable SafeArea" : "Enable SafeArea"),
          ),
          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.deepOrange,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              Navigator.push(
                context,
                ScaleRoute(widget: BasicWheelListScreen()),
              );
            }),
            child: Text("Wheel List"),
          ),
          // =====================
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.orange,
            child: Text(
              "This widget is above safe area",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * create Tablet/Horizontal View
   */
  Widget _homeTabletView() {
    return SafeArea(
      top: _isEnabled,
      bottom: _isEnabled,
      left: _isEnabled,
      right: _isEnabled,
      minimum: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Text(
              "Tablet View!! This widget is below safe area. If you remove the SafeArea "
                  "widget then this text will be behind the notch.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),

          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              _isEnabled == true ? _isEnabled = false : _isEnabled = true;
            }),
            child: Text(_isEnabled ? "Disable SafeArea" : "Enable SafeArea"),
          ),
          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              Navigator.push(
                context,
                ScaleRoute(widget: BasicWheelListScreen()),
              );
            }),
            child: Text("Wheel List"),
          ),
          // =====================
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Text(
              "This widget is above safe area",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * create Tablet/Horizontal View
   */
  Widget _safeAreaTabletView() {
    return SafeArea(
      top: _isEnabled,
      bottom: _isEnabled,
      left: _isEnabled,
      right: _isEnabled,
      minimum: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Text(
              "Tablet View!! This widget is below safe area. If you remove the SafeArea "
                  "widget then this text will be behind the notch.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),

          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              _isEnabled == true ? _isEnabled = false : _isEnabled = true;
            }),
            child: Text(_isEnabled ? "Disable SafeArea" : "Enable SafeArea"),
          ),
          // =========================
          RaisedButton(
            textColor: Colors.white,
            color: Colors.indigo,
//              child: Text('Open route'),
            onPressed: () => setState(() {
              Navigator.push(
                context,
                ScaleRoute(widget: BasicWheelListScreen()),
              );
            }),
            child: Text("Wheel List"),
          ),
          // =====================
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Text(
              "This widget is above safe area",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _homeListWheel(BuildContext context) {
    List<Widget> listtiles = [];
    for(var i = 1; i <= 82; i++) {
      var runner = i.toString().padLeft(2, '0');
//      if(i > 9) {
//        runner = i.toString();
//      }
//      debugPrint(runner);
      listtiles.add(GestureDetector(
//          onTap: () {
//            print('hello monster $i');
//          },
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
            leading: new Image.asset("assets/dq/dq${runner}.png"), //Icon(Icons.portrait),
            title: Text("Monster-${runner}"),
//            GestureDetector(
//              onTap: () {
//                print('tap monster $i');
//              },
//              child: FlatButton(
//                  onPressed: () {
//                    print('pressed monster $i');
//                  },
//                  child: Text("Monster-${runner}"),
//              ),
//            ),

            subtitle: Text("Beautiful View..!"),
    //      trailing: Icon(Icons.arrow_forward_ios),
//            onTap: () {
//              print('hello ${runner}');
//            },
      )));
    }


    return listtiles;
  }
}

class DetailScreen extends StatelessWidget {
  final String imageToShowHero;
  final String imageToShowPath;

  DetailScreen( {this.imageToShowHero, this.imageToShowPath });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: imageToShowHero,
            child: Image.asset(
              imageToShowPath,
              scale: 0.5,
            ),
            transitionOnUserGestures: true,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}



class _SafeAreaState extends State<HomeScreen> {

  // Bool value to control the behaviour of SafeArea widget
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
//      appBar: AppBar(
//        title: Text('First Routex'),
//      ),
      body: SafeArea(
        top: _isEnabled,
        bottom: _isEnabled,
        left: _isEnabled,
        right: _isEnabled,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.blue,
              child: Text(
                "This widget is below safe area. If you remove the SafeArea "
                    "widget then this text will be behind the notch.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),

            // =========================
            RaisedButton(
              textColor: Colors.white,
              color: Colors.indigo,
//              child: Text('Open route'),
              onPressed: () => setState(() {
                _isEnabled == true ? _isEnabled = false : _isEnabled = true;
              }),
              child: Text(_isEnabled ? "Disable SafeArea" : "Enable SafeArea"),
            ),
            // =====================
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.blue,
              child: Text(
                "This widget is above safe area",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
//              onPressed: () {
//                // Navigate to second route when tapped.
//
//                Navigator.push(
//                  context,
//                  ScaleRoute(widget: MyHomePage()),
////                ScaleRoute(widget: SecondRoute()),
////              SlideRightRoute(widget: SecondRoute()),
////              MaterialPageRoute(builder: (context) => SecondRoute()),
//                );
//              },
//            ),
          ],
        ),


      ),

//      body: Center(
//        child: RaisedButton(
//          child: Text('Open route'),
//          onPressed: () {
//            // Navigate to second route when tapped.
//
//            Navigator.push(
//              context,
//                ScaleRoute(widget: MyHomePage()),
////                ScaleRoute(widget: SecondRoute()),
////              SlideRightRoute(widget: SecondRoute()),
////              MaterialPageRoute(builder: (context) => SecondRoute()),
//            );
//          },
//        ),
//      ),
    );
  }
}