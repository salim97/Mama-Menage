import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class MyListTile extends StatefulWidget {
  final int index;

  MyListTile({Key key, @required this.index}) : super(key: key);

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  get product => myAppState.selectedProducts.elementAt(widget.index);
  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    final height = windowsSize.width / (landscape ? 4.8 : 3.5);
    final SPACE_ROW_QUANTITY = 10.0;
    final SPACE_COLUMN_TEXT = landscape ? 20.0 : 5.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        child: Row(
          children: <Widget>[
            Checkbox(
              value: product.checked,
              onChanged: (newValue) {
                setState(() {
                  product.checked = newValue;
                });
                myAppState.notifyListeners();
              },
            ),
            DEV_MODE
                ? Image.asset(product.imagePath.first, fit: BoxFit.fill, height: height, width: height)
                // : Image.network(product.imagePath.first, fit: BoxFit.fill, height: height, width: height)
                : Image(
                    image: AdvancedNetworkImage(
                      product.imagePath.first,
                      // header: header,
                      loadedCallback: () {
                        print(product.imagePath.first);
                        print('It works!');
                      },
                      loadFailedCallback: () {
                        print(product.imagePath.first);
                        print('Oh, no!');
                      },
                      // loadingProgress: (progress, list) {
                      //   print('Now Loading: $progress');
                      // },
                      loadedFromDiskCacheCallback: () {
                        print('Now loadedFromDiskCacheCallback: ');
                      },
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    ),
                    fit: BoxFit.fill,
                    height: height,
                    width: height)
            // :CachedNetworkImage(
            //     imageUrl: product.imagePath.first,
            //     fit: BoxFit.fill,
            //     height: height,
            //     width: height,
            //     placeholder: (context, url) => CircularProgressIndicator(),
            //     errorWidget: (context, url, error) => Icon(Icons.error),
            //   )
            ,
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: SPACE_COLUMN_TEXT,
                    ),
                    myAppState.user.isPriceVisible
                        ? Text(
                            product.cost.toStringAsFixed(2) + " DA",
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          )
                        : Container(),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        FloatingActionButton(
                          backgroundColor: Color.fromRGBO(57, 178, 186, 1.0),
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
                          width: SPACE_ROW_QUANTITY,
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
                                  if(number_input > product.quantity)
                                  {
                                    myAppState.flushbar(context: context, message: "max quantity is " +product.quantity.toString() );
                                    return ;
                                  }
                                  product.selectedQuantity = number_input ;
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
                          width: SPACE_ROW_QUANTITY,
                        ),
                        FloatingActionButton(
                          backgroundColor: Color.fromRGBO(57, 178, 186, 1.0),
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
                    )
                  
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
