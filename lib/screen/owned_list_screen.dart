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

  int _currentGradeIndex = 0;
  int _currentSortingIndex = 0;
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

  final List<Image> _gradeFilterImages = [
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
  PopupMenu _sortingMenu;
  GlobalKey _sortingMenuKey = GlobalKey();

  User user = User();

  List<bool> _actionSelections = List.generate(3, (_) => false);
  HashMap _gunplaActionMap = HashMap<String, GunplaAction>();
  HashMap _gunplaOwnedMap = HashMap<String, Owned>();
  List<Owned> _gunplaOwnedList = List<Owned>();
  bool _isChangeGrade = false;
  bool _isChangeSorting = false;

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
    _initPopupSortingMenu();
    super.initState();
  }

  Future<void> executeAfterBuild() async {
    setCurrentSortingSelected(_currentSortingIndex);
//    WidgetsBinding.instance.addPostFrameCallback((_) =>
//        setCurrentSortingSelected(_currentSortingIndex)
//    );

    print('call executeAfterBuild()');
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
        onClickMenu: onClickGradeFilterMenu,
        onDismiss: onDismiss,
        maxColumn: 3
    );
  }

  _initPopupSortingMenu() {
    _sortingMenu = PopupMenu(items: [
      MenuItem(
        title: 'Name',
      ),
      MenuItem(
        title: 'Grade',
      ),
      MenuItem(
        title: 'Price',
      ),
      MenuItem(
        title: 'Released',
      ),
      MenuItem(
        title: 'Owned',
      ),
    ],
        onClickMenu: onClickSortingMenu,
        onDismiss: onDismiss,
        maxColumn: 3
    );
  }

  void onClickGradeFilterMenu(MenuItemProvider item) {
    print('Click Grade Filter menu -> ${item.menuTitle}');
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
      setCurrentGradeSelected(menuIndex);
    });
  }

  void onClickSortingMenu(MenuItemProvider item) {
    print('Click Sorting menu -> ${item.menuTitle}');
    setState(() {
      int menuIndex = 0;
      switch(item.menuTitle) {
        case 'Name':
          menuIndex = 0;
          break;
        case 'Grade':
          menuIndex = 1;
          break;
        case 'Price':
          menuIndex = 2;
          break;
        case 'Released':
          menuIndex = 3;
          break;
        case 'Owned':
          menuIndex = 4;
          break;
      }
      setCurrentSortingSelected(menuIndex);
    });
  }

  void setCurrentGradeSelected(int selectedIndex) {
    print('_currentFabIndex[${_currentGradeIndex}] | selectedFabIndex[${selectedIndex}]');
    if (_currentGradeIndex != selectedIndex) {
      _currentGradeIndex = selectedIndex;
      _isChangeGrade = true;

      setState(() {
        reloadOwnedDataList();
      });

    } else {
      _isChangeGrade = false;
    }

    print(
        "Pressed _isChangeGrade[${_isChangeGrade}] - ${_currentGradeIndex} - ${_fabGrades[_currentGradeIndex].name} - ${_fabGrades[_currentGradeIndex].jsonpath}");
  }

  void setCurrentSortingSelected(int selectedIndex) {
    print('call setCurrentSortingSelected(${selectedIndex}) _currentSortingIndex[${_currentSortingIndex}] | selectedFabIndex[${selectedIndex}]');
    if (_currentSortingIndex != selectedIndex) {
      _currentSortingIndex = selectedIndex;
      _isChangeSorting = true;

    } else {
      _isChangeSorting = false;
    }

    print(
        "Pressed _isChangeSorting[${_isChangeSorting}] - ${_currentSortingIndex} - ${_sortingMenu.items[_currentSortingIndex].menuTitle} - ${_sortingMenu.items[_currentSortingIndex].menuUserInfo}");

    setState(() {

        print('sorting[${_sortingMenu.items[_currentSortingIndex].menuTitle}]'); //name[${a.name}] grade[${a.box_art_path.substring(0, 2).toLowerCase()}] box_art_path[${a.box_art_path}]' );
        switch (_sortingMenu.items[_currentSortingIndex].menuTitle) {
          case 'Name':
            _gunplaOwnedList.sort((Owned a, Owned b) => a.name.compareTo(b.name));
            break;
          case 'Grade':
            _gunplaOwnedList.sort((Owned a, Owned b) => a.box_art_path.substring(0, 2).toLowerCase().compareTo(
                b.box_art_path.substring(0, 2).toLowerCase()));
            break;
          case 'Price':
            _gunplaOwnedList.sort((Owned a, Owned b) => a.price_yen.compareTo(b.price_yen));
            break;
          case 'Released':
            _gunplaOwnedList.sort((Owned a, Owned b) => a.released_when.compareTo(b.released_when));
            break;
          case 'Owned':
            _gunplaOwnedList.sort((Owned a, Owned b) => a.created_when.compareTo(b.created_when));
            break;
        }
      });
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
      _gunplaOwnedList.clear();
      Firestore.instance
          .collection("users/${user.uid}/owned")
          .snapshots()
          .listen((data) => data.documents.forEach((doc) {
        print('=>${doc["uid"]}');
        Owned own = Owned(
            uid: doc['uid'],
            name: doc['name'],
            box_art_path: doc['box_art_path'],
            price_yen: (doc['price_yen'] == null) ? 0 : doc['price_yen'],
            price_thb: (doc['price_thb'] == null) ? 0 : doc['price_thb'],
            created_when: doc['created_when'],
            released_when: doc['released_when'],
            is_liked: doc['is_liked'],
            is_owned: doc['is_owned'],
            is_shared: doc['is_shared']
        );

        String ownedGradeLowerCase = own.box_art_path.substring(0, 2).toLowerCase();
        String currentGrade = _fabGrades[_currentGradeIndex].name;

        if(currentGrade.toLowerCase() == ownedGradeLowerCase || currentGrade.toLowerCase() == 'all') {
          _gunplaOwnedMap[own.uid] = own;
          _gunplaOwnedList.add(own);
        }
      }));

    } on Exception catch (err) {
      print('getOwnedDataDB error: $err');
    } finally {
      print(
          'End of getOwnedDataDB ${_gunplaOwnedMap.length} records');
    }
  }

  void reloadOwnedDataList() async {
    try {
      _gunplaOwnedList.clear();
      _gunplaOwnedMap.forEach((k, v) {
        Owned own = v;
        print('=>${own.uid}');
        String ownedGradeLowerCase = own.box_art_path.substring(0, 2).toLowerCase();
        String currentGrade = _fabGrades[_currentGradeIndex].name;

        if(currentGrade.toLowerCase() == ownedGradeLowerCase || currentGrade.toLowerCase() == 'all') {
          _gunplaOwnedList.add(own);
        }
      });
    } on Exception catch (err) {
      print('reloadOwnedDataList error: $err');
    } finally {
      print(
          'End of reloadOwnedDataList ${_gunplaOwnedList.length} records');
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

    executeAfterBuild();

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


  Widget _drawGridListOwned() {
    print('call _gridListOwned() - _gunplaOwnedList.length[${_gunplaOwnedList.length}]');

    return GridView.count(
      crossAxisCount: 2,
      children:
      List.generate(_gunplaOwnedList.length, (index) {
        Owned owned = _gunplaOwnedList[index];
        String ownedGradeLowerCase = owned.box_art_path.substring(0, 2).toLowerCase();
        String currentGrade = _fabGrades[_currentGradeIndex].name;
        if(currentGrade.toLowerCase() == ownedGradeLowerCase || currentGrade.toLowerCase() == 'all' ) {
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
                        Tooltip(
                          message: owned.name,
                          child: Text(
                          '${shrinkText(owned.name, 48)}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'K2D-Light'
                          ),
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
        }

      }),
    );
  }
  String shrinkText(String text, int len) {
    return (text.length > len) ? '${text.substring(0, len)}...' : text;
  }

  Widget _gradeFilter() {
    return Container(
      margin: EdgeInsets.only(top: 8.0, left: 8.0),
      child: Card(
        color: Colors.black26,
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
                child: _gradeFilterImages[_currentGradeIndex],
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

  Widget _sortingFilter() {
    return Container(
      margin: EdgeInsets.only(top: 8.0, left: 8.0),
      child: Card(
        color: Colors.black26,
        elevation: 15.0,
        child: GestureDetector(
          child: SizedBox(
            child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.scaleDown,
              child:
              Tooltip(
                message: 'Sorting',
                verticalOffset: 28,
                child: Text(
                  _sortingMenu.items[_currentSortingIndex].menuTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
//                    fontFamily: "K2D-Light"
                  ),
                ),
              ),
            ),
            width: 60,
            height: 36,
          ),
          key: _sortingMenuKey,
          onTap: () {
            showPopupSortingMenu();

          },
        ),
      ),
    );
  }

  void showPopupGradeMenu() {
    _initPopupGradeFilterMenu();
    _gradeMenu.show(widgetKey: _gradeMenuKey);
  }

  void showPopupSortingMenu() {
    _initPopupSortingMenu();
    _sortingMenu.show(widgetKey: _sortingMenuKey);
  }

  Widget _mainBody() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                _gradeFilter(),
                _sortingFilter(),
              ],
            ), 
            
          ),
          Container(
            child: Expanded(
                child: _drawGridListOwned(),
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

