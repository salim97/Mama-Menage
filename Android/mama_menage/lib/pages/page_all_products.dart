import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/components/card_categories.dart';
import 'package:mama_menage/components/card_items.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/pages/page_login.dart';
import 'package:mama_menage/pages/page_validation.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'page_products_quantity.dart';

final Color inactiveColor = Color(0xffc2c2c2);
enum filterProduct {
  names,
  prices,
  quantite,
}

class Page_AllProdutcs extends StatefulWidget {
  const Page_AllProdutcs({Key key}) : super(key: key);

  @override
  _Page_AllProdutcsState createState() => _Page_AllProdutcsState();
}

class _Page_AllProdutcsState extends State<Page_AllProdutcs> {
  filterProduct category = filterProduct.names;

  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myAppState = Provider.of<MyAppState>(context, listen: false);
    readProducts();
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
      //readProducts();
    });
  }

  readProducts() async {
    print("readProducts() async {");
    if (myAppState.databaseReferenceProducts == null) await myAppState.signInAnonymously();
    DataSnapshot snapshot = await myAppState.databaseReferenceProducts.once();
    print('Data : ${snapshot.value}');
    await myAppState.mapToProducts(snapshot.value);
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) => _products.add(p));
    });
  }

  final c_nameController = TextEditingController();

  List<ModelProduct> _products = List<ModelProduct>();
  onApplyFilter() async {
    setState(() {
      _products.clear();
      myAppState.products.forEach((p) {
        if (c_nameController.text.isEmpty)
          _products.add(p);
        else if (p.name.contains(c_nameController.text)) _products.add(p);
      });
    });
  }

  onSignOut() async {
            // Navigator.of(context)
            //           .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => new Page_Login()));
    
        final landscape = windowsSize.width > windowsSize.height ? true : false;
        if(!landscape) Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
              left: 0,
              top: 0,
              width: windowsSize.width - drawerWidth,
              height: windowsSize.height,
              child:body()
            ),
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
      title: Text('LOGO'),
      leading: Container(),
      actions: <Widget>[
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
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Products_Quantity()));
              }),
        )
      ],
    );
  }

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
        //monitor fetch data from network
        await readProducts();
        if (mounted) setState(() {});
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        //monitor fetch data from network
        print("-----------------------------");
        print("onLoading: () async {");

        //if (mounted) setState(() {});
        //_refreshController.loadFailed();
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: landscape ? 2 : 3, childAspectRatio: (itemWidth / itemHeight)),
                  itemCount: _products.length,
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return CardItems(
                      image: _products.elementAt(index).imagePath,
                      name: _products.elementAt(index).name,
                      cost: _products.elementAt(index).cost,
                      onPress: () {
                        for(int i = 0 ; i < myAppState.selectedProducts.length ; i++)
                        {
                          if(_products.elementAt(index).name == myAppState.selectedProducts.elementAt(i).name)
                            return ;
                        }
                        myAppState.selectedProducts.add(_products.elementAt(index));
                     
                        myAppState.notifyListeners();
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
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
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CardCategories(
                            onPress: () {
                              setState(() {
                                category = filterProduct.names;
                              });
                            },
                            cardColour: category == filterProduct.names ? inactiveColor : Colors.white,
                            textColor: category == filterProduct.names ? Colors.black : inactiveColor,
                            text: "Names"),
                        SizedBox(
                          width: 10,
                        ),
                        CardCategories(
                            onPress: () {
                              setState(() {
                                category = filterProduct.prices;
                              });
                            },
                            cardColour: category == filterProduct.prices ? inactiveColor : Colors.white,
                            textColor: category == filterProduct.prices ? Colors.black : inactiveColor,
                            text: "Price"),
                        SizedBox(
                          width: 10,
                        ),
                        CardCategories(
                            onPress: () {
                              setState(() {
                                category = filterProduct.quantite;
                              });
                            },
                            cardColour: category == filterProduct.quantite ? inactiveColor : Colors.white,
                            textColor: category == filterProduct.quantite ? Colors.black : inactiveColor,
                            text: "Quantite"),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new TextFormField(
                      style: new TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        labelText: 'Name',
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
                "Sign Out",
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                onSignOut();
              },
            ),
          ),
        )
      ],
    );
  }
}
