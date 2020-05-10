import 'package:flutter/material.dart';
import 'package:hobbybase/model/User.dart';
import 'package:hobbybase/screen/owned_list_screen.dart';
import 'package:hobbybase/widget/fonts_effect.dart';
import 'dart:ui' as ui show Gradient, TextBox, lerpDouble, Image;

class OwnedDisplayWidget extends StatelessWidget {
  final Color color;
  final Function getLiked;
  final Function getOwned;
  final Function getShared;
  final fontUtils = FontsUtils();
  final User user;

  OwnedDisplayWidget(
      this.color,
      this.getLiked,
      this.getOwned,
      this.getShared,
      this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 6.0),
      decoration: new BoxDecoration(
//              color: Colors.cyan,
        gradient: new LinearGradient(
            colors: [Colors.brown[100], Colors.grey[400], Colors.grey[700], Colors.brown[900] ],
//            center: Alignment(-1.5, -0.2),
//            radius: 3.3,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.2, 0.4, 0.9]
        ),
        boxShadow: [new BoxShadow(
            color: Colors.black54,
            offset: new Offset(4.0, 4.0),
            blurRadius: 4.0
        )],
      ),
      child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Liked Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      fontUtils.drawScoreTitleButton('Liked'),
                      Text(getLikedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                            shadows: [
                              fontUtils.getShadowScore()
                            ],
                            fontSize: 48.0,
                            color: Colors.yellowAccent,
                            fontFamily: 'K2D-ExtraBoldItalic'),
                      ),
                    ],
                  ),
                  // Owned Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                      color: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.white,
                                width: 1
                            )
                        ),
                        onPressed: () => navigationPage(context, user),
                        child: Text('Owned',
                          style: TextStyle(
                            fontFamily: 'K2D-Medium',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(getOwnedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                          shadows: [
                            fontUtils.getShadowScore()
                          ],
                            fontSize: 48.0,
                            color: Colors.yellowAccent,
                            fontFamily: 'K2D-ExtraBoldItalic',
                        ),

                      ),
                    ],
                  ),
                  // Shared Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      fontUtils.drawScoreTitleButton('Shared'),
                      Text(getSharedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                            shadows: [
                              fontUtils.getShadowScore()
                            ],
                            fontSize: 48.0,
                            color: Colors.yellowAccent,
                            fontFamily: 'K2D-ExtraBoldItalic'),
                      ),
                    ],
                  ),
              ],
            ),
    );


  }

  navigationPage(BuildContext context, User user) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OwnedListScreen(user) ));
  }

  String getLikedValue() {
    return getLiked();
  }

  String getOwnedValue() {
    return getOwned();
  }

  String getSharedValue() {
    return getShared();
  }
}

