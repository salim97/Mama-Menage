import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mama_menage_v3/models/model_product.dart';
import 'package:mama_menage_v3/providers/my_app_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PageLoading extends StatefulWidget {
  PageLoading({Key key}) : super(key: key);

  @override
  _PageLoadingState createState() => _PageLoadingState();
}

class _PageLoadingState extends State<PageLoading> {
  Size windowsSize;
  MyAppState myAppState;
  int currentProgress = 0;
  String current_msg = "Connecting ...";
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
      DataSnapshot snapshot = await myAppState.database.reference().child(DATABASE_PATH_prdocuts).once();
      Map<dynamic, dynamic> mapResponse = snapshot.value;
      myAppState.products.clear();
      mapResponse?.forEach((key, value) {
        if (key.toString().isNotEmpty) {
          if (ModelProduct.fromJson(value) != null) myAppState.products.add(ModelProduct.fromJson(value));
        }
      });
      myAppState.notifyListeners();

      Future.delayed(Duration(milliseconds: 100)).then((_) async {
        await myAppState.signInAnonymously();
        setState(() {
          current_msg = "Connected, Downloading ...";
        });
        myAppState.products.forEach((p) async {
          String url = await myAppState.loadImage(p.imagePath.first);
          Directory tempDir = await getExternalStorageDirectory();
          String localStorageFile = tempDir.path + "/" + p.imagePath.first;
          print(localStorageFile);

          final File tempFile = File(localStorageFile);
          if (tempFile.existsSync()) {
            await tempFile.delete();
          }
          await tempFile.create();
          // assert(await tempFile.readAsString() == "");
          final StorageFileDownloadTask task =
              FirebaseStorage.instance.ref().child(p.imagePath.first).writeToFile(tempFile);
          FileDownloadTaskSnapshot fileDownloeded = await task.future;

          // assert(tempFileContents == kTestString);
          // assert(byteCount == kTestString.length);
          setState(() {
            currentProgress++;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    windowsSize = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Loading data from backend"),
      // ),
      body: Column(
        children: <Widget>[
          new CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: (currentProgress / myAppState.products.length).toDouble(),
            // header: Image.asset('assets/logo.png', fit: BoxFit.fitHeight),
            center: Text(((currentProgress / myAppState.products.length).toDouble() * 100).toStringAsFixed(0) + "%"),
            // new Icon(
            //   Icons.cloud_download,
            //   size: 50.0,
            //   color: Colors.blue,
            // ),
            footer: new Text(
              current_msg,
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            ),
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
          ),
          currentProgress == myAppState.products.length
              ? RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Continue..."),
                )
              : Container()
        ],
      ),
    );
  }
}
