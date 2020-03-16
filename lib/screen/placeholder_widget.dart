import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

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
    );
  }
}