import 'package:fleva_icons/fleva_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/pages/page_products_details.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';

class CardItems extends StatefulWidget {
  final int index;

  CardItems({
    Key key,
    @required this.index,
  }) : super(key: key);

  @override
  _CardItemsState createState() => _CardItemsState();
}

class _CardItemsState extends State<CardItems> {
  MyAppState myAppState;
  Size windowsSize;
  ModelProduct get product => myAppState.products.elementAt(widget.index);
  onDetails() {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => new Page_Products_Details(
              index: widget.index,
            )));
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    windowsSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        product.selectedQP = product.qp.first;
        product.selectedProduct = !product.selectedProduct;
        myAppState.notifyListeners();
      },
      onLongPress: onDetails,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3, //                   <--- border width here
              color: product.selectedProduct ? Colors.red : Colors.transparent,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                // bottom: windowsSize.height * 0.15,
                // height: windowsSize.height * 0.75,
                child: Image(
                  image: DEV_MODE
                      ? AssetImage(product.imagePath.first)
                      : AdvancedNetworkImage(product.imagePath.first,
                          // header: header,
                          loadedCallback: () {
                          print(product.imagePath.first);
                          print('It works!');
                        }, loadFailedCallback: () {
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
                          timeoutDuration: const Duration(seconds: 1),
                          retryLimit: 1),
                  fit: BoxFit.fill,
                  // height: windowsSize.height * 0.75,
                  // width: windowsSize.width,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                // height: windowsSize.height * 0.15,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product.name,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product.cost.toString() + " DA",
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  onPressed: onDetails,
                ),
              )
            ],
          ),
        ),
      ),
    );
/*
    return GestureDetector(
      onTap: widget.onPress,
      onLongPress: widget.onLongPress,
      child: Container(
        margin: EdgeInsets.all(10),
        width: 100,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            // image: DecorationImage(image: DEV_MODE ? AssetImage(image) : NetworkImage(image),
            image: DecorationImage(
                image: DEV_MODE
                    ? AssetImage(widget.image)
                    : AdvancedNetworkImage(
                        widget.image,
                        printError: true,

                        loadedCallback: () {
                          print(widget.image);
                          print('It works!');
                        },
                        loadFailedCallback: () {
                          print(widget.image);
                          print('Oh, no!');
                        },
                        loadingProgress: (progress, list) {
                          print('Now Loading: $progress');
                        },
                        loadedFromDiskCacheCallback: () {
                          print('Now loadedFromDiskCacheCallback: ');
                        },
                        // header: header,
                        useDiskCache: true,
                        cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                      ))
            //  : CachedNetworkImageProvider(image),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                IconButton(icon: Icon(FlevaIcons.shopping_cart_outline), onPressed: () {}),
              ],
            ),
            Expanded(child: SizedBox()),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                  ),
                  widget.isPriceVisible
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text(
                            '${widget.cost} DA',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  */
  }
}
