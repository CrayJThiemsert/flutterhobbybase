import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobbybase/model/Grade.dart';
import 'package:hobbybase/model/Gunpla.dart';
import 'package:hobbybase/model/GunplaAction.dart';
import 'package:hobbybase/model/Owned.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/popup/popup_menu.dart';
import 'package:hobbybase/screen/screen_profile.dart';
import 'package:hobbybase/widget/dialog_widget.dart';
import 'package:hobbybase/widget/display_owned_widget.dart';
import 'package:hobbybase/widget/list_owned.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:intl/intl.dart';
import 'hero_gunpla_detail_screen.dart';
import 'owned_list_screen.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  final FixedExtentScrollController _controller = FixedExtentScrollController();

  //Uses a Ticker Mixin for Animations
  Animation<double> _animation;
  AnimationController _animationController;
  // Bool value to control the behaviour of SafeArea widget
  bool _isEnabled = true;

  AssetImage _imageToShow;
  String _imagePathToShow = "assets/cardboard01.png"; //"assets/dq/dq01.png";
  String _imageToShowTag = ""; //"demoTag";
  String _imageToShowBoxArt = "";
  int _imageWheelIndex = 0;

  int _totalLiked = 0;
  int _totalOwned = 0;
  int _totalShared = 0;

  double _fontTileSize = 8;

  int _currentFabIndex = 0;
  bool _wheelListVisibility = false;
  List<Gunpla> gunplas = List<Gunpla>(); // parseJson(snapshot.data.toString());

  int _currentBottomNavIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.amberAccent),
    PlaceholderWidget(Colors.lime),
    PlaceholderWidget(Colors.brown),
//    PlaceholderWidget(Colors.greenAccent)
  ];
  
  Color _borderHeroColor = Colors.limeAccent;

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
//    Image.asset("assets/gunpla_grade/ic_sd_96.png"),
//    Image.asset("assets/gunpla_grade/ic_sd_96.png"),
    Image.asset("assets/gunpla_grade/ic_highgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_re100_96.png"),
    Image.asset("assets/gunpla_grade/ic_realgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_mastergrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_perfectgrade_96.png"),
  ];

  final List<Grade> _fabGrades = [
//    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
//    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
    Grade(name: "HG", jsonpath: "assets/json/hg.json", totalOwned: 0),
    Grade(name: "RE100", jsonpath: "assets/json/re100.json", totalOwned: 0),
    Grade(name: "RG", jsonpath: "assets/json/rg.json", totalOwned: 0),
    Grade(name: "MG", jsonpath: "assets/json/mg.json", totalOwned: 0),
    Grade(name: "PG", jsonpath: "assets/json/pg.json", totalOwned: 0),
  ];

  PopupMenu _gradeMenu;
  GlobalKey _gradeMenuKey = GlobalKey();

  User user = User();

  List<bool> _actionSelections = List.generate(3, (_) => false);
  HashMap _gunplaActionMap = HashMap<String, GunplaAction>();
  HashMap _gunplaOwnedMap = HashMap<String, Owned>();
  bool _isChangeGrade = false;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  _HomeScreenState(this.user);

  Future<bool> _onWillPop() {
    return
      DialogUtils().showConfirmationDialog(context,
          'Are you sure?',
          'Do you want to exit an App?',
          'Yes',
          'No',
          'close_app',
          'close_dialog'
      ) ??
      false;
  }

  gotoOwnedScreen(User user) async {
    PageController p;
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OwnedListScreen(user) ));

