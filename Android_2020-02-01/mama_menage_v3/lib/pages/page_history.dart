import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gradient_input_border/gradient_input_border.dart';
import 'package:mama_menage_v3/models/model_facture.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
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
    if (myAppState.database == null) await myAppState.signInAnonymously();
    await myAppState.getAllCommandes();
    if (!mounted) {
      // dispose();
      return;
    }
    setState(() {
      _listData.clear();
      myAppState.factures.forEach((p) {
        if (p.user.name == myAppState.user.name) _listData.add(p);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);

    final drawerWidth = windowsSize.width * 0.25;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
              right: 0, top: 0, width: windowsSize.width - drawerWidth, height: windowsSize.height, child: body()),
          Positioned(top: 0, left: 0, width: drawerWidth, height: windowsSize.height, child: filterPage())
        ],
      ),
    );
  }

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Widget body() {
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
      // onLoading: () async {
      //   //monitor fetch data from network
      //   print("-----------------------------");
      //   print("onLoading: () async {");

      //   //if (mounted) setState(() {});
      //   //_refreshController.loadFailed();
      //   _refreshController.refreshCompleted();
      // },
      child: ListView.builder(
        itemCount: _listData.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_listData.elementAt(index).createdAt +
                " ( " +
                new DateTime.fromMillisecondsSinceEpoch(int.parse(_listData.elementAt(index).createdAt)).toString() +
                " ) "),
            subtitle: Text(_listData.elementAt(index).client.name + " " + _listData.elementAt(index).user.name),
            leading: CircleAvatar(
              // backgroundColor: Colors.brown.shade800,
              child: Text(_listData.elementAt(index).client.name[0].toUpperCase()),
            ),
            onTap: () {
              myAppState.currentFacture = _listData.elementAt(index);
              myAppState.notifyListeners();
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_Validation()));
              // TODO: open validation mode
            },
          );
        },
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
        if (p.client.name.toLowerCase().contains(c_nom_de_client.text.toLowerCase()) &&  temp.toLowerCase().contains(c_datetime.text.toLowerCase())) {
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
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
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
        ),
      ],
    );
  }
}
