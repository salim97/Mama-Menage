import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void containerForSheet<String>({BuildContext context, Widget child, Function(String) callback}) {
  showCupertinoModalPopup<String>(
    context: context,
    builder: (BuildContext context) => child,
  ).then<void>((String value) {
    callback(value);
    // Scaffold.of(context).showSnackBar(new SnackBar(
    //   content: new Text('You clicked $value'),
    //   duration: Duration(milliseconds: 800),
    // ));
  });
}

class MyDialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key, String title, String body, VoidCallback onCancel) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, backgroundColor: Colors.white, children: <Widget>[
                Center(
                  child: Column(children: [
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        body,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      onPressed: () {
                        onCancel();
                      },
                      child: Text("Annuler",
                          style: TextStyle(
                            color: Colors.green,
                          )),
                    )
                  ]),
                )
              ]));
        });
  }

  static void askuser(BuildContext context, String title, String body, VoidCallback onYes) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("oui"),
              onPressed: () {
                Navigator.of(context).pop();
                onYes();
              },
            ),
            new FlatButton(
              child: new Text("attendre"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void askuserYESNO(BuildContext context, String title, String body, {VoidCallback onYes, VoidCallback onNo}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("oui"),
              onPressed: () {
                Navigator.of(context).pop();
                onYes();
              },
            ),
            new FlatButton(
              child: new Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
                onNo();
              },
            ),
          ],
        );
      },
    );
  }

  static Future showMSGtoUSER(BuildContext context, String msg) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(msg),
           
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}