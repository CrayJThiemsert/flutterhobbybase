import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobbybase/model/Grade.dart';
import 'package:hobbybase/model/Gunpla.dart';
import 'package:hobbybase/model/User.dart';
import 'package:imagebutton/imagebutton.dart';
import 'placeholder_widget.dart';
import 'package:hobbybase/transition/scale_transition.dart';
import 'package:hobbybase/transition/slide_right_transition.dart';
import 'package:hobbybase/screen/secondroute.dart';

class HomeScreen extends StatefulWidget {
  User user = User();
  HomeScreen(this.user);

  @override
//  _SafeAreaState createState() => _SafeAreaState();
  _HomeScreenState createState() => _HomeScreenState(this.user);
}
    // TODO: implement createState
//    return null;
//  }

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  final FixedExtentScrollController _controller = FixedExtentScrollController();

  //Uses a Ticker Mixin for Animations
  Animation<double> _animation;
  AnimationController _animationController;
  // Bool value to control the behaviour of SafeArea widget
  bool _isEnabled = true;

  AssetImage _imageToShow;
  String _imagePathToShow = "assets/cardboard01.png"; //"assets/dq/dq01.png";
  String _imageToShowTag = ""; //"demoTag";

  int _currentFabIndex = 1;
  bool _wheelListVisibility = false;

  int _currentIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.amberAccent),
    PlaceholderWidget(Colors.lime),
    PlaceholderWidget(Colors.brown),
