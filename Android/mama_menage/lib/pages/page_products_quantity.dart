import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/components/myListTile.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'page_validation.dart';

class Page_Products_Quantity extends StatefulWidget {
  Page_Products_Quantity({Key key}) : super(key: key);

  @override
  _Page_Products_QuantityState createState() => _Page_Products_QuantityState();
}

class _Page_Products_QuantityState extends State<Page_Products_Quantity> {
  
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
myAppState = Provider.of<MyAppState>(context, listen: false);
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
    });
  }

  valider() async {
     Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Validation()));
  }

  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Cart (" + myAppState.selectedProducts.length.toString() + ")"),
          actions: <Widget>[
            Badge(
              position: BadgePosition.topRight(top: 0, right: 3),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                myAppState.counterSelectedProducts.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: IconButton(
                  icon: Icon(Icons.restore_from_trash,
                      color: myAppState.counterSelectedProducts == 0 ? Colors.white : Colors.orange),
                  onPressed: () {
                    myAppState.selectedProducts.removeWhere((p) => p.checked);
                    myAppState.notifyListeners();
                  }),
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
           
              height: windowsSize.height * 0.7,
              width: windowsSize.width,
              child: ListView.builder(
                itemCount: myAppState.selectedProducts.length,
                itemBuilder: (BuildContext context, int index) {
                  return MyListTile(
                    index: index,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              height: windowsSize.height * 0.1,
              child: Container(
                width: windowsSize.width,
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: myAppState.selectedProducts.length == myAppState.counterSelectedProducts,
                        onChanged: (newValue) {
                          myAppState.selectedProducts.forEach((p) => p.checked = newValue);
                          myAppState.notifyListeners();
                        },
                      ),
                      Text("All", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Container(),
                      ),
                      Text(myAppState.totalCostSelectedProducts.toString() + " DA",
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 10.0,
                      ),
                      FlatButton(
                        color: Colors.red,
                        child: Text(
                          "Valider (" + myAppState.counterSelectedProducts.toString() + ")",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          valider();
                        },
                      ),
                       SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
