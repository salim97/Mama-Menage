import 'package:badges/badges.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/components/card_categories.dart';
import 'package:mama_menage/components/card_items.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/pages/page_login.dart';
import 'package:mama_menage/pages/page_products_details.dart';
import 'package:mama_menage/pages/page_settings.dart';
import 'package:mama_menage/pages/page_validation.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'page_products_quantity.dart';

final Color inactiveColor = Color(0xffc2c2c2);
enum sortProduct {
  name_ascending,
  name_descending,
  createdAt_ascending,
  createdAt_descending,
  price_ascending,
  price_descending
}

class Page_AllProdutcs extends StatefulWidget {
  const Page_AllProdutcs({Key key}) : super(key: key);

  @override
  _Page_AllProdutcsState createState() => _Page_AllProdutcsState();
}

class _Page_AllProdutcsState extends State<Page_AllProdutcs> {
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myAppState = Provider.of<MyAppState>(context, listen: false);
    

    //onRefresh();
    //_refreshController
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
      //readProducts();
    });
  }

  onRefresh() async {
    if (myAppState.database == null) await myAppState.signInAnonymously();
    await myAppState.getAllProducts();
    if(!mounted) {
      // dispose();
      return ;
    }
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) => _products.add(p));
    });
  }

  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);

    final drawerWidth = windowsSize.width * 0.25;
    final double itemHeight = (windowsSize.height - kToolbarHeight - 150) / 2;
    final double itemWidth = (windowsSize.width - drawerWidth) / 2;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    if (landscape)
      return Scaffold(
        appBar: appBar(),
        body: Stack(
          children: <Widget>[
            Positioned(
                left: 0, top: 0, width: windowsSize.width - drawerWidth, height: windowsSize.height, child: body()),
            Positioned(top: 0, right: 0, width: drawerWidth, height: windowsSize.height, child: filterPage())
          ],
        ),
      );
    else
      return Scaffold(appBar: appBar(), endDrawer: Drawer(child: filterPage()), body: body());
  }

  Widget appBar() {
    final drawerWidth = windowsSize.width * 0.25;
    final double itemHeight = (windowsSize.height - kToolbarHeight - 150) / 2;
    final double itemWidth = (windowsSize.width - drawerWidth) / 2;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    return AppBar(
      title: Text(AppLocalizations.of(context).tr('p_allProducts_appBar_title')),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.restore_from_trash,
                color: myAppState.selectedProducts.length == 0 ? Colors.transparent : Colors.white),
            onPressed: () {
              myAppState.products.forEach((p) => p.selectedProduct = false);
              myAppState.notifyListeners();
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
    );
  }

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Widget body() {
    final drawerWidth = windowsSize.width * 0.25;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final double itemHeight = (windowsSize.height - kToolbarHeight - (landscape ? 60 : 150)) / 2;
    final double itemWidth = (windowsSize.width - drawerWidth) / 2;

    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowAlways,
        completeDuration: Duration(milliseconds: 500),
      ),
      header: WaterDropHeader(),
      onRefresh: () async {
        print("-----------------------------");
        print("onRefresh: () async {");
        //monitor fetch data from network
        await onRefresh();

        _refreshController.refreshCompleted();
      },
      // onLoading: () async {
      //   //monitor fetch data from network
      //   print("-----------------------------");
      //   print("onLoading: () async {");

      //   //if (mounted) setState(() {});
      //   //_refreshController.loadFailed();
      //   _refreshController.refreshCompleted();
      // },
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: landscape ? myAppState.landscape_count : myAppState.portrait_count,
                      childAspectRatio: 1.0),
                  padding: const EdgeInsets.all(4.0),
                  itemCount: _products.length,
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return CardItems(index: index);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  final c_nameController = TextEditingController();

  List<ModelProduct> _products = List<ModelProduct>();
  onApplyFilter() async {
    onApplySort();
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) {
        if (c_nameController.text.isEmpty)
          _products.add(p);
        else if (p.name.contains(c_nameController.text)) _products.add(p);
      });
    });
  }

  onApplySort() {
    setState(() {
      if (_sortProduct == sortProduct.name_ascending) myAppState.products.sort((a, b) => a.name.compareTo(b.name));
      if (_sortProduct == sortProduct.name_descending) myAppState.products.sort((b, a) => a.name.compareTo(b.name));
      if (_sortProduct == sortProduct.price_ascending) myAppState.products.sort((a, b) => a.cost.compareTo(b.cost));
      if (_sortProduct == sortProduct.price_descending) myAppState.products.sort((b, a) => a.cost.compareTo(b.cost));
      if (_sortProduct == sortProduct.createdAt_ascending) myAppState.products.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (_sortProduct == sortProduct.createdAt_descending)
        myAppState.products.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    });
  }

  sortProduct _sortProduct = sortProduct.name_ascending;
  var sortList = [
    {
      "display": "Name - ascending",
      "value": sortProduct.name_ascending,
    },
    {
      "display": "Name - descending",
      "value": sortProduct.name_descending,
    },
    {
      "display": "Price - ascending",
      "value": sortProduct.price_ascending,
    },
    {
      "display": "Price - descending",
      "value": sortProduct.price_descending,
    },
    {
      "display": "Created At - ascending",
      "value": sortProduct.createdAt_ascending,
    },
    {
      "display": "Created At - descending",
      "value": sortProduct.createdAt_descending,
    },
  ];

  onSort() async {
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    if (!landscape) Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: 16,
            child: Container(
                height: 400.0,
                width: 360.0,
                child: ListView.builder(
                    itemCount: sortList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FlatButton(
                        child: Text(sortList.elementAt(index)["display"]),
                        onPressed: () {
                          setState(() {
                            _sortProduct = sortList.elementAt(index)["value"];
                          });
                          onApplySort();
                          // onApplyFilter();
                          Navigator.of(context).pop();
                        },
                      );
                    })),
          );
        });
  }

  Widget filterPage() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        myAppState.user?.name ?? "no data",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              RaisedButton.icon(
                label: Text(AppLocalizations.of(context).tr("drawer_btn_sort"),),
                icon: Icon(Icons.sort),
                onPressed: onSort,
              ),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).tr("drawer_filter_name"),
                        //prefixIcon: Icon(Icons.email),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                c_nameController.text = "";
                              });
                              onApplyFilter();
                            })),
                    keyboardType: TextInputType.emailAddress,
                    controller: c_nameController,
                    onChanged: (string) {
                      onApplyFilter();
                    },
                  )),
              RaisedButton.icon(
                icon: Icon(Icons.settings),
                label: Text(AppLocalizations.of(context).tr("drawer_btn_settings"),),
                onPressed: () {
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Settings()));
                },
              )
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: FlatButton.icon(
              color: Colors.green,
              label: Text(
                AppLocalizations.of(context).tr("drawer_btn_signout"),
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                myAppState.signOut();
              },
            ),
          ),
        )
      ],
    );
  }
}
