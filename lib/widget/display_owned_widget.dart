import 'package:flutter/material.dart';
import 'package:hobbybase/widget/fonts_effect.dart';
import 'dart:ui' as ui show Gradient, TextBox, lerpDouble, Image;

class OwnedDisplayWidget extends StatelessWidget {
  final Color color;
  final Function getLiked;
  final Function getOwned;
  final Function getShared;
  final fontUtils = FontsUtils();

  OwnedDisplayWidget(
      this.color,
      this.getLiked,
      this.getOwned,
      this.getShared);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 6.0),
      decoration: new BoxDecoration(
//              color: Colors.cyan,
        gradient: new LinearGradient(
            colors: [Colors.white, color ],
//            center: Alignment(-1.5, -0.2),
//            radius: 3.3,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.9]
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
                      fontUtils.drawScoreTitle('Liked'),
                      Text(getLikedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                            shadows: [
                              fontUtils.getShadowScore()
                            ],
                            fontSize: 48.0,
                            color: Colors.white,
                            fontFamily: 'K2D-ExtraBoldItalic'),
                      ),
                    ],
                  ),
                  // Owned Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      fontUtils.drawScoreTitle('Owned'),
                      Text(getOwnedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                          shadows: [
                            fontUtils.getShadowScore()
                          ],
                            fontSize: 48.0,
                            color: Colors.white,
                            fontFamily: 'K2D-ExtraBoldItalic',
                        ),

                      ),
                    ],
                  ),
                  // Shared Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      fontUtils.drawScoreTitle('Shared'),
                      Text(getSharedValue(),
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(
                            shadows: [
                              fontUtils.getShadowScore()
                            ],
                            fontSize: 48.0,
                            color: Colors.white,
                            fontFamily: 'K2D-ExtraBoldItalic'),
                      ),
                    ],
                  ),
              ],
            ),
    );
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

