import 'dart:ui' as ui show Gradient, TextBox, lerpDouble, Image;
import 'package:flutter/material.dart';

class FontsUtils {

  Shadow getShadowScore() {
    return Shadow(
      blurRadius: 5.0,
      color: Colors.indigo,
      offset: Offset(5.0, 5.0),
    );
  }

  Widget drawScoreTitle(String title) {
    return Container(
      width: 100,
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          colors: [Colors.lightBlue[400], Colors.indigo[900]],
          begin: Alignment(-1.0, -4.0),
          end: Alignment(1.0, 4.0),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          width: 2.0,
          color: Colors.redAccent,
        ),
      ),
      child: Text(title,
        textAlign: TextAlign.center,
        style: TextStyle(
            foreground: Paint()
              ..shader =
                  ui.Gradient.linear(
                  const Offset(0, 20),
                  const Offset(300, 20),
                  <Color>[
                    Colors.red,
                    Colors.yellow
                  ]
              )
//                              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.red,
            fontSize: 24.0,
//                              color: Colors.white,
            fontFamily: 'K2D-BoldItalic'
        ),
      ),
    );
  }
}