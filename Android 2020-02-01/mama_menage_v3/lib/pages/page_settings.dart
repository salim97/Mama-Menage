import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:provider/provider.dart';

class Page_Settings extends StatefulWidget {
  Page_Settings({Key key}) : super(key: key);

  @override
  _Page_SettingsState createState() => _Page_SettingsState();
}

class _Page_SettingsState extends State<Page_Settings> {
  final c_landscape_count = TextEditingController();
  final c_portrait_count = TextEditingController();

  MyAppState myAppState;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myAppState = Provider.of<MyAppState>(context, listen: false);
    c_landscape_count.text = myAppState.landscape_count.toString();
    c_portrait_count.text = myAppState.portrait_count.toString();
  }

  @override
  Widget build(BuildContext context) {
    myAppState = Provider.of<MyAppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('p_settings_appBar_title'),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              myAppState.landscape_count = int.parse(c_landscape_count.text);
              myAppState.portrait_count = int.parse(c_portrait_count.text);
              myAppState.notifyListeners();
              myAppState.saveSettings();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(10.0),
                child: new TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).tr('p_settings_inputNumber_landscape'),
                    prefixIcon: Icon(Icons.screen_lock_landscape),
                  ),
                  keyboardType: TextInputType.number,
                  controller: c_landscape_count,
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: new TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).tr('p_settings_inputNumber_Portrait'),
                    prefixIcon: Icon(Icons.screen_lock_portrait),
                  ),
                  keyboardType: TextInputType.number,
                  controller: c_portrait_count,
                )),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
