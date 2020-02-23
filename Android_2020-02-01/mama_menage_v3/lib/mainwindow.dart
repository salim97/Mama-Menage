import 'dart:async';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/pages/page_products_quantity.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/ValideTotal.dart';
import 'components/askUser.dart';
import 'components/productItem.dart';
import 'pages/page_all_products.dart';
import 'pages/page_clients.dart';
import 'pages/page_history.dart';
import 'pages/page_loading.dart';
import 'pages/page_login.dart';
import 'pages/page_panier.dart';

enum mainWindowMenu {
  historique,
  products,
  acceuille,
  clients,
  panier,
}

class MainWindow extends StatefulWidget {
  MainWindow({Key key}) : super(key: key);

  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  MyAppState myAppState;
  Size windowsSize;
  mainWindowMenu currentSelectedMenuItem = mainWindowMenu.acceuille;
  Widget currentWidget;

  StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    super.initState();
    myAppState = Provider.of<MyAppState>(context, listen: false);
    myAppState.goNextTab = () {
      setState(() {
        currentSelectedMenuItem = mainWindowMenu.products;
      });
    };
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      myAppState.internet = result;
      print("=========================================");
      print(result);
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  onAjouteAuPanier() async {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
          height: windowsSize.height * 0.80,
          width: windowsSize.width * 0.80,
          child: ProductItem(index: myAppState.current_index_carousel_products)),
    );
    showDialog(context: context, builder: (BuildContext context) => errorDialog);

    //myAppState.products.elementAt(myAppState.current_index_carousel_products).selectedProduct = true;
    //myAppState.notifyListeners();
  }

  onValide() async {
    myAppState.genereateCurrentFacture();
    if (myAppState.tmp_currentFacture.client == null) {
      myAppState.flushbar(context: context, message: "Veuillez sélectionner un client", color: Colors.orange);
      setState(() {
        currentSelectedMenuItem = mainWindowMenu.clients;
      });
      return;
    }
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(height: windowsSize.height * 0.80, width: windowsSize.width * 0.80, child: ValideTotal()),
    );
    showDialog(context: context, builder: (BuildContext context) => errorDialog);
  }

  onRetirer() async {
    MyDialogs.askuserYESNO(
      context,
      "WITHDRAW",
      "êtes-vous sûr de vouloir tout retirer",
      onNo: () {
        Navigator.of(context).pop();
      },
      onYes: () {
        myAppState.tmp_currentFacture = null;
        myAppState.products.forEach((p) {
          p.selectedProduct = false;
          p.checked = false;
          p.selectedQuantity = 0;
        });
        myAppState.notifyListeners();
        Navigator.of(context).pop();
      },
    );
  }

  final key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    //  return PageLoading();
    if (myAppState.user == null) return Page_Login();
    // else if (myAppState.client == null)
    // return Page_Clients();

    if (currentSelectedMenuItem == mainWindowMenu.acceuille)
      currentWidget = Row(
        children: <Widget>[
            Column(
        children: <Widget>[
          Image.asset(
            //TODO update this
            'assets/logo.png',
            fit: BoxFit.fill,
            width: windowsSize.width * 0.80,
            height: windowsSize.height * 0.70,
          ),
          RaisedButton(
            child: Text(
              "Log out",
              style: TextStyle(color: Colors.white),
            ),
            color: Color.fromRGBO(48, 196, 35, 1.0),
            onPressed: () async {
              myAppState.signOut();
            },
          )
        ],
      ),
    //   Column(
    //     children: <Widget>[
    //       Text(
    //         "Actualité"
    //       ),
    // //        Text(
    // //         "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ul"
    // //       ,overflow: TextOverflow.ellipsis,
    // // maxLines: 50,
    // //       ),
    //        Text(
    //         "Notification"
    //       ),
    //        Text(
    //         "Lorem ipsum dolor sit amet, consectetuer ad"
    //       ),
    //     ],
    //   ),
        ],
      );
    
    if (currentSelectedMenuItem == mainWindowMenu.historique) currentWidget = Page_History();
    if (currentSelectedMenuItem == mainWindowMenu.products) currentWidget = Page_AllProdutcs();
    if (currentSelectedMenuItem == mainWindowMenu.clients) currentWidget = Page_Clients();
    if (currentSelectedMenuItem == mainWindowMenu.panier) currentWidget = Page_Panier();

    return Scaffold(
      drawer: Container(
        width: 100,
        child: Drawer(
  child: menuBar(),
),
      ),
      key: key,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: windowsSize.height * 0.10,
            left: 0 , //windowsSize.width * 0.11,
            height: currentSelectedMenuItem != mainWindowMenu.historique ?  windowsSize.height * 0.80 :  windowsSize.height * 0.90,
            width: windowsSize.width * 0.99,
            child: currentWidget,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: appBar(),
          ),
          currentSelectedMenuItem != mainWindowMenu.historique ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: footerBar(),
          ) : Container(),
          
          // Positioned(
          //   top: windowsSize.height * 0.10,
          //   right: 0,
          //   child: _visibile_btn_filter ? Container() : filterBar(),
          // ),
        ],
      ),
    );
    // else
    //   return Page_AllProdutcs();
  }

  final c_searchBar = TextEditingController();

  onSearchBarTextChanged(String currentText) {}

  Widget appBar() {
    var containerHeight = windowsSize.height * 0.10;
    var containerWidth = windowsSize.width;

    return Container(
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            //TODO update this
            'assets/logo.png',
            fit: BoxFit.fill,
            width: containerHeight,
            height: containerHeight,
          ),
          // Expanded(
          //   child: ListTile(
          //       leading: new Icon(Icons.search),
          //       title: new TextField(
          //           controller: c_searchBar,
          //           decoration: new InputDecoration(hintText: 'Recherche', border: InputBorder.none),
          //           onChanged: onSearchBarTextChanged),
          //       trailing: new IconButton(
          //         icon: new Icon(Icons.cancel),
          //         onPressed: () {
          //           c_searchBar.clear();
          //           onSearchBarTextChanged('');
          //         },
          //       )),
          // ),
        ],
      ),
    );
  }

  Widget footerBar() {
    var containerHeight = windowsSize.height * 0.10;
    var containerWidth = windowsSize.width;
    Widget localWidget = null;

    if (currentSelectedMenuItem == mainWindowMenu.products)
      localWidget = Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: windowsSize.width / 10,
            child: Align(
              alignment: Alignment.center,
              child: RaisedButton(
                elevation: 0.0,
                child: Text(myAppState.counterSelectedProducts.toString()),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: myAppState.counterSelectedProducts.toString()));
                  myAppState.flushbar(context: context, message: "Copied to Clipboard", color: Colors.green);
                  // key.currentState.showSnackBar(                    new SnackBar(content: new Text("Copied to Clipboard"),));
                },
                color: Color.fromRGBO(244, 244, 244, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: windowsSize.width / 10,
            child: Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  elevation: 0.0,
                  child: Text(
                    "Ajouter au panier",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: myAppState.loading01
                      ? null
                      : () async {
                          await onAjouteAuPanier();
                        },
                  color: Color.fromRGBO(48, 196, 35, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                  ),
                )),
          )
        ],
      );
    // Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[
    //     RaisedButton(
    //       child: Text(myAppState.counterSelectedProducts.toString()),
    //       onPressed: () {},
    //       color: Color.fromRGBO(244, 244, 244, 1.0),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: new BorderRadius.circular(18.0),
    //       ),
    //     ),
    //     RaisedButton(
    //       child: Text(
    //         "Ajouter au panier",
    //         style: TextStyle(color: Colors.white),
    //       ),
    //       onPressed: myAppState.loading01
    //           ? null
    //           : () async {
    //               await onAjouteAuPanier();
    //             },
    //       color: Color.fromRGBO(48, 196, 35, 1.0),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: new BorderRadius.circular(18.0),
    //       ),
    //     )
    //   ],
    // );

    if (currentSelectedMenuItem == mainWindowMenu.panier)
      localWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: windowsSize.width * 0.05,
          ),
          RaisedButton(
            child: Text(
              "Retirer",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: myAppState.selectedProducts.length == 0
                ? null
                : () async {
                    await onRetirer();
                  },
            color: Color.fromRGBO(255, 0, 0, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
            ),
          ),
          Expanded(child: Container()),
          RaisedButton(
            child: Text(myAppState.totalCostCheckedProducts.toString()),
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: myAppState.counterSelectedProducts.toString()));
              myAppState.flushbar(context: context, message: "Copied to Clipboard", color: Colors.green);
              // key.currentState.showSnackBar(                    new SnackBar(content: new Text("Copied to Clipboard"),));
            },
            color: Color.fromRGBO(244, 244, 244, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
            ),
          ),
          RaisedButton(
            child: Text(
              "Valider",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: myAppState.selectedProducts.length == 0
                ? null
                : () async {
                    await onValide();
                  },
            color: Color.fromRGBO(48, 196, 35, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
            ),
          ),
          SizedBox(
            width: windowsSize.width * 0.05,
          ),
        ],
      );
    return Container(
        height: containerHeight,
        width: containerWidth,
        decoration: BoxDecoration(color: Colors.white),
        child: localWidget);
  }

  Widget menuBar() {
    var containerHeight = windowsSize.height * 0.80;
    var containerWidth = windowsSize.width * 0.20;

    return Container(
      // height: containerHeight,
      // width: containerWidth,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          menuButton(
              containerHeight: containerHeight,
              containerWidth: containerWidth,
              icon: MdiIcons.fileDocumentEditOutline,
              label: "Acceuille",
              index: mainWindowMenu.acceuille,
              onPressed: () {
                setState(() {
                  currentSelectedMenuItem = mainWindowMenu.acceuille;
                });
                Navigator.of(context).pop();
              }),
          menuButton(
              containerHeight: containerHeight,
              containerWidth: containerWidth,
              icon: MdiIcons.accountGroup,
              label: "Clients",
              index: mainWindowMenu.clients,
              onPressed: () {
                setState(() {
                  currentSelectedMenuItem = mainWindowMenu.clients;
                });
                Navigator.of(context).pop();
              }),
          menuButton(
              containerHeight: containerHeight,
              containerWidth: containerWidth,
              icon: MdiIcons.shoppingOutline,
              label: "Produit",
              index: mainWindowMenu.products,
              onPressed: () {
                setState(() {
                  currentSelectedMenuItem = mainWindowMenu.products;
                });
                Navigator.of(context).pop();
              }),
          menuButton(
              containerHeight: containerHeight,
              containerWidth: containerWidth,
              icon: MdiIcons.cart,
              label: "Panier",
              index: mainWindowMenu.panier,
              onPressed: () {
                setState(() {
                  currentSelectedMenuItem = mainWindowMenu.panier;
                });
                Navigator.of(context).pop();
              }),
          menuButton(
              containerHeight: containerHeight,
              containerWidth: containerWidth,
              icon: Icons.history,
              label: "Historique",
              index: mainWindowMenu.historique,
              onPressed: () {
                setState(() {
                  currentSelectedMenuItem = mainWindowMenu.historique;
                });
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  Widget filterBar() {
    return Container(
      height: windowsSize.height * 0.80,
      width: windowsSize.width * 0.20,
      decoration: BoxDecoration(color: Colors.white),
      child: null,
    );
  }

  Widget menuButton({containerWidth, containerHeight, label, icon, onPressed, mainWindowMenu index}) {
    return SizedBox(
      width: containerWidth * 1.3,
      height: containerHeight / 5,
      child: RaisedButton(
        elevation: 0.0,
        onPressed: onPressed,
        color: currentSelectedMenuItem == index ? Color.fromRGBO(255, 0, 0, 1.0) : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: currentSelectedMenuItem == index ? Colors.white : Colors.black,
            ),
            Text(
              label,
              style: TextStyle(color: currentSelectedMenuItem == index ? Colors.white : Colors.black),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(18.0),
        ),
      ),
    );
  }
}
