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
    Image.asset("assets/gunpla_grade/baseline_pets_white_24dp.png"),
    Image.asset("assets/gunpla_grade/ic_highgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_re100_96.png"),
    Image.asset("assets/gunpla_grade/ic_realgrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_mastergrade_96.png"),
    Image.asset("assets/gunpla_grade/ic_perfectgrade_96.png"),
  ];

  final List<Grade> _fabGrades = [
//    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
//    Grade(name: "SD", jsonpath: "assets/json/sd.json"),
    Grade(name: "ALL", jsonpath: "assets/json/hg.json", totalOwned: 0),
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
          debugPrint("Back to Home screen");
          Navigator.pop(context, 'back');
          break;
//        case 2:
//          break;
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

    _initPopupGradeFilterMenu();

    super.initState();
  }

  _getTotalOwnedByGrade() {
    for(int i=0;i < _fabGrades.length; i++) {
      String gradeLowerCase = _fabGrades[i].name.substring(0, 2).toLowerCase();
      int totalOwnedGrade = 0;
      for(int j=0;j < _gunplaOwnedList.length;j++) {
        String ownedGradeLowerCase = _gunplaOwnedList[j].box_art_path.substring(0, 2).toLowerCase();
        if(i == 0) {
          totalOwnedGrade++;
        } else {
          if (gradeLowerCase == ownedGradeLowerCase) {
            totalOwnedGrade++;
          }
        }
      }
      _fabGrades[i].totalOwned = totalOwnedGrade;
    }
  }

  _initPopupGradeFilterMenu() {
    _getTotalOwnedByGrade();
    _gradeMenu = PopupMenu(items: [
      MenuItem(
        title: 'ALL',
        userInfo: _fabGrades[0].totalOwned,
        image: Image.asset("assets/gunpla_grade/baseline_pets_white_24dp.png"),

      ),
      MenuItem(
        title: 'HG',
        userInfo: _fabGrades[1].totalOwned,
        image: Image.asset("assets/gunpla_grade/ic_highgrade_96.png"),

      ),
      MenuItem(
        title: 'RE100',
        userInfo: _fabGrades[2].totalOwned,
        image: Image.asset("assets/gunpla_grade/ic_re100_96.png"),
      ),
      MenuItem(
        title: 'RG',
        userInfo: _fabGrades[3].totalOwned,
        image: Image.asset("assets/gunpla_grade/ic_realgrade_96.png"),
      ),
      MenuItem(
        title: 'MG',
        userInfo: _fabGrades[4].totalOwned,
        image: Image.asset("assets/gunpla_grade/ic_mastergrade_96.png"),
      ),
      MenuItem(
        title: 'PG',
        userInfo: _fabGrades[5].totalOwned,
        image: Image.asset("assets/gunpla_grade/ic_perfectgrade_96.png"),
      ),

    ],
        onClickMenu: onClickMenu,
        onDismiss: onDismiss,
        maxColumn: 3
    );
  }

  void onClickMenu(MenuItemProvider item) {
    print('Click menu -> ${item.menuTitle}');
    setState(() {
      int menuIndex = 0;
      switch(item.menuTitle) {
        case 'ALL':
          menuIndex = 0;
          break;
        case 'HG':
          menuIndex = 1;
          break;
        case 'RE100':
          menuIndex = 2;
          break;
        case 'RG':
          menuIndex = 3;
          break;
        case 'MG':
          menuIndex = 4;
          break;
        case 'PG':
          menuIndex = 5;
          break;
      }
      setCurrentFabSelected(menuIndex);
    });
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
              return _mainBody();
//            } else {
//              // Tablet/Horizontal
//              return _homeTabletView();
//            }
          },
        ),
        bottomNavigationBar:
          _useCustomBottomNavigationBar(),

      ),
    );
  }

  _tapBack() {
    print('tap on back');
    Navigator.pop(context, 'back');
  }

  Widget _useCustomBottomNavigationBar() {
    return Container(
      height: 60,
//      color: Colors.black87,
      child: InkWell(
        onTap: () => {
          _tapBack()
        },
        child: Padding(
          padding: EdgeInsets.only( top: 8.0),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.arrow_back,
                color: Theme.of(context).accentColor,
              ),
              Text('Back',
                style: TextStyle(
                  fontFamily: 'K2D-Regular',
                ),
              )
            ],
          ),
        ),
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

  Widget _gradeFilter() {
    return Container(

      margin: EdgeInsets.only(top: 8.0, left: 8.0),
      child: Card(
        color: Colors.black87,
        elevation: 15.0,
        child: GestureDetector(
          child: SizedBox(
            child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.fitHeight,
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
    );
  }

  void showPopupGradeMenu() {
    _initPopupGradeFilterMenu();
    _gradeMenu.show(widgetKey: _gradeMenuKey);
  }

  Widget _mainBody() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            child: _gradeFilter(),
          ),
          Container(
            child: Expanded(
                child: _gridListOwned(),
            )
          )
        ],
      )
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

