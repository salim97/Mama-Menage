import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage/models/model_client.dart';
import 'package:mama_menage/providers/my_app_state.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
    onRefresh();
    Future.delayed(Duration(milliseconds: 100)).then((_) async {
      setState(() {
        windowsSize = MediaQuery.of(context).size;
      });
      //readProducts();
    });
  }

  onRefresh() async {
    if (myAppState.database == null) await myAppState.signInAnonymously();
    await myAppState.getAllClients();
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
    if (landscape)
      return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: <Widget>[
            Positioned(
                left: 0, top: 0, width: windowsSize.width - drawerWidth, height: windowsSize.height, child: body()),
            Positioned(top: 0, right: 0, width: drawerWidth, height: windowsSize.height, child: filterPage())
          ],
        ),
      );
    else
      return Scaffold(appBar: AppBar(), endDrawer: Drawer(child : filterPage()), body: body());
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
      onLoading: () async {
        //monitor fetch data from network
        print("-----------------------------");
        print("onLoading: () async {");

        //if (mounted) setState(() {});
        //_refreshController.loadFailed();
      },
      child: ListView.builder(
        itemCount: _listData.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_listData.elementAt(index).name),
            subtitle: Text(_listData.elementAt(index).address),
            trailing: Icon(Icons.gps_fixed),
            onTap: () {
              myAppState.client = _listData.elementAt(index);
              myAppState.notifyListeners();
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
        if (p.name.toLowerCase().contains(c_name.text.toLowerCase()) && p.address.toLowerCase().contains(c_address.text.toLowerCase()))
        {
          print("ADD" +p.name);
          print(p.address.contains(c_address.text));
          print(p.name.contains(c_name.text));

           _listData.add(p);
        }

        // if (name.isEmpty)

        // else if (p.name.contains(name))
      });
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
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                width: double.infinity,
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        myAppState.user?.name ?? "no data",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        labelText: 'Name',
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
                        labelText: 'Address',
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
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: FlatButton.icon(
              color: Colors.green,
              label: Text(
                "Sign Out",
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () {
                myAppState.signOut();
              },
            ),
          ),
        )
      ],
    );
  }
}
