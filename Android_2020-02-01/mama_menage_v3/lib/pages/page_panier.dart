import 'package:flutter/material.dart';
import 'package:mama_menage_v3/components/panierItem.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';

class Page_Panier extends StatefulWidget {
  Page_Panier({Key key}) : super(key: key);

  @override
  _Page_PanierState createState() => _Page_PanierState();
}

class _Page_PanierState extends State<Page_Panier> {
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


  
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.5),
          // padding: const EdgeInsets.only(bottom: 90.0, top: 90.0),

          scrollDirection: Axis.horizontal,
          itemCount: myAppState.selectedProducts.length,
          controller: new ScrollController(keepScrollOffset: true),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return PanierItem(
              index: index,
            );
          }),
       ),
    );
  }
}