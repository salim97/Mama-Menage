import 'package:badges/badges.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gradient_input_border/gradient_input_border.dart';
import 'package:mama_menage_v3/models/model_client.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'page_all_products.dart';

enum sortClient {
  name_ascending,
  name_descending,
  address_ascending,
  address_descending,
}

class Page_Clients extends StatefulWidget {
  Page_Clients({Key key}) : super(key: key);

  @override
  _Page_ClientsState createState() => _Page_ClientsState();
}

class _Page_ClientsState extends State<Page_Clients> {
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

  onRefresh() async {
    if (myAppState.database == null) await myAppState.signInAnonymously();
    await myAppState.getAllClients();
    if (!mounted) {
      // dispose();
      return;
    }
    setState(() {
      _listData.clear();
      myAppState.clients.forEach((p) => _listData.add(p));
    });
  }

  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;
    myAppState = Provider.of<MyAppState>(context);

    final drawerWidth = windowsSize.width * 0.25;
    final landscape = windowsSize.width > windowsSize.height ? true : false;
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
            title: Text(_listData.elementAt(index).name),
            subtitle: Text(_listData.elementAt(index).address),
            leading: CircleAvatar(
              backgroundColor: Color.fromRGBO(104, 193, 139, 1.0),
              child: Text(
                _listData.elementAt(index).name[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              myAppState.products.forEach((p) => p.selectedProduct = false);
              myAppState.client = _listData.elementAt(index);
              myAppState.notifyListeners();
              myAppState.goNextTab();
              // Navigator.of(context)
              //     .push(new MaterialPageRoute(builder: (BuildContext context) => new Page_AllProdutcs()));
            },
          );
        },
      ),
    );
  }

  final c_name = TextEditingController();
  final c_address = TextEditingController();

  List<ModelClient> _listData = List<ModelClient>();
  onApplyFilter() async {
    setState(() {
      _listData.clear();
      myAppState.clients.forEach((p) {
        if (c_name.text.isEmpty && c_address.text.isEmpty) {
          _listData.add(p);
          return;
        }
        if (p.name.toLowerCase().contains(c_name.text.toLowerCase()) &&
            p.address.toLowerCase().contains(c_address.text.toLowerCase())) {
          // print("ADD" + p.name);
          // print(p.address.contains(c_address.text));
          // print(p.name.contains(c_name.text));

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
      if (_sortClient == sortClient.name_ascending) _listData.sort((a, b) => a.name.compareTo(b.name));
      if (_sortClient == sortClient.name_descending) _listData.sort((b, a) => a.name.compareTo(b.name));
      if (_sortClient == sortClient.address_ascending) _listData.sort((a, b) => a.address.compareTo(b.address));
      if (_sortClient == sortClient.address_descending) _listData.sort((b, a) => a.address.compareTo(b.address));
    });
  }

  sortClient _sortClient = sortClient.name_ascending;
  var sortList = [
    {
      "display": "Nom - Ascendant",
      "value": sortClient.name_ascending,
    },
    {
      "display": "Nom - Descendant",
      "value": sortClient.name_descending,
    },
    {
      "display": "Address - Ascendant",
      "value": sortClient.address_ascending,
    },
    {
      "display": "Address - Descendant",
      "value": sortClient.address_descending,
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
              myAppState.client != null ?
              Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text("Client : " + myAppState.client.name,  
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),)
              ) : Container(),
              Divider(),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        border: GradientOutlineInputBorder(
                          focusedGradient: myGradient,
                          unfocusedGradient: myGradient,
                        ),
                        labelText: AppLocalizations.of(context).tr("drawer_filter_name"),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                c_name.text = "";
                              });
                              onApplyFilter();
                            })),
                    keyboardType: TextInputType.text,
                    controller: c_name,
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
                        labelText: AppLocalizations.of(context).tr("drawer_filter_address"),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                c_address.text = "";
                              });
                              onApplyFilter();
                            })),
                    keyboardType: TextInputType.text,
                    controller: c_address,
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
