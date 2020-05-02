import 'dart:io';
import 'dart:ui' as ui show Gradient, TextBox, lerpDouble, Image;
import 'package:flutter/material.dart';

class DialogUtils {

  Future<bool> showConfirmationDialog(BuildContext context,
      String title,
      String content,
      String yesText,
      String noText,
      String yesFunc,
      String noFunc
      ) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.limeAccent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                backgroundColor: Colors.grey[800],
                title: Text(title,
                  style: TextStyle(
                    fontFamily: 'K2D-ExtraBold',
                    color: Colors.white,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(content,
                      style: TextStyle(
                        fontFamily: 'K2D-Regular',
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FlatButton(
                          color: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.white,
                                  width: 1
                              )
                          ),
                          onPressed: () => doFunction(context, noFunc),
                          child: Text(noText,
                            style: TextStyle(
                              fontFamily: 'K2D-Medium',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        FlatButton(
                          color: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.white,
                                  width: 1
                              )
                          ),
                          onPressed: () => doFunction(context, yesFunc),
                          child: Text(yesText,
                            style: TextStyle(
                              fontFamily: 'K2D-Medium',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {})
//     ??
//    false
    ;
  }

  doFunction(BuildContext context, String command) {
    switch(command) {
      case 'close_app':
        exitApp();
        break;
      case 'close_dialog':
        Navigator.of(context).pop(false);
        break;
    }
  }

  exitApp() =>
      exit(0);
}