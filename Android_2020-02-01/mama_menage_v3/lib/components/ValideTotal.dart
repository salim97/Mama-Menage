import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:mama_menage_v3/components/clientAvatar.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/pages/page_validation.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ValideTotal extends StatefulWidget {
  ValideTotal({Key key}) : super(key: key);
  @override
  _ValideTotalState createState() => _ValideTotalState();
}

class _ValideTotalState extends State<ValideTotal> {
  MyAppState myAppState;
  Size windowsSize;
  // ModelProduct get product => myAppState.products.elementAt(widget.index);
  sendToBackEND() async {
          myAppState.currentFacture = myAppState.tmp_currentFacture;
       await  myAppState.saveFatures() ;
              myAppState.notifyListeners();
             await  Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Validation()));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);

    return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    "  Méthode \nde payment",
                    style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Espece"),
                      LiteRollingSwitch(
                        //initial value
                        value: true,
                        textOn: 'On',
                        textOff: 'Off',
                        colorOn: Color.fromRGBO(48, 196, 35, 1.0),
                        colorOff: Colors.grey,
                        iconOn: Icons.done,
                        iconOff: Icons.remove_circle_outline,
                        textSize: 16.0,
                        onChanged: (bool state) {
                          //Use it to manage the different states
                          print('Current State of SWITCH IS: $state');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              myAppState.tmp_currentFacture.espece = state;
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Par chéque"),
                      LiteRollingSwitch(
                        //initial value
                        value: false,
                        textOn: 'On',
                        textOff: 'Off',
                        colorOn: Color.fromRGBO(48, 196, 35, 1.0),
                        colorOff: Colors.grey,
                        iconOn: Icons.done,
                        iconOff: Icons.remove_circle_outline,
                        textSize: 16.0,
                        onChanged: (bool state) {
                          //Use it to manage the different states
                          print('Current State of SWITCH IS: $state');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              myAppState.tmp_currentFacture.par_cheque = state;
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  Image.asset(
                    //TODO update this
                    'assets/logo.png',
                    fit: BoxFit.fill,
                    // width: 200,
                    height: 200,
                  ),
                ],
              ),
            ),
            VerticalDivider(),
            Expanded(
              child: Column(
                children: <Widget>[
                  rowInfo(label: "Réff", data: myAppState.tmp_currentFacture.createdAt),
                  rowInfo(label: "Client", data: myAppState.tmp_currentFacture.client.name),
                  Expanded(child: Divider()),
                  GestureDetector(
                      onTap: () async {
                        var alert = AlertDialog(
                          title: Text("Versement (DA)"),
                          content: TextField(
                            style: TextStyle(decoration: TextDecoration.none),
                            maxLines: 1,
                            maxLengthEnforced: false,
                            autofocus: true,
                            enabled: true,
                            onSubmitted: (String text) {
                              myAppState.tmp_currentFacture.versement = int.parse(text);
                              myAppState.tmp_currentFacture.crecue =
                                  myAppState.tmp_currentFacture.total - myAppState.tmp_currentFacture.versement;
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
                      child: rowInfo(label: "Versement", data: myAppState.tmp_currentFacture.versement.toString())),
                  rowInfo(label: "Crecue", data: myAppState.tmp_currentFacture.crecue.toString()),
                  rowInfo(label: "Total", data: myAppState.tmp_currentFacture.total.toString()),
                  RaisedButton(
                    child: Text(
                      "Valider",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: myAppState.products.length == 0
                        ? null
                        : () async {
                            await sendToBackEND();
                          },
                    color: Color.fromRGBO(48, 196, 35, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget rowInfo({label, data}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data,
                  overflow: TextOverflow.ellipsis,
                ),
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
