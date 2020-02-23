import 'package:flutter/material.dart';
import 'package:mama_menage_v3/components/clientAvatar.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';

class HistoriqueItem extends StatefulWidget {
  final ModelFacture facture;
  GestureTapCallback onTap;
  HistoriqueItem({Key key, @required this.facture, this.onTap}) : super(key: key);

  @override
  _HistoriqueItemState createState() => _HistoriqueItemState();
}

class _HistoriqueItemState extends State<HistoriqueItem> {
  MyAppState myAppState;
  Size windowsSize;

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    Size windowsSize = MediaQuery.of(context).size;
    var minSize = windowsSize.height > windowsSize.width ? windowsSize.width : windowsSize.height;
    final double itemWidth = windowsSize.width / 2;
    final double itemHeight = itemWidth * 2;
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GestureDetector(
        onTap: () => widget.onTap(),
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
                    flex: 4, // 40% of space
                    child: ClientAvatar(
                      client: widget.facture.client,
                      onTap: () => widget.onTap(),
                    ),
                  ),
                  Expanded(
                    flex: 5, // 60% of space => (6/(6 + 4))
                    child: Column(
                      children: <Widget>[
                        // rowInfo(label: "Nom Compléte", data: widget.facture.user.name),
                        rowInfo(label: "Reffernce de piece", data: widget.facture.createdAt),
                        rowInfo(label: "La date", data: widget.facture.date),
                        rowInfo(label: "L'heure", data: widget.facture.time),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.facture.toSYNC
                ? Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.sync,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromRGBO(48, 196, 35, 1.0),
                        elevation: 0,
                        onPressed: () async {
                          myAppState.currentFacture = widget.facture;
                          bool ok = await myAppState.saveFatures();
                          if (ok) {
                            if (context == null) return;
                            myAppState.flushbar(
                                context: context,
                                message: "synchronisé avec succès",
                                color: Colors.green);
                          } else {
                            myAppState.flushbar(
                                context: context,
                                message: "échec de synchronisation",
                                color: Colors.red);
                          }
                        },
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget rowInfo({label, data}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0, right: 3.0, ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(label),
          ),
          Flexible(
                      child: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(data),
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
          ),
        ],
      ),
    );
  }
}
