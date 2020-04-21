import 'package:flutter/material.dart';

class OwnedDisplayWidget extends StatelessWidget {
  final Color color;
  final Function getLiked;
  final Function getOwned;
  final Function getShared;

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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Liked',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(getLikedValue(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  // Owned Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Owned',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(getOwnedValue(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  // Shared Counter
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Shared',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(getSharedValue(),
                        style: TextStyle(color: Colors.white),
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

