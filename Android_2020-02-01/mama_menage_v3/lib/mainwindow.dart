import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage_v3/pages/page_products_quantity.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';

import 'package:provider/provider.dart';

import 'pages/page_all_products.dart';
import 'pages/page_clients.dart';
import 'pages/page_login.dart';

class MainWindow extends StatefulWidget {
  MainWindow({Key key}) : super(key: key);

  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with SingleTickerProviderStateMixin {
  MyAppState myAppState;
  Size windowsSize;
  List<String> choices = <String>[
    "Accueil",
    "Clients",
    "Produits",
    // "Options",
  ];
  int currentIndex = 1;
  Widget currentWidget;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
        myAppState = Provider.of<MyAppState>(context, listen: false);
myAppState.goNextTab = () {
setState(() {
  _tabController.index = 2 ;
  currentIndex = 2 ;
});
};
    
    _tabController = new TabController(vsync: this, length: choices.length);
    _tabController.index = 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    if (myAppState.user == null) return Page_Login();
    // else if (myAppState.client == null)
    // return Page_Clients();
    if (currentIndex == 0)
      currentWidget = Center(
          child: Image.asset(
        //TODO update this
        'assets/logo.png',
        fit: BoxFit.fill,
        width: windowsSize.height,
        height: windowsSize.height,
      ));
    if (currentIndex == 1) currentWidget = Page_Clients();
    if (currentIndex == 2) currentWidget = Page_AllProdutcs();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              myAppState.signOut();
            }),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.restore_from_trash,
                  color: myAppState.selectedProducts.length == 0 ? Colors.transparent : Colors.white),
              onPressed: () {
                myAppState.products.forEach((p) => p.selectedProduct = false);
                myAppState.client = null;
                myAppState.notifyListeners();
                setState(() {
                  _tabController.index = 1 ;
                  currentIndex = 1 ;
                });
              }),
          Badge(
            position: BadgePosition.topRight(top: 0, right: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            badgeContent: Text(
              myAppState.selectedProducts.length.toString(),
              style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
                icon: Icon(Icons.shopping_cart,
                    color: myAppState.selectedProducts.length == 0 ? Colors.white : Colors.orange),
                onPressed: () {
                  if (myAppState.selectedProducts.length == 0) return;
                  // myAppState.selectedProducts.forEach((p) => p.checked = true);
                  //           myAppState.notifyListeners();
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Products_Quantity()));
                }),
          )
        ],
        title: Center(
          child: Image.asset(
            //TODO update this
            'assets/logo.png',
            fit: BoxFit.fill,
            width: AppBar().preferredSize.height * 2.0,
            height: AppBar().preferredSize.height * 2.0,
          ),
        ),
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: myTheme))),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: choices.map<Widget>((String choice) {
            return Tab(
              text: choice,
              icon: null,
            );
          }).toList(),
          onTap: (index) {
            if ( index == 2 && myAppState.client == null) {
              setState(() {
                _tabController.index = currentIndex;
              });
              myAppState.flushbar(context: context, message: "veuillez sélectionner un client", color: Colors.orange) ;
              return;
            }

            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
      body: currentWidget,
    );
    // else
    //   return Page_AllProdutcs();
  }
}