//    Scaffold.of(context)
//    ..removeCurrentSnackBar()
//    ..showSnackBar(SnackBar(content: Text("${result}"),));

    setState(() {
      _currentBottomNavIndex = 0;
      onTabTapped(_currentBottomNavIndex);
    });
  }

  gotoProfileScreen(User user) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(user) ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
      debugPrint("_currentBottomNavIndex[${_currentBottomNavIndex}]");
      switch(_currentBottomNavIndex) {
        case 0:
          _fcm.subscribeToTopic('puppies');
          break;
        case 1:
          gotoProfileScreen(user);
          break;
        case 2:
          debugPrint("Do logoff");
          DialogUtils().showConfirmationDialog(context,
              'Sign Out',
              'Are you sure you would like to sign out?',
              'Sign out',
              'Cancel',
              'sign_out',
              'close_dialog'
          );
          break;
      }
    });
  }

  IconData displayFabOpenIcon() {
    setState(() {
      switch (_currentFabIndex) {
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
        default:
          return Icons.menu;
      }
    });
  }

  String getLiked() {
    return "${_totalLiked}";
  }

  void addLiked() {
    setState(() {
      _totalLiked = _totalLiked + 1;
      print('add liked - [${_totalLiked}]');
    });
  }

  void deleteLiked() {
    setState(() {
      if(_totalLiked > 0) {
        _totalLiked = _totalLiked - 1;
      }
      print('delete liked - [${_totalLiked}]');
    });
  }

  String getOwned() {
    return "${_totalOwned}";
  }

  void addOwned() {
    setState(() {
      _totalOwned = _totalOwned + 1;
      print('add liked - [${_totalOwned}]');
    });
  }

  void deleteOwned() {
    setState(() {
      if(_totalOwned > 0) {
        _totalOwned = _totalOwned - 1;
      }
      print('delete liked - [${_totalOwned}]');
    });
  }

  String getShared() {
    return "${_totalShared}";
  }

  void addShared() {
    setState(() {
      _totalShared = _totalShared + 1;
      print('add liked - [${_totalShared}]');
    });
  }

  void deleteShared() {
    setState(() {
      if(_totalShared > 0) {
        _totalShared = _totalShared - 1;
      }
      print('delete liked - [${_totalShared}]');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _totalLiked = 0;
    _totalOwned = 0;
    _totalShared = 0;
    
    getUserData();
    getOwnedDataDB().then((_) {
      print(
          'fnEnd of getOwnedDataDB ${_gunplaOwnedMap.length} records');
    });

    _gradeMenu = PopupMenu(items: [
      MenuItem(
        title: 'HG',
        image: Image.asset("assets/gunpla_grade/ic_highgrade_96.png"),
      ),
      MenuItem(
        title: 'RE100',
        image: Image.asset("assets/gunpla_grade/ic_re100_96.png"),
      ),
      MenuItem(
        title: 'RG',
        image: Image.asset("assets/gunpla_grade/ic_realgrade_96.png"),
      ),
      MenuItem(
        title: 'MG',
        image: Image.asset("assets/gunpla_grade/ic_mastergrade_96.png"),
      ),
      MenuItem(
        title: 'PG',
        image: Image.asset("assets/gunpla_grade/ic_perfectgrade_96.png"),
      ),

    ],
      onClickMenu: onClickMenu,
      onDismiss: onDismiss,
      maxColumn: 3
    );

    _isChangeGrade = true;
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

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: ${message}');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            )
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: ${message}');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: ${message}');
      },
    );
  }



  Future<void> getUsersData() async {
    Firestore.instance
        .collection('users')
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => print(doc["uid"])));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    PopupMenu.context = context;

//    print("Test get cloud firectore data: ");
    // Test get cloud firestore data
//    getUsersData();

//    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
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
          currentIndex: _currentBottomNavIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
            ),