//    PlaceholderWidget(Colors.greenAccent)
  ];

  final List<IconData> _fabIcons = [
//    IconData(AssetImage("assets/gunpla_grade/ic_sd_96.png")),
//    ImageIcon(AssetImage("assets/gunpla_grade/ic_highgrade_96.png")),
//    ImageIcon(AssetImage("assets/gunpla_grade/ic_re100_96.png")),
//    ImageIcon(AssetImage("assets/gunpla_grade/ic_realgrade_96.png")),
//    ImageIcon(AssetImage("assets/gunpla_grade/ic_mastergrade_96.png")),
//    ImageIcon(AssetImage("assets/gunpla_grade/ic_perfectgrade_96.png")),
    Icons.menu,
    Icons.airplanemode_active,
    Icons.audiotrack,
    Icons.wb_sunny,
    Icons.wb_cloudy,
    Icons.visibility,
    Icons.mood,
  ];

  final List<Image> _fabImages = [
    Image.asset("assets/gunpla_grade/ic_sd_96.png"),
    Image.asset("assets/gunpla_grade/ic_sd_96.png"),
    Image.asset("assets/gunpla_grade/ic_highgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_re100_96.png"),
    Image.asset("assets/gunpla_grade/ic_realgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_mastergrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_perfectgrade_96.png"),
  ];

  final List<Grade> _fabGrades = [
    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
    Grade(name: "HG", jsonpath: "assets/json/hg.json"),
    Grade(name: "RE100", jsonpath: "assets/json/re100.json"),
    Grade(name: "RG", jsonpath: "assets/json/rg.json"),
    Grade(name: "MG", jsonpath: "assets/json/mg.json"),
    Grade(name: "PG", jsonpath: "assets/json/pg.json"),
  ];

  User user = User();
  _HomeScreenState(this.user);

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

  IconData displayFabOpenIcon() {
    setState(() {
      switch(_currentFabIndex) {
        case 0:
          return Icons.airplanemode_active;
        case 1:
          return Icons.audiotrack;
        case 2:
          return Icons.wb_sunny;
        case 3:
          return Icons.wb_cloudy;
        case 4:
          return Icons.visibility;
        case 5:
          return Icons.video_call;
        default :
          return Icons.menu;
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
    getUserData();

    _wheelListVisibility = true;
//    _imageToShow = AssetImage("assets/dq/dq01.png");
//    _imagePathToShow = "assets/dq/dq01.png";
//    _imageToShowTag = "dq01";
    _imageToShow = AssetImage("assets/cardboard01.png");
    _imagePathToShow = "assets/cardboard01.png";
    _imageToShowTag = user.name;
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

  Future<void> getUsersData() async {
    Firestore.instance
        .collection('users')
        .snapshots()
        .listen((data) =>
          data.documents.forEach((doc) => print(doc["uid"])));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

//    print("Test get cloud firectore data: ");
    // Test get cloud firestore data
//    getUsersData();


    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(

//      appBar: AppBar(
//        title: Text('First Routex'),
//      ),
        floatingActionButton: Builder(
          builder: (context) =>
//              Container(
//                padding: EdgeInsets.only(top: 32.0, left: 8.0),
//                child:
          FabCircularMenu(

            key: fabKey,
            // Cannot be `Alignment.center`
            alignment: Alignment.topLeft,
            ringColor: Colors.white.withAlpha(25),
            ringDiameter: 450.0,
            ringWidth: 70.0,
            fabSize: 64.0,
            fabElevation: 1.0,


            // Also can use specific color based on weather
            // the menu is open or not:
            // fabOpenColor: Colors.white
            // fabCloseColor: Colors.white
            // These properties take precedence over fabColor
            fabColor: Colors.white,

            fabOpenIcon: Icon(_fabIcons[_currentFabIndex], color: primaryColor),
            fabCloseIcon: Icon(Icons.close, color: primaryColor),
            fabMargin: const EdgeInsets.only(top: 16.0, left: 0.0),
            animationDuration: const Duration(milliseconds: 800),
//                  animationCurve: Curves.easeInOutCirc,
            animationCurve: Curves.elasticInOut,
            onDisplayChange: (isOpen) {
              //              _showSnackBar(context, "The menu is ${isOpen ? "open" : "closed"}");
            },
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 1");
                  setState(() {
//                    _currentFabIndex = 0;
                    setCurrentFabSelected(0);
                  });
                  _wheelListVisibility = true;
                  fabKey.currentState.close();
                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('XX'),
//                      child: Icon(Icons.looks_one, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 1");
                  setState(() {
//                    _currentFabIndex = 1;
                    setCurrentFabSelected(1);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('SD'),
//                      child: Icon(Icons.looks_one, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 2");
                  setState(() {
//                    _currentFabIndex = 2;
                    setCurrentFabSelected(2);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('HG'),
//                      child: Icon(Icons.looks_two, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 1");
                  setState(() {
//                    _currentFabIndex = 3;
                    setCurrentFabSelected(3);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('RE'),
//                      child: Icon(Icons.looks_one, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 3");
                  setState(() {
//                    _currentFabIndex = 4;
                    setCurrentFabSelected(4);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('RG'),
//                      child: Icon(Icons.looks_3, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 4. This one closes the menu on tap");
                  setState(() {
//                    _currentFabIndex = 5;
                    setCurrentFabSelected(5);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('MG'),
//                      child: Icon(Icons.looks_4, color: Colors.white, size: 48,),
              ),
              RaisedButton(
                onPressed: () {
                  //                  _showSnackBar(context, "You pressed 5");
                  setState(() {
//                    _currentFabIndex = 6;
                    setCurrentFabSelected(6);
                    _wheelListVisibility = true;
                    fabKey.currentState.close();
                  });

                },
                shape: CircleBorder(),
//                      padding: const EdgeInsets.all(24.0),
                child: Text('PG'),
              ),
            ],
          ),
        ),
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
//    print('call _homePhoneView');
    return SafeArea(
      top: _isEnabled,
      bottom: _isEnabled,
      left: _isEnabled,
      right: _isEnabled,
      minimum: const EdgeInsets.all(2.0),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Top area for Hero & Wheel List
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
//                alignment: AlignmentDirectional.centerStart,

                children: <Widget>[
                  // Wheel list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: <Widget>[
                      buildWheelList(),

                    ],
                  ),

                  // Hero Image
                  buildHeroFrame(),


                  // Grade Image
                  Container(
                    margin: EdgeInsets.only(top: 8.0, left: 8.0),
                    child:
                    Card(
                      elevation: 15.0,
                      child:
                        GestureDetector(
                          child: SizedBox(
                            child:
                              FittedBox(
                                alignment: Alignment.center,
                                fit: BoxFit.fill,
                                child:  _fabImages[_currentFabIndex],
                              ),
                            width: 60,
                            height: 36,
                          ),
                          onTap: () {

                            setState(() {
                              _wheelListVisibility = false;
                            });

                            _currentFabIndex = _currentFabIndex;

                            if(fabKey.currentState.isOpen) {
                              fabKey.currentState.close();
                            } else {
                              fabKey.currentState.open();
                            }
                          },
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body area for contents
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

  List<Widget> _gunplaListWheel(BuildContext context, List<Gunpla> gunplas) {
    List<Widget> listtiles = [];
    for(var i = 0; i < gunplas.length; i++) {
      var runner = i.toString().padLeft(2, '0');
      var name = gunplas[i].name.toUpperCase();
      var boxart = "assets/gunpla/${gunplas[i].boxArtPath}";
//      if(i > 9) {
//        runner = i.toString();
//      }
//      print("${runner} - ${name} - [${boxart}]");
      listtiles.add(GestureDetector(
//          onTap: () {
//            print('hello monster $i');
//          },
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
            // leading = Image icon on the left of tile
//            leading: new Image.asset("assets/dq/dq${runner}.png"), //Icon(Icons.portrait),
            leading: new Image.asset(boxart),
            title: Text("${runner} - ${name}"),
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

  Widget buildWheelList() {
    return FutureBuilder(
//      future: DefaultAssetBundle.of(context).loadString('assets/json/re100.json'),
//        future: DefaultAssetBundle.of(context).loadString('assets/json/hg.json'),
//        future: DefaultAssetBundle.of(context).loadString('assets/json/mg.json'),
//        future: DefaultAssetBundle.of(context).loadString('assets/json/rg.json'),
//        future: DefaultAssetBundle.of(context).loadString('assets/json/pg.json'),
        future: DefaultAssetBundle.of(context).loadString(_fabGrades[_currentFabIndex].jsonpath),
      builder: (context, snapshot) {
        List<Gunpla> gunplas = parseJson(snapshot.data.toString());
        return !gunplas.isEmpty
            ? wheelList(gunplas)
            : Center( child: CircularProgressIndicator());
      });


  }

  Widget wheelList(List<Gunpla> gunplas) {
    return Visibility(
      visible: true, //_wheelListVisibility,
      child:
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
//              _imageToShow = new AssetImage("assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png");
              if(index > gunplas.length) {
                index = 0;
              }
              var boxart = "assets/gunpla/${gunplas[index].boxArtPath}";
              _imageToShow = new AssetImage("${boxart}");
//              _imagePathToShow = "assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png";
              _imagePathToShow = boxart;
//              _imageToShowTag = "dq${(index+1).toString().padLeft(2, '0')}";
              var name = gunplas[index].name;
              _imageToShowTag = name;
              //                      _animationController
              //                          .forward(); // tapping the button, starts the animation.
            });
          },
//          controller: _controller, // not used controller in this case?
          diameterRatio: 2.5,
          offAxisFraction: -1.5,
          itemExtent: 80,
          //              magnification: 1.0,
          squeeze: 1.0,
          //              useMagnifier: true,
          physics:  FixedExtentScrollPhysics(), // BouncingScrollPhysics()
          children: ListTile.divideTiles(
            context: context,
            tiles: _gunplaListWheel(context, gunplas), //List of widgets,
          ).toList(),

        ),
      ),
    );
  }

  List<Gunpla> parseJson(String response) {
    if(response == null) {
      return [];
    }
    final parsed = json.decode(response.toString()); //.cast<Map<String, dynamic>>();
    return parsed?.map<Gunpla>((json) => new Gunpla.fromJson(json))?.toList() ?? [];
  }

  void setCurrentFabSelected(int selectedFabIndex) {
    _currentFabIndex = selectedFabIndex;

    print("Pressed ${_currentFabIndex} - ${_fabGrades[_currentFabIndex].name} - ${_fabGrades[_currentFabIndex].jsonpath}");
  }

  Widget buildHeroFrame() {
    return // Hero Image
      Container(
        margin: EdgeInsets.only(top: 80, right: 50),

        child: SizedBox(
          child: GestureDetector(
            child: Hero(
              tag: _imageToShowTag,
              child:
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          gradient: new RadialGradient(
                              colors: [Colors.yellow, Colors.black],
                              center: Alignment(1.5, 0.2),
                              radius: 3.3,
                              stops: [0.0, 0.2]
                          ),
                          boxShadow: [new BoxShadow(
                              color: Colors.black54,
                              offset: new Offset(4.0, 4.0),
                              blurRadius: 4.0
                          )],
      //                                  color: Colors.indigoAccent,
                          border: Border.all(
                            color: Colors.tealAccent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: ClipRRect(

                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0)
                        ),
                        child:
                            Image.asset(
                              _imagePathToShow,
                              //                            scale: 0.8,
                              height: 170,
                              width: 170,
                              fit: BoxFit.scaleDown,
                            ),
                      ),
                    ),
                    // Hero title
                    Container(
                      width: 170,
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          gradient: new RadialGradient(
                              colors: [Colors.indigoAccent, Colors.indigo],
                              center: Alignment(1.5, 0.2),
                              radius: 3.3,
                              stops: [0.0, 0.2]
                          ),
                          boxShadow: [new BoxShadow(
                              color: Colors.black54,
                              offset: new Offset(4.0, 4.0),
                              blurRadius: 4.0
                          )],
                          //                                  color: Colors.indigoAccent,
                          border: Border.all(
                            color: Colors.purpleAccent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: ClipRRect(

                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0)
                        ),
                        child:
                          Text(
                            _imageToShowTag.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: //Theme.of(context).textTheme.headline,
                            TextStyle(

                              fontSize: 12.0,
                              color: Colors.white,
                              fontFamily: 'K2D-BoldItalic'
                            ),
                          ),
                      ),
                    ),
                  ],
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

      );
  }

  Future<void> getUserData() {

    User.getUserDB(user.email).then((userdb) {
      user = userdb;
      print('--- Current user is ${user.name} ---');
      setState(() {
        _imageToShowTag = user.name;
      });
    });
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
            child:
              Column(
                children: [
                  Image.asset(
                      imageToShowPath,
                      scale: 0.5,
                    ),
                  Container(
                    width: 170,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        gradient: new RadialGradient(
                            colors: [Colors.indigoAccent, Colors.indigo],
                            center: Alignment(1.5, 0.2),
                            radius: 3.3,
                            stops: [0.0, 0.2]
                        ),
                        boxShadow: [new BoxShadow(
                            color: Colors.black54,
                            offset: new Offset(4.0, 4.0),
                            blurRadius: 4.0
                        )],
                        //                                  color: Colors.indigoAccent,
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: ClipRRect(

                      borderRadius: BorderRadius.all(
                          Radius.circular(5.0)
                      ),
                      child:
                      Text(
                        imageToShowHero.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: //Theme.of(context).textTheme.headline,
                        TextStyle(

                            fontSize: 12.0,
                            color: Colors.white,
                            fontFamily: 'K2D-BoldItalic'
                        ),
                      ),
                    ),
                  ),
                ],
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