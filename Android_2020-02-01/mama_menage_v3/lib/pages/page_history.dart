import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gradient_input_border/gradient_input_border.dart';
import 'package:mama_menage_v3/components/historiqueItem.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'page_validation.dart';

enum sortCommande {
  numero_ascending,
  numero_descending,
}

class Page_History extends StatefulWidget {
  Page_History({Key key}) : super(key: key);

  @override
  _Page_HistoryState createState() => _Page_HistoryState();
}

class _Page_HistoryState extends State<Page_History> {
  MyAppState myAppState;
  Size windowsSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myAppState = Provider.of<MyAppState>(context, listen: false);
    // myAppState.login(email: "salim", password: "123456");
    //onRefresh();
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
    });
  }

  List<ModelFacture> _listData = List<ModelFacture>();
  onRefresh() async {
    myAppState.currentFacture = null;
    myAppState.notifyListeners();
    // if (myAppState.database == null) await myAppState.signInAnonymously();
    await myAppState.getAllCommandes();
    if (!mounted) {
      // dispose();
      return;
    }
    setState(() {
      _listData.clear();
      myAppState.factures.forEach((p) {

        if (p.user.name == myAppState.user.name)
        {
        _listData.add(p);
          if(_listData.last.toSYNC)
          {
            print("YEEEEEEEEEEEEEEEEEEEEESSS");
          }
        }
      });
      _listData.sort((b, a) => a.toSYNC.toString().compareTo(b.toSYNC.toString() ));
      
    });
  }

  bool _visibile_btn_filter = true;
  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);

    final drawerWidth = windowsSize.width * 0.25;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(right: 0, top: 0, left: 0, bottom: 0, child: body()),
          Positioned(
            top: 0,
            right: 0,
            child: _visibile_btn_filter ? Container() : filterPage(),
          ),
          Positioned(
            top: windowsSize.height * 0.02,
            right: windowsSize.width * 0.02,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _visibile_btn_filter = !_visibile_btn_filter;
                });
              },
              child: Icon(
                MdiIcons.tune,
                color: _visibile_btn_filter ? Colors.black : Colors.white,
              ),
              backgroundColor: _visibile_btn_filter ? Colors.white : Colors.black,
              mini: true,
            ),
          ),
        ],
      ),
    );
  }

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Widget body() {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width * 2;
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowAlways,
        completeDuration: Duration(milliseconds: 500),
      ),
      header: WaterDropHeader(),
      onRefresh: () async {
        //monitor fetch data from network
        await onRefresh();
        _refreshController.refreshCompleted();
      },
      child: Container(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.5),
            // padding: const EdgeInsets.only(bottom: 90.0, top: 90.0),

            scrollDirection: Axis.horizontal,
            itemCount: _listData.length,
            controller: new ScrollController(keepScrollOffset: true),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {

              return HistoriqueItem(
                facture: _listData.elementAt(index),
                onTap: () {
                  myAppState.currentFacture = _listData.elementAt(index);
                  myAppState.notifyListeners();
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Validation()));
                },
              );
            }),
      ),
    );
  }

  final c_nom_de_client = TextEditingController();
  final c_datetime = TextEditingController();

  onApplyFilter() async {
    String temp;
    setState(() {
      _listData.clear();
      myAppState.factures.forEach((p) {
        temp = new DateTime.fromMillisecondsSinceEpoch(int.parse(p.createdAt)).toString();

        if (c_nom_de_client.text.isEmpty && c_datetime.text.isEmpty) {
          _listData.add(p);
          return;
        }
        if (p.client.name.toLowerCase().contains(c_nom_de_client.text.toLowerCase()) &&
            temp.toLowerCase().contains(c_datetime.text.toLowerCase())) {
          _listData.add(p);
        }

        // if (name.isEmpty)

        // else if (p.name.contains(name))
      });
    });
    onApplySort();
  }

  onApplySort() {
    setState(() {
      if (_sortClient == sortCommande.numero_ascending) _listData.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (_sortClient == sortCommande.numero_descending) _listData.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    });
  }

  sortCommande _sortClient = sortCommande.numero_ascending;
  var sortList = [
    {
      "display": "Date Heure - Ascendant",
      "value": sortCommande.numero_ascending,
    },
    {
      "display": "Date Heure - Descendant",
      "value": sortCommande.numero_descending,
    },
  ];

  onSort() async {
    final landscape = windowsSize.width > windowsSize.height ? true : false;
    if (!landscape) Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: 16,
            child: Container(
                height: 400.0,
                width: 360.0,
                child: ListView.builder(
                    itemCount: sortList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FlatButton(
                        child: Text(sortList.elementAt(index)["display"]),
                        onPressed: () {
                          setState(() {
                            _sortClient = sortList.elementAt(index)["value"];
                          });
                          onApplySort();
                          // onApplyFilter();
                          Navigator.of(context).pop();
                        },
                      );
                    })),
          );
        });
  }

  Widget filterPage() {
    return Container(
      height: windowsSize.height * 0.90,
      width: windowsSize.width * 0.20,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: windowsSize.height * 0.04,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Filtrer par :",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox(
            height: windowsSize.height * 0.04,
          ),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: new TextFormField(
                style: new TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: GradientOutlineInputBorder(
                      focusedGradient: myGradient,
                      unfocusedGradient: myGradient,
                    ),
                    labelText: "Nom de Client",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            c_nom_de_client.text = "";
                          });
                          onApplyFilter();
                        })),
                keyboardType: TextInputType.text,
                controller: c_nom_de_client,
                onChanged: (query) {
                  onApplyFilter();
                },
              )),
          Padding(
              padding: EdgeInsets.all(10.0),
              child: new TextFormField(
                style: new TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: GradientOutlineInputBorder(
                      focusedGradient: myGradient,
                      unfocusedGradient: myGradient,
                    ),
                    labelText: "Date Heure",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            c_datetime.text = "";
                          });
                          onApplyFilter();
                        })),
                keyboardType: TextInputType.datetime,
                controller: c_datetime,
                onChanged: (query) {
                  onApplyFilter();
                },
              )),
              
          Divider(),
          Align(
            alignment: Alignment.center,
            child: Text("Plus de filtres"),
          ),
          RaisedButton.icon(
            label: Text(
              AppLocalizations.of(context).tr("drawer_btn_sort"),
            ),
            icon: Icon(Icons.sort),
            onPressed: onSort,
          ),
        ],
      ),
    );
  }
}
