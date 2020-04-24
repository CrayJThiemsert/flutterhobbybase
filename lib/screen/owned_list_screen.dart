import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hobbybase/model/Grade.dart';
import 'package:hobbybase/model/Gunpla.dart';
import 'package:hobbybase/model/GunplaAction.dart';
import 'package:hobbybase/model/Owned.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/popup/popup_menu.dart';
import 'package:hobbybase/screen/placeholder_widget.dart';


class OwnedListScreen extends StatefulWidget {
  User user = User();
  OwnedListScreen(this.user);

  @override
//  _SafeAreaState createState() => _SafeAreaState();
  _OwnedListScreenState createState() => _OwnedListScreenState(this.user);
}
// TODO: implement createState
//    return null;
//  }

class _OwnedListScreenState extends State<OwnedListScreen> {

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

  int _currentIndex = 0;
  final List<Widget> _children = [
    PlaceholderWidget(Colors.amberAccent),
//    OwnedDisplayWidget(Colors.black87),
    PlaceholderWidget(Colors.lime),
    PlaceholderWidget(Colors.brown),
//    PlaceholderWidget(Colors.greenAccent)
  ];

  Color _borderHeroColor = Colors.lime[800];

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
    Grade(name: "HG", jsonpath: "assets/json/hg.json"),
    Grade(name: "RE100", jsonpath: "assets/json/re100.json"),
    Grade(name: "RG", jsonpath: "assets/json/rg.json"),
    Grade(name: "MG", jsonpath: "assets/json/mg.json"),
    Grade(name: "PG", jsonpath: "assets/json/pg.json"),
  ];

  PopupMenu _gradeMenu;
  GlobalKey _gradeMenuKey = GlobalKey();

  User user = User();

  List<bool> _actionSelections = List.generate(3, (_) => false);
  HashMap _gunplaActionMap = HashMap<String, GunplaAction>();
  HashMap _gunplaOwnedMap = HashMap<String, Owned>();
  List<Owned> _gunplaOwnedList = List<Owned>();
  bool _isChangeGrade = false;

  _OwnedListScreenState(this.user);

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
      switch(_currentIndex) {
        case 0:

          break;
        case 2:
          debugPrint("Do logoff");
          signOut();
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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          "/SignInScreen", ModalRoute.withName("/HomeScreen"));
    });
  }


  @override
  void initState() {
    getUserData();
    getOwnedDataDB().then((_) {
      print(
          'fnEnd of getOwnedDataDB ${_gunplaOwnedMap.length} records');
    });


    super.initState();
  }



  Future<void> getUsersData() async {
    Firestore.instance
        .collection('users')
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => print(doc["uid"])));
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
        _gunplaOwnedList.add(own);
      }));

    } on Exception catch (err) {
      print('getOwnedDataDB error: $err');
    } finally {
      print(
          'End of getOwnedDataDB ${_gunplaOwnedMap.length} records');
    }
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
//      onWillPop: _onWillPop,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
//            if (constraints.maxWidth < 600) {
              // Mobile/Vertical
              return _gridListOwned();
//                _homePhoneView();
//            } else {
//              // Tablet/Horizontal
//              return _homeTabletView();
//            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Owned'),
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
                child: _gridListOwned(),
              ),
            ),
            // Body area for contents
          ],
      ),
    );
  }

  Future<void> getUserData() {
    User.getUserDB(user.email).then((userdb) {
      user = userdb;
      print('--- Current user is ${user.toString()} ---');
      setState(() {
        _imageToShowTag = user.name;
      });
    });
  }

  void onDismiss() {
    print('Menu is dismiss');
  }

  Widget _gridListOwned() {
    return GridView.count(
      crossAxisCount: 2,

      children:
      List.generate(_gunplaOwnedMap.length, (index) {
        Owned owned = _gunplaOwnedList[index];
        var boxart = "assets/gunpla/${owned.box_art_path}";
        return
          Center(
          child:
            GestureDetector(
              onTap: () {_openImage(context, index); },
            child:
          Container(

            margin: EdgeInsets.all(4),
            height: 200,
            child: Card(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ClipRRect(

                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Image.asset(
                      boxart,
                      height: 120,
//                      width: 130,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
//                  ListTile(
//                    title:
                    Text(
                      '${owned.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'K2D-BoldItalic'
                      ),
                    ),
//                  ),

                ],
              ),
            ),
          ),
            ),
//          Text(
//            'Item ${owned.box_art_path}',
//              style: Theme.of(context).textTheme.headline,
//          ),
        );
      }),

    );
  }

   void _openImage(context, index)  {
    Owned owned = _gunplaOwnedList[index];
    var boxart = "assets/gunpla/${owned.box_art_path}";
    showDialog(
      context: context,
      builder: (a) => AlertDialog(
        title: Text('Look at this! Very Nice!'),
        content: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Image.asset(
            boxart,

//                                        scale: 0.2,
            height: 150,
//                      width: 130,
            fit: BoxFit.fitHeight,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _dismissDialog(context);
            },
          ),
        ],

      )
    );
  }

  void _dismissDialog(context) {
    Navigator.pop(context);
  }

}