//            new BottomNavigationBarItem(
//                icon: Icon(Icons.person),
//                title: Text('Profile')
//            ),
            new BottomNavigationBarItem(
                icon: Icon(Icons.settings_power), title: Text('Logoff'))
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
          // Top area for Hero & Wheel List
          Container(
            decoration: new BoxDecoration(
//              color: Colors.cyan,
              gradient: new RadialGradient(
                  colors: [Colors.indigo[900], Colors.teal[50]],
                  center: Alignment(-1.5, -0.2),
                  radius: 3.3,
                  stops: [0.0, 0.2]),
              boxShadow: [
                new BoxShadow(
                    color: Colors.black54,
                    offset: new Offset(4.0, 4.0),
                    blurRadius: 4.0)
              ],
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
//                      buildWheelListNoFutureBuild(),
                    ],
                  ),

                  // Hero Image
                  buildHeroFrame(),

                  // Grade Image
                  Container(
                    margin: EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Card(
                      elevation: 15.0,
                      child: GestureDetector(
                        child: SizedBox(
                          child: FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.fill,
                            child:
                              Tooltip(
                                  message: 'Grade',
                                  verticalOffset: 28,
                                  child: _fabImages[_currentFabIndex],
                              ),
                          ),
                          width: 60,
                          height: 36,
                        ),
                        key: _gradeMenuKey,
                        onTap: () {
                          showPopupGradeMenu();

                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body area for contents
          Divider(
            thickness: 2,
            indent: 4,
            endIndent: 4,
            height: 2.0,
            color: Colors.orange[700],
          ),
          Expanded(
            child: Container(
//            height: 200,
              color: Colors.amberAccent,
              child: getChildPanel(),
            ),
          )
        ],
      ),
    );
  }

  Widget getChildPanel() {
    if(_currentBottomNavIndex <= 1) {
      return OwnedDisplayWidget(Colors.black87, getLiked, getOwned, getShared, user);
    } else {
      return _children[_currentBottomNavIndex];
    }
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
    for (var i = 1; i <= 82; i++) {
      var runner = i.toString().padLeft(2, '0');
//      if(i > 9) {
//        runner = i.toString();
//      }
//      debugPrint(runner);
      listtiles.add(GestureDetector(
          child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
        leading: new Image.asset(
            "assets/dq/dq${runner}.png"), //Icon(Icons.portrait),
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
    for (var i = 0; i < gunplas.length; i++) {
      var runner = i.toString().padLeft(2, '0');
      var name = gunplas[i].name.toUpperCase();
      var boxart = "assets/gunpla/${gunplas[i].box_art_path}";
//      if(i > 9) {
//        runner = i.toString();
//      }
//      print("${runner} - ${name} - [${boxart}]");
      listtiles.add(GestureDetector(
          child: ListTile(
          dense: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          // leading = Image icon on the left of tile
  //            leading: new Image.asset("assets/dq/dq${runner}.png"), //Icon(Icons.portrait),
          leading: new Image.asset(boxart),
          title: Text(
              "${runner} - ${name}",
              style: TextStyle(
                  fontFamily: "RobotoMedium",
                  fontSize: _fontTileSize,
//                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[50])
            ),
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

          subtitle:
            Text(""),
//          Text("Beautiful View..!"),
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
        // Load JSON of gunpla list
        future: DefaultAssetBundle.of(context)
            .loadString(_fabGrades[_currentFabIndex].jsonpath),
        builder: (context, snapshot) {
          if (_isChangeGrade) {
            gunplas = parseJson(snapshot.data.toString());
            initGunplaActionMap(gunplas);
          }

          return (!gunplas.isEmpty && gunplas.length > 0)
              ? wheelList(gunplas)
              : Center(child: CircularProgressIndicator());
        });
  }

  Future<void> _loadJSONAsset() async {
    return await DefaultAssetBundle.of(context)
            .loadString(_fabGrades[_currentFabIndex].jsonpath);
  }

  Future parseJSONAsset() async {
    gunplas = parseJson(await _loadJSONAsset().toString());
    initGunplaActionMap(gunplas);
  }

  Widget buildWheelListNoFutureBuild() {
    parseJSONAsset();
    return (!gunplas.isEmpty && gunplas.length > 0)
        ? wheelList(gunplas)
        : Center(child: CircularProgressIndicator());

    return FutureBuilder(
      // Load JSON of gunpla list
//        future: DefaultAssetBundle.of(context)
//            .loadString(_fabGrades[_currentFabIndex].jsonpath),
        builder: (context, snapshot) {
          if (_isChangeGrade) {
            gunplas = parseJson(snapshot.data.toString());
            initGunplaActionMap(gunplas);
          }

          return (!gunplas.isEmpty && gunplas.length > 0)
              ? wheelList(gunplas)
              : Center(child: CircularProgressIndicator());
        });
  }

  void initTotalOwnedInfo() {
    _totalLiked = 0;
    _totalOwned = 0;
    _totalShared = 0;
    for(Owned v in _gunplaOwnedMap.values) {
      if(v.is_liked) {
        _totalLiked++;
      }
      if(v.is_owned) {
        _totalOwned++;
      }
      if(v.is_shared) {
        _totalShared++;
      }
    }
  }

  Widget wheelList(List<Gunpla> gunplas) {
    print(
        'wheelList - getOwnedDataDB ${_gunplaOwnedMap.length} records');
    initTotalOwnedInfo();
    return Visibility(
      visible: true, //_wheelListVisibility,
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.indigo,
          gradient: new LinearGradient(
            colors: [Colors.teal[50], Colors.indigo[900]],
          ),
          boxShadow: [
            new BoxShadow(
                color: Colors.black54,
                offset: new Offset(4.0, 4.0),
                blurRadius: 4.0)
          ],
        ),

        //            alignment: Alignment.center,
        //            color: Colors.amber,
        height: MediaQuery.of(context).size.height / 2,
        width: 225, //MediaQuery.of(context).size.width - 120,
        child: ListWheelScrollView(
          onSelectedItemChanged: (index) {
            print('hello monster ${(index + 1).toString().padLeft(2, '0')}');
            print(
                'Here getOwnedDataDB ${_gunplaOwnedMap.length} records');

            setState(() {
//              _imageToShow = new AssetImage("assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png");
              if (index > gunplas.length) {
                index = 0;
              }

              _imageWheelIndex = index;
              var boxart = "assets/gunpla/${gunplas[index].box_art_path}";
              _imageToShow = new AssetImage("${boxart}");
//              _imagePathToShow = "assets/dq/dq${(index+1).toString().padLeft(2, '0')}.png";
              _imagePathToShow = boxart;
//              _imageToShowTag = "dq${(index+1).toString().padLeft(2, '0')}";
              var name = gunplas[index].name;
              _imageToShowTag = name;
              _imageToShowBoxArt = gunplas[index].box_art_path;
              clearActionToggleButtons();
            });
          },
//          controller: _controller, // not used controller in this case?
          diameterRatio: 2.5,
          offAxisFraction: -1.5,
          itemExtent: 80,
          //              magnification: 1.0,
          squeeze: 1.0,
          //              useMagnifier: true,
          physics: FixedExtentScrollPhysics(), // BouncingScrollPhysics()
          children: ListTile.divideTiles(
            context: context,
            tiles: _gunplaListWheel(context, gunplas), //List of widgets,
          ).toList(),
        ),
      ),
    );
  }

  List<Gunpla> parseJson(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()); //.cast<Map<String, dynamic>>();
    return parsed?.map<Gunpla>((json) => new Gunpla.fromJson(json))?.toList() ??
        [];
  }

  void setCurrentFabSelected(int selectedFabIndex) {
    print('_currentFabIndex[${_currentFabIndex}] | selectedFabIndex[${selectedFabIndex}]');
    if (_currentFabIndex != selectedFabIndex) {
      _currentFabIndex = selectedFabIndex;
      _isChangeGrade = true;

    } else {
      _isChangeGrade = false;
    }

    print(
        "Pressed _isChangeGrade[${_isChangeGrade}] - ${_currentFabIndex} - ${_fabGrades[_currentFabIndex].name} - ${_fabGrades[_currentFabIndex].jsonpath}");
  }

  Widget buildHeroFrame() {
    return // Hero Image
        Container(
          margin: EdgeInsets.only(top: 60, right: 50),
          child: SizedBox(
            child: GestureDetector(
              child: Hero(
                tag: _imageToShowTag,
                child: Column(
  //                mainAxisAlignment: MainAxisAlignment.start,
  //                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Background & Hero Image
                    Container(
                          decoration: BoxDecoration(
                            gradient: new RadialGradient(
                                colors: [Colors.yellow, Colors.black],
                                center: Alignment(1.5, 0.2),
                                radius: 3.3,
                                stops: [0.0, 0.2]),
                            boxShadow: [
                              new BoxShadow(
                                  color: Colors.black54,
                                  offset: new Offset(4.0, 4.0),
                                  blurRadius: 4.0)
                            ],
                            //                                  color: Colors.indigoAccent,
                            border: Border(
                              left: BorderSide(
                                color: _borderHeroColor,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: _borderHeroColor,
                                width: 2.0,
                              ),
                              top: BorderSide(
                                color: _borderHeroColor,
                                width: 2.0,
                              ),
                            ),
      //                      borderRadius: BorderRadius.circular(8.0)
                        ),
  
                        // HeroMainHome Image
                        child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                              child: Image.asset(
                                _imagePathToShow,
                                //                            scale: 0.8,
                                height: 170,
                                width: 170,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                      ),
                    // Divider
                    Container(
                      width: 174,
                      height: 2,
                      child: Divider(
                        thickness: 1,
                        indent: 2,
                        endIndent: 2,
                        height: 2.0,
                        color: Colors.limeAccent,
                      ),
                    ),
                    // Hero Caption
                    Container(
                        height: 75,
                        width: 174,
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [Colors.teal[200], Colors.indigo[900]],
                                stops: [0.0, 0.3]
                                ),
                            boxShadow: [
                              new BoxShadow(
                                  color: Colors.black54,
                                  offset: new Offset(4.0, 4.0),
                                  blurRadius: 4.0)
                            ],
                            border: Border(
                              left: BorderSide(
                                color: _borderHeroColor,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: _borderHeroColor,
                                width: 2.0,
                              ),
                            ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Text(
                            _imageToShowTag.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: //Theme.of(context).textTheme.headline,
                                TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.teal[50],
                                    fontFamily: 'K2D-BoldItalic'),
                          ),
                        ),
                      ),
                    // Divider
                    Container(
                      width: 174,
                      height: 2,
                      child: Divider(
                        thickness: 1,
                        indent: 2,
                        endIndent: 2,
                        height: 2.0,
                        color: Colors.limeAccent,
                      ),
                    ),
                    
                    // Toggle Action buttons (Liked, Owned, Shared)
  //            SingleChildScrollView(
  //              child:
                    Container(
                      height: 75,
                      width: 174,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
  //                          gradient: new LinearGradient(
  //                              colors: [Colors.teal[200], Colors.indigo[900]],
  //                              stops: [0.0, 0.3]
  //                          ),
                            boxShadow: [
                              new BoxShadow(
                                  color: Colors.black54,
                                  offset: new Offset(4.0, 4.0),
                                  blurRadius: 4.0)
                            ],
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(
                                  color: _borderHeroColor,
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  color: _borderHeroColor,
                                  width: 2.0,
                                ),
                                bottom: BorderSide(
                                  color: _borderHeroColor,
                                  width: 2.0,
                                ),
                              ),
  
                          ),
                      child:
//                        ClipRRect(
//                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                          child:
                          Material(
                            child: ToggleButtons(
                              children: <Widget>[
                                Tooltip(
                                  message: 'Liked',
                                  verticalOffset: 38,
                                  child: Icon(Icons.thumb_up),
                                ),
                                Tooltip(
                                  message: 'Owned',
                                  verticalOffset: 38,
                                  child: Icon(Icons.pets),
                                ),
                                Tooltip(
                                    message: 'Shared',
                                    verticalOffset: 38,
                                    child: Icon(Icons.record_voice_over),
                                ),
                              ],
                              color: Colors.black26,
                              selectedColor: Colors.white,
                              fillColor: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                              borderWidth: 2,
                              borderColor: Colors.lime,
                              selectedBorderColor: Colors.lime,
                              isSelected: _actionSelections,
                              onPressed: (int index) {
                                setState(() {
                                  _actionSelections[index] = !_actionSelections[index];
                                  print('${index} - ${_actionSelections[index]}');
                                  if (updateSelectedActionMap(index)) {
                                    updateGunplaActionDB(index);
                                  }
                                });
                              },
//                          ),
                          ),
                        ),
                    ),
  //          ),
                  ],
                ),
                transitionOnUserGestures: true,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return HeroGunplaDetailScreen(
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
      print('--- Current user is ${user.toString()} ---');
//      setState(() {
//        _imageToShowTag = user.name;
//      });
    });
  }

  void clearActionToggleButtons() {
    setState(() {
      for (var i = 0; i < _actionSelections.length; i++) {
        _actionSelections[i] = false;
      }
      // Set Actions from select gunpla
      if (_imageToShowBoxArt != null &&
          _gunplaActionMap.containsKey(_imageToShowBoxArt)) {
        GunplaAction gunplaAction = _gunplaActionMap[_imageToShowBoxArt];
        _actionSelections[0] = gunplaAction.is_liked;
        _actionSelections[1] = gunplaAction.is_owned;
        _actionSelections[2] = gunplaAction.is_shared;
      }
    });
  }

  void initGunplaActionMap(List<Gunpla> gunplas) {
    print('call initGunplaActionMap +++++');
    _gunplaActionMap.clear();

    for (var i = 0; i < gunplas.length; i++) {
//      if(i == 5) { // For test only, can deleted after done
//        _gunplaActions[gunplas[i].box_art_path] = GunplaAction(
//          gunpla: gunplas[i],
//          is_liked: false,
//          is_owned: true,
//          is_shared: false,
//        );
//      } else {
      _gunplaActionMap[gunplas[i].box_art_path] = GunplaAction(
        gunpla: gunplas[i],
        is_liked: getActionValue(gunplas[i].box_art_path, 0),
        is_owned: getActionValue(gunplas[i].box_art_path, 1),
        is_shared: getActionValue(gunplas[i].box_art_path, 2),
      );
//      }

    }
    if (gunplas.length > 0 &&
        _fabGrades[_currentFabIndex].name == gunplas[0].grade.substring(0,2)) {
      _isChangeGrade = false;
      print('change grade to false!!');

      setState(() {
        // Reload image hero after change grade wheel list
        _imageWheelIndex = 0;
        var boxart = "assets/gunpla/${gunplas[_imageWheelIndex].box_art_path}";
        _imageToShow = new AssetImage("${boxart}");
        _imagePathToShow = boxart;
        var name = gunplas[_imageWheelIndex].name;
        _imageToShowTag = name;
        _imageToShowBoxArt = gunplas[_imageWheelIndex].box_art_path;

        // Load first item in wheel list's actions liked, owned, shared
        if (_imageToShowBoxArt != null &&
            _gunplaActionMap.containsKey(_imageToShowBoxArt)) {
          GunplaAction gunplaAction = _gunplaActionMap[_imageToShowBoxArt];
          _actionSelections[0] = gunplaAction.is_liked;
          _actionSelections[1] = gunplaAction.is_owned;
          _actionSelections[2] = gunplaAction.is_shared;
        }
      });


    } else {
      // Load hero image first time after load screen.
      if(gunplas.length > 0) {
          _imageWheelIndex = 0;
          var boxart = "assets/gunpla/${gunplas[_imageWheelIndex].box_art_path}";
          _imageToShow = new AssetImage("${boxart}");
          _imagePathToShow = boxart;
          var name = gunplas[_imageWheelIndex].name;
          _imageToShowTag = name;
          _imageToShowBoxArt = gunplas[_imageWheelIndex].box_art_path;
      }
    }
  }

  bool getActionValue(String box_art_path, int index) {
    bool result = false;
    String key = box_art_path.replaceAll('/', '_');
    if(_gunplaOwnedMap.containsKey(key)) {
      switch(index) {
        case 0:
          result = _gunplaOwnedMap[key].is_liked;
          break;
        case 1:
          result = _gunplaOwnedMap[key].is_owned;
          break;
        case 2:
          result = _gunplaOwnedMap[key].is_shared;
          break;
      }

    }
    return result;

  }

  /**
   * Update select Action back to selected gunpla Map
   */
  bool updateSelectedActionMap(int index) {
    bool is_done = false;
    print(
        'before updated - ANA is_shared=${_gunplaActionMap[_imageToShowBoxArt].is_shared}');
    if (_imageToShowBoxArt != null &&
        _gunplaActionMap.containsKey(_imageToShowBoxArt)) {
      GunplaAction gunplaAction = _gunplaActionMap[_imageToShowBoxArt];
      switch (index) {
        case 0:
          gunplaAction.is_liked = _actionSelections[index];
          _gunplaActionMap[_imageToShowBoxArt] = gunplaAction;
          break;
        case 1:
          gunplaAction.is_owned = _actionSelections[index];
          _gunplaActionMap[_imageToShowBoxArt] = gunplaAction;
          break;
        case 2:
          gunplaAction.is_shared = _actionSelections[index];
          _gunplaActionMap[_imageToShowBoxArt] = gunplaAction;
          break;
      }
      is_done = true;
    }
    print(
        'after updated - ANA is_shared=${_gunplaActionMap[_imageToShowBoxArt].is_shared}');
    return is_done;
  }

  Future<GunplaAction> updateGunplaActionDB(int index) async {
    GunplaAction gunplaAction = GunplaAction();
    try {
      if (_gunplaActionMap.containsKey(_imageToShowBoxArt)) {
        gunplaAction = _gunplaActionMap[_imageToShowBoxArt];
        var db = Firestore.instance;
        if (!gunplaAction.is_liked &&
            !gunplaAction.is_owned &&
            !gunplaAction.is_shared) {
          // delete
          print('deleting...');


          await db
              .collection("users/${user.uid}/owned")
              .document(
                  "${gunplaAction.gunpla.box_art_path.replaceAll('/', '_')}")
              .delete();
        } else {
          // update
          print('updating...');
          String uid = "${gunplaAction.gunpla.box_art_path.replaceAll('/', '_')}";
          await db
              .collection("users/${user.uid}/owned")
              .document(uid)
              .setData({
            'uid': uid,
            'name': gunplaAction.gunpla.name,
            'box_art_path': gunplaAction.gunpla.box_art_path,
            'price_yen': double.parse(gunplaAction.gunpla.price_yen),
            'price_thb': double.parse(gunplaAction.gunpla.price_thb),
            'released_when': dateFormat.parse(gunplaAction.gunpla.releasedWhen),
            'is_liked': gunplaAction.is_liked,
            'is_owned': gunplaAction.is_owned,
            'is_shared': gunplaAction.is_shared,
            'created_when': Timestamp.now(),
            'created_by': user.email,
            'updated_when': Timestamp.now(),
            'updated_by': user.email,
            'active': true,
          });
        }
        updateTotalOwnedDisplay(index, gunplaAction);
      }

      return gunplaAction;
    } on Exception catch (err) {
      print('Update Owned error: $err');
      return gunplaAction;
    } finally {
      print(
          'End of updateGunplaActionDB ${gunplaAction.gunpla.box_art_path.replaceAll('/', '_')}');
    }
  }

  void updateTotalOwnedDisplay(int index, GunplaAction gunplaAction) {
    switch(index) {
      case 0:
        // Update Liked display
        if(gunplaAction.is_liked) {
          addLiked();
        } else {
          deleteLiked();
        }
        break;
      case 1:
        // Update Owned display
        if(gunplaAction.is_owned) {
          addOwned();
        } else {
          deleteOwned();
        }
        break;
      case 2:
        // Update Shared display
        if(gunplaAction.is_shared) {
          addShared();
        } else {
          deleteShared();
        }
        break;
    }
  }

  Future<void> getOwnedDataDB() async {
    try {
      _gunplaOwnedMap.clear();
       Firestore.instance
          .collection("users/${user.uid}/owned")
          .snapshots()
          .listen((data) => data.documents.forEach((doc) {
                print('=>${doc["uid"]}');
                Owned own = Owned(
                  uid: doc['uid'],
                  name: doc['name'],
                  box_art_path: doc['box_art_path'],
                  is_liked: doc['is_liked'],
                  is_owned: doc['is_owned'],
                  is_shared: doc['is_shared']
                );
                _gunplaOwnedMap[own.uid] =  own;
              }));

    } on Exception catch (err) {
      print('getOwnedDataDB error: $err');
    } finally {
      print(
          'End of getOwnedDataDB ${_gunplaOwnedMap.length} records');
    }
  }

  void stateChanged(bool isShow) {
    print('menu is ${isShow ? 'showing' : 'closed'}');
  }

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
    setState(() {
      int menuIndex = 0;
      switch(item.menuTitle) {
        case 'HG':
          menuIndex = 0;
          break;
        case 'RE100':
          menuIndex = 1;
          break;
        case 'RG':
          menuIndex = 2;
          break;
        case 'MG':
          menuIndex = 3;
          break;
        case 'PG':
          menuIndex = 4;
          break;
      }
      setCurrentFabSelected(menuIndex);
    });
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  void showPopupGradeMenu() {
    _gradeMenu.show(widgetKey: _gradeMenuKey);
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
