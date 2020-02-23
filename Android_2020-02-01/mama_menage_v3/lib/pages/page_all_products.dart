import 'package:badges/badges.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gradient_input_border/gradient_input_border.dart';
import 'package:mama_menage_v3/components/card_categories.dart';
import 'package:mama_menage_v3/components/card_items.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/pages/page_login.dart';
import 'package:mama_menage_v3/pages/page_products_details.dart';
import 'package:mama_menage_v3/pages/page_settings.dart';
import 'package:mama_menage_v3/pages/page_validation.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
    myAppState.loading01 = true;
    myAppState.notifyListeners();
    // if (myAppState.database == null) await myAppState.signInAnonymously();

    // await myAppState.getAllProductsFromCache();
    await myAppState.getAllProducts();
    if (!mounted) {
      // dispose();
      return;
    }
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) => _products.add(p));
    });
    onApplySort();
    onImageChange(0, 0);
    myAppState.loading01 = false;
    myAppState.notifyListeners();
  }

  bool _visibile_btn_filter = true;
  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);

    final drawerWidth = windowsSize.width * 0.25;
    final double itemHeight = (windowsSize.height - kToolbarHeight - 150) / 2;
    final double itemWidth = (windowsSize.width - drawerWidth) / 2;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(right: 0, top: 0, left: 0, bottom: 0, child: body()),
          Positioned(
            top: 0,
            right: 0,
            child: _visibile_btn_filter ? Container() : filterPage(),
          ),
          Positioned(
            top: windowsSize.height * 0.02,
            right: windowsSize.width * 0.02,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _visibile_btn_filter = !_visibile_btn_filter;
                });
              },
              child: Icon(
                MdiIcons.tune,
                color: _visibile_btn_filter ? Colors.black : Colors.white,
              ),
              backgroundColor: _visibile_btn_filter ? Colors.white : Colors.black,
              mini: true,
            ),
          ),
        ],
      ),
    );
  }

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  onImageChange(previousIndex, currentIndex) {
    for (int i = 0; i < myAppState.products.length; i++) {
      if (myAppState.products.elementAt(i) == _products.elementAt(currentIndex)) {
        myAppState.current_index_carousel_products = i;
        myAppState.notifyListeners();
      }
    }
    print("================================================");

    // print(_products.elementAt(currentIndex).name +
    //     " = " +
    //     myAppState.products.elementAt(myAppState.current_index_carousel_products).name);
    // print(_products.elementAt(currentIndex).cost.toString() +
    //     " = " +
    //     myAppState.products.elementAt(myAppState.current_index_carousel_products).cost.toString());
    // print(_products.elementAt(currentIndex).code +
    //     " = " +
    //     myAppState.products.elementAt(myAppState.current_index_carousel_products).code);
    // print(_products.elementAt(currentIndex).category +
    //     " = " +
    //     myAppState.products.elementAt(myAppState.current_index_carousel_products).category);
  }

  Widget body() {
    final drawerWidth = windowsSize.width * 0.25;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final double itemHeight = (windowsSize.height - kToolbarHeight - 60);
    final double itemWidth = (windowsSize.width - drawerWidth) / 3;
    Widget currentWidget;

    // if (_products.length != 0) currentWidget = Container();
    // if (myAppState.current_total_getAllProducts != myAppState.total_getAllProducts)
    //   currentWidget = Center(
    //     child: new CircularPercentIndicator(
    //       radius: 100.0,
    //       lineWidth: 10.0,
    //       percent: (myAppState.current_total_getAllProducts / myAppState.total_getAllProducts).toDouble(),
    //       // header: Image.asset('assets/logo.png', fit: BoxFit.fitHeight),
    //       center: Text(((myAppState.current_total_getAllProducts / myAppState.total_getAllProducts).toDouble() * 100)
    //               .toStringAsFixed(0) +
    //           "%"),
    //       // new Icon(
    //       //   Icons.cloud_download,
    //       //   size: 50.0,
    //       //   color: Colors.blue,
    //       // ),
    //       footer: new Text(
    //         "Downloading ...",
    //         style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
    //       ),
    //       backgroundColor: Colors.grey,
    //       progressColor: Colors.blue,
    //     ),
    //   );
    // else
    currentWidget = Carousel(images: products(), autoplay: false, onImageChange: onImageChange);

    return SmartRefresher(
        controller: _refreshController,
        enablePullUp: false,
        enablePullDown: true,
        footer: ClassicFooter(
          loadStyle: LoadStyle.HideAlways,
          completeDuration: Duration(milliseconds: 1),
        ),
        header: WaterDropHeader(),
        onRefresh: () async {
          print("-----------------------------");
          // print("onRefresh: () async {");
          //monitor fetch data from network
          final stopwatch = Stopwatch()..start();
          await onRefresh();
          print('onRefresh() executed in ${stopwatch.elapsed}');

          _refreshController.refreshCompleted();
        },
        child: SizedBox(
            height: itemHeight,
            width: itemWidth,
            child: _products.length == 0
                ? Container()
                : Carousel(images: products(), autoplay: false, onImageChange: onImageChange)));
  }

  List<Widget> products() {
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final longSize = landscape ? windowsSize.width : windowsSize.height;
    List<Widget> images = new List<Widget>();
    for (int index = 0; index < _products.length; index++) {
      bool founded = false;
      for (int i = 0; i < myAppState.products.length; i++) {
        if (myAppState.products.elementAt(i) == _products.elementAt(index)) {
          images.add(CardItems(
            index: i,
          ));
          founded = true;
        }
      }
      //if (founded) continue;
      //images.add(CardItems(index: index));
    }
    return images;
  }

  final c_nameController = TextEditingController();
  final c_categoryController = TextEditingController();

  List<ModelProduct> _products = List<ModelProduct>();
  onApplyFilter() async {
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) {
        // if (c_nameController.text.isEmpty)
        //   _products.add(p);
        // else if (p.name.contains(c_nameController.text)) _products.add(p);

        if (c_nameController.text.isEmpty && c_categoryController.text.isEmpty) {
          _products.add(p);
          return;
        }

        if (p.name.toLowerCase().contains(c_nameController.text.toLowerCase()) &&
            p.category.toLowerCase().contains(c_categoryController.text.toLowerCase())) {
          _products.add(p);
        }
      });
    });
    onApplySort();
    //readProducts();
  }

  onApplySort() {
    setState(() {
      if (_sortProduct == sortProduct.name_ascending) _products.sort((a, b) => a.name.compareTo(b.name));
      if (_sortProduct == sortProduct.name_descending) _products.sort((b, a) => a.name.compareTo(b.name));
      if (_sortProduct == sortProduct.price_ascending) _products.sort((a, b) => a.cost.compareTo(b.cost));
      if (_sortProduct == sortProduct.price_descending) _products.sort((b, a) => a.cost.compareTo(b.cost));
      if (_sortProduct == sortProduct.createdAt_ascending) _products.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (_sortProduct == sortProduct.createdAt_descending)
        _products.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    });
  }

  sortProduct _sortProduct = sortProduct.name_ascending;
  var sortList = [
    {
      "display": "Nom - Ascendant",
      "value": sortProduct.name_ascending,
    },
    {
      "display": "Nom - Descendant",
      "value": sortProduct.name_descending,
    },
    {
      "display": "Prix - Ascendant",
      "value": sortProduct.price_ascending,
    },
    {
      "display": "Prix - Descendant",
      "value": sortProduct.price_descending,
    },
    {
      "display": "Créé à - Ascendant",
      "value": sortProduct.createdAt_ascending,
    },
    {
      "display": "Créé à - Descendant",
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
    // return Container(
    //   height: windowsSize.height * 0.80,
    //   width: windowsSize.width * 0.20,
    //   decoration: BoxDecoration(color: Colors.white),
    //   child: null,
    // );
    return Container(
      height: windowsSize.height * 0.80,
      width: windowsSize.width * 0.20,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: windowsSize.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filtrer par :",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox(
            height: windowsSize.height * 0.04,
          ),
          myAppState.client != null
              ? Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Client : " + myAppState.client.name,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ))
              : Container(),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: new TextFormField(
                style: new TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: GradientOutlineInputBorder(
                      focusedGradient: myGradient,
                      unfocusedGradient: myGradient,
                    ),
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
                keyboardType: TextInputType.text,
                controller: c_nameController,
                onChanged: (string) {
                  onApplyFilter();
                },
              )),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: new TextFormField(
                style: new TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: GradientOutlineInputBorder(
                      focusedGradient: myGradient,
                      unfocusedGradient: myGradient,
                    ),
                    labelText: "Catégorie",
                    //prefixIcon: Icon(Icons.email),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            c_categoryController.text = "";
                          });
                          onApplyFilter();
                        })),
                keyboardType: TextInputType.emailAddress,
                controller: c_categoryController,
                onChanged: (string) {
                  onApplyFilter();
                },
              )),
          Divider(),
          Align(
            alignment: Alignment.center,
            child: Text("Plus de filtres"),
          ),
          RaisedButton.icon(
            label: Text(
              AppLocalizations.of(context).tr("drawer_btn_sort"),
            ),
            icon: Icon(Icons.sort),
            onPressed: onSort,
          ),
          RaisedButton.icon(
            icon: Icon(Icons.settings),
            label: Text(
              AppLocalizations.of(context).tr("drawer_btn_settings"),
            ),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Settings()));
            },
          )
        ],
      ),
    );
  }
}
