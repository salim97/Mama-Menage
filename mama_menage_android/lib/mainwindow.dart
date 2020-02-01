import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/page_all_products.dart';
import 'pages/page_clients.dart';
import 'pages/page_login.dart';
import 'providers/my_app_state.dart';

class MainWindow extends StatefulWidget {
  MainWindow({Key key}) : super(key: key);

  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  MyAppState myAppState;
  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    if (myAppState.user == null)
      return Page_Login();
    // else if (myAppState.client == null)
      return Page_Clients();
    // else
    //   return Page_AllProdutcs();
  }
}
