import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hobbybase/model/GunplaComment.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/utils/comments.dart';
import 'package:hobbybase/utils/const.dart';
import 'package:hobbybase/widget/smooth_star_rating.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

class HeroGunplaDetailScreen extends StatefulWidget {
  final String uidHero;
  final String imageToShowHero;
  final String imageToShowPath;
  final User user;


  HeroGunplaDetailScreen({this.uidHero, this.imageToShowHero, this.imageToShowPath, this.user});

  @override
  _HeroGunplaDetailScreenState createState() => _HeroGunplaDetailScreenState(this.uidHero, this.imageToShowHero, this.imageToShowPath, this.user);

}

class _HeroGunplaDetailScreenState extends State<HeroGunplaDetailScreen> {
  final String uidHero;
  final String imageToShowHero;
  final String imageToShowPath;
  User user = User();
  _HeroGunplaDetailScreenState(this.uidHero, this.imageToShowHero, this.imageToShowPath, this.user);

  bool _isEnabled = true;
  Color _borderHeroColor = Colors.limeAccent;
  // Japanese Yen
  Currency jpy = Currency.create('JPY', 0, symbol: '¥', pattern: 'S0');

  // Thai Baht
  Currency thb = Currency.create('THB', 0, symbol: 'THB', pattern: 'S0');

  final String descTestString = "From \“Mobile Suit Gundam: Hathaway\’s Flash,\” comes a new HGUC kit, the Messer! (Name currently tentative.)\nThis new HG boasts a moveable gimmick inside the fuselage, as well as a slide gimmick in the side armor to allow for better movement of the legs. Other moveable parts and articulation are used throughout the kit to maximize the Messer\’s ability to pull off great action poses!";

  final MainAxisAlignment statusMainAxisAlign = MainAxisAlignment.spaceAround;
  final CrossAxisAlignment statusCrossAxisAlign =  CrossAxisAlignment.start;
  final double statusValueSize = 20.0;

