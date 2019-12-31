import 'package:flutter/material.dart';
import 'package:mama_menage/components/card_categories.dart';
import 'package:mama_menage/components/card_items.dart';
import 'package:mama_menage/models/model_clothes.dart';

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

  List<ModelClothes> item_clothes = [
    ModelClothes(image_path: "assets/images/clothes1.jpg", name: "Jacket", cost: 100),
    ModelClothes(image_path: "assets/images/clothes6.jpg", name: "Jacket", cost: 150),
    ModelClothes(image_path: "assets/images/clothes3.jpg", name: "Shirt", cost: 200),
    ModelClothes(image_path: "assets/images/clothes4.jpg", name: "Jacket", cost: 50),
    ModelClothes(image_path: "assets/images/clothes5.jpg", name: "Shirt", cost: 80),
    ModelClothes(image_path: "assets/images/clothes7.jpg", name: "Shirt", cost: 180),
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 150) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: AppBar(),
      endDrawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
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
        ]),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: (itemWidth / itemHeight)),
                  itemCount: item_clothes.length,
                  controller: new ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return CardItems(
                        image: item_clothes[index].image_path,
                        name: item_clothes[index].name,
                        cost: item_clothes[index].cost);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
