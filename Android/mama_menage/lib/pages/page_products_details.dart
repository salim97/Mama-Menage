import 'package:badges/badges.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/components/myListTile.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'page_products_quantity.dart';

class Page_Products_Details extends StatefulWidget {
  int index;
  Page_Products_Details({Key key, this.index = 1}) : super(key: key);

  @override
  _Page_Products_DetailsState createState() => _Page_Products_DetailsState();
}

class _Page_Products_DetailsState extends State<Page_Products_Details> {
  final TextEditingController _textEditingController = TextEditingController();
  int quantity = 0;
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

  get product => myAppState.products.elementAt(widget.index);
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final longSize = landscape ? windowsSize.width : windowsSize.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(product.name),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Container(
              child: Wrap(
                direction: landscape ? Axis.vertical : Axis.horizontal,
                children: <Widget>[
                   SizedBox(
                    height: longSize/2,
                    width: longSize/2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: new InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          labelText: 'Details du produit',
                          border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                        ),
                        controller: _textEditingController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: longSize / 2,
                      width: longSize / 2,
                      child: Carousel(images: productImages()
                          //  [
                          //   NetworkImage('https://cdn-images-1.medium.com/max/2000/1*GqdzzfB_BHorv7V2NV7Jgg.jpeg'),
                          //   NetworkImage('https://cdn-images-1.medium.com/max/2000/1*wnIEgP1gNMrK5gZU7QS0-A.jpeg'),
                          //   ExactAssetImage("assets/images/LaunchImage.jpg")
                          // ],
                          )),
                 
                ],
              ),
            ),
          ),
        ));
  }

  List<Widget> productImages() {
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final longSize = landscape ? windowsSize.width : windowsSize.height;
    List<Widget> images = new List<Widget>();
    myAppState.selectedProducts.forEach((p) {
      images.add(Builder(
        builder: (BuildContext context) {
          return Image.asset(
            p.imagePath,
            fit: BoxFit.fill,
          );
        },
      ));
    });
    return images;
  }
}