  List<GunplaComment> _gunplaCommentMap = List<GunplaComment>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('loading... comments');
    getGunplaCommentsDB().then((value) => print('then comment ${_gunplaCommentMap.length} comments'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      body:  SafeArea(
        top: _isEnabled,
        bottom: _isEnabled,
        left: _isEnabled,
        right: _isEnabled,
        child:
        GestureDetector(
          child: Center(
            child: Hero(
              tag: imageToShowHero,
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.blueGrey[600], Colors.blueGrey[200], Colors.blueGrey[600], Colors.grey[900]],
                        //                          center: Alignment(1.5, 0.2),
                        //                          radius: 3.3,
//                          begin: Alignment.topRight,
//                          end: Alignment.bottomLeft,
                        stops: [0.1, 0.3, 0.6, 0.9]
                    ),
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
                    ),
                    //                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: Column(
                    children: [
                      // Hero Image
                      Image.asset(
                        imageToShowPath,
                        height: 200,
                      ),
                      // Hero Title
                      drawHeroTitle(context),
                      Divider(
                        thickness: 2,
                        indent: 4,
                        endIndent: 4,
                        height: 2.0,
                        color: Colors.orange[700],
                      ),
                      drawHeroStatus(context),
                      Divider(
                        thickness: 2,
                        indent: 4,
                        endIndent: 4,
                        height: 2.0,
                        color: Colors.orange[700],
                      ),
                      drawHeroDescription(context),
                      Divider(
                        thickness: 2,
                        indent: 4,
                        endIndent: 4,
                        height: 2.0,
                        color: Colors.orange[700],
                      ),
                      drawHeroReviews(context),
                    ],
                  ),
                ),
              ),
              transitionOnUserGestures: true,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget drawHeroTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.98,
            height: 50,
            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.blueGrey[200], Colors.blueGrey[400], Colors.blueGrey[600], Colors.blueGrey[900]],
                  stops: [0.0, 0.2, 0.4, 0.8]
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
              //                      borderRadius: BorderRadius.circular(8.0)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Center(
                child: Text(
                  imageToShowHero.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontFamily: 'K2D-BoldItalic'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget drawHeroStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.98,
            height: 90,
            padding: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.brown[50], Colors.brown[50], Colors.brown[50], Colors.brown[100]],
                  stops: [0.0, 0.2, 0.4, 0.8]
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
              //                      borderRadius: BorderRadius.circular(8.0)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: statusMainAxisAlign,
                    crossAxisAlignment: statusCrossAxisAlign,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            //                          color: Colors.blue,
                            //                          height: 40,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 0.0),
                            child: Text(
                              'Scale:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-Bold'),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            //                          color: Colors.yellow,
                            //                        height: 40,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 4.0),
                            child:  Text(
                              '1/144',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: statusValueSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-ExtraBold'),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 0.0),
                            child: Text(
                              'Price:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-Bold'),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 4.0),
                            child: Text(
                              '${Money.fromInt(1099, jpy)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: statusValueSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-ExtraBold'),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: statusMainAxisAlign,
                    crossAxisAlignment: statusCrossAxisAlign,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            //                          color: Colors.blue,
                            //                          height: 40,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 0.0),
                            child: Text(
                              'Released Date:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-Bold'),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            //                          color: Colors.yellow,
                            //                        height: 40,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 4.0),
                            child:  Text(
                              'May 7, 2020',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: statusValueSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-ExtraBold'),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 0.0),
                            child: Text(
                              'Price:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-Bold'),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 4.0),
                            child: Text(
                              '${Money.fromInt(1099, thb)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: statusValueSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontFamily: 'K2D-ExtraBold'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget drawTestDesc(BuildContext context) {
    String descSectionText = "${descTestString}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.title,
            children: [
              TextSpan(
                text: 'Item ',
                style: TextStyle(
//                    fontSize: 12.0,
                    color: Colors.grey[700],
                    fontFamily: 'K2D-Light'
                ),
              ),
              TextSpan(
                text: 'description:',
                style: TextStyle(
//                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontFamily: 'K2D-Bold'
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Text(
          descTestString,
          overflow: TextOverflow.ellipsis,
          maxLines: 8,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[700],
              fontFamily: 'K2D-Bold'
          ),
        ),

      ],
    );
  }

  Widget drawTestReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.title,
            children: [
              TextSpan(
                text: 'Item ',
                style: TextStyle(
//                    fontSize: 12.0,
                    color: Colors.grey[700],
                    fontFamily: 'K2D-Light'
                ),
              ),
              TextSpan(
                text: 'reviews:',
                style: TextStyle(
//                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontFamily: 'K2D-Bold'
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _gunplaCommentMap == null?0:_gunplaCommentMap.length,
          itemBuilder: (BuildContext context, int index) {
            GunplaComment comment = _gunplaCommentMap[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 25.0,
                backgroundImage: AssetImage(
                  "assets/dq/dq01.png",
                ),
              ),

              title: Text("${comment.updated_by}"),
              subtitle: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SmoothStarRating(
                        starCount: 5,
                        color: Constants.ratingBG,
                        allowHalfRating: true,
                        rating: 5.0,
                        size: 12.0,
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        DateFormat.yMMMd().format(comment.updated_when.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 7.0),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${comment.comment}",
                      style: TextStyle(

                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

      ],
    );
  }

  Widget drawHeroDescription(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(

          child: Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.98,
//            height: 120,
//            padding: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.brown[50], Colors.brown[50], Colors.brown[50], Colors.brown[100]],
                  stops: [0.0, 0.2, 0.4, 0.8]
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
              //                      borderRadius: BorderRadius.circular(8.0)
            ),
            child: SingleChildScrollView(
              child:
              drawTestDesc(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget drawHeroReviews(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.98,
//            height: 300,
            padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.brown[50], Colors.brown[50], Colors.brown[50], Colors.brown[100]],
                  stops: [0.0, 0.2, 0.4, 0.8]
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
              //                      borderRadius: BorderRadius.circular(8.0)
            ),
            child: SingleChildScrollView(
              child:
              drawTestReviews(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getGunplaCommentsDB() async {
    print('imageToShowHero[${imageToShowPath}]');
    print('uidHero[${uidHero}]');
    try {
      _gunplaCommentMap.clear();
      await Firestore.instance
          .collection("gunpla/${uidHero}/comments")
          .getDocuments().then((snapshot) {
             snapshot.documents.forEach((doc) {
               print(doc.data);
               GunplaComment own = GunplaComment(
                 uid: doc['uid'],
                 comment: doc['comment'],
                 updated_when: doc['updated_when'],
                 updated_by: doc['updated_by'],
               );
               _gunplaCommentMap.add(own);
             });
             print('onDone - Get comment ${_gunplaCommentMap.length} comments');
             setState(() {
               _gunplaCommentMap;
             });
      });

    } on Exception catch (err) {
      print('getGunplaCommentsDB error: $err');
    } finally {
      print(
          'End of getGunplaCommentsDB ${_gunplaCommentMap.length} records');
    }
  }

  Future<void> get_notused_GunplaCommentsDBListen() async {
    print('imageToShowHero[${imageToShowPath}]');
    print('uidHero[${uidHero}]');
    try {
      _gunplaCommentMap.clear();
      await Firestore.instance
          .collection("gunpla/${uidHero}/comments")
          .snapshots()
          .listen((data) => data.documents.forEach((doc) {
        print('=>${doc["uid"]}');
        GunplaComment own = GunplaComment(
          uid: doc['uid'],
          comment: doc['comment'],
          updated_when: doc['updated_when'],
          updated_by: doc['updated_by'],
        );
        _gunplaCommentMap.add(own);
      }
      ), onDone: () {
        print('Get comment ${_gunplaCommentMap.length} comments');
      }
      ).onDone(() {
        print('onDone - Get comment ${_gunplaCommentMap.length} comments');
      });

    } on Exception catch (err) {
      print('getGunplaCommentsDB error: $err');
    } finally {
      print(
          'End of getGunplaCommentsDB ${_gunplaCommentMap.length} records');
    }
  }

}

