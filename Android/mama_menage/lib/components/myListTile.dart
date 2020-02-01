import 'package:flutter/material.dart';
import 'package:mama_menage/models/model_product.dart';
import 'package:mama_menage/providers/my_app_state.dart';
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
                    image: NetworkImage(
                      product.imagePath.first,
                      // header: header,
                        //  loadedCallback: () {
                        //   print( product.imagePath.first);
                        //   print('It works!');
                        // },
                        // loadFailedCallback: () {
                        //   print( product.imagePath.first);
                        //   print('Oh, no!');
                        // },
                        // loadingProgress: (progress, list) {
                        //   print('Now Loading: $progress');
                        // },
                        // loadedFromDiskCacheCallback: () {
                        //   print('Now loadedFromDiskCacheCallback: ');
                        // },
                      // useDiskCache: true,
                      // cacheRule: CacheRule(maxAge: const Duration(days: 7)),
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
                        heroTag: product.name + "++",
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
                      Text(
                        product.selectedQuantity.toString(),
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: SPACE_ROW_QUANTITY,
                      ),
                      FloatingActionButton(
                        heroTag: product.name + "--",
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
            )
          ],
        ),
      ),
    );
  }
}
