import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:mama_menage_v3/components/clientAvatar.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatefulWidget {
  ProductItem({Key key, @required this.index}) : super(key: key);
  final int index;

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  MyAppState myAppState;
  Size windowsSize;
  ModelProduct get product => myAppState.products.elementAt(widget.index);
  addPanier() {
    product.selectedProduct = true;
    myAppState.notifyListeners();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.all(Radius.circular(20.0)),
                border: Border.all(
                  width: 3, //                   <--- border width here
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 0,
            bottom: 0,
            // width:  itemWidth/2,
            // height:  itemWidth/2,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5, // 40% of space
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image(
                      image: DEV_MODE
                          ? AssetImage(product.imagePath.first)
                          : AdvancedNetworkImage(
                              product.imagePath.first,

                              // header: header,
                              loadedCallback: () {
                                print(product.imagePath.first);
                                print('It works!');
                              },
                              loadFailedCallback: () {
                                print(product.imagePath.first);
                                print('Oh, no!');
                                product.imagePath[0] = BLACK_IMAGE;
                                myAppState.notifyListeners();
                              },
                              // loadingProgress: (progress, list) {
                              //   print('Now Loading: $progress');
                              // },
                              loadedFromDiskCacheCallback: () {
                                print('Now loadedFromDiskCacheCallback: ');
                              },
                              useDiskCache: true,
                              cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                              retryLimit: 3,
                            ),
                      fit: BoxFit.fill,
                      // height: windowsSize.height * 0.75,
                      // width: windowsSize.width,
                    ),
                  ),
                ),
                Expanded(
                    flex: 5, // 60% of space => (6/(6 + 4))
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 10,
                          right: 10,
                          child: FloatingActionButton(
                            child: Icon(
                              MdiIcons.cart,
                              color: Colors.white,
                            ),
                            backgroundColor: Color.fromRGBO(48, 196, 35, 1.0),
                            onPressed: addPanier,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          left: 0,
                          top: 70,
                          bottom: 0,
                          child: Column(
                            children: <Widget>[
                              rowInfo(label: "Nom De produit", data: product.name),
                              rowInfo(label: "Marque", data: product.mark),
                              rowInfo(label: "Famille", data: product.category),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Quantité"),
                                  FloatingActionButton(
                                    backgroundColor: Color.fromRGBO(48, 196, 35, 1.0),
                                    heroTag: null,
                                    mini: true,
                                    child: Icon(MdiIcons.minus),
                                    onPressed: () {
                                      if (product.selectedQuantity > 1)
                                        setState(() {
                                          product.selectedQuantity--;
                                        });
                                      myAppState.notifyListeners();
                                    },
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      var alert = AlertDialog(
                                        title: Text("De combien d'objets as-tu besoin?"),
                                        content: TextField(
                                          style: TextStyle(decoration: TextDecoration.none),
                                          maxLines: 1,
                                          maxLengthEnforced: false,
                                          autofocus: true,
                                          enabled: true,
                                          onSubmitted: (String text) {
                                            int number_input = int.parse(text);
                                            // Do something with your number like pass it to the next material page route
                                            if (number_input > product.quantity) {
                                              myAppState.flushbar(
                                                  context: context,
                                                  message: "max quantity is " + product.quantity.toString());
                                              return;
                                            }
                                            product.selectedQuantity = number_input;
                                            myAppState.notifyListeners();
                                            Navigator.of(context).pop();
                                          },
                                          keyboardType: TextInputType.number,
                                          //controller: _controller,
                                        ),
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    
                                    child: Text(
                                      product.selectedQuantity.toString(),
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  FloatingActionButton(
                                    backgroundColor: Color.fromRGBO(48, 196, 35, 1.0),
                                    heroTag: null,
                                    mini: true,
                                    child: Icon(MdiIcons.plus),
                                    onPressed: () {
                                      if (product.selectedQuantity < product.quantity)
                                        setState(() {
                                          product.selectedQuantity++;
                                        });
                                      myAppState.notifyListeners();
                                    },
                                  ),
                                ],
                              ),
                              rowInfo(label: "Prix d'unite", data: product.cost.toString()),
                              rowInfo(label: "Prix total", data: product.total_per_selectedQuantity.toString()),
                            ],
                          ),
                        )
                      ],
                    )
                    // Column(
                    //   children: <Widget>[
                    //     rowInfo(label: "Nom Compléte", data:"############"),
                    //     rowInfo(label: "Reffernce de piece", data:product.name),
                    //     rowInfo(label: "La date", data:product.name),
                    //     rowInfo(label: "L'heure", data:product.name),
                    //   ],
                    // ),
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget rowInfo({label, data}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, overflow: TextOverflow.ellipsis,),
          Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(data, overflow: TextOverflow.ellipsis,),
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(
                width: 3, //                   <--- border width here
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
