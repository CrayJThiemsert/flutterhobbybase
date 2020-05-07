import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

class HeroGunplaDetailScreen extends StatelessWidget {
  final String imageToShowHero;
  final String imageToShowPath;
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

  HeroGunplaDetailScreen({this.imageToShowHero, this.imageToShowPath});

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
              child: Container(
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                  colors: [Colors.teal[100], Colors.blueGrey[200], Colors.blueGrey[600], Colors.teal[900]],
                      //                          center: Alignment(1.5, 0.2),
                      //                          radius: 3.3,
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
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
                  ],
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
            height: 100,
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
                              '07.May.2020',
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
    return Text(
      descTestString,
      overflow: TextOverflow.ellipsis,
      maxLines: 8,
      textAlign: TextAlign.start,
      style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey[700],
          fontFamily: 'K2D-Bold'),
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
            height: 120,
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
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: drawTestDesc(context),

            ),
          ),
        ),
      ],
    );
  }
}

