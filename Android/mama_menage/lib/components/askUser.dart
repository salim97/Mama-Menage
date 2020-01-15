import 'package:flutter/cupertino.dart';

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