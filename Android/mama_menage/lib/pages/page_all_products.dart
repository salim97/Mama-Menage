import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/components/card_categories.dart';
import 'package:mama_menage/components/card_items.dart';
import 'package:mama_menage/models/model_clothes.dart';
import 'package:mama_menage/pages/page_validation.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:provider/provider.dart';

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

    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
        myAppState = Provider.of<MyAppState>(context);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);
    
    final double itemHeight = (windowsSize.height - kToolbarHeight - 150) / 2;
    final double itemWidth = windowsSize.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGO'),
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
                icon: Icon(Icons.shopping_cart, color: myAppState.selectedProducts.length == 0 ? Colors.white : Colors.orange),
                onPressed: () {
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Products_Quantity()));
;
                }),
          )
        ],
      ),
      endDrawer: Drawer(child: filterPage()),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: (itemWidth / itemHeight)),
                  itemCount: myAppState.products.length,
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return CardItems(
                      image: myAppState.products.elementAt(index).imagePath,
                      name: myAppState.products.elementAt(index).name,
                      cost: myAppState.products.elementAt(index).cost,
                      onPress: () {
                        myAppState.selectedProducts.add(myAppState.products.elementAt(index));
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
    return ListView(padding: EdgeInsets.zero, children: <Widget>[
      UserAccountsDrawerHeader(
        //accountEmail: new Text(myRestAPI.model_current_user.point.toString() + " Point de parking"),
        accountName: new Text("Salim"),

        decoration: new BoxDecoration(
          color: Theme.of(context).primaryColor,
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
            decoration: const InputDecoration(
              labelText: 'Name',
              //prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            //controller: emailController,
          )),
      Padding(
          padding: EdgeInsets.all(10.0),
          child: new TextFormField(
            decoration: const InputDecoration(
              labelText: 'Refernce',
              //prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            //controller: emailController,
          )),
      RaisedButton(
        child: Text("Apply"),
        onPressed: () {},
      )
    ]);
  }
}
